# H4 communication-network component: feasibility/design script (NOT the real analysis).
# Answers four open questions before the real response-split L-R analysis is designed around
# an assumption:
#  1. What is LIANA Consensus's actual gene universe, and does restricting our expression
#     matrix to it (the proposed fix for Step 3's OOM kill) change natmi's output versus the
#     full-gene matrix already validated in Step 3? If not verified equivalent, this "fix"
#     cannot be trusted.
#  2. Real per-compartment x response cell counts (not assumed from the TF-activity secondary
#     test's patient-level power constraint, which does not directly transfer to LIANA's
#     cell-level operation).
#  3. Timed, full-scale (not subsampled) natmi run, gene-restricted, pooled across response --
#     does the memory fix actually work at real scale, and how long does it take (measured,
#     never estimated, per REPRODUCIBILITY.md's own standard).
#  4. A small-scale timed cellphonedb run (permutation-based, the slowest of LIANA's methods)
#     to get a real per-cell cost estimate before deciding whether a full 5-method consensus
#     (LIANA's own recommended standard usage) is tractable, or whether natmi alone is the
#     documented fallback.
#
# Discovery-discipline reminder (binding, restated here per CHANGELOG.md's pre-registration
# style): CXCL8/CXCR1/2 remain banned from inspection or commentary anywhere in this script's
# output or any script downstream of it, before 09_synthesis. If they appear in the unbiased
# resource/output tables below (likely, since Consensus is comprehensive), they get no special
# treatment.

library(data.table)
suppressPackageStartupMessages({
  library(liana)
  library(SingleCellExperiment)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
comp <- read.csv("results/gse120575_compartment_calls.csv")

n_before <- nrow(tpm)
tpm <- tpm[!is.na(gene)]
stopifnot("Unexpectedly many NA-gene rows" = (n_before - nrow(tpm)) <= 5)

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
usable_compartments <- c("T_cell", "B_cell", "Myeloid", "NK")
cell_meta <- merge(comp, pre[, c("title", "patient", resp_col)], by.x = "cell", by.y = "title")
cell_meta <- cell_meta[cell_meta$compartment_call %in% usable_compartments, ]
cat("Total usable cells (pre-treatment, response-labeled, real compartment):",
    nrow(cell_meta), "\n")

# ==== 1. LIANA Consensus gene universe ======================================================
resource <- select_resource("Consensus")[[1]]
cat("\n--- Consensus resource structure ---\n")
cat("Columns:", paste(colnames(resource), collapse = ", "), "\n")
print(head(resource))

# Actual columns confirmed by the printed structure above: source_genesymbol/target_genesymbol
# (same convention as the CollecTRI raw interactions table) -- NOT "ligand"/"receptor" as
# guessed initially; that guess failed loudly (empty selection) rather than silently, caught
# before any downstream computation used it.
gene_cols <- c("source_genesymbol", "target_genesymbol")
stopifnot("Expected gene-symbol columns not found in Consensus resource" =
  all(gene_cols %in% colnames(resource)))
cat("\nGene-containing columns used:", paste(gene_cols, collapse = ", "), "\n")
raw_strings <- unique(unlist(resource[gene_cols]))
lr_genes <- unique(unlist(strsplit(raw_strings, "_", fixed = TRUE)))  # split heteromeric complexes
lr_genes <- lr_genes[lr_genes != "" & !is.na(lr_genes)]
cat("Unique L-R universe genes (after complex-splitting):", length(lr_genes), "\n")

lr_genes_in_matrix <- intersect(lr_genes, tpm$gene)
cat("L-R genes present in our expression matrix:", length(lr_genes_in_matrix),
    "of", length(lr_genes), "\n")
missing <- setdiff(lr_genes, tpm$gene)
cat("Missing from our matrix (up to 20 shown):\n")
print(head(sort(missing), 20))

est_mb_restricted <- length(lr_genes_in_matrix) * nrow(cell_meta) * 8 * 2 / 1e6
est_mb_full <- nrow(tpm) * nrow(cell_meta) * 8 * 2 / 1e6
cat(sprintf("\nEstimated dual-assay matrix size: %.0f MB restricted vs %.0f MB full-gene\n",
            est_mb_restricted, est_mb_full))

# ==== 2. Does gene-restriction change natmi's output? Reuse Step 3's exact subsample recipe =
set.seed(20260802)
sub_meta <- do.call(rbind, lapply(split(cell_meta, cell_meta$compartment_call), function(d) {
  d[sample(nrow(d), min(50, nrow(d))), ]
}))
cat("\n--- Gene-restriction equivalence check, same", nrow(sub_meta), "-cell subsample as Step 3 ---\n")

sel_cells <- sub_meta$cell
sub_meta_ord <- sub_meta
rownames(sub_meta_ord) <- sub_meta_ord$cell

build_sce <- function(genes) {
  m <- as.matrix(tpm[gene %in% genes, ..sel_cells])
  rownames(m) <- tpm$gene[tpm$gene %in% genes]
  m <- m[, sel_cells]  # enforce column order
  SingleCellExperiment(assays = list(counts = m, logcounts = log2(m + 1)),
                        colData = sub_meta_ord[sel_cells, ])
}

sce_full <- build_sce(tpm$gene)
sce_restricted <- build_sce(lr_genes_in_matrix)
cat("Full SCE:", nrow(sce_full), "genes | Restricted SCE:", nrow(sce_restricted), "genes\n")

res_full <- liana_wrap(sce_full, method = "natmi", resource = "Consensus",
                        idents_col = "compartment_call", verbose = FALSE)
res_restricted <- liana_wrap(sce_restricted, method = "natmi", resource = "Consensus",
                              idents_col = "compartment_call", verbose = FALSE)

key_cols <- c("source", "target", "ligand.complex", "receptor.complex")
merged_check <- merge(res_full[, c(key_cols, "edge_specificity")],
                       res_restricted[, c(key_cols, "edge_specificity")],
                       by = key_cols, suffixes = c("_full", "_restricted"))
cat("Rows in full result:", nrow(res_full), "| restricted result:", nrow(res_restricted),
    "| matched on identical edges:", nrow(merged_check), "\n")
cat("Max absolute difference in edge_specificity (full vs restricted):",
    max(abs(merged_check$edge_specificity_full - merged_check$edge_specificity_restricted)), "\n")
stopifnot(
  "Gene restriction changes natmi's output -- the memory-saving approach is NOT safe as designed" =
    max(abs(merged_check$edge_specificity_full - merged_check$edge_specificity_restricted)) < 1e-8
)
cat("CONFIRMED: gene restriction to the L-R universe does not change natmi's output.\n")

# ==== 3. Real per-compartment x response cell counts ========================================
cat("\n--- Cell counts per compartment x response ---\n")
print(table(cell_meta$compartment_call, cell_meta[[resp_col]]))

# ==== 4. Timed, full-scale, gene-restricted natmi run (pooled across response) ==============
cat("\n--- Full-scale timed natmi run (all", nrow(cell_meta), "usable cells, gene-restricted) ---\n")
full_sel_cells <- cell_meta$cell
full_m <- as.matrix(tpm[gene %in% lr_genes_in_matrix, ..full_sel_cells])
rownames(full_m) <- tpm$gene[tpm$gene %in% lr_genes_in_matrix]
cell_meta_ord <- cell_meta
rownames(cell_meta_ord) <- cell_meta_ord$cell
cell_meta_ord <- cell_meta_ord[colnames(full_m), ]

sce_full_scale <- SingleCellExperiment(
  assays  = list(counts = full_m, logcounts = log2(full_m + 1)),
  colData = cell_meta_ord
)
cat("Full-scale SCE:", nrow(sce_full_scale), "genes x", ncol(sce_full_scale), "cells\n")

gc_before <- gc(reset = TRUE)
t_natmi <- system.time({
  res_full_scale <- liana_wrap(sce_full_scale, method = "natmi", resource = "Consensus",
                                idents_col = "compartment_call", verbose = FALSE)
})
gc_after <- gc()
cat("natmi full-scale run: elapsed", round(t_natmi["elapsed"], 1), "sec |",
    nrow(res_full_scale), "edges returned\n")
cat("Peak memory (Mb, cumulative max used):", gc_after[2, 6], "\n")

# ==== 5. Small-scale timed cellphonedb run (permutation-based -- the expensive method) ======
cat("\n--- Small-scale (", nrow(sub_meta), "cells) timed cellphonedb run ---\n")
t_cpdb <- system.time({
  res_cpdb <- liana_wrap(sce_restricted, method = "cellphonedb", resource = "Consensus",
                          idents_col = "compartment_call", verbose = FALSE)
})
cat("cellphonedb,", nrow(sub_meta), "cells: elapsed", round(t_cpdb["elapsed"], 1), "sec |",
    nrow(res_cpdb), "edges returned\n")
per_cell_sec <- t_cpdb["elapsed"] / nrow(sub_meta)
cat("Per-cell cost:", round(per_cell_sec, 3), "sec/cell | extrapolated full-scale (",
    nrow(cell_meta), "cells ) estimate:", round(per_cell_sec * nrow(cell_meta) / 60, 1),
    "min (EXTRAPOLATION ONLY, not a measured full-scale runtime)\n")

cat("\n--- Feasibility script complete ---\n")
