# Minimal, standalone reproduction of the module_score() failure -- bypasses all
# abstraction to see exactly what tpm[gene %in% present, ..cells] actually returns.

library(data.table)
tpm <- readRDS("data/processed/GSE120575/tpm.rds")
cells <- setdiff(colnames(tpm), "gene")
markers <- c("CD3D", "CD3E", "CD3G", "CD2")
present <- intersect(markers, tpm$gene)
cat("present:", paste(present, collapse=", "), "\n\n")

sub <- tpm[gene %in% present, ..cells]
cat("dim(sub):", paste(dim(sub), collapse=" x "), "\n")
cat("class(sub):", paste(class(sub), collapse=", "), "\n\n")

cat("class of first 3 columns of sub:\n")
print(sapply(sub[, 1:3, with = FALSE], class))

cat("\nraw values, first marker row, first 5 cells:\n")
print(sub[1, 1:5, with = FALSE])

cat("\nsum(is.na(sub)):", sum(is.na(sub)), " of", nrow(sub)*ncol(sub), "total cells in sub\n")
cat("\nmanual mean of column 1 (should be mean of the 4 marker values for cell 1):\n")
col1_vals <- sub[[1]]
print(col1_vals)
cat("mean:", mean(col1_vals), "  mean(na.rm=TRUE):", mean(col1_vals, na.rm = TRUE), "\n")

cat("\nlapply(.SD, mean) on just the first 3 columns:\n")
print(sub[, lapply(.SD, mean), .SDcols = 1:3])
