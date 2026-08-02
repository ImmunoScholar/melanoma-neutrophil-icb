# Figure 5 (H5a, confirmatory): gene-level replication forest plot. Deliberately restrained
# in scope -- confirmatory results only (H1 discovery + the two validation cohorts' estimates
# and CIs), no broader biological synthesis, per the project owner's explicit instruction.
# Any such synthesis belongs in 09_synthesis, after H5 is complete.

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})
source("R/theme_project.R")

target_genes <- c("LTB", "CCL3", "CCL4", "CXCL13")

h1 <- read.csv("results/h1_discovery_screen_ranked.csv")
h1_sub <- h1[h1$gene %in% target_genes, c("gene", "logFC", "t", "P.Value")]
h1_sub$cohort <- "GSE120575 (H1 discovery)"

h5 <- readRDS("results/h5a_gene_replication.rds")
h5_sub <- h5$combined[, c("gene", "cohort", "logFC", "t", "P.Value")]

plot_data <- bind_rows(h1_sub, h5_sub)
plot_data$se <- plot_data$logFC / plot_data$t
plot_data$ci_lo <- plot_data$logFC - 1.96 * plot_data$se
plot_data$ci_hi <- plot_data$logFC + 1.96 * plot_data$se
plot_data$sig <- plot_data$P.Value < 0.05

plot_data$cohort <- factor(plot_data$cohort,
                            levels = c("GSE91061", "GSE78220", "GSE120575 (H1 discovery)"))
plot_data$gene <- factor(plot_data$gene, levels = target_genes)

verdict <- h5$verdict
verdict_short <- ifelse(grepl("EXPLORATORY", verdict$verdict), "Exploratory",
                  ifelse(grepl("NEGATIVE", verdict$verdict), "Negative finding", "?"))
gene_labels <- setNames(paste0(verdict$gene, "  (", verdict_short, ")"), verdict$gene)

cohort_colors <- c("GSE120575 (H1 discovery)" = unname(PROJECT_COLORS["highlight"]),
                   "GSE78220" = unname(PROJECT_COLORS["neutral"]),
                   "GSE91061" = unname(PROJECT_COLORS["gse72056"]))

# ggplot does not auto-wrap plot.title/plot.subtitle -- long text overflows the panel edge
# uncorrected. Same failure mode already documented for Figure 1 and fixed for Figure 4;
# checked here before sending anything to Priya, not assumed fine because "no error".
wrap_text <- function(x, width) paste(strwrap(x, width = width), collapse = "\n")

figure5 <- ggplot(plot_data, aes(x = logFC, y = cohort, color = cohort)) +
  geom_vline(xintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), orientation = "y", width = 0.18, linewidth = 0.5) +
  geom_point(aes(shape = sig), size = 3) +
  scale_shape_manual(values = c(`TRUE` = 16, `FALSE` = 1),
                     labels = c(`TRUE` = "P < 0.05", `FALSE` = "P >= 0.05"), name = NULL) +
  scale_color_manual(values = cohort_colors, guide = "none") +
  facet_wrap(~gene, ncol = 1, labeller = labeller(gene = gene_labels), scales = "free_x") +
  labs(title = "Figure 5. H5a - confirmatory gene-level replication",
       subtitle = wrap_text(paste0(
         "H1's 4 FDR<0.05 hits tested for replication in 2 independent bulk cohorts. ",
         "Point: log2FC estimate (positive = higher in non-responder). ",
         "Bars: 95% CI. Verdict requires concordant direction AND significance (see README)."), 95),
       x = "log2 fold change (non-responder vs responder)", y = NULL) +
  theme_project() +
  theme(legend.position = "bottom", strip.text = element_text(face = "bold", hjust = 0))

save_figure(figure5, "figures/figure5_h5a_gene_replication", width = 8, height = 10)
