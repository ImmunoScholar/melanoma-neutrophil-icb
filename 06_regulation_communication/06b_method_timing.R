# Follow-up to 06_h4_lr_feasibility.R: time LIANA's two remaining default methods
# (connectome, sca -- neither is permutation-based, unlike cellphonedb) on the SAME 200-cell
# subsample used for cellphonedb's timing, to decide whether a leaner multi-method consensus
# (natmi + connectome + sca, excluding cellphonedb) is tractable at full scale, before
# committing to either a single-method (natmi-only) or full 5-method design.
#
# Rebuilds the identical subsample from 06_h4_lr_feasibility.R (same seed, same recipe) rather
# than assuming session state persists between separate Rscript invocations.

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

resource <- select_resource("Consensus")[[1]]
lr_genes <- unique(unlist(strsplit(
  unique(unlist(resource[c("source_genesymbol", "target_genesymbol")])), "_", fixed = TRUE)))
lr_genes_in_matrix <- intersect(lr_genes, tpm$gene)

set.seed(20260802)
sub_meta <- do.call(rbind, lapply(split(cell_meta, cell_meta$compartment_call), function(d) {
  d[sample(nrow(d), min(50, nrow(d))), ]
}))
sel_cells <- sub_meta$cell
sub_meta_ord <- sub_meta
rownames(sub_meta_ord) <- sub_meta_ord$cell

m <- as.matrix(tpm[gene %in% lr_genes_in_matrix, ..sel_cells])
rownames(m) <- tpm$gene[tpm$gene %in% lr_genes_in_matrix]
m <- m[, sel_cells]
sce_restricted <- SingleCellExperiment(assays = list(counts = m, logcounts = log2(m + 1)),
                                        colData = sub_meta_ord[sel_cells, ])
rm(tpm, meta, comp); gc()

for (method in c("logfc")) {
  gc(reset = TRUE)
  t <- system.time({
    res <- liana_wrap(sce_restricted, method = method, resource = "Consensus",
                       idents_col = "compartment_call", verbose = FALSE)
  })
  g <- gc()
  cat(method, ",", nrow(sub_meta), "cells: elapsed", round(t["elapsed"], 1), "sec |",
      nrow(res), "edges | peak Mb:", g[2, 6], "\n")
}
