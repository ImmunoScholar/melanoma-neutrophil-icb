# H4 sanity check (CONTINUATION_BRIEF.md §8, Step 3): confirm the actual input formats
# decoupleR and liana need can be built from existing cached objects, before designing the
# real TF-activity / ligand-receptor analyses (Steps 4-5) around an unverified assumption.
#
# A) decoupleR::run_ulm(mat, network, ...) needs a plain genes x samples numeric matrix.
#    H1's and H2's already-saved pseudobulk objects are NOT reusable here -- both are
#    restricted to narrow gene panels (H1: 327 msigdbr cytokine/chemokine/growth-factor
#    genes; H2: H1's 35 tested hits only), and CollecTRI's regulons need broad target-gene
#    coverage to score meaningfully (6,383 of 6,619 unique CollecTRI targets are present in
#    the full matrix, vs. a tiny fraction of that in either narrow panel). A fresh,
#    whole-transcriptome patient-level pseudobulk is built here instead, using the same
#    aggregation logic as H1 (mean TPM per patient, pre-treatment/response-labeled cells
#    only) but over all genes.
#
# B) liana::liana_wrap(sce, ...) requires a SingleCellExperiment or Seurat object -- confirmed
#    via `liana:::liana_prep.SingleCellExperiment`'s source, not assumed from documentation
#    alone; no lighter matrix+labels input exists. Two things confirmed from that source that
#    were not obvious from the exported docs: (1) idents_col takes a colData COLUMN NAME
#    (string), not a pre-built factor vector -- simpler than expected. (2) the SCE must carry
#    BOTH `counts` and `logcounts` assays, or liana_prep() stops immediately. This dataset has
#    no raw counts (TPM-only, GEO-deposited -- the same reason H1/H2 use `limma`, not
#    `edgeR`/`voom`, see CHANGELOG.md), so `counts` is populated with raw TPM as the closest
#    available substitute. This is a real, documented limitation -- flagged here for review
#    before Step 5's real analysis, not silently worked around.

suppressPackageStartupMessages({
  library(data.table)
  library(decoupleR)
  library(liana)
  library(SingleCellExperiment)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
net  <- readRDS("data/processed/collectri_human_verified.rds")
comp <- read.csv("results/gse120575_compartment_calls.csv")

# One row of tpm.rds (of 55,738) has a literal NA gene symbol -- confirmed isolated (0
# duplicated gene symbols elsewhere, exactly 1 NA, 0 empty strings), found only now because
# H1's/H2's narrow gene-panel pseudobulk never happened to include it. Never surfaced in H0-H2
# because every prior script filtered/subset to specific named genes before any bulk numeric
# operation. Dropped here rather than guessed at -- see
# 06_regulation_communication/02b_diagnose_pseudobulk_na.R for the isolation check.
n_before <- nrow(tpm)
tpm <- tpm[!is.na(gene)]
n_dropped <- n_before - nrow(tpm)
cat("Dropped", n_dropped, "row(s) with NA gene symbol from tpm (", nrow(tpm), "remain ).\n")
stopifnot("Unexpectedly many NA-gene rows -- investigate before dropping silently" = n_dropped <= 5)

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
cat("Pre-treatment, response-labeled cells:", nrow(pre),
    "| patients:", length(unique(pre$patient)), "\n")

# --- A) whole-transcriptome patient-level pseudobulk, for decoupleR ---
patients <- sort(unique(pre$patient))
pseudobulk <- sapply(patients, function(p) {
  pcells <- intersect(pre$title[pre$patient == p], colnames(tpm))
  rowMeans(tpm[, ..pcells])
})
rownames(pseudobulk) <- tpm$gene
cat("\nWhole-transcriptome pseudobulk:", nrow(pseudobulk), "genes x", ncol(pseudobulk), "patients\n")

log_pb <- log2(pseudobulk + 1)
cat("CollecTRI target coverage in pseudobulk:",
    length(intersect(unique(net$target), rownames(log_pb))), "of", length(unique(net$target)), "\n")

cat("\n--- decoupleR::run_ulm() smoke test on real pseudobulk ---\n")
act <- run_ulm(mat = log_pb, network = net, minsize = 5)
cat("run_ulm() succeeded:", nrow(act), "rows (TF x patient combinations),",
    length(unique(act$source)), "unique TFs scored\n")
print(head(act))
stopifnot("run_ulm produced zero rows -- something is wrong with the input format" = nrow(act) > 0)

# --- B) SingleCellExperiment for liana, real compartments only (matching H2's exclusion of
#     Mast/Malignant/Unassigned for unusable cell counts) ---
usable_compartments <- c("T_cell", "B_cell", "Myeloid", "NK")
cell_meta <- merge(comp, pre[, c("title", "patient", resp_col)], by.x = "cell", by.y = "title")
cell_meta <- cell_meta[cell_meta$compartment_call %in% usable_compartments, ]
cat("\nCells usable for liana (pre-treatment, response-labeled, real compartment):",
    nrow(cell_meta), "\n")
print(table(cell_meta$compartment_call))

# Building BOTH counts and logcounts dense matrices (liana_prep() requires both -- confirmed
# from its source, see the header comment) for the full 55,737 genes x 5,892 cells, on top of
# the already-resident full tpm object, was OOM-killed on this machine's 10 GB WSL2 budget on
# first attempt (matches the documented resource constraint in REPRODUCIBILITY.md for a
# different full-matrix operation). This is a Step 3 format check, not the real Step 5
# analysis -- a small, seeded per-compartment subsample is sufficient to prove liana_wrap()
# accepts the SCE structure. Step 5's real analysis will need its own memory-appropriate
# strategy for the full dataset (e.g. one compartment/response group at a time, or a sparse
# matrix) -- a genuine open design question, left to Step 5, not resolved here.
set.seed(20260802)
cell_meta <- do.call(rbind, lapply(split(cell_meta, cell_meta$compartment_call), function(d) {
  d[sample(nrow(d), min(50, nrow(d))), ]
}))
cat("Smoke-test subsample (seed 20260802, <=50 cells/compartment):", nrow(cell_meta), "\n")
print(table(cell_meta$compartment_call))

# data.table's `..` prefix only reliably resolves a bare variable name, not a compound `$`
# expression (`..cell_meta$cell` parses ambiguously) -- assign to a plain variable first,
# same pattern already proven correct for `pcells` above.
sel_cells <- cell_meta$cell
sc_tpm <- as.matrix(tpm[, ..sel_cells])
rownames(sc_tpm) <- tpm$gene
cell_meta <- cell_meta[match(colnames(sc_tpm), cell_meta$cell), ]
stopifnot("Cell order mismatch between expression matrix and metadata" =
  identical(colnames(sc_tpm), cell_meta$cell))
# SummarizedExperiment requires colData's row names to exactly match the assay's column
# names -- cell_meta still had default integer row names from merge()/subsampling.
rownames(cell_meta) <- cell_meta$cell

sce <- SingleCellExperiment(
  assays  = list(counts = sc_tpm, logcounts = log2(sc_tpm + 1)),
  colData = cell_meta
)
cat("SCE built:", nrow(sce), "genes x", ncol(sce), "cells |",
    length(unique(colData(sce)$compartment_call)), "compartments\n")

cat("\n--- liana::liana_wrap() smoke test (single fast method, real data subset) ---\n")
res <- liana_wrap(sce, method = "natmi", resource = "Consensus",
                   idents_col = "compartment_call")
cat("liana_wrap() succeeded:", nrow(res), "ligand-receptor results\n")
print(head(res))
stopifnot("liana_wrap produced zero rows -- something is wrong with the SCE format" = nrow(res) > 0)

cat("\nBoth input formats confirmed working end-to-end on real data.\n")
cat("Ready to design the real H4 analyses (Steps 4-5) -- NOT run here, by design.\n")
