# H4 Step 4: primary TF-activity analysis (CONTINUATION_BRIEF.md §8, Step 4). Tests whether
# the recruitment programme is "regulatorily coherent" -- driven by an identifiable set of
# transcription factors whose inferred activity differs systematically between ICB responders
# and non-responders -- using the same patient-level, pre-treatment-only cohort and `limma`
# testing discipline as H1/H2, applied to decoupleR TF-activity scores instead of raw gene
# expression.
#
# Direction convention (matching H1 exactly): positive logFC/t = higher in Non-responder
# (associated with resistance).
#
# Unit of analysis: patient-level pseudobulk (19 patients, pre-treatment, response-labeled --
# same cohort as H1/H2). TF panel: whatever decoupleR::run_ulm(minsize=5) scores against the
# verified CollecTRI network (data/processed/collectri_human_verified.rds) -- externally
# defined by the network plus decoupleR's own minimum-regulon-size rule, not hand-picked,
# matching this project's discovery-discipline requirement (no TF is named or excluded by us).
#
# This is H4's PRIMARY result. Its ranked output must be committed before any secondary,
# compartment-level follow-up is even considered -- see CHANGELOG.md, "Pre-registration: H4
# secondary compartment-level TF-activity analysis" for the binding conditions on that
# follow-up.

library(data.table)
suppressPackageStartupMessages({
  library(decoupleR)
  library(limma)
})

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
net  <- readRDS("data/processed/collectri_human_verified.rds")

# One row of tpm.rds (of 55,738) has a literal NA gene symbol -- isolated artefact, see
# CHANGELOG.md ("H4 data structures confirmed"). Guarded, not assumed unchanged since the
# sanity check.
n_before <- nrow(tpm)
tpm <- tpm[!is.na(gene)]
n_dropped <- n_before - nrow(tpm)
cat("Dropped", n_dropped, "row(s) with NA gene symbol from tpm (", nrow(tpm), "remain ).\n")
stopifnot("Unexpectedly many NA-gene rows -- investigate before dropping silently" = n_dropped <= 5)

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
cat("Pre-treatment, response-labeled cells:", nrow(pre),
    "| patients:", length(unique(pre$patient)), "\n")

# --- whole-transcriptome patient-level pseudobulk (same aggregation logic as H1, all genes) ---
patients <- sort(unique(pre$patient))
pseudobulk <- sapply(patients, function(p) {
  pcells <- intersect(pre$title[pre$patient == p], colnames(tpm))
  rowMeans(tpm[, ..pcells])
})
rownames(pseudobulk) <- tpm$gene
log_pb <- log2(pseudobulk + 1)
cat("\nPseudobulk:", nrow(log_pb), "genes x", ncol(log_pb), "patients\n")

# one response label per patient -- guard, don't assume, that pre-treatment restriction
# already enforced this (it did for H1; re-verified here rather than re-trusted)
resp_lookup <- unique(pre[, c("patient", resp_col)])
stopifnot("Patient has more than one response label" = !any(duplicated(resp_lookup$patient)))
patient_response <- setNames(resp_lookup[[resp_col]], resp_lookup$patient)[patients]
cat("\nResponse labels:\n")
print(table(patient_response))

# --- decoupleR::run_ulm(): TF activity per patient ---
cat("\n--- decoupleR::run_ulm(): TF activity per patient ---\n")
act <- run_ulm(mat = log_pb, network = net, minsize = 5)
cat("Scored", length(unique(act$source)), "TFs across", length(unique(act$condition)), "patients\n")

# reshape long (source, condition, score) to wide (TF x patient) for limma
tf_ids <- sort(unique(act$source))
score_mat <- matrix(NA_real_, nrow = length(tf_ids), ncol = length(patients),
                     dimnames = list(tf_ids, patients))
score_mat[cbind(match(act$source, tf_ids), match(act$condition, patients))] <- act$score
stopifnot(
  "NA remaining in TF activity score matrix -- some TF x patient combination missing" =
    !anyNA(score_mat)
)

# --- limma, same testing discipline as H1/H2: patient-level, moderated t, BH-FDR ---
resp_factor <- factor(patient_response[colnames(score_mat)],
                       levels = c("Responder", "Non-responder"))
stopifnot("Response factor order/alignment mismatch" =
  identical(names(patient_response[colnames(score_mat)]), colnames(score_mat)))
design <- model.matrix(~ resp_factor)
colnames(design) <- c("Intercept", "NonResponderVsResponder")

fit <- lmFit(score_mat, design)
fit <- eBayes(fit)
results <- topTable(fit, coef = "NonResponderVsResponder", number = Inf, sort.by = "P")
results$TF <- rownames(results)
rownames(results) <- NULL
results <- results[, c("TF", setdiff(colnames(results), "TF"))]

sig05 <- results[results$adj.P.Val < 0.05, ]
sig10 <- results[results$adj.P.Val < 0.10, ]
cat("\n--- H4 primary result ---\n")
cat("TFs tested:", nrow(results), "\n")
cat("Significant at FDR<0.05:", nrow(sig05), "\n")
if (nrow(sig05) > 0) print(sig05)
cat("\nSignificant at FDR<0.10:", nrow(sig10), "\n")
if (nrow(sig10) > 0) print(sig10)

saveRDS(list(score_mat = score_mat, patient_response = patient_response, results = results),
        "results/h4_tf_activity_summary.rds")
write.csv(results, "results/h4_tf_activity_ranked.csv", row.names = FALSE)
cat("\nSaved: results/h4_tf_activity_ranked.csv, results/h4_tf_activity_summary.rds\n")
