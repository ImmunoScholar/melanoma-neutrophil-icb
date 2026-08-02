# H1: unbiased discovery screen of the secreted chemokine/cytokine/growth-factor
# repertoire, responder vs non-responder, GSE120575. Pre-treatment only (avoids the
# treatment-effect confound), whole-sample pseudobulk (compartment attribution is H2's
# question, not H1's). Gene panel is externally sourced (GO molecular function terms
# via msigdbr), not hand-picked -- no pathway is privileged in this screen.
#
# Direction convention: positive logFC = higher in Non-responder (associated with
# resistance), matching how the central question frames the biology.
library(data.table)
suppressPackageStartupMessages({
  library(msigdbr)
  library(limma)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
therapy_col <- grep("therapy", colnames(meta), ignore.case = TRUE, value = TRUE)[1]
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
# --- sample: pre-treatment, response-labeled cells only ---
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
cat("Patients:", length(unique(pre$patient)), "| cells:", nrow(pre), "\n")
# --- confound check: therapy type by response, reported not adjusted for ---
patient_level <- unique(pre[, c("patient", resp_col, therapy_col)])
cat("\n--- therapy x response, at the patient level (reported, not adjusted for) ---\n")
print(table(patient_level[[therapy_col]], patient_level[[resp_col]]))
# --- gene panel: union of GO cytokine/chemokine/growth-factor activity, present in matrix ---
go_mf <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:MF")
panel_sets <- c("GOMF_CYTOKINE_ACTIVITY", "GOMF_CHEMOKINE_ACTIVITY", "GOMF_GROWTH_FACTOR_ACTIVITY")
panel_genes <- unique(go_mf$gene_symbol[go_mf$gs_name %in% panel_sets])
panel_genes <- intersect(panel_genes, tpm$gene)
cat("\nDiscovery panel: union of", paste(panel_sets, collapse=", "), "\n")
cat("Genes in panel, present in matrix:", length(panel_genes), "\n")

# --- patient-level pseudobulk: mean TPM per gene per patient, whole-sample ---
patients <- sort(unique(pre$patient))
panel_tpm <- tpm[gene %in% panel_genes]

pseudobulk <- sapply(patients, function(p) {
  pcells <- pre$title[pre$patient == p]
  pcells <- intersect(pcells, colnames(panel_tpm))
  rowMeans(panel_tpm[, ..pcells])
})
rownames(pseudobulk) <- panel_tpm$gene
cat("\nPseudobulk matrix:", nrow(pseudobulk), "genes x", ncol(pseudobulk), "patients\n")
# --- low-expression filter: TPM > 1 in fewer than ~20% of patients is dropped ---
min_patients <- ceiling(0.2 * length(patients))
keep <- rowSums(pseudobulk > 1) >= min_patients
cat("Genes passing expression filter (TPM>1 in >=", min_patients, "of", length(patients),
    "patients):", sum(keep), "of", length(keep), "\n")
pseudobulk <- pseudobulk[keep, ]
# --- limma on log2(TPM+1) -- NOT voom/edgeR, this is continuous TPM, not counts ---
log_expr <- log2(pseudobulk + 1)

response <- factor(patient_level[[resp_col]][match(colnames(log_expr), patient_level$patient)],
                    levels = c("Responder", "Non-responder"))
stopifnot(!any(is.na(response)))

design <- model.matrix(~response)
fit <- lmFit(log_expr, design)
fit <- eBayes(fit)
results <- topTable(fit, coef = "responseNon-responder", number = Inf, sort.by = "P")
results$gene <- rownames(results)
results <- results[, c("gene", "logFC", "AveExpr", "t", "P.Value", "adj.P.Val")]
cat("\n--- discovery screen result: top 20 by p-value (full unbiased ranking, no filtering by identity) ---\n")
print(head(results, 20))
cat("\nGenes significant at FDR < 0.05:", sum(results$adj.P.Val < 0.05), "\n")
cat("Genes significant at FDR < 0.10:", sum(results$adj.P.Val < 0.10), "\n")
dir.create("results", showWarnings = FALSE)
write.csv(results, "results/h1_discovery_screen_ranked.csv", row.names = FALSE)
saveRDS(list(n_patients = length(patients),
             n_responder = sum(response == "Responder"),
             n_nonresponder = sum(response == "Non-responder"),
             n_panel_genes = length(panel_genes),
             n_tested = nrow(results),
             n_sig_fdr05 = sum(results$adj.P.Val < 0.05),
             n_sig_fdr10 = sum(results$adj.P.Val < 0.10)),
        "results/h1_discovery_screen_summary.rds")
cat("\nFull ranked table written to results/h1_discovery_screen_ranked.csv\n")
