# Decisive check: is T_cell's 76.8% hit rate genuine T-cell-localized biology, or is it
# because T cells dominate the whole-sample pseudobulk (69%, per 03_recruitment/README.md)
# that PRODUCED these 56 TFs as hits in the first place -- making the "T_cell compartment"
# secondary test a near-redundant echo of the primary test, not an independent result.
# Directly tested: correlate each compartment's logFC (56 locked TFs) against the primary
# whole-sample logFC for the same TFs. Near-1 correlation for T_cell but not NK/B_cell would
# confirm the redundancy concern; similar correlations across all three would argue against it.

primary <- read.csv("results/h4_tf_activity_ranked.csv")
secondary <- read.csv("results/h4_secondary_compartment_tf_activity.csv")

hit_tfs <- primary$TF[primary$adj.P.Val < 0.05]
primary_sub <- primary[primary$TF %in% hit_tfs, c("TF", "logFC")]
colnames(primary_sub)[2] <- "primary_logFC"

for (comp in c("T_cell", "NK", "B_cell")) {
  sub <- secondary[secondary$compartment == comp, c("TF", "logFC")]
  merged <- merge(primary_sub, sub, by = "TF")
  r <- cor(merged$primary_logFC, merged$logFC, method = "pearson")
  cat(comp, ": Pearson r (primary whole-sample logFC vs compartment logFC) =", round(r, 3), "\n")
}

cat("\nFor reference: H1's README states the whole-sample pseudobulk is 69% T-cell composition.\n")
