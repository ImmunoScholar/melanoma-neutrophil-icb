# Figure 4 (H4, primary): patient-level TF-activity analysis. Landscape of all 754 tested
# TFs (A), the correlation/module structure among the 56 FDR<0.05 hits that motivates
# reporting Meff instead of a raw count (B), and per-patient raw activity scores for
# representative TFs from each named module (C) -- same grammar as Figure 2's volcano +
# per-patient panel and Figure 3's ordered heatmap.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
})
source("R/theme_project.R")

results_full <- read.csv("results/h4_tf_activity_ranked.csv")
clust <- readRDS("results/h4_tf_module_clustering.rds")
summary_obj <- readRDS("results/h4_tf_activity_summary.rds")
score_mat <- summary_obj$score_mat
patient_response <- summary_obj$patient_response

dir_colors <- c("Higher in non-responder" = unname(PROJECT_COLORS["non_responder"]),
                 "Higher in responder"     = unname(PROJECT_COLORS["responder"]))

# ==== Panel A: volcano, all 754 tested TFs =================================================
results_full <- results_full %>%
  mutate(
    direction = ifelse(logFC > 0, "Higher in non-responder", "Higher in responder"),
    sig_tier  = case_when(
      adj.P.Val < 0.05 ~ "FDR < 0.05",
      adj.P.Val < 0.10 ~ "FDR < 0.10",
      TRUE ~ "Not significant"
    ),
    sig_tier = factor(sig_tier, levels = c("FDR < 0.05", "FDR < 0.10", "Not significant"))
  )

label_tfs <- c("SREBF1", "BACH1", "E2F1", "IKZF3", "BACH2", "SATB2", "CTBP1", "SNAI2", "PPARA")

panel_A <- ggplot(results_full, aes(logFC, -log10(P.Value), color = direction, alpha = sig_tier)) +
  geom_point(size = 1.5) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey50", linewidth = 0.3) +
  ggrepel::geom_text_repel(
    data = subset(results_full, TF %in% label_tfs),
    aes(label = TF), size = 3, family = PROJECT_FONT_FAMILY, color = "grey20",
    show.legend = FALSE, seed = 1
  ) +
  scale_color_manual(values = dir_colors, guide = "none") +
  scale_alpha_manual(values = c("FDR < 0.05" = 1, "FDR < 0.10" = 0.7, "Not significant" = 0.25),
                      guide = "none") +
  labs(title = "A. TF-activity landscape, full tested panel (n = 754)",
       subtitle = "56 significant at FDR<0.05. Labeled TFs are module-representative (see panels B/C).",
       x = "log2 fold change (activity score)", y = expression(-log[10]("p-value"))) +
  theme_project()

# ==== Panel B: correlation structure among the 56 FDR<0.05 hits, ordered by hclust =========
cor_mat <- clust$cor_mat
hc <- clust$hc
ord <- hc$labels[hc$order]

cor_long <- as.data.frame(as.table(cor_mat[ord, ord]))
colnames(cor_long) <- c("TF1", "TF2", "r")
cor_long$TF1 <- factor(cor_long$TF1, levels = ord)
cor_long$TF2 <- factor(cor_long$TF2, levels = rev(ord))

modules <- cutree(hc, h = 1 - 0.7)
mod_size <- table(modules)
module_df <- data.frame(TF = names(modules), module = unname(modules))
module_df$module_label <- ifelse(mod_size[as.character(module_df$module)] == 1,
                                  "Unclustered (singleton)", paste("Module", module_df$module))
module_df$TF <- factor(module_df$TF, levels = ord)

named_levels <- sort(setdiff(unique(module_df$module_label), "Unclustered (singleton)"))
strip_colors <- setNames(c(scales::hue_pal()(length(named_levels)), "grey75"),
                          c(named_levels, "Unclustered (singleton)"))

panel_B_strip <- ggplot(module_df, aes(TF, y = 1, fill = module_label)) +
  geom_tile() +
  scale_fill_manual(values = strip_colors, name = "Module (r>0.7)") +
  theme_void() +
  theme(legend.position = "bottom", legend.text = element_text(size = rel(0.65)),
        legend.title = element_text(size = rel(0.75)))

panel_B_heat <- ggplot(cor_long, aes(TF1, TF2, fill = r)) +
  geom_tile() +
  scale_fill_gradientn(colors = PROJECT_PALETTE_DIVERGING, limits = c(-1, 1), name = "Pearson r") +
  labs(title = "B. Correlation structure among the 56 FDR<0.05 hits",
       subtitle = paste0("Ordered by hierarchical clustering (average linkage). ",
                          "Nyholt effective independent programs: Meff = ", round(clust$Meff, 1)),
       x = NULL, y = NULL) +
  theme_project() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = rel(0.45)),
        axis.text.y = element_text(size = rel(0.45)),
        legend.position = "right")

panel_B <- panel_B_strip / panel_B_heat + plot_layout(heights = c(0.04, 1))

# ==== Panel C: per-patient activity scores, representative TFs from each named module ======
rep_tfs <- c("E2F1", "E2F4", "SREBF1", "PPARA", "IKZF3", "BACH2")
rep_data <- do.call(rbind, lapply(rep_tfs, function(tf) {
  data.frame(TF = tf, patient = colnames(score_mat), score = score_mat[tf, ],
             response = patient_response[colnames(score_mat)])
}))
rep_data$TF <- factor(rep_data$TF, levels = rep_tfs)
rep_data$module_group <- factor(
  ifelse(rep_data$TF %in% c("E2F1", "E2F4"), "Module 2 (E2F, NR-elevated)",
  ifelse(rep_data$TF %in% c("SREBF1", "PPARA"), "Module 1 (metabolic, NR-elevated)",
         "Module 5 (lymphocyte, R-elevated)")),
  levels = c("Module 1 (metabolic, NR-elevated)", "Module 2 (E2F, NR-elevated)",
             "Module 5 (lymphocyte, R-elevated)")
)

panel_C <- ggplot(rep_data, aes(response, score, color = response)) +
  geom_jitter(width = 0.12, size = 2.2, alpha = 0.85) +
  stat_summary(fun = mean, geom = "crossbar", width = 0.35, color = "grey30", linewidth = 0.3) +
  facet_grid(~ module_group + TF, scales = "free_y",
             labeller = labeller(module_group = label_wrap_gen(18))) +
  scale_color_manual(values = c(Responder = unname(PROJECT_COLORS["responder"]),
                                  `Non-responder` = unname(PROJECT_COLORS["non_responder"])),
                      guide = "none") +
  labs(title = "C. Per-patient activity scores, representative TFs from each named module",
       subtitle = "Every point is one patient (n = 19). 2 TFs shown per module (A/B/E labels match panel B's strip).",
       x = NULL, y = "decoupleR ULM activity score") +
  theme_project() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1),
        strip.text = element_text(size = rel(0.65)))

# ==== compose ================================================================================
figure4 <- panel_A / panel_B / panel_C +
  plot_layout(heights = c(1, 1.7, 0.9)) +
  plot_annotation(
    title = "Figure 4. H4 - regulatory coherence: patient-level TF-activity analysis (primary)",
    caption = paste0("754 TFs tested (decoupleR::run_ulm against verified CollecTRI, 42,698 edges/1,178 TFs). ",
                      "56 significant at FDR<0.05, Meff=31.3 effective independent programs (Nyholt 2004). ",
                      "Grade: Moderate. Communication-network component of H4 not yet run. ",
                      "Compartment-level exploratory analysis is reported in the H4 module documentation, ",
                      "not shown here. See 06_regulation_communication/README.md."),
    theme = theme_project()
  )

save_figure(figure4, "figures/figure4_h4_tf_activity", width = 13, height = 15)
