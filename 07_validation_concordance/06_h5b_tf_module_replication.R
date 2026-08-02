# H5b (confirmatory): does replication hold at the TF-MODULE level for H4's two named,
# non-responder-elevated modules? Pre-registered in CHANGELOG.md before this script was
# written: modules, cohorts, statistical approach, and grading rubric are fixed in advance.
# Module-level score ONLY -- NOT a 56-TF re-screen, which would be a new discovery search in
# validation data and is explicitly excluded by the pre-registration.
#
# Module membership is locked from H4 (06_regulation_communication/README.md), copied here
# verbatim, not re-derived:
#   Module 1 (21 TFs, all higher in non-responder in the discovery cohort): metabolic/
#     nuclear-receptor cluster.
#   Module 2 (13 TFs, all higher in non-responder in the discovery cohort): E2F cell-cycle/
#     proliferation cluster.
# Expected direction for both modules, per H4's own result: positive (higher in
# non-responder). This is the only reference direction needed for the concordance check --
# no need to re-load H4's raw per-TF scores, since every member of both modules already
# shares this one direction by construction (H4 README).
#
# Method notes (finalized here, not pre-decided, since this depends on how TF activity scores
# relate to each cohort's data type -- consistent with, not contradicting, H5a's pre-
# registration): the per-cohort data-type-driven method choice (limma-on-FPKM vs voom-on-
# counts, CHANGELOG.md) governs GENE-LEVEL tests on raw/FPKM expression (H5a). TF-activity
# module scores are already a continuous, model-derived quantity once computed by
# decoupleR::run_ulm() -- exactly like H4's own primary analysis, which used limma uniformly
# on activity scores regardless of the underlying expression data's own type. H5b therefore
# uses limma::lmFit/eBayes on module scores for BOTH cohorts. Where a cohort's own raw counts
# require normalization before TF-activity inference (GSE91061), edgeR's TMM + log-CPM is
# used to build run_ulm()'s input matrix -- this is normalization prep, not the final test.
#
# STANDING RULE (unchanged from H5a): a replication verdict requires BOTH concordant
# direction AND statistical significance (FDR<0.05, BH across the 2 pre-specified modules
# within each cohort) -- neither alone establishes replication.

module1_tfs <- c("SREBF1", "BACH1", "SREBF2", "KLF15", "PARK7", "TFAP2A", "DNMT1", "CEBPA",
                  "PPARA", "PDX1", "ESR1", "NR1H4", "NFE2L2", "VDR", "CEBPZ", "EP300", "SP3",
                  "EHF", "CEBPE", "SP2", "MNT")
module2_tfs <- c("TLX2", "OLIG2", "STOX1", "SMARCA1", "E2F5", "SIM2", "E2F4", "E2F1", "E2F3",
                  "POU1F1", "ARID3B", "E2F2", "HCFC1")

net <- readRDS("data/processed/collectri_human_verified.rds")

score_module <- function(act, module_tfs, label) {
  present <- intersect(module_tfs, unique(act$source))
  cat(label, "coverage:", length(present), "of", length(module_tfs), "TFs scored\n")
  if (length(present) < length(module_tfs)) {
    cat("  Missing:", paste(setdiff(module_tfs, present), collapse = ", "), "\n")
  }
  sub <- act[act$source %in% present, ]
  # mean activity across the module's present members, per sample
  tapply(sub$score, sub$condition, mean)
}

# =========================================================================================
# GSE78220 -- limma on log2(FPKM+1), decoupleR input = same log2(FPKM+1) matrix
# =========================================================================================
suppressPackageStartupMessages({
  library(GEOquery)
  library(readxl)
  library(limma)
  library(decoupleR)
})

cat("=== GSE78220 ===\n")
pheno78220 <- pData(getGEO(filename = "data/raw/GSE78220/GSE78220_series_matrix.txt.gz",
                            GSEMatrix = TRUE, getGPL = FALSE))
pre78220 <- pheno78220[pheno78220[["biopsy time:ch1"]] == "pre-treatment", ]

fpkm <- as.data.frame(read_excel("data/raw/GSE78220/GSE78220_PatientFPKM.xlsx"))
rownames(fpkm) <- fpkm$Gene
fpkm$Gene <- NULL

match_col <- function(title) {
  hits <- grep(paste0("^", title, "\\."), colnames(fpkm), value = TRUE)
  stopifnot("Ambiguous or missing FPKM column match" = length(hits) == 1)
  hits
}
pre78220$fpkm_col <- vapply(pre78220$title, match_col, character(1))
expr78220 <- fpkm[, pre78220$fpkm_col]
colnames(expr78220) <- pre78220$title
log_expr_78220 <- log2(expr78220 + 1)
cat("Expression matrix:", nrow(log_expr_78220), "genes x", ncol(log_expr_78220), "samples\n")

resp_raw_78220 <- pre78220[["anti-pd-1 response:ch1"]]
response_78220 <- ifelse(resp_raw_78220 %in% c("Complete Response", "Partial Response"), "Responder",
                    ifelse(resp_raw_78220 == "Progressive Disease", "Non-responder", NA))
names(response_78220) <- pre78220$title
cat("Response tally:\n"); print(table(response_78220))

act_78220 <- run_ulm(mat = as.matrix(log_expr_78220), network = net, minsize = 5)
cat("TFs scored:", length(unique(act_78220$source)), "\n")

m1_78220 <- score_module(act_78220, module1_tfs, "Module 1")
m2_78220 <- score_module(act_78220, module2_tfs, "Module 2")

module_scores_78220 <- rbind(Module1 = m1_78220, Module2 = m2_78220)
resp_78220 <- factor(response_78220[colnames(module_scores_78220)],
                      levels = c("Responder", "Non-responder"))
design_78220 <- model.matrix(~resp_78220)
fit_78220 <- eBayes(lmFit(module_scores_78220, design_78220))
tt_78220 <- topTable(fit_78220, coef = "resp_78220Non-responder", number = Inf, sort.by = "none")
tt_78220$module <- rownames(tt_78220)
tt_78220$cohort <- "GSE78220"
cat("\nGSE78220 module-level results:\n"); print(tt_78220[, c("module", "logFC", "t", "P.Value")])

# =========================================================================================
# GSE91061 -- TMM+log-CPM for decoupleR input, limma on module scores
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

raw91061 <- fread("data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.raw.csv.gz")
entrez_ids <- as.character(raw91061[[1]])
count_mat <- as.matrix(raw91061[, -1])
storage.mode(count_mat) <- "numeric"
rownames(count_mat) <- entrez_ids
count_mat <- count_mat[, pre91061$title]

# Entrez -> symbol, full matrix this time (not just 4 genes). Duplicate symbols (multiple
# Entrez IDs mapping to the same gene, e.g. stale/alias entries) are collapsed by keeping the
# row with the higher mean expression -- a standard, disclosed convention, not silently
# resolved.
map_full <- AnnotationDbi::select(org.Hs.eg.db, keys = rownames(count_mat),
                                   keytype = "ENTREZID", columns = "SYMBOL")
map_full <- map_full[!is.na(map_full$SYMBOL), ]
cat("Entrez IDs mapped to a symbol:", nrow(map_full), "of", nrow(count_mat), "\n")
mean_expr <- rowMeans(count_mat[map_full$ENTREZID, , drop = FALSE])
map_full$mean_expr <- mean_expr
map_full <- map_full[order(map_full$SYMBOL, -map_full$mean_expr), ]
n_dup <- sum(duplicated(map_full$SYMBOL))
cat("Duplicate symbol mappings collapsed (kept higher-mean-expression row):", n_dup, "\n")
map_full <- map_full[!duplicated(map_full$SYMBOL), ]

count_mat_sym <- count_mat[map_full$ENTREZID, ]
rownames(count_mat_sym) <- map_full$SYMBOL
cat("Symbol-mapped count matrix:", nrow(count_mat_sym), "genes x", ncol(count_mat_sym), "samples\n")

response_91061 <- ifelse(pre91061[["response:ch1"]] == "PRCR", "Responder",
                    ifelse(pre91061[["response:ch1"]] %in% c("PD", "SD"), "Non-responder", NA))
names(response_91061) <- pre91061$title
cat("Response tally:\n"); print(table(response_91061))

dge <- DGEList(counts = count_mat_sym)
keep <- filterByExpr(dge, group = response_91061[colnames(dge)])
dge <- dge[keep, , keep.lib.sizes = FALSE]
dge <- calcNormFactors(dge)
cat("Genes retained after filterByExpr:", nrow(dge), "of", nrow(count_mat_sym), "\n")
log_cpm_91061 <- cpm(dge, log = TRUE)

act_91061 <- run_ulm(mat = log_cpm_91061, network = net, minsize = 5)
cat("TFs scored:", length(unique(act_91061$source)), "\n")

m1_91061 <- score_module(act_91061, module1_tfs, "Module 1")
m2_91061 <- score_module(act_91061, module2_tfs, "Module 2")

module_scores_91061 <- rbind(Module1 = m1_91061, Module2 = m2_91061)
resp_91061 <- factor(response_91061[colnames(module_scores_91061)],
                      levels = c("Responder", "Non-responder"))
design_91061 <- model.matrix(~resp_91061)
fit_91061 <- eBayes(lmFit(module_scores_91061, design_91061))
tt_91061 <- topTable(fit_91061, coef = "resp_91061Non-responder", number = Inf, sort.by = "none")
tt_91061$module <- rownames(tt_91061)
tt_91061$cohort <- "GSE91061"
cat("\nGSE91061 module-level results:\n"); print(tt_91061[, c("module", "logFC", "t", "P.Value")])

# =========================================================================================
# Combine and apply the pre-registered, direction+significance joint verdict
# =========================================================================================
combined <- rbind(tt_78220[, c("cohort", "module", "logFC", "t", "P.Value")],
                   tt_91061[, c("cohort", "module", "logFC", "t", "P.Value")])
combined$fdr_h5 <- ave(combined$P.Value, combined$cohort, FUN = function(p) p.adjust(p, method = "BH"))
combined$expected_direction <- 1  # both modules: higher in non-responder, per H4
combined$concordant_direction <- sign(combined$logFC) == combined$expected_direction
combined$significant <- combined$fdr_h5 < 0.05
combined <- combined[order(combined$module, combined$cohort), ]
cat("\n\n=== H5b combined result ===\n")
print(combined[, c("module", "cohort", "logFC", "P.Value", "fdr_h5",
                    "concordant_direction", "significant")])

verdict <- vapply(c("Module1", "Module2"), function(m) {
  sub <- combined[combined$module == m, ]
  if (any(!sub$concordant_direction)) return("NEGATIVE FINDING (opposite direction in >=1 cohort)")
  if (all(sub$significant)) return("STRONG (concordant direction + significant in both)")
  if (any(sub$significant)) return("MODERATE (concordant direction, significant in >=1 cohort)")
  "EXPLORATORY (concordant direction, not significant in either)"
}, character(1))
verdict_df <- data.frame(module = c("Module1", "Module2"), verdict = verdict)
cat("\n=== Per-module H5b verdict (pre-registered rubric, direction+significance jointly) ===\n")
print(verdict_df)

saveRDS(list(combined = combined, verdict = verdict_df,
             module1_tfs = module1_tfs, module2_tfs = module2_tfs,
             act_78220 = act_78220, act_91061 = act_91061),
        "results/h5b_tf_module_replication.rds")
write.csv(combined, "results/h5b_tf_module_replication_combined.csv", row.names = FALSE)
cat("\nSaved: results/h5b_tf_module_replication_combined.csv, results/h5b_tf_module_replication.rds\n")
