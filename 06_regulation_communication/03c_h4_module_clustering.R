# H4 Step 4 (continued): module-clustering characterization of the primary TF-activity hit
# list. The audit (03b_h4_audit.R) found substantial p-value enrichment (41% of all 754 tested
# TFs in raw P<0.1) driven by regulon redundancy -- TF families sharing overlapping CollecTRI
# target genes (E2F1-5, IRF2/3/5/6/7/8/9, SP1/2/3, STAT1/3/5B, etc. all appeared together with
# the same direction) produce correlated activity scores. Reporting "56 significant TFs" at
# face value would overstate the finding as 56 independent regulatory signals. This script
# quantifies how many effectively distinct programs the 56 FDR<0.05 hits actually represent,
# using two complementary methods so the answer isn't a single cherry-picked cutoff:
#  1. Hierarchical clustering on pairwise correlation of each TF's activity-score profile
#     across the 19 patients, reported at multiple cut heights -- for interpretable, named
#     modules.
#  2. Nyholt's (2004, Am J Hum Genet) eigenvalue-based effective-number-of-independent-tests
#     method, applied to the same correlation matrix -- for a single, quantified,
#     non-arbitrary summary number.

summary_obj <- readRDS("results/h4_tf_activity_summary.rds")
results   <- summary_obj$results
score_mat <- summary_obj$score_mat

sig05 <- results[results$adj.P.Val < 0.05, ]
cat("Characterizing", nrow(sig05), "TFs significant at FDR<0.05\n")

hit_mat <- score_mat[sig05$TF, , drop = FALSE]
stopifnot("Row count mismatch after subsetting to significant TFs" = nrow(hit_mat) == nrow(sig05))

# --- pairwise correlation of activity-score profiles across the 19 patients ---
cor_mat <- cor(t(hit_mat), method = "pearson")

# --- 1. hierarchical clustering, multiple cut heights reported (not a single chosen cutoff) ---
dist_mat <- as.dist(1 - cor_mat)
hc <- hclust(dist_mat, method = "average")

for (r_cut in c(0.9, 0.8, 0.7)) {
  clusters <- cutree(hc, h = 1 - r_cut)
  cat("\n--- Modules at r >", r_cut, "cutoff:", length(unique(clusters)), "clusters ---\n")
  for (cl in sort(unique(clusters))) {
    members <- names(clusters)[clusters == cl]
    if (length(members) > 1) {
      dirs <- sign(sig05$logFC[match(members, sig05$TF)])
      dir_label <- if (length(unique(dirs)) == 1) {
        if (dirs[1] > 0) "all higher in Non-responder" else "all higher in Responder"
      } else {
        "MIXED direction -- flag"
      }
      cat(" Module", cl, "(", length(members), "TFs):", paste(members, collapse = ", "),
          "|", dir_label, "\n")
    }
  }
  cat(" Singleton (unclustered) TFs at this cutoff:", sum(table(clusters) == 1), "\n")
}

# --- 2. Nyholt (2004) effective number of independent tests, eigenvalue-based ---
eig <- eigen(cor_mat, symmetric = TRUE, only.values = TRUE)$values
eig[eig < 0] <- 0  # guard tiny negative eigenvalues from numerical noise
M <- length(eig)
Meff <- 1 + (M - 1) * (1 - var(eig) / M)
cat("\n--- Effective number of independent tests (Nyholt 2004) ---\n")
cat("Nominal significant TFs:", M, "| Effective independent regulatory programs (Meff):",
    round(Meff, 1), "\n")

saveRDS(list(cor_mat = cor_mat, hc = hc, Meff = Meff, sig05 = sig05),
        "results/h4_tf_module_clustering.rds")
cat("\nSaved: results/h4_tf_module_clustering.rds\n")
