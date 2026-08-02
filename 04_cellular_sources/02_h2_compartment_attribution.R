# H2: is the recruitment programme compartment-restricted or uniformly distributed?
#
# Primary test: per-gene compartment specificity (Kruskal-Wallis across T_cell/B_cell/
# Myeloid/NK patient-level pseudobulk), run on all 35 genes H1 tested -- this asks about
# the programme generally, not just the genes that happened to differ by response.
#
# Secondary, exploratory: within-compartment response comparison (limma, same method as
# H1), restricted to compartments with adequate per-patient power (T_cell, NK, B_cell)
# and to H1's 9 FDR<0.10 hit genes specifically. Myeloid is excluded from this secondary
# test (only 3 usable responder patients, see 01_h2_sanity_check.R) but remains eligible
# for the primary attribution test above, which does not split by response.
library(data.table)
suppressPackageStartupMessages(library(limma))
meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
compartments <- read.csv("results/gse120575_compartment_calls.csv")
h1_ranked <- read.csv("results/h1_discovery_screen_ranked.csv")
pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient <- sub("^(Pre|Post)_", "", meta[[pat_col]])
# select only needed columns before merging -- avoids the blank-trailing-column warning
# seen in the sanity check (harmless there, verified by row-count match, but avoidable)
meta_sub <- meta[, c("title", "patient", "timepoint", resp_col)]
pre <- meta_sub[meta_sub$timepoint == "Pre" & meta_sub[[resp_col]] %in% c("Responder", "Non-responder"), ]
pre <- merge(pre, compartments, by.x = "title", by.y = "cell", all.x = TRUE)
stopifnot(sum(is.na(pre$compartment_call)) == 0)
testable_compartments <- c("T_cell", "B_cell", "Myeloid", "NK")
panel_genes <- h1_ranked$gene
gene_tpm <- tpm[gene %in% panel_genes]
cell_ids <- colnames(gene_tpm)[-1]

# --- patient x compartment pseudobulk; patients with <10 cells in a compartment are
# excluded from that compartment's pseudobulk, matching the sanity check's threshold ---
build_pseudobulk <- function(comp) {
  sub <- pre[pre$compartment_call == comp, ]
  counts <- table(sub$patient)
  usable <- names(counts)[counts >= 10]
  pb <- sapply(usable, function(p) {
    pcells <- intersect(sub$title[sub$patient == p], cell_ids)
    rowMeans(gene_tpm[, ..pcells])
  })
  rownames(pb) <- gene_tpm$gene
  pb
}
pb_list <- lapply(testable_compartments, build_pseudobulk)
names(pb_list) <- testable_compartments
cat("Patients per compartment pseudobulk:\n")
print(sapply(pb_list, ncol))
# --- primary test: compartment specificity, all 35 H1-tested genes ---
cat("\n--- primary test: compartment specificity (Kruskal-Wallis), all", length(panel_genes), "genes ---\n")
kw_results <- data.frame(gene = panel_genes, kw_stat = NA_real_, p_value = NA_real_,
                          dominant_compartment = NA_character_)
for (i in seq_along(panel_genes)) {
  g <- panel_genes[i]
  vals <- unlist(lapply(pb_list, function(pb) log2(pb[g, ] + 1)))
  grp  <- rep(names(pb_list), sapply(pb_list, ncol))
  test <- kruskal.test(vals, grp)
  kw_results$kw_stat[i] <- unname(test$statistic)
  kw_results$p_value[i] <- test$p.value
  means <- tapply(vals, grp, mean)
  kw_results$dominant_compartment[i] <- names(means)[which.max(means)]
}
kw_results$fdr <- p.adjust(kw_results$p_value, method = "BH")
kw_results <- kw_results[order(kw_results$p_value), ]
print(kw_results)
cat("\nGenes with significant compartment restriction (FDR<0.05):",
    sum(kw_results$fdr < 0.05), "of", nrow(kw_results), "\n")
write.csv(kw_results, "results/h2_compartment_specificity.csv", row.names = FALSE)
# --- secondary, exploratory: within-compartment response test ---
secondary_compartments <- c("T_cell", "NK", "B_cell")   # Myeloid excluded: 3 usable responders
secondary_genes <- h1_ranked$gene[h1_ranked$adj.P.Val < 0.10]
cat("\n--- secondary (exploratory): within-compartment response test ---\n")
cat("Compartments:", paste(secondary_compartments, collapse=", "),
    "| genes:", paste(secondary_genes, collapse=", "), "\n")
resp_per_patient <- unique(pre[, c("patient", resp_col)])
secondary_results <- list()
for (comp in secondary_compartments) {
  pb <- pb_list[[comp]]
  pb_sub <- log2(pb[secondary_genes, , drop = FALSE] + 1)
  resp <- factor(resp_per_patient[[resp_col]][match(colnames(pb_sub), resp_per_patient$patient)],
                  levels = c("Responder", "Non-responder"))
  design <- model.matrix(~resp)
  fit <- eBayes(lmFit(pb_sub, design))
  tt <- topTable(fit, coef = "respNon-responder", number = Inf, sort.by = "none")
  tt$gene <- rownames(tt)
  tt$compartment <- comp
  secondary_results[[comp]] <- tt[, c("compartment", "gene", "logFC", "P.Value", "adj.P.Val")]
}
secondary_df <- do.call(rbind, secondary_results)
secondary_df$fdr_global <- p.adjust(secondary_df$P.Value, method = "BH")
secondary_df <- secondary_df[order(secondary_df$P.Value), ]
print(secondary_df)
write.csv(secondary_df, "results/h2_within_compartment_response.csv", row.names = FALSE)
cat("\nResults written to results/h2_compartment_specificity.csv and\n",
    "results/h2_within_compartment_response.csv\n")
