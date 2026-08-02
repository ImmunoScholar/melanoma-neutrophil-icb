# H4 SECONDARY / EXPLORATORY analysis -- pre-registered in CHANGELOG.md ("Pre-registration:
# H4 secondary compartment-level TF-activity analysis", written before this script existed).
# Binding conditions from that entry, restated here and enforced programmatically where
# possible, not just promised in prose:
#   1. Primary (patient-level) TF-activity analysis is complete and committed (682be13,
#      24816be, 9200163) -- satisfied.
#   2. Only TFs meeting the primary's FDR<0.05 threshold are eligible -- enforced below by
#      reading the LOCKED, COMMITTED results/h4_tf_activity_ranked.csv and asserting exactly
#      56 hit TFs, not recomputed or re-thresholded here.
#   3. Labeled Exploratory/Secondary everywhere -- this header, the module README, the
#      ledger row, and the figure caption all state this explicitly.
#   4. Purpose: does the primary TF signal trace to a specific compartment, and does it
#      reinforce or contradict H2's "regulation != abundance" pattern -- not a new discovery
#      search, not a redesign of H4's primary conclusion.
#   5-6. If results are weak/inconsistent, reported honestly and left supplementary --
#      handled in the audit/interpretation, not here.
#
# Method: same two-tier structure as H2's own primary/secondary split (H2's secondary test
# is the direct precedent for this design -- restricted compartments, restricted gene/TF set,
# limma, globally-pooled BH-FDR). T_cell/NK/B_cell only; Myeloid excluded for the same reason
# H2 excluded it from ITS secondary test (only 3 usable responder patients -- a power
# constraint, verified below to still hold, not assumed unchanged).

library(data.table)
suppressPackageStartupMessages({
  library(decoupleR)
  library(limma)
})

meta  <- readRDS("data/processed/GSE120575/meta.rds")
tpm   <- readRDS("data/processed/GSE120575/tpm.rds")
net   <- readRDS("data/processed/collectri_human_verified.rds")
compartments <- read.csv("results/gse120575_compartment_calls.csv")
h4_primary   <- read.csv("results/h4_tf_activity_ranked.csv")

# One row of tpm.rds has a literal NA gene symbol -- isolated artefact, see CHANGELOG.md.
n_before <- nrow(tpm)
tpm <- tpm[!is.na(gene)]
n_dropped <- n_before - nrow(tpm)
stopifnot("Unexpectedly many NA-gene rows" = n_dropped <= 5)

# --- locked TF panel: read from the committed primary result, do not recompute ---
hit_tfs <- h4_primary$TF[h4_primary$adj.P.Val < 0.05]
stopifnot(
  "Locked TF panel does not match the committed primary result (expected 56) -- STOP, this
   analysis is only valid against the exact primary result already committed" =
    length(hit_tfs) == 56
)
cat("Locked panel (from committed h4_tf_activity_ranked.csv):", length(hit_tfs), "TFs\n")

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
meta_sub <- meta[, c("title", "patient", "timepoint", resp_col)]
pre <- meta_sub[meta_sub$timepoint == "Pre" & meta_sub[[resp_col]] %in% c("Responder", "Non-responder"), ]
pre <- merge(pre, compartments, by.x = "title", by.y = "cell", all.x = TRUE)
stopifnot(sum(is.na(pre$compartment_call)) == 0)

# --- compartment x patient whole-transcriptome pseudobulk (same >=10-cell threshold as H2) ---
build_pseudobulk <- function(comp) {
  sub <- pre[pre$compartment_call == comp, ]
  counts <- table(sub$patient)
  usable <- names(counts)[counts >= 10]
  pb <- sapply(usable, function(p) {
    pcells <- intersect(sub$title[sub$patient == p], colnames(tpm))
    rowMeans(tpm[, ..pcells])
  })
  rownames(pb) <- tpm$gene
  pb
}
all_compartments <- c("T_cell", "B_cell", "Myeloid", "NK")
pb_list <- lapply(all_compartments, build_pseudobulk)
names(pb_list) <- all_compartments
cat("\nPatients per compartment pseudobulk:\n")
print(sapply(pb_list, ncol))

resp_per_patient <- unique(pre[, c("patient", resp_col)])
usable_responders <- sapply(pb_list, function(pb) {
  r <- resp_per_patient[[resp_col]][match(colnames(pb), resp_per_patient$patient)]
  sum(r == "Responder")
})
cat("\nUsable RESPONDER patients per compartment:\n")
print(usable_responders)
stopifnot(
  "Myeloid's responder-patient count no longer matches H2's documented power constraint --
   the exclusion below needs to be reconsidered, not assumed" =
    usable_responders["Myeloid"] <= 5
)

secondary_compartments <- c("T_cell", "NK", "B_cell")  # Myeloid excluded, same reason as H2
cat("\nSecondary test restricted to:", paste(secondary_compartments, collapse = ", "),
    "(Myeloid excluded --", usable_responders["Myeloid"], "usable responder patients)\n")

# --- TF activity per compartment, then subset to the locked 56 -- decoupleR is run on the
# full transcriptome/full network as always (its panel is externally defined, not ours), the
# LOCKED PANEL is only applied when selecting which TFs are tested for response, satisfying
# condition 2 without distorting how run_ulm itself works ---
activity_by_compartment <- lapply(secondary_compartments, function(comp) {
  pb <- pb_list[[comp]]
  log_pb <- log2(pb + 1)
  act <- run_ulm(mat = log_pb, network = net, minsize = 5)
  act
})
names(activity_by_compartment) <- secondary_compartments

secondary_results <- list()
dominant_compartment <- list()
for (comp in secondary_compartments) {
  act <- activity_by_compartment[[comp]]
  missing_tfs <- setdiff(hit_tfs, unique(act$source))
  stopifnot(
    "Some locked hit TFs were not scored in this compartment -- investigate before proceeding" =
      length(missing_tfs) == 0
  )
  act_sub <- act[act$source %in% hit_tfs, ]

  patients <- sort(unique(act_sub$condition))
  score_mat <- matrix(NA_real_, nrow = length(hit_tfs), ncol = length(patients),
                       dimnames = list(hit_tfs, patients))
  score_mat[cbind(match(act_sub$source, hit_tfs), match(act_sub$condition, patients))] <- act_sub$score
  stopifnot("NA in compartment TF-activity score matrix" = !anyNA(score_mat))

  resp <- factor(resp_per_patient[[resp_col]][match(colnames(score_mat), resp_per_patient$patient)],
                  levels = c("Responder", "Non-responder"))
  design <- model.matrix(~resp)
  fit <- eBayes(lmFit(score_mat, design))
  tt <- topTable(fit, coef = "respNon-responder", number = Inf, sort.by = "none")
  tt$TF <- rownames(tt)
  tt$compartment <- comp
  secondary_results[[comp]] <- tt[, c("compartment", "TF", "logFC", "P.Value", "adj.P.Val")]

  # mean activity magnitude per TF in this compartment -- for the abundance/regulation-style
  # comparison below (H2's key secondary insight: regulation is not always co-located with
  # where a gene/TF is most active)
  dominant_compartment[[comp]] <- data.frame(TF = hit_tfs, compartment = comp,
                                              mean_activity = rowMeans(score_mat))
}
secondary_df <- do.call(rbind, secondary_results)
secondary_df$fdr_global <- p.adjust(secondary_df$P.Value, method = "BH")
secondary_df <- secondary_df[order(secondary_df$P.Value), ]

cat("\n--- H4 SECONDARY/EXPLORATORY: within-compartment response test, locked 56 TFs ---\n")
cat("Tests performed:", nrow(secondary_df), "(", length(secondary_compartments), "compartments x",
    length(hit_tfs), "TFs )\n")
sig <- secondary_df[secondary_df$fdr_global < 0.05, ]
cat("Significant at global FDR<0.05:", nrow(sig), "\n")
if (nrow(sig) > 0) print(sig)

# --- abundance/regulation comparison, matching H2's secondary-test framing ---
magnitude_df <- do.call(rbind, dominant_compartment)
magnitude_wide <- reshape(magnitude_df, idvar = "TF", timevar = "compartment", direction = "wide")
magnitude_wide$dominant <- apply(
  magnitude_wide[, paste0("mean_activity.", secondary_compartments)], 1,
  function(x) secondary_compartments[which.max(x)]
)
if (nrow(sig) > 0) {
  sig_with_dominant <- merge(sig, magnitude_wide[, c("TF", "dominant")], by = "TF")
  sig_with_dominant$abundance_regulation_mismatch <-
    sig_with_dominant$compartment != sig_with_dominant$dominant
  cat("\n--- Regulation vs activity-magnitude comparison (H2-style check) ---\n")
  print(sig_with_dominant[, c("TF", "compartment", "dominant",
                               "abundance_regulation_mismatch", "adj.P.Val")])
}

write.csv(secondary_df, "results/h4_secondary_compartment_tf_activity.csv", row.names = FALSE)
saveRDS(list(secondary_df = secondary_df, magnitude_wide = magnitude_wide,
             activity_by_compartment = activity_by_compartment),
        "results/h4_secondary_compartment_tf_activity_summary.rds")
cat("\nSaved: results/h4_secondary_compartment_tf_activity.csv,",
    "results/h4_secondary_compartment_tf_activity_summary.rds\n")
