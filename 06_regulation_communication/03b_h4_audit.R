# Audit of the H4 primary TF-activity result (03_h4_tf_activity.R), before it is treated as
# locked/final -- "no error on run" is not sufficient verification (project standing rule).
# Three checks:
#  1. p-value distribution shape: real signal should show enrichment near 0 against a roughly
#     uniform background, not near-total or near-zero significance across all 754 TFs (either
#     extreme would suggest a technical artefact, e.g. an unmodeled confound or normalization
#     issue, rather than a specific regulatory signal).
#  2. The same anti-PD1-monotherapy / anti-CTLA4+PD1-combo confound H1 documented (same
#     patient cohort) is re-checked here -- if therapy type predicts response almost as well
#     as response predicts TF activity, the "confound not adjusted for" caveat must be
#     restated for H4, not silently dropped just because it was already said once for H1.
#  3. Direction/effect-size sanity: are hits split across both directions (not a single
#     uniform shift suggesting a global technical shift), and are t-statistics in a
#     scientifically plausible range for n=19 (df=17)?

library(data.table)
meta <- readRDS("data/processed/GSE120575/meta.rds")
results <- read.csv("results/h4_tf_activity_ranked.csv")

pat_col     <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col    <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
therapy_col <- grep("therapy", colnames(meta), ignore.case = TRUE, value = TRUE)[1]
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
patient_level <- unique(pre[, c("patient", resp_col, therapy_col)])

cat("--- 1. p-value distribution ---\n")
cat("Quantiles of raw P.Value across all", nrow(results), "tested TFs:\n")
print(quantile(results$P.Value, probs = c(0, .1, .25, .5, .75, .9, 1)))
cat("\nHistogram (10 bins, 0-1):\n")
print(table(cut(results$P.Value, breaks = seq(0, 1, 0.1), include.lowest = TRUE)))
cat("\nFraction of ALL 754 TFs with raw P<0.05:", mean(results$P.Value < 0.05), "\n")
cat("(A well-behaved test should show a spike near 0 and a roughly flat tail toward 1 --",
    "near-uniform enrichment across the WHOLE range would suggest a technical artefact.)\n")

cat("\n--- 2. Therapy-type confound (same cohort as H1's documented confound) ---\n")
print(table(patient_level[[therapy_col]], patient_level[[resp_col]]))
cat("(Matches H1's documented confound if similar imbalance: anti-PD1 monotherapy skewing",
    "Non-responder, combo therapy skewing Responder. Restated here since it applies to any",
    "analysis using this same 19-patient pre-treatment cohort, not just H1.)\n")

cat("\n--- 3. Direction and effect-size sanity ---\n")
sig05 <- results[results$adj.P.Val < 0.05, ]
cat("Significant TFs (FDR<0.05):", nrow(sig05), "\n")
cat("Higher in Non-responder (positive logFC):", sum(sig05$logFC > 0),
    "| Higher in Responder (negative logFC):", sum(sig05$logFC < 0), "\n")
cat("\nlogFC range among significant TFs:\n")
print(summary(sig05$logFC))
cat("\n|t| range among significant TFs (df = 17):\n")
print(summary(abs(sig05$t)))
cat("\nFor reference, a two-sided t-test with df=17 needs |t| > 2.11 for P<0.05 uncorrected;",
    "max observed |t| here is", round(max(abs(results$t)), 2),
    "-- extreme values (e.g. >10) would suggest near-perfect separation, worth distrusting.\n")
