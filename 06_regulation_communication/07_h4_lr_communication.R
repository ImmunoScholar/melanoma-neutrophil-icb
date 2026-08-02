# H4 communication-network analysis (CONTINUATION_BRIEF.md Step 5). Tests whether
# intercellular communication structure converges on T-cell-directed edges, and whether that
# differs between ICB responders and non-responders. Design confirmed against real, measured
# feasibility data (06_h4_lr_feasibility.R, 06b_method_timing.R), not assumed:
#  - Gene scope restricted to LIANA Consensus's own L-R universe (1,839 genes present in our
#    matrix) -- PROVEN bit-identical to the full 55,737-gene matrix for natmi's output
#    (max abs difference = 0), so this is a scope reduction to what LIANA actually needs, not
#    a shortcut. Cuts assay memory from ~5.25 GB to ~173 MB.
#  - 4-method consensus (natmi, connectome, logfc, sca) via liana_aggregate() -- LIANA's own
#    standard multi-method usage. cellphonedb excluded: measured ~87 min extrapolated
#    full-scale runtime (178 sec for 200 cells) and real OOM risk (natmi alone touched 9.6 GB
#    of this machine's 10 GB budget even before adding a permutation-heavy method).
#  - Two separate networks (Responder-only cells, Non-responder-only cells), pooled across
#    patients within each group -- a general property of how LIANA operates on pooled cells,
#    not a project-specific shortcut. Every compartment x response cell count clears LIANA's
#    min_cells=5 floor by a wide margin (min: Myeloid-Responder, 87 cells).
#  - IMPORTANT, stated up front: because each response group produces exactly ONE pooled
#    network (not a per-patient replicate), any Responder-vs-Non-responder comparison at the
#    network level is inherently DESCRIPTIVE, not a patient-level inferential test like H1/H2/
#    H4's TF-activity component. The GO-enrichment test below IS a legitimate significance
#    test, but its unit of analysis is EDGES within one network, not patients -- this
#    distinction is carried into the module README rather than glossed over.
#
# Discovery-discipline reminder, restated per this project's standing rule: CXCL8/CXCR1/2
# remain banned from inspection or commentary anywhere in this script's interpretation or any
# downstream documentation, before 09_synthesis. They are not filtered out of the data (that
# would itself be a form of biasing the panel) -- they simply receive no special commentary if
# they appear in the unbiased output.

library(data.table)
suppressPackageStartupMessages({
  library(liana)
  library(SingleCellExperiment)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
comp <- read.csv("results/gse120575_compartment_calls.csv")
tpm <- tpm[!is.na(gene)]

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
usable_compartments <- c("T_cell", "B_cell", "Myeloid", "NK")
cell_meta <- merge(comp, pre[, c("title", "patient", resp_col)], by.x = "cell", by.y = "title")
cell_meta <- cell_meta[cell_meta$compartment_call %in% usable_compartments, ]
cat("Total usable cells:", nrow(cell_meta), "\n")
print(table(cell_meta$compartment_call, cell_meta[[resp_col]]))

resource <- select_resource("Consensus")[[1]]
lr_genes <- unique(unlist(strsplit(
  unique(unlist(resource[c("source_genesymbol", "target_genesymbol")])), "_", fixed = TRUE)))
lr_genes_in_matrix <- intersect(lr_genes, tpm$gene)
cat("L-R genes in matrix:", length(lr_genes_in_matrix), "of", length(lr_genes), "\n")

# Restrict tpm to the L-R universe IMMEDIATELY, before building either response group's SCE --
# keeps peak memory low throughout the whole script rather than only at the SCE-build step
# (the feasibility script's 9.6 GB peak happened partly because the full 55,737-gene tpm
# object stayed resident the entire time).
tpm_lr <- tpm[gene %in% lr_genes_in_matrix]
rm(tpm); gc()
cat("tpm restricted to L-R genes:", nrow(tpm_lr), "rows (from 55,737)\n")

methods <- c("natmi", "connectome", "logfc", "sca")

build_network <- function(response_label) {
  cat("\n=== Building network:", response_label, "===\n")
  sub_meta <- cell_meta[cell_meta[[resp_col]] == response_label, ]
  sel_cells <- sub_meta$cell
  m <- as.matrix(tpm_lr[, ..sel_cells])
  rownames(m) <- tpm_lr$gene
  m <- m[, sel_cells]
  sub_meta_ord <- sub_meta
  rownames(sub_meta_ord) <- sub_meta_ord$cell
  sub_meta_ord <- sub_meta_ord[sel_cells, ]

  sce <- SingleCellExperiment(assays = list(counts = m, logcounts = log2(m + 1)),
                               colData = sub_meta_ord)
  cat("SCE:", nrow(sce), "genes x", ncol(sce), "cells\n")
  rm(m); gc()

  gc(reset = TRUE)
  t <- system.time({
    res_list <- liana_wrap(sce, method = methods, resource = "Consensus",
                            idents_col = "compartment_call", verbose = FALSE)
  })
  g <- gc()
  cat(response_label, "network, 4-method liana_wrap: elapsed", round(t["elapsed"], 1),
      "sec | peak Mb:", g[2, 6], "\n")
  cat("res_list structure:", paste(names(res_list), collapse = ", "), "\n")

  agg <- liana_aggregate(res_list, verbose = FALSE)
  cat("Aggregated network columns:", paste(colnames(agg), collapse = ", "), "\n")
  cat("Aggregated network:", nrow(agg), "edges\n")
  print(head(agg))

  rm(sce, res_list); gc()
  agg
}

agg_responder <- build_network("Responder")
saveRDS(agg_responder, "results/h4_lr_responder_aggregated.rds")
write.csv(agg_responder, "results/h4_lr_responder_aggregated.csv", row.names = FALSE)
cat("\nSaved Responder network.\n")

agg_nonresponder <- build_network("Non-responder")
saveRDS(agg_nonresponder, "results/h4_lr_nonresponder_aggregated.rds")
write.csv(agg_nonresponder, "results/h4_lr_nonresponder_aggregated.csv", row.names = FALSE)
cat("\nSaved Non-responder network.\n")

# --- discover the rank/significance column at runtime rather than assume its exact name ---
rank_col <- grep("aggregate_rank|^rank$", colnames(agg_responder), ignore.case = TRUE, value = TRUE)
cat("\nDiscovered rank column(s):", paste(rank_col, collapse = ", "), "\n")
stopifnot(
  "Expected exactly one aggregate-rank-like column in liana_aggregate() output -- inspect
   the printed column list above and adjust before proceeding to the GO-enrichment step" =
    length(rank_col) == 1
)
cat("Both networks saved successfully. Rank column confirmed:", rank_col,
    "-- proceed to GO-enrichment step (07b) using this confirmed structure.\n")
