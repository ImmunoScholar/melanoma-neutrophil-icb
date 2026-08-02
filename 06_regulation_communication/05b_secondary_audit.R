# Audit of the H4 secondary compartment result before treating it as final -- "no error on
# run" is not sufficient (project standing rule). The raw result shows 44/51 significant hits
# in T_cell, which is also the best-powered compartment (19/19 patients usable, vs NK 16,
# B_cell 11) -- this needs to be distinguished from genuine T-cell-specific biology, not
# assumed one way or the other.

secondary_df <- read.csv("results/h4_secondary_compartment_tf_activity.csv")

cat("--- 1. Hit count vs test count, by compartment (raw rate, not just significant count) ---\n")
tab <- table(secondary_df$compartment)
sig_tab <- table(secondary_df$compartment[secondary_df$fdr_global < 0.05])
rate <- data.frame(compartment = names(tab), tests = as.integer(tab),
                    significant = as.integer(sig_tab[names(tab)]))
rate$significant[is.na(rate$significant)] <- 0
rate$rate <- rate$significant / rate$tests
print(rate)
cat("(If T_cell's higher power alone explained this, we'd expect a similarly elevated RATE,",
    "not just a higher raw count, in whichever compartment has more patients -- but all three",
    "compartments tested the identical 56 TFs, so an equal underlying effect would still show",
    "a rate difference driven by power. This does not distinguish power from biology on its",
    "own -- it just quantifies the pattern precisely instead of eyeballing raw counts.)\n")

cat("\n--- 2. Raw (uncorrected) p-value distribution by compartment ---\n")
for (comp in unique(secondary_df$compartment)) {
  sub <- secondary_df[secondary_df$compartment == comp, ]
  cat(comp, ": n=", nrow(sub), "| median P=", round(median(sub$P.Value), 4),
      "| fraction P<0.05=", round(mean(sub$P.Value < 0.05), 3), "\n")
}

cat("\n--- 3. Direction consistency across compartments for the SAME TF ---\n")
wide <- reshape(secondary_df[, c("compartment", "TF", "logFC")], idvar = "TF",
                 timevar = "compartment", direction = "wide")
sign_mat <- sign(wide[, c("logFC.T_cell", "logFC.NK", "logFC.B_cell")])
consistent <- apply(sign_mat, 1, function(x) length(unique(x[!is.na(x)])) == 1)
cat("TFs with the SAME direction across all 3 compartments:", sum(consistent), "of", nrow(wide), "\n")
cat("(High consistency would suggest one shared underlying signal expressed with different",
    "power/magnitude per compartment, rather than compartment-specific biology -- worth",
    "stating honestly either way.)\n")
