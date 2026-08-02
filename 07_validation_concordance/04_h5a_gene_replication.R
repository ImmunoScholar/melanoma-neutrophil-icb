# H5a (confirmatory): does H1's FDR<0.05 gene panel (LTB, CCL3, CCL4, CXCL13) replicate in
# two independent bulk cohorts? Pre-registered in CHANGELOG.md before this script was written
# -- genes, cohorts, methods, and grading rubric are all fixed in advance; nothing here was
# chosen after seeing results.
#
# Statistical method is per-cohort, forced by each cohort's actual verified data type (see
# CHANGELOG.md): GSE78220 (FPKM-only) uses limma on log2(FPKM+1), same justification as H1;
# GSE91061 (true raw counts available) uses edgeR/voom, the statistically correct tool for
# count data, not limma-on-FPKM for superficial cross-cohort uniformity.
#
# Direction convention matches H1 exactly: positive logFC = higher in non-responder.
#
# Background genes (beyond the 4 pre-specified) are included ONLY so limma's eBayes
# moderation / edgeR's TMM normalization have a realistic gene population to work from --
# they are never examined, tested, or reported individually. Only the 4 pre-specified genes
# are extracted from each fit and interpreted. This is not a new discovery search.
#
# STANDING RULE (binding, added at the project owner's instruction): a replication verdict
# requires BOTH concordant effect direction AND statistical significance at the pre-defined
# threshold (FDR<0.05, BH across the 4 pre-specified genes within each cohort) -- neither
# alone establishes replication.

target_genes <- c("LTB", "CCL3", "CCL4", "CXCL13")

# =========================================================================================
# GSE78220 (Hugo et al.) -- limma on log2(FPKM+1)
# =========================================================================================
suppressPackageStartupMessages({
  library(GEOquery)
  library(readxl)
  library(limma)
})

cat("=== GSE78220 ===\n")
pheno78220 <- pData(getGEO(filename = "data/raw/GSE78220/GSE78220_series_matrix.txt.gz",
                            GSEMatrix = TRUE, getGPL = FALSE))
pre78220 <- pheno78220[pheno78220[["biopsy time:ch1"]] == "pre-treatment", ]
cat("Pre-treatment N:", nrow(pre78220), "\n")

fpkm <- as.data.frame(read_excel("data/raw/GSE78220/GSE78220_PatientFPKM.xlsx"))
rownames(fpkm) <- fpkm$Gene
fpkm$Gene <- NULL

# Join key verified in Step 2/3 audit: title ("Pt16") does not match FPKM columns
# ("Pt16.baseline") directly -- constructed via patient-ID substring match, not assumed.
match_col <- function(title) {
  hits <- grep(paste0("^", title, "\\."), colnames(fpkm), value = TRUE)
  stopifnot("Ambiguous or missing FPKM column match for a pre-treatment sample" = length(hits) == 1)
  hits
}
pre78220$fpkm_col <- vapply(pre78220$title, match_col, character(1))
stopifnot("Duplicate FPKM column matches" = !any(duplicated(pre78220$fpkm_col)))

expr78220 <- fpkm[, pre78220$fpkm_col]
colnames(expr78220) <- pre78220$title
cat("Expression matrix:", nrow(expr78220), "genes x", ncol(expr78220), "samples\n")
stopifnot("Pre-specified genes missing from GSE78220 FPKM matrix entirely" =
  all(target_genes %in% rownames(expr78220)))

# Response binarization, pre-registered: CR+PR = Responder, PD = Non-responder
resp_raw_78220 <- pre78220[["anti-pd-1 response:ch1"]]
response_78220 <- ifelse(resp_raw_78220 %in% c("Complete Response", "Partial Response"), "Responder",
                    ifelse(resp_raw_78220 == "Progressive Disease", "Non-responder", NA))
stopifnot("Unmapped response category in GSE78220" = !anyNA(response_78220))
names(response_78220) <- pre78220$title
cat("Response tally:\n"); print(table(response_78220))

log_expr_78220 <- log2(expr78220 + 1)
# Background filter for eBayes moderation only -- the 4 pre-specified genes are always
# force-included regardless of this filter, so they can never be silently dropped.
keep_78220 <- rowMeans(expr78220 > 1) >= 0.2 | rownames(expr78220) %in% target_genes
cat("Background genes retained (FPKM>1 in >=20% of samples, plus the 4 forced-included):",
    sum(keep_78220), "of", nrow(expr78220), "\n")
log_expr_78220_filt <- log_expr_78220[keep_78220, ]

resp_78220 <- factor(response_78220[colnames(log_expr_78220_filt)],
                      levels = c("Responder", "Non-responder"))
design_78220 <- model.matrix(~resp_78220)
fit_78220 <- eBayes(lmFit(log_expr_78220_filt, design_78220))

tt_78220 <- topTable(fit_78220, coef = "resp_78220Non-responder", number = Inf, sort.by = "none")
results_78220 <- tt_78220[target_genes, c("logFC", "t", "P.Value")]
results_78220$gene <- rownames(results_78220)
results_78220$fdr_h5 <- p.adjust(results_78220$P.Value, method = "BH")
results_78220$cohort <- "GSE78220"
cat("\nGSE78220 results (4 pre-specified genes only):\n")
print(results_78220)

# =========================================================================================
# GSE91061 (Riaz et al.) -- edgeR/voom on raw counts
# =========================================================================================
suppressPackageStartupMessages({
  library(data.table)
  library(edgeR)
  library(org.Hs.eg.db)
})

cat("\n\n=== GSE91061 ===\n")
pheno91061 <- pData(getGEO(filename = "data/raw/GSE91061/GSE91061_series_matrix.txt.gz",
                            GSEMatrix = TRUE, getGPL = FALSE))
pheno91061$patient_id <- sub("_.*$", "", pheno91061$title)
pre91061 <- pheno91061[pheno91061[["visit (pre or on treatment):ch1"]] == "Pre" &
                        pheno91061[["response:ch1"]] %in% c("PRCR", "PD", "SD"), ]
cat("Pre-treatment, response-labeled N (UNK excluded):", nrow(pre91061), "\n")
stopifnot("Duplicate patients in GSE91061 usable set" = !any(duplicated(pre91061$patient_id)))

raw91061 <- fread("data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.raw.csv.gz")
entrez_ids <- as.character(raw91061[[1]])
count_mat <- as.matrix(raw91061[, -1])
rownames(count_mat) <- entrez_ids
storage.mode(count_mat) <- "numeric"

stopifnot("Join key mismatch: GSE91061 phenotype title not found in count matrix columns" =
  all(pre91061$title %in% colnames(count_mat)))
count_mat <- count_mat[, pre91061$title]
cat("Raw count matrix:", nrow(count_mat), "genes x", ncol(count_mat), "samples\n")

# Entrez -> symbol mapping, verified working in Step 3 audit (1->A1BG, 10->NAT2, etc.)
gene_map <- AnnotationDbi::select(org.Hs.eg.db, keys = target_genes,
                                   keytype = "SYMBOL", columns = "ENTREZID")
cat("\nTarget-gene Entrez mapping:\n"); print(gene_map)
stopifnot(
  "Missing or ambiguous Entrez mapping for a pre-specified gene" =
    !anyNA(gene_map$ENTREZID) && !any(duplicated(gene_map$SYMBOL)),
  "A pre-specified gene's Entrez ID is not present in the GSE91061 count matrix" =
    all(gene_map$ENTREZID %in% rownames(count_mat))
)

response_91061 <- ifelse(pre91061[["response:ch1"]] == "PRCR", "Responder",
                    ifelse(pre91061[["response:ch1"]] %in% c("PD", "SD"), "Non-responder", NA))
names(response_91061) <- pre91061$title
cat("Response tally:\n"); print(table(response_91061))

dge <- DGEList(counts = count_mat)
keep_91061 <- filterByExpr(dge, group = response_91061[colnames(dge)]) | rownames(dge) %in% gene_map$ENTREZID
dge <- dge[keep_91061, , keep.lib.sizes = FALSE]
dge <- calcNormFactors(dge)
cat("Genes retained after filterByExpr (plus the 4 forced-included):", nrow(dge), "of",
    nrow(count_mat), "\n")

resp_91061 <- factor(response_91061[colnames(dge)], levels = c("Responder", "Non-responder"))
design_91061 <- model.matrix(~resp_91061)
v_91061 <- voom(dge, design_91061)
fit_91061 <- eBayes(lmFit(v_91061, design_91061))

tt_91061 <- topTable(fit_91061, coef = "resp_91061Non-responder", number = Inf, sort.by = "none")
results_91061 <- tt_91061[gene_map$ENTREZID, c("logFC", "t", "P.Value")]
results_91061$gene <- gene_map$SYMBOL[match(rownames(results_91061), gene_map$ENTREZID)]
results_91061$fdr_h5 <- p.adjust(results_91061$P.Value, method = "BH")
results_91061$cohort <- "GSE91061"
cat("\nGSE91061 results (4 pre-specified genes only):\n")
print(results_91061)

# =========================================================================================
# Combine and apply the pre-registered, direction+significance joint verdict
# =========================================================================================
h1 <- read.csv("results/h1_discovery_screen_ranked.csv")
h1_sub <- h1[h1$gene %in% target_genes, c("gene", "logFC")]
colnames(h1_sub) <- c("gene", "h1_logFC")
stopifnot("H1 reference logFC missing for a pre-specified gene" = nrow(h1_sub) == 4)

combined <- rbind(
  results_78220[, c("cohort", "gene", "logFC", "t", "P.Value", "fdr_h5")],
  results_91061[, c("cohort", "gene", "logFC", "t", "P.Value", "fdr_h5")]
)
combined <- merge(combined, h1_sub, by = "gene")
combined$concordant_direction <- sign(combined$logFC) == sign(combined$h1_logFC)
combined$significant <- combined$fdr_h5 < 0.05
combined <- combined[order(combined$gene, combined$cohort), ]
cat("\n\n=== H5a combined result ===\n")
print(combined[, c("gene", "cohort", "h1_logFC", "logFC", "P.Value", "fdr_h5",
                    "concordant_direction", "significant")])

verdict <- vapply(target_genes, function(g) {
  sub <- combined[combined$gene == g, ]
  if (any(!sub$concordant_direction)) return("NEGATIVE FINDING (opposite direction in >=1 cohort)")
  if (all(sub$significant)) return("STRONG (concordant direction + significant in both)")
  if (any(sub$significant)) return("MODERATE (concordant direction, significant in >=1 cohort)")
  "EXPLORATORY (concordant direction, not significant in either)"
}, character(1))
verdict_df <- data.frame(gene = target_genes, verdict = verdict)
cat("\n=== Per-gene H5a verdict (pre-registered rubric, direction+significance jointly) ===\n")
print(verdict_df)

saveRDS(list(combined = combined, verdict = verdict_df,
             results_78220 = results_78220, results_91061 = results_91061),
        "results/h5a_gene_replication.rds")
write.csv(combined, "results/h5a_gene_replication_combined.csv", row.names = FALSE)
cat("\nSaved: results/h5a_gene_replication_combined.csv, results/h5a_gene_replication.rds\n")
