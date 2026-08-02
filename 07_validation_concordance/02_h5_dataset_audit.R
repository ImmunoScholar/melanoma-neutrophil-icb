# H5 Step 2: dataset audit for GSE78220 and GSE91061. Determines real sample sizes,
# response-label distributions, therapy composition, treatment-timepoint structure, and
# expression data format/gene-ID system -- none of which are assumed from the GEO summary
# pages alone (matching H0's own audit discipline). This directly determines H5a/H5b's final
# statistical method (the "finalize methods" step in the pre-registration sequence) -- the
# method is NOT decided before this data exists, per the project owner's explicit instruction.
#
# Requires GEOquery (already a project dependency) and readxl (NOT yet used elsewhere in this
# project -- install first if needed: renv::install("readxl")).

suppressPackageStartupMessages({
  library(GEOquery)
  library(readxl)
  library(data.table)
})

# ---- GSE78220 ----
cat("=== GSE78220 ===\n")
gse78220_meta <- getGEO(filename = "data/raw/GSE78220/GSE78220_series_matrix.txt.gz",
                         GSEMatrix = TRUE, getGPL = FALSE)
pheno78220 <- pData(gse78220_meta)
cat("Samples:", nrow(pheno78220), "\n")
cat("Columns available:\n")
print(colnames(pheno78220))

resp_col_78220    <- grep("response", colnames(pheno78220), ignore.case = TRUE, value = TRUE)
time_col_78220    <- grep("biopsy|time", colnames(pheno78220), ignore.case = TRUE, value = TRUE)
therapy_col_78220 <- grep("treatment", colnames(pheno78220), ignore.case = TRUE, value = TRUE)
cat("\nCandidate response column(s):", paste(resp_col_78220, collapse = ", "), "\n")
cat("Candidate timepoint column(s):", paste(time_col_78220, collapse = ", "), "\n")
cat("Candidate therapy column(s):", paste(therapy_col_78220, collapse = ", "), "\n")
for (col in resp_col_78220)    { cat("\n[", col, "] distribution:\n"); print(table(pheno78220[[col]], useNA = "always")) }
for (col in time_col_78220)    { cat("\n[", col, "] distribution:\n"); print(table(pheno78220[[col]], useNA = "always")) }
for (col in therapy_col_78220) { cat("\n[", col, "] distribution:\n"); print(table(pheno78220[[col]], useNA = "always")) }

cat("\n--- GSE78220 FPKM matrix structure ---\n")
fpkm78220 <- read_excel("data/raw/GSE78220/GSE78220_PatientFPKM.xlsx")
cat("Dimensions:", nrow(fpkm78220), "rows x", ncol(fpkm78220), "cols\n")
cat("First column name (should be gene identifier):", colnames(fpkm78220)[1], "\n")
print(head(as.data.frame(fpkm78220[, 1:min(6, ncol(fpkm78220))])))
cat("Sample columns vs GSM count:", ncol(fpkm78220) - 1, "expression columns vs",
    nrow(pheno78220), "GSM records\n")

# ---- GSE91061 ----
cat("\n\n=== GSE91061 ===\n")
gse91061_meta <- getGEO(filename = "data/raw/GSE91061/GSE91061_series_matrix.txt.gz",
                         GSEMatrix = TRUE, getGPL = FALSE)
pheno91061 <- pData(gse91061_meta)
cat("Samples:", nrow(pheno91061), "\n")
print(colnames(pheno91061))

resp_col_91061    <- grep("response", colnames(pheno91061), ignore.case = TRUE, value = TRUE)
time_col_91061    <- grep("time|pre|on.treatment|biopsy", colnames(pheno91061), ignore.case = TRUE, value = TRUE)
therapy_col_91061 <- grep("treatment|drug|arm", colnames(pheno91061), ignore.case = TRUE, value = TRUE)
patient_col_91061 <- grep("patient|subject", colnames(pheno91061), ignore.case = TRUE, value = TRUE)
cat("\nCandidate response column(s):", paste(resp_col_91061, collapse = ", "), "\n")
cat("Candidate timepoint column(s):", paste(time_col_91061, collapse = ", "), "\n")
cat("Candidate therapy column(s):", paste(therapy_col_91061, collapse = ", "), "\n")
cat("Candidate patient-ID column(s):", paste(patient_col_91061, collapse = ", "), "\n")
for (col in resp_col_91061)    { cat("\n[", col, "] distribution:\n"); print(table(pheno91061[[col]], useNA = "always")) }
for (col in time_col_91061)    { cat("\n[", col, "] distribution:\n"); print(table(pheno91061[[col]], useNA = "always")) }
for (col in therapy_col_91061) { cat("\n[", col, "] distribution:\n"); print(table(pheno91061[[col]], useNA = "always")) }

cat("\n--- GSE91061 expression matrix structure (FPKM) ---\n")
fpkm91061 <- fread("data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.fpkm.csv.gz")
cat("Dimensions:", nrow(fpkm91061), "rows x", ncol(fpkm91061), "cols\n")
cat("First column name (gene identifier):", colnames(fpkm91061)[1], "\n")
cat("Gene identifier format, first 10 values:\n")
print(head(fpkm91061[[1]], 10))
cat("Sample column names, first 6:\n")
print(head(colnames(fpkm91061), 6))

cat("\n--- GSE91061 raw counts matrix structure ---\n")
raw91061 <- fread("data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.raw.csv.gz")
cat("Dimensions:", nrow(raw91061), "rows x", ncol(raw91061), "cols\n")
cat("Sample of values (should be integer-like if true raw counts):\n")
print(raw91061[1:3, 2:5, with = FALSE])

cat("\n--- Cross-checks ---\n")
if (length(time_col_78220) > 0) {
  cat("GSE78220: all samples pre-treatment (per series title claim)?",
      all(grepl("pre", pheno78220[[time_col_78220[1]]], ignore.case = TRUE)), "\n")
} else {
  cat("GSE78220: could not locate a timepoint column -- inspect the column list above.\n")
}
cat("GSE78220 expression-column count matches GSM count:",
    (ncol(fpkm78220) - 1) == nrow(pheno78220), "\n")
cat("GSE91061 FPKM/raw column counts match:", ncol(fpkm91061) == ncol(raw91061), "\n")

cat("\n=== Audit complete. Do NOT finalize H5's statistical method until this output is",
    "reviewed with Claude -- gene-ID mapping strategy, response-label recoding, and",
    "count-vs-FPKM choice all depend on what was actually printed above, not on",
    "assumptions carried in from the GEO summary pages. ===\n")
