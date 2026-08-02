# Sanity check before designing H1's discovery screen: verify metadata integrity at
# the patient level, determine a defensible sample (pre-treatment, response-labeled),
# and source the discovery gene panel externally rather than hand-picking it.
library(data.table)
suppressPackageStartupMessages(library(msigdbr))
meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient   <- sub("^(Pre|Post)_", "", meta[[pat_col]])
cat("--- timepoint parsing check ---\n")
print(table(meta$timepoint, useNA = "ifany"))
# Response is a patient-level clinical outcome. If any patient's cells carry more
# than one response label, that's a parsing bug -- must be zero for pseudobulk to
# be meaningful at all.
cat("\n--- response consistency per patient (must show exactly 1 nonzero per row) ---\n")
resp_tab <- table(meta$patient, meta[[resp_col]])
print(resp_tab)
inconsistent <- rownames(resp_tab)[rowSums(resp_tab > 0) > 1]
cat("\nPatients with inconsistent response labels:", length(inconsistent),
    if (length(inconsistent) > 0) paste("->", paste(inconsistent, collapse=", ")) else "", "\n")

cat("\n--- patients x timepoint, cell counts ---\n")
print(table(meta$patient, meta$timepoint))

cat("\n--- candidate sample: Pre-treatment, response-labeled patients ---\n")
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]
cell_counts <- table(pre$patient)
cat("Unique patients:", length(unique(pre$patient)), "\n")
cat("Cell count per patient (min/median/max):",
    min(cell_counts), "/", median(cell_counts), "/", max(cell_counts), "\n")
cat("Patients with <10 cells:", sum(cell_counts < 10), "\n")
resp_per_patient <- unique(pre[, c("patient", resp_col)])
cat("\nResponse breakdown, at the PATIENT level (not cell level):\n")
print(table(resp_per_patient[[resp_col]]))
# --- discovery gene panel: externally sourced, not hand-picked ---
cat("\n--- candidate GO gene sets (searching, not assuming exact names) ---\n")
go_mf <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:MF")
candidates <- unique(go_mf$gs_name[grepl("CYTOKINE|CHEMOKINE|GROWTH_FACTOR", go_mf$gs_name)])
print(candidates)
for (set_name in c("GOMF_CYTOKINE_ACTIVITY", "GOMF_CHEMOKINE_ACTIVITY", "GOMF_GROWTH_FACTOR_ACTIVITY")) {
  genes <- unique(go_mf$gene_symbol[go_mf$gs_name == set_name])
  present <- intersect(genes, tpm$gene)
  cat(sprintf("\n%s: %d genes in set, %d present in GSE120575 matrix\n",
              set_name, length(genes), length(present)))
}
