# Figure 5 (H5, confirmatory): gene-level (Panel A, H5a) and TF-module-level (Panel B, H5b)
# replication forest plots. Deliberately restrained in scope -- confirmatory results only
# (discovery-cohort estimate + the two validation cohorts' estimates and CIs), no broader
# biological synthesis, per the project owner's explicit instruction. Any such synthesis
# belongs in 09_synthesis, after H5 (including H5c) is complete.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
})
source("R/theme_project.R")

# ggplot does not auto-wrap plot.title/plot.subtitle -- long text overflows the panel edge
# uncorrected. Same failure mode already documented for Figure 1 and fixed for Figure 4;
# checked here before sending anything to Priya, not assumed fine because "no error".
wrap_text <- function(x, width) paste(strwrap(x, width = width), collapse = "\n")

cohort_colors <- c("GSE120575 (H1 discovery)" = unname(PROJECT_COLORS["highlight"]),
                   "GSE120575 (H4 discovery)" = unname(PROJECT_COLORS["highlight"]),
                   "GSE78220" = unname(PROJECT_COLORS["neutral"]),
                   "GSE91061" = unname(PROJECT_COLORS["gse72056"]))

forest_panel <- function(plot_data, facet_var, facet_labels, title, subtitle) {
  ggplot(plot_data, aes(x = logFC, y = cohort, color = cohort)) +
    geom_vline(xintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), orientation = "y", width = 0.18, linewidth = 0.5) +
    geom_point(aes(shape = sig), size = 3) +
    scale_shape_manual(values = c(`TRUE` = 16, `FALSE` = 1),
                       labels = c(`TRUE` = "P < 0.05", `FALSE` = "P >= 0.05"), name = NULL) +
    scale_color_manual(values = cohort_colors, guide = "none") +
    facet_wrap(as.formula(paste("~", facet_var)), ncol = 1,
               labeller = labeller(.default = facet_labels), scales = "free_x") +
    labs(title = title, subtitle = wrap_text(subtitle, 95),
         x = "log2 fold change (non-responder vs responder)", y = NULL) +
    theme_project() +
    theme(legend.position = "bottom", strip.text = element_text(face = "bold", hjust = 0))
}

# ==== Panel A: H5a, gene-level replication ================================================
target_genes <- c("LTB", "CCL3", "CCL4", "CXCL13")

h1 <- read.csv("results/h1_discovery_screen_ranked.csv")
h1_sub <- h1[h1$gene %in% target_genes, c("gene", "logFC", "t", "P.Value")]
h1_sub$cohort <- "GSE120575 (H1 discovery)"

h5a <- readRDS("results/h5a_gene_replication.rds")
h5a_sub <- h5a$combined[, c("gene", "cohort", "logFC", "t", "P.Value")]

gene_data <- bind_rows(h1_sub, h5a_sub)
gene_data$se <- gene_data$logFC / gene_data$t
gene_data$ci_lo <- gene_data$logFC - 1.96 * gene_data$se
gene_data$ci_hi <- gene_data$logFC + 1.96 * gene_data$se
gene_data$sig <- gene_data$P.Value < 0.05
gene_data$cohort <- factor(gene_data$cohort,
                           levels = c("GSE91061", "GSE78220", "GSE120575 (H1 discovery)"))
gene_data$gene <- factor(gene_data$gene, levels = target_genes)

gene_verdict <- h5a$verdict
gene_verdict_short <- ifelse(grepl("EXPLORATORY", gene_verdict$verdict), "Exploratory",
                       ifelse(grepl("NEGATIVE", gene_verdict$verdict), "Negative finding", "?"))
gene_labels <- setNames(paste0(gene_verdict$gene, "  (", gene_verdict_short, ")"),
                         gene_verdict$gene)

panel_A <- forest_panel(
  gene_data, "gene", gene_labels,
  "A. H5a - gene-level replication",
  paste0("H1's 4 FDR<0.05 hits tested for replication in 2 independent bulk cohorts. ",
         "Point: log2FC estimate (positive = higher in non-responder). ",
         "Bars: 95% CI. Verdict requires concordant direction AND significance (see README).")
)

# ==== Panel B: H5b, TF-module-level replication ============================================
h5b <- readRDS("results/h5b_tf_module_replication.rds")

# H4's own discovery-cohort module-level estimate: mean of member TFs' primary activity
# scores, tested the same way (limma), for a like-for-like reference point alongside H5b's
# two validation cohorts -- computed from H4's already-committed primary summary object, not
# a new analysis.
h4_summary <- readRDS("results/h4_tf_activity_summary.rds")
module_h4_score <- function(tfs) {
  present <- intersect(tfs, rownames(h4_summary$score_mat))
  colMeans(h4_summary$score_mat[present, , drop = FALSE])
}
m1_h4 <- module_h4_score(h5b$module1_tfs)
m2_h4 <- module_h4_score(h5b$module2_tfs)
resp_h4 <- factor(h4_summary$patient_response[names(m1_h4)], levels = c("Responder", "Non-responder"))
design_h4 <- model.matrix(~resp_h4)
fit_h4 <- limma::eBayes(limma::lmFit(rbind(Module1 = m1_h4, Module2 = m2_h4), design_h4))
tt_h4 <- limma::topTable(fit_h4, coef = "resp_h4Non-responder", number = Inf, sort.by = "none")
tt_h4$module <- rownames(tt_h4)
tt_h4$cohort <- "GSE120575 (H4 discovery)"

module_data <- bind_rows(
  tt_h4[, c("cohort", "module", "logFC", "t", "P.Value")],
  h5b$combined[, c("cohort", "module", "logFC", "t", "P.Value")]
)
module_data$se <- module_data$logFC / module_data$t
module_data$ci_lo <- module_data$logFC - 1.96 * module_data$se
module_data$ci_hi <- module_data$logFC + 1.96 * module_data$se
module_data$sig <- module_data$P.Value < 0.05
module_data$cohort <- factor(module_data$cohort,
                             levels = c("GSE91061", "GSE78220", "GSE120575 (H4 discovery)"))
module_data$module <- factor(module_data$module, levels = c("Module1", "Module2"))

module_verdict <- h5b$verdict
module_verdict_short <- ifelse(grepl("NEGATIVE", module_verdict$verdict), "Negative finding",
                         ifelse(grepl("EXPLORATORY", module_verdict$verdict), "Exploratory", "?"))
module_labels <- setNames(
  paste0(c("Module 1 (metabolic/NR)", "Module 2 (E2F)"), "  (", module_verdict_short, ")"),
  module_verdict$module)

panel_B <- forest_panel(
  module_data, "module", module_labels,
  "B. H5b - TF-activity module-level replication",
  paste0("H4's 2 named non-responder-elevated modules tested for replication. ",
         "Point: log2FC estimate (positive = higher in non-responder). ",
         "Bars: 95% CI. Verdict requires concordant direction AND significance (see README).")
)

# ==== compose ================================================================================
figure5 <- panel_A / panel_B +
  plot_layout(heights = c(2, 1)) +
  plot_annotation(
    title = "Figure 5. H5 - confirmatory independent-cohort replication",
    caption = wrap_text(paste0(
      "Panel A: 1 of 4 genes (LTB) Exploratory, 3 (CCL3/CCL4/CXCL13) Negative finding. ",
      "Panel B: both modules Negative finding. All reversals occur specifically in GSE91061. ",
      "No broader synthesis drawn here -- see 09_synthesis. See 07_validation_concordance/README.md."),
      150),
    theme = theme_project()
  )

save_figure(figure5, "figures/figure5_h5_validation", width = 8, height = 14)
