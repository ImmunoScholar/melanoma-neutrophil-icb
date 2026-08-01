# H0, step 3 of 3: replication in an independent cohort (GSE72056, Tirosh et al.)
#
# Same protocol class as GSE120575 (CD45+ sorted, Smart-seq2) but an independent cohort,
# lab, year and normalisation pipeline -- so agreement here tests the finding rather than
# the analyst.
#
# Two methodological points that shape this script:
#
# 1. Values are log2(TPM/10 + 1), not TPM. They are back-transformed before thresholding so
#    that "positive" means the same physical quantity as in GSE120575.
#
# 2. Even after back-transforming, ABSOLUTE positivity rates are ~100x higher here than in
#    GSE120575 for the same genes (see REPRODUCIBILITY.md). Absolute thresholds therefore do
#    not transfer between independently-normalised datasets, and a like-for-like chance
#    comparison would be misleading. Replication instead uses an orthogonal check: the
#    original authors annotated cell types with their own independent marker panel, and that
#    panel contains NO neutrophil category -- so a genuine unrecognised neutrophil must
#    appear as non-malignant AND unassigned. Cross-tabulating candidates against those
#    annotations tests the finding without depending on a shared threshold.

Sys.setenv(VROOM_CONNECTION_SIZE = "10000000")  # default 128KB line buffer is too small here

library(data.table)
library(readr)
source("R/neutrophil_markers.R")

raw_path  <- "data/raw/GSE72056/GSE72056_melanoma_single_cell_revised_v2.txt.gz"
proc_dir  <- "data/processed/GSE72056"
meta_rds  <- file.path(proc_dir, "meta.rds")
expr_rds  <- file.path(proc_dir, "tpm_log.rds")

dir.create(proc_dir,  recursive = TRUE, showWarnings = FALSE)
dir.create("results", recursive = TRUE, showWarnings = FALSE)

if (file.exists(meta_rds) && file.exists(expr_rds)) {
  cat("Loading from cache...\n")
  meta  <- readRDS(meta_rds)
  genes <- readRDS(expr_rds)
} else {
  cat("Parsing GSE72056...\n")
  t0  <- Sys.time()
  dat <- read_tsv(raw_path, show_col_types = FALSE, progress = FALSE)
  cat("read_tsv wall time:", round(difftime(Sys.time(), t0, units = "secs"), 1), "sec\n")
  setDT(dat)
  setnames(dat, 1, "row_label")

  # This file embeds three per-cell annotation rows at the top of the matrix rather than
  # shipping separate metadata. Locate them by pattern, not by fixed index.
  tumor_idx     <- which(dat$row_label == "tumor")
  malignant_idx <- which(grepl("^malignant", dat$row_label, ignore.case = TRUE))
  celltype_idx  <- which(grepl("^non-malignant cell type", dat$row_label, ignore.case = TRUE))
  stopifnot(length(tumor_idx) == 1, length(malignant_idx) == 1, length(celltype_idx) == 1)

  cells <- setdiff(colnames(dat), "row_label")
  meta  <- data.frame(
    cell      = cells,
    tumor     = as.numeric(dat[tumor_idx,     ..cells][1, ]),
    malignant = as.numeric(dat[malignant_idx, ..cells][1, ]),  # 1=no, 2=yes, 0=unresolved
    celltype  = as.numeric(dat[celltype_idx,  ..cells][1, ])   # 1=T,2=B,3=Mac,4=Endo,5=CAF,6=NK, 0=unassigned
  )

  genes <- dat[-c(tumor_idx, malignant_idx, celltype_idx)]
  setnames(genes, "row_label", "gene")

  saveRDS(meta,  meta_rds)
  saveRDS(genes, expr_rds)
}

cat("Expression:", nrow(genes), "genes x", ncol(genes) - 1, "cells\n")
cat("\nMalignant flag (1=no, 2=yes, 0=unresolved):\n"); print(table(meta$malignant))
cat("Cell type (0=unassigned, 1=T, 2=B, 3=Mac, 4=Endo, 5=CAF, 6=NK):\n"); print(table(meta$celltype))

# ---- H0 test ---------------------------------------------------------------------------
from_log <- function(x) 10 * (2^x - 1)   # invert log2(TPM/10 + 1)

pos_all      <- marker_positivity(genes, NEUTROPHIL_MARKERS,          transform = from_log)
pos_specific <- marker_positivity(genes, NEUTROPHIL_MARKERS_SPECIFIC, transform = from_log)

summary_all <- marker_summary(pos_all)
cat("\n--- per-marker positivity ---\n"); print(summary_all)

cat("\n--- co-occurrence, specific granule markers only ---\n")
dist_specific <- cooccurrence_distribution(pos_specific)
print(dist_specific)

candidates <- colnames(pos_specific)[colSums(pos_specific) >= 2]
cm <- meta[meta$cell %in% candidates, ]
cat("\nCandidates (>=2 specific markers):", nrow(cm), "\n")

# ---- orthogonal check: what did the original authors call these cells? -----------------
cat("\n--- candidates cross-tabulated against independent annotation ---\n")
xt <- table(malignant = cm$malignant, celltype = cm$celltype)
print(xt)

# A genuine unrecognised neutrophil must be non-malignant AND unassigned, since the
# authors' panel has no neutrophil category. This is the only bucket consistent with one.
key <- cm[cm$malignant == 1 & cm$celltype == 0, ]
cat("\nNon-malignant AND unassigned (the only neutrophil-consistent bucket):", nrow(key), "\n")
print(key)

# Some cells appear twice under different naming conventions; a shared patient + plate well
# + sequencing index indicates the same physical cell, which would inflate the count.
sig <- toupper(gsub("[^A-Za-z0-9]", "", sub(".*?([A-H][0-9]{1,2}[_-]S[0-9]+).*", "\\1", key$cell)))
n_distinct <- length(unique(sig))
cat("\nApparent duplicates (shared well + sequencing index):", nrow(key) - n_distinct, "\n")
cat("Distinct candidate cells after resolving duplicates:", n_distinct, "\n")
cat("Patients represented:", length(unique(key$tumor)), "\n")

unresolved <- cm[cm$malignant == 0 & cm$celltype == 0, ]
cat("\nAlso unassigned but with unresolved malignancy status:", nrow(unresolved), "\n")

write.csv(summary_all, "results/h0_gse72056_marker_summary.csv", row.names = FALSE)
write.csv(cm,          "results/h0_gse72056_candidates.csv",     row.names = FALSE)
write.csv(as.data.frame(xt), "results/h0_gse72056_crosstab.csv", row.names = FALSE)

saveRDS(
  list(dataset = "GSE72056", n_cells = ncol(pos_specific),
       n_candidates = nrow(cm), n_key_bucket = nrow(key),
       n_distinct_key = n_distinct, n_patients_key = length(unique(key$tumor)),
       n_unresolved_unassigned = nrow(unresolved)),
  "results/h0_gse72056_result.rds"
)
cat("\nResults written to results/\n")
