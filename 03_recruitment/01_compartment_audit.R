# Before designing H1's discovery screen, verify what cell compartments GSE120575
# actually contains. It was CD45+ FACS-sorted (per GEO protocol description) -- but
# that's a claim about the *sorting gate*, not evidence about what's in the resulting
# matrix. Sorts are never perfectly pure, and "tumour-derived" in the central question
# needs to mean something specific: does this dataset contain malignant cells at all,
# or is the recruitment signal necessarily immune-compartment-only?
library(data.table)
meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")

compartment_markers <- list(
  T_cell     = c("CD3D", "CD3E", "CD3G", "CD2"),
  B_cell     = c("CD19", "MS4A1", "CD79A", "CD79B"),
  Myeloid    = c("CD14", "LYZ", "CD68", "AIF1", "ITGAM"),
  NK         = c("KLRD1", "NKG7", "GNLY", "NCAM1"),
  Mast       = c("TPSAB1", "TPSB2", "KIT"),
  Malignant  = c("MLANA", "PMEL", "MITF", "TYR", "DCT", "S100B")
)

cells <- setdiff(colnames(tpm), "gene")

cat("--- marker presence and positivity across all", length(cells), "cells ---\n\n")
for (comp in names(compartment_markers)) {
  markers <- compartment_markers[[comp]]
  present <- intersect(markers, tpm$gene)
  cat(comp, "-- markers present:", paste(present, collapse = ", "),
      if (length(present) < length(markers)) paste0(" | MISSING: ", paste(setdiff(markers, present), collapse=", ")) else "",
      "\n")
  for (g in present) {
    vals <- as.numeric(tpm[gene == g, ..cells][1, ])
    cat(sprintf("   %-8s max TPM=%.1f  mean TPM=%.3f  %%cells TPM>1: %.1f%%\n",
                g, max(vals), mean(vals), 100 * mean(vals > 1)))
  }
  cat("\n")
}
# Coarse per-cell compartment call: assign each cell to whichever compartment's
# markers show the highest combined expression, using module mean (not any single
# gene) so one noisy marker doesn't drive the call.
module_score <- function(markers) {
  present <- intersect(markers, tpm$gene)
  if (length(present) == 0) return(rep(0, length(cells)))
  sub <- tpm[gene %in% present, ..cells]
  # native data.table column-mean idiom -- avoids an as.matrix()/colMeans() failure
  # on this many columns, whose exact cause wasn't worth chasing given a robust
  # alternative exists.
  unlist(sub[, lapply(.SD, mean)], use.names = FALSE)
}

# Coarse per-cell compartment call: whichever compartment's module score is highest.
# Cells where every module scores below 1 TPM are left unassigned rather than forced
# into a low-confidence call.
scores <- sapply(compartment_markers, module_score)
call <- colnames(scores)[apply(scores, 1, which.max)]
call[apply(scores, 1, max) < 1] <- "Unassigned (all modules low)"
cat("--- coarse compartment composition (module-score max-call) ---\n")
print(table(call))
cat("\nAs % of all cells:\n")
print(round(100 * table(call) / length(cells), 2))

cat("\n--- malignant-marker-called cells: patient distribution ---\n")
malignant_cells <- cells[call == "Malignant"]
cat("n =", length(malignant_cells), "\n")
if (length(malignant_cells) > 0) {
  pat_col <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
  print(table(meta[[pat_col]][meta$title %in% malignant_cells]))
}
write.csv(data.frame(cell = cells, compartment_call = call),
          "results/gse120575_compartment_calls.csv", row.names = FALSE)
cat("\nWritten to results/gse120575_compartment_calls.csv\n")
