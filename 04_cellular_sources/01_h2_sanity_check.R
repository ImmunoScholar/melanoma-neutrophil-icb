# Sanity check before designing H2: verify per-patient, per-compartment cell counts are
# sufficient for pseudobulk, and check which compartment(s) actually express H1's hits --
# deciding which compartments to test on real expression data, not assumption.
library(data.table)

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
compartments <- read.csv("results/gse120575_compartment_calls.csv")
pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
pre <- merge(pre, compartments, by.x = "title", by.y = "cell", all.x = TRUE)
cat("Pre-treatment cells with a compartment call:", sum(!is.na(pre$compartment_call)),
    "of", nrow(pre), "\n")

cat("\n--- compartment composition, restricted to the H1 Pre-treatment sample ---\n")
print(table(pre$compartment_call))

cat("\n--- patient x compartment cell counts ---\n")
ct <- table(pre$patient, pre$compartment_call)
print(ct)

cat("\n--- feasibility: patients with <10 cells, per compartment ---\n")
for (comp in colnames(ct)) {
  cat(sprintf("%-30s %d of %d patients have <10 cells\n", comp, sum(ct[, comp] < 10), nrow(ct)))
}
cat("\n--- response balance among patients with >=10 cells in each compartment ---\n")
resp_per_patient <- unique(pre[, c("patient", resp_col)])
for (comp in c("Myeloid", "T_cell", "B_cell", "NK")) {
  usable <- rownames(ct)[ct[, comp] >= 10]
  resp_sub <- resp_per_patient[resp_per_patient$patient %in% usable, ]
  cat(sprintf("\n%s (n=%d patients with >=10 cells):\n", comp, length(usable)))
  print(table(resp_sub[[resp_col]]))
}

# --- which compartment(s) actually express H1's hits? real data, not assumption ---
sig_genes <- c("LTB", "CCL3", "CCL4", "CXCL13", "TYMP", "CCL4L2", "GPI", "CD320", "FAM3C")
gene_tpm <- tpm[gene %in% sig_genes]
cat("\n--- per-compartment mean TPM, H1's FDR<0.10 hits ---\n")
cell_ids <- colnames(gene_tpm)[-1]
for (g in sig_genes) {
  vals <- as.numeric(gene_tpm[gene == g, -1, with = FALSE])
  names(vals) <- cell_ids
  pre_vals <- vals[pre$title]
  means <- tapply(pre_vals, pre$compartment_call, mean)
  cat(sprintf("%-8s %s\n", g,
      paste(sprintf("%s=%.2f", names(means), round(means, 2)), collapse = "  ")))
}
