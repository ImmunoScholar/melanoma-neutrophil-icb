# H1 sensitivity audit (A2, post-hoc peer-review response, 2026-08-02): does H1's discovery
# result survive controlling for therapy type, or could the already-disclosed therapy-type
# confound (anti-PD1 monotherapy skews non-responder; anti-CTLA4+PD1 combo skews responder,
# both in this same 19-patient cohort) fully explain it?
#
# This is a ROBUSTNESS CHECK on an already-tested, already-committed result -- in the same
# audit category as H4's own p-value-shape audit (03b_h4_audit.R) and H5a's sign-flip sanity
# check, not a new discovery analysis. The panel (H1's already-committed 35 detection-filter-
# passing genes) is fixed and reused exactly as committed -- no gene is added, dropped, or
# re-selected here. The only change is one additional covariate term in the same limma design
# already frozen in 03_h1_discovery_screen.R.
library(data.table)
suppressPackageStartupMessages({
  library(msigdbr)
  library(limma)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
pat_col     <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col    <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
therapy_col <- grep("therapy", colnames(meta), ignore.case = TRUE, value = TRUE)[1]
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
patients <- sort(unique(pre$patient))
cat("Patients (identical to H1):", length(patients), "\n")

patient_level <- unique(pre[, c("patient", resp_col, therapy_col)])
patient_level <- patient_level[match(patients, patient_level$patient), ]
stopifnot(nrow(patient_level) == length(patients))

# --- Step 1: reproduce the exact therapy x response contingency table, don't assume its ---
# --- shape from prior prose -- print it in full before building anything on top of it. ---
cat("\n--- Full therapy x response contingency table (this cohort, n=", length(patients),
    ") ---\n", sep = "")
print(table(patient_level[[therapy_col]], patient_level[[resp_col]], useNA = "ifany"))
cat("\nRaw therapy value counts:\n")
print(table(patient_level[[therapy_col]], useNA = "ifany"))

# --- Step 2: reproduce H1's exact panel + detection-filter-passing 35-gene set ---
go_mf <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:MF")
panel_sets <- c("GOMF_CYTOKINE_ACTIVITY", "GOMF_CHEMOKINE_ACTIVITY", "GOMF_GROWTH_FACTOR_ACTIVITY")
panel_genes <- unique(go_mf$gene_symbol[go_mf$gs_name %in% panel_sets])
panel_genes <- intersect(panel_genes, tpm$gene)
stopifnot("Panel size must match H1's own committed count exactly" = length(panel_genes) == 327)

panel_tpm <- tpm[gene %in% panel_genes]
pseudobulk <- sapply(patients, function(p) {
  pcells <- pre$title[pre$patient == p]
  pcells <- intersect(pcells, colnames(panel_tpm))
  rowMeans(panel_tpm[, ..pcells])
})
rownames(pseudobulk) <- panel_tpm$gene
min_patients <- ceiling(0.2 * length(patients))
keep <- rowSums(pseudobulk > 1) >= min_patients
stopifnot("Detection-filter pass count must match H1's own committed count (35)" = sum(keep) == 35)
pseudobulk <- pseudobulk[keep, ]
log_expr <- log2(pseudobulk + 1)
cat("\nReproduced H1's exact 35-gene tested panel (sanity check passed).\n")

response <- factor(patient_level[[resp_col]][match(colnames(log_expr), patient_level$patient)],
                    levels = c("Responder", "Non-responder"))
therapy_raw <- patient_level[[therapy_col]][match(colnames(log_expr), patient_level$patient)]
stopifnot(!any(is.na(response)))

# --- Step 3: original (unadjusted) model, reproduced for a side-by-side baseline ---
design_orig <- model.matrix(~response)
fit_orig <- eBayes(lmFit(log_expr, design_orig))
res_orig <- topTable(fit_orig, coef = "responseNon-responder", number = Inf, sort.by = "none")
res_orig$gene <- rownames(res_orig)

# --- Step 4: therapy-adjusted model. Complete-case only -- any patient with missing/NA ---
# --- therapy is dropped from THIS sensitivity check and the exact number dropped is ---
# --- reported, never silently absorbed by model.matrix's own NA-handling. ---
complete <- !is.na(therapy_raw) & therapy_raw != ""
n_dropped <- sum(!complete)
cat("\nPatients with usable (non-missing) therapy label:", sum(complete), "of", length(patients),
    "--", n_dropped, "dropped from the adjusted model only.\n")

therapy <- factor(therapy_raw[complete])
cat("\nTherapy factor levels used in the adjusted model:\n")
print(table(therapy))
response_cc <- response[complete]
log_expr_cc <- log_expr[, complete]

if (nlevels(therapy) < 2) {
  stop("Fewer than 2 therapy levels after removing missing values -- cannot fit a therapy covariate. Stopping here rather than proceeding with an uninformative model.")
}

design_adj <- model.matrix(~response_cc + therapy)
cat("\nAdjusted design matrix columns:", paste(colnames(design_adj), collapse = ", "), "\n")
cat("Residual degrees of freedom, adjusted model:", sum(complete) - ncol(design_adj), "\n")

fit_adj <- eBayes(lmFit(log_expr_cc, design_adj))
resp_coef <- grep("^response_cc", colnames(design_adj), value = TRUE)
stopifnot(length(resp_coef) == 1)
res_adj <- topTable(fit_adj, coef = resp_coef, number = Inf, sort.by = "none")
res_adj$gene <- rownames(res_adj)

# --- Step 5: side-by-side comparison, full 35-gene panel and the 4 original FDR<0.05 hits ---
compare <- merge(
  res_orig[, c("gene", "logFC", "P.Value", "adj.P.Val")],
  res_adj[, c("gene", "logFC", "P.Value", "adj.P.Val")],
  by = "gene", suffixes = c("_unadjusted", "_therapy_adjusted")
)
compare <- compare[order(compare$adj.P.Val_unadjusted), ]
cat("\n--- Full 35-gene comparison: unadjusted vs therapy-adjusted ---\n")
print(compare, digits = 3)

h1_hits <- c("LTB", "CCL3", "CCL4", "CXCL13")
cat("\n--- H1's 4 original FDR<0.05 hits specifically ---\n")
print(compare[compare$gene %in% h1_hits, ], digits = 3)

cat("\nGenes significant at FDR<0.05, unadjusted model:", sum(res_orig$adj.P.Val < 0.05), "\n")
cat("Genes significant at FDR<0.05, therapy-adjusted model:", sum(res_adj$adj.P.Val < 0.05), "\n")
cat("Of H1's original 4 hits, number still significant (FDR<0.05) after adjustment:",
    sum(compare$adj.P.Val_therapy_adjusted[compare$gene %in% h1_hits] < 0.05), "of 4\n")
cat("Of H1's original 4 hits, number with SAME direction (sign of logFC unchanged) after adjustment:",
    sum(sign(compare$logFC_unadjusted[compare$gene %in% h1_hits]) ==
        sign(compare$logFC_therapy_adjusted[compare$gene %in% h1_hits])), "of 4\n")

dir.create("results", showWarnings = FALSE)
write.csv(compare, "results/h1_therapy_sensitivity_comparison.csv", row.names = FALSE)
saveRDS(list(n_total = length(patients), n_complete_case = sum(complete), n_dropped = n_dropped,
             therapy_levels = levels(therapy), design_cols = colnames(design_adj),
             residual_df = sum(complete) - ncol(design_adj)),
        "results/h1_therapy_sensitivity_summary.rds")
cat("\nFull comparison written to results/h1_therapy_sensitivity_comparison.csv\n")
