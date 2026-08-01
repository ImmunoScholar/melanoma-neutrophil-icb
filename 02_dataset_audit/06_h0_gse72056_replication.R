# H0 replication on GSE72056 (Tirosh et al.): does the null co-occurrence result from
# GSE120575 replicate in this independent CD45+-sorted, Smart-seq2 melanoma cohort?

# vroom's default 128KB line buffer is too small for this file's wide rows; the error
# message names this exact fix. Must be set before any read_tsv/vroom call.
Sys.setenv(VROOM_CONNECTION_SIZE = "10000000")

library(data.table)
library(readr)
path <- "data/raw/GSE72056/GSE72056_melanoma_single_cell_revised_v2.txt.gz"

cat("Loading GSE72056...\n")
t0  <- Sys.time()
dat <- read_tsv(path, show_col_types = FALSE, progress = FALSE)
cat("read_tsv wall time:", round(difftime(Sys.time(), t0, units = "secs"), 1), "sec\n")
setDT(dat)
setnames(dat, 1, "row_label")
cat("Dimensions:", nrow(dat), "rows x", ncol(dat) - 1, "cells\n")

# --- locate the 3 metadata rows by pattern, not exact string match ---
tumor_idx     <- which(dat$row_label == "tumor")
malignant_idx <- which(grepl("^malignant", dat$row_label, ignore.case = TRUE))
celltype_idx  <- which(grepl("^non-malignant cell type", dat$row_label, ignore.case = TRUE))
stopifnot(length(tumor_idx) == 1, length(malignant_idx) == 1, length(celltype_idx) == 1)
cell_ids <- colnames(dat)[-1]
meta <- data.frame(
  cell      = cell_ids,
  tumor     = as.numeric(dat[tumor_idx, -1, with = FALSE]),
  malignant = as.numeric(dat[malignant_idx, -1, with = FALSE]),
  celltype  = as.numeric(dat[celltype_idx, -1, with = FALSE])
)
cat("\nMalignant flag distribution:\n"); print(table(meta$malignant, useNA = "ifany"))
cat("Non-malignant cell type (1=T,2=B,3=Macro,4=Endo,5=CAF,6=NK):\n")
print(table(meta$celltype, useNA = "ifany"))
# --- gene rows only ---
genes <- dat[-c(tumor_idx, malignant_idx, celltype_idx)]
setnames(genes, "row_label", "gene")
cat("\nGene expression matrix:", nrow(genes), "genes x", ncol(genes) - 1, "cells\n")

dir.create("data/processed/GSE72056", recursive = TRUE, showWarnings = FALSE)
saveRDS(meta, "data/processed/GSE72056/meta.rds")
saveRDS(genes, "data/processed/GSE72056/tpm_log.rds")
# --- H0 test: convert log2(TPM/10+1) back to TPM-equivalent so ">1 TPM" means the
# same real quantity as in the GSE120575 analysis ---
markers          <- c("FCGR3B", "CSF3R", "CEACAM8", "MPO", "ELANE", "FUT4", "S100A8", "S100A9")
specific_markers <- c("CEACAM8", "MPO", "ELANE")
to_tpm <- function(log_vals) 10 * (2^log_vals - 1)

marker_rows <- genes[gene %in% markers]
cat("\nMarkers found:", paste(marker_rows$gene, collapse = ", "), "\n")
cat("Markers NOT found:", paste(setdiff(markers, marker_rows$gene), collapse = ", "), "\n")

pos_mat <- t(sapply(marker_rows$gene, function(g) {
  vals <- as.numeric(marker_rows[gene == g, -1, with = FALSE])
  to_tpm(vals) > 1
}))
colnames(pos_mat) <- cell_ids

n_pos <- colSums(pos_mat)
cat("\n--- markers positive per cell (of", nrow(pos_mat), "found) ---\n")
print(table(n_pos))

present_specific <- intersect(specific_markers, marker_rows$gene)
if (length(present_specific) >= 2) {
  n_pos_specific <- colSums(pos_mat[present_specific, , drop = FALSE])
  cat("\n--- SPECIFIC markers positive per cell (", paste(present_specific, collapse = ", "), ") ---\n")
  print(table(n_pos_specific))

candidates <- cell_ids[n_pos_specific >= 2]
  cat("\nCells positive for >=2 specific markers:", length(candidates), "\n")
  if (length(candidates) > 0) print(meta[meta$cell %in% candidates, ])
} else {
  cat("\nFewer than 2 specific markers present -- cannot run co-occurrence test as designed.\n")
}
