# AUDIT: verify the classification breakdown of the 25 GSE72056 candidate cells.
# A previous interpretation claimed zero candidates were non-malignant-and-unclassified;
# this re-derives the counts from the cached data to confirm or refute that.
library(data.table)
meta  <- readRDS("data/processed/GSE72056/meta.rds")
genes <- readRDS("data/processed/GSE72056/tpm_log.rds")

specific <- c("CEACAM8", "MPO", "ELANE")
to_tpm   <- function(x) 10 * (2^x - 1)
rows <- genes[gene %in% specific]
pos  <- t(sapply(rows$gene, function(g) to_tpm(as.numeric(rows[gene == g, -1, with = FALSE])) > 1))
colnames(pos) <- colnames(genes)[-1]

cand <- colnames(pos)[colSums(pos) >= 2]
cm   <- meta[meta$cell %in% cand, ]
cat("Total candidates:", nrow(cm), "\n\n")

cat("--- cross-tab: malignant (1=no,2=yes,0=unresolved) x celltype (0=unassigned) ---\n")
print(table(malignant = cm$malignant, celltype = cm$celltype))

cat("\n--- THE KEY BUCKET: non-malignant (malignant==1) AND unclassified (celltype==0) ---\n")
key <- cm[cm$malignant == 1 & cm$celltype == 0, ]
cat("Count:", nrow(key), "\n")
print(key)

cat("\n--- also unresolved-malignancy AND unclassified (malignant==0 & celltype==0) ---\n")
print(cm[cm$malignant == 0 & cm$celltype == 0, ])
cat("\n--- patient spread of the key bucket ---\n")
print(table(key$tumor))
cat("\n--- duplicate check: do any key-bucket cells share plate well + S-index? ---\n")
sig <- toupper(gsub("[^A-Za-z0-9]", "", sub(".*?([A-H][0-9]{1,2}[_-]S[0-9]+).*", "\\1", key$cell)))
print(data.frame(cell = key$cell, signature = sig))
cat("Duplicated signatures:", sum(duplicated(sig)), "\n")
