# H1 follow-up audit (A1, post-hoc peer-review response, 2026-08-02): does H1's discovery
# panel/hits actually contain the canonical neutrophil-recruitment chemoattractants, or is
# "neutrophil recruitment" in this project's central question resting on genes (LTB, CCL3,
# CCL4, CXCL13) that are not, in fact, neutrophil-specific?
#
# This is DELIBERATELY NOT a new discovery test. It performs NO comparison against response
# labels and computes NO p-value. It only asks two factual questions, using EXACTLY the same
# panel-construction and detection-filter logic already frozen in
# 03_recruitment/03_h1_discovery_screen.R (reproduced here, not reinvented):
#   1. Are the canonical neutrophil chemoattractant genes even members of the GO-sourced
#      327-gene candidate panel H1 screened from?
#   2. Of those that are panel members, which pass H1's own pre-specified detection filter
#      (TPM>1 in >=20% of the same 19 patients) and so could, in principle, have been tested?
# Per this project's discovery discipline (the same reasoning that kept CXCL8/CXCR1/2 out of
# every discovery test through H1-H5), no gene is added to or removed from any tested panel
# here, and nothing in this script is compared to the response labels at all.

library(data.table)
suppressPackageStartupMessages({
  library(msigdbr)
})

# --- canonical neutrophil-recruitment chemoattractant panel (defined here, once, before ---
# --- looking at any result below -- not adjusted after seeing which genes are present) ---
# ELR+ CXC chemokines: the canonical CXCR1/CXCR2-axis neutrophil chemoattractants.
# CSF3 (G-CSF): canonical neutrophil-lineage growth factor.
# Receptors (CXCR1, CXCR2, FPR1, LTB4R) are deliberately excluded: H1's panel is built from
# GO *ligand*-activity terms (cytokine/chemokine/growth-factor ACTIVITY), which categorically
# excludes receptors by construction -- the same reasoning already documented in
# 07_validation_concordance/README.md for why Guo et al. 2025's receptor markers (CXCR2, VNN2)
# could never appear in H1's panel regardless of their true biology.
neutrophil_chemoattractants <- c(
  "CXCL1", "CXCL2", "CXCL3", "CXCL5", "CXCL6", "PPBP",  # PPBP = CXCL7
  "CXCL8", "CSF3"
)
cat("Canonical neutrophil-chemoattractant panel defined (fixed before any check below):\n")
print(neutrophil_chemoattractants)

meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
patients <- sort(unique(pre$patient))
cat("\nPatients (identical to H1):", length(patients), "\n")

# --- Step 1: reproduce H1's exact panel construction (union of the same 3 GO:MF terms) ---
go_mf <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:MF")
panel_sets <- c("GOMF_CYTOKINE_ACTIVITY", "GOMF_CHEMOKINE_ACTIVITY", "GOMF_GROWTH_FACTOR_ACTIVITY")
panel_genes_all <- unique(go_mf$gene_symbol[go_mf$gs_name %in% panel_sets])
panel_genes <- intersect(panel_genes_all, tpm$gene)
stopifnot("Panel size must match H1's own committed count exactly" = length(panel_genes) == 327)
cat("\nReproduced H1's 327-gene panel exactly (sanity check passed).\n")

in_panel <- neutrophil_chemoattractants %in% panel_genes
cat("\n--- Question 1: which canonical neutrophil chemoattractants are in H1's 327-gene panel? ---\n")
print(data.frame(gene = neutrophil_chemoattractants, in_go_panel = in_panel))

# also report, separately, which are even present in the raw expression matrix at all
# (a gene absent from GO:MF chemokine/cytokine/growth-factor terms entirely -- e.g. if
# annotated under a different GO category -- would never reach panel_genes above regardless
# of expression, so this is checked independently for completeness)
in_matrix <- neutrophil_chemoattractants %in% tpm$gene
cat("\nPresent in the raw GSE120575 expression matrix at all (independent of GO annotation):\n")
print(data.frame(gene = neutrophil_chemoattractants, in_matrix = in_matrix))

# --- Step 2: for panel members only, reproduce H1's exact detection filter ---
panel_tpm <- tpm[gene %in% panel_genes]
pseudobulk <- sapply(patients, function(p) {
  pcells <- pre$title[pre$patient == p]
  pcells <- intersect(pcells, colnames(panel_tpm))
  rowMeans(panel_tpm[, ..pcells])
})
rownames(pseudobulk) <- panel_tpm$gene
min_patients <- ceiling(0.2 * length(patients))
detect_rate <- rowSums(pseudobulk > 1) / length(patients)
passes_filter <- rowSums(pseudobulk > 1) >= min_patients
stopifnot("Detection-filter pass count must match H1's own committed count (35)" =
  sum(passes_filter) == 35)
cat("\nReproduced H1's detection filter exactly: ", sum(passes_filter),
    "of", length(passes_filter), "panel genes pass (matches H1's committed 35).\n")

audit_genes <- intersect(neutrophil_chemoattractants, panel_genes)
audit_result <- data.frame(
  gene = audit_genes,
  detect_rate_pct = round(100 * detect_rate[audit_genes], 1),
  patients_detected = round(detect_rate[audit_genes] * length(patients)),
  passes_h1_detection_filter = passes_filter[audit_genes]
)
cat("\n--- Question 2: of those in the panel, detection rate and H1 filter pass/fail ---\n")
print(audit_result)

# --- Step 3: cross-check against H1's own committed, tested 35-gene ranked table ---
h1_ranked <- read.csv("results/h1_discovery_screen_ranked.csv", stringsAsFactors = FALSE)
in_tested_35 <- audit_genes %in% h1_ranked$gene
cat("\n--- Cross-check: any of these genes in H1's actually-tested 35-gene table? ---\n")
print(data.frame(gene = audit_genes, in_h1_tested_35 = in_tested_35))
if (any(in_tested_35)) {
  cat("\nFull H1 result row(s) for any matches (for reference only -- no new test run):\n")
  print(h1_ranked[h1_ranked$gene %in% audit_genes[in_tested_35], ])
}

# --- Save a single audit table, no p-values, no response comparison anywhere in this file ---
full_audit <- data.frame(
  gene = neutrophil_chemoattractants,
  in_raw_matrix = in_matrix,
  in_go_chemokine_cytokine_growthfactor_panel = in_panel,
  detect_rate_pct_of_19_patients = ifelse(neutrophil_chemoattractants %in% audit_genes,
    round(100 * detect_rate[neutrophil_chemoattractants], 1), NA),
  passes_h1_20pct_detection_filter = ifelse(neutrophil_chemoattractants %in% audit_genes,
    passes_filter[neutrophil_chemoattractants], NA),
  in_h1_tested_35_gene_table = neutrophil_chemoattractants %in% h1_ranked$gene
)
dir.create("results", showWarnings = FALSE)
write.csv(full_audit, "results/neutrophil_chemoattractant_panel_audit.csv", row.names = FALSE)
cat("\nFull audit table written to results/neutrophil_chemoattractant_panel_audit.csv\n")
cat("\n=== SUMMARY (facts only -- interpretation belongs in README/CHANGELOG, not here) ===\n")
cat(sum(in_matrix), "of", length(neutrophil_chemoattractants), "canonical neutrophil chemoattractants are present in the raw matrix.\n")
cat(sum(in_panel), "of", length(neutrophil_chemoattractants), "are members of H1's GO-sourced 327-gene panel.\n")
cat(sum(full_audit$passes_h1_20pct_detection_filter, na.rm = TRUE), "of", sum(in_panel),
    "panel members pass H1's detection filter and could, in principle, have been tested.\n")
cat(sum(in_tested_35), "of", length(audit_genes), "actually appear in H1's tested 35-gene table.\n")
