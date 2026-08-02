# H5 Step 2 (continued): resolve two remaining unknowns before finalizing statistical
# methods -- (a) the exact join key between each cohort's phenotype table and its expression
# matrix column names (never assumed -- this project has been burned by join-key mismatches
# before, e.g. GSE120575's title/TPM-column match had to be verified explicitly), and (b)
# whether an Entrez-to-symbol mapping resource is available for GSE91061's numeric gene IDs.

suppressPackageStartupMessages({
  library(GEOquery)
  library(readxl)
  library(data.table)
})

# ---- GSE78220: identify the on-treatment sample, verify the join key ----
cat("=== GSE78220 join key ===\n")
gse78220_meta <- getGEO(filename = "data/raw/GSE78220/GSE78220_series_matrix.txt.gz",
                         GSEMatrix = TRUE, getGPL = FALSE)
pheno78220 <- pData(gse78220_meta)
cat("title column, first 6:\n"); print(head(pheno78220$title, 6))
cat("description column, first 6:\n"); print(head(pheno78220$description, 6))

fpkm78220 <- read_excel("data/raw/GSE78220/GSE78220_PatientFPKM.xlsx")
expr_cols_78220 <- colnames(fpkm78220)[-1]
cat("\nExpression matrix columns, first 6:\n"); print(head(expr_cols_78220, 6))

cat("\nDirect match, title vs expression columns:",
    sum(pheno78220$title %in% expr_cols_78220), "of", nrow(pheno78220), "\n")
cat("Direct match, description vs expression columns:",
    sum(pheno78220$description %in% expr_cols_78220), "of", nrow(pheno78220), "\n")

on_tx <- pheno78220[pheno78220[["biopsy time:ch1"]] == "on-treatment", ]
cat("\nOn-treatment sample (to be EXCLUDED):\n")
print(on_tx[, c("title", "description", "patient id:ch1", "anti-pd-1 response:ch1", "biopsy time:ch1")])

pre78220 <- pheno78220[pheno78220[["biopsy time:ch1"]] == "pre-treatment", ]
cat("\nFinal GSE78220 pre-treatment-only response tally:\n")
print(table(pre78220[["anti-pd-1 response:ch1"]]))

# ---- GSE91061: verify join key, patient extraction, response binarization ----
cat("\n\n=== GSE91061 join key ===\n")
gse91061_meta <- getGEO(filename = "data/raw/GSE91061/GSE91061_series_matrix.txt.gz",
                         GSEMatrix = TRUE, getGPL = FALSE)
pheno91061 <- pData(gse91061_meta)
cat("title column, first 6:\n"); print(head(pheno91061$title, 6))

fpkm91061 <- fread("data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.fpkm.csv.gz")
expr_cols_91061 <- colnames(fpkm91061)[-1]
cat("\nExpression matrix columns, first 6:\n"); print(head(expr_cols_91061, 6))
cat("\nDirect match, title vs expression columns:",
    sum(pheno91061$title %in% expr_cols_91061), "of", nrow(pheno91061), "\n")

pheno91061$patient_id <- sub("_.*$", "", pheno91061$title)
cat("\nExtracted patient IDs, first 6:\n"); print(head(pheno91061$patient_id, 6))
cat("Unique patients:", length(unique(pheno91061$patient_id)), "\n")

pre91061 <- pheno91061[pheno91061[["visit (pre or on treatment):ch1"]] == "Pre", ]
cat("\nGSE91061 pre-treatment-only: ", nrow(pre91061), "samples,",
    length(unique(pre91061$patient_id)), "unique patients\n")
cat("Any patient appearing more than once in the pre-treatment-only set?",
    any(table(pre91061$patient_id) > 1), "\n")
cat("\nResponse tally, pre-treatment-only (before excluding UNK):\n")
print(table(pre91061[["response:ch1"]]))
cat("\nProposed binarization: Responder = PRCR; Non-responder = PD + SD; Excluded = UNK.\n")
cat("Resulting N: Responder =", sum(pre91061[["response:ch1"]] == "PRCR"),
    "| Non-responder =", sum(pre91061[["response:ch1"]] %in% c("PD", "SD")),
    "| Excluded (UNK) =", sum(pre91061[["response:ch1"]] == "UNK"), "\n")

# ---- Entrez-to-symbol mapping availability ----
cat("\n\n=== Entrez-to-symbol mapping resource check ===\n")
has_orgdb <- requireNamespace("org.Hs.eg.db", quietly = TRUE)
cat("org.Hs.eg.db available:", has_orgdb, "\n")
if (!has_orgdb) {
  cat("NOT installed -- would need renv::install('bioc::org.Hs.eg.db') before Step 3.\n")
} else {
  suppressPackageStartupMessages(library(org.Hs.eg.db))
  test_ids <- head(fpkm91061[[1]], 5)
  mapped <- AnnotationDbi::select(org.Hs.eg.db, keys = as.character(test_ids),
                                   keytype = "ENTREZID", columns = "SYMBOL")
  cat("Test mapping (first 5 Entrez IDs from the actual file):\n")
  print(mapped)
}

cat("\n=== Join-key and mapping check complete. ===\n")
