# Figure 4 (H4, primary): both components of H4's hypothesis, coordinated in one figure.
# Panel A (top three sub-panels, A-C): TF-activity analysis -- the major statistical result.
# Panel B (bottom two sub-panels, D-E): communication network -- D is the pre-specified,
# formal statistical result (Fisher enrichment test, NEGATIVE in both networks); E is an
# explicitly-labeled DESCRIPTIVE OBSERVATION (checkpoint-associated edges noticed while
# inspecting D's significant-edge subset), not independently tested, not part of H4's
# evidence grade. This separation is deliberate -- see README.md for the full terminology
# (Finding / Negative finding / Descriptive observation / Hypothesis for later synthesis)
# used consistently across this figure, the module README, and the evidence ledger.

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

# Panels D and E are each only half-figure-width -- long titles/subtitles must be wrapped
# explicitly (ggplot does not auto-wrap plot.title/plot.subtitle), or adjacent panels' text
# collides. This is exactly the failure mode documented for Figure 1 (fixed-width text
# overflow) -- checked here before sending anything to Priya, not assumed fine because "no
# error" (see caption fix earlier in this same rendering pass).
wrap_text <- function(x, width) paste(strwrap(x, width = width), collapse = "\n")

# ==== Panel D: pre-specified enrichment test -- the FORMAL STATISTICAL RESULT =============
supp <- readRDS("results/h4_lr_suppression_enrichment.rds")

build_summary <- function(x, label) {
  x$annotated %>%
    mutate(group = ifelse(target_is_tcell, "T-cell-directed", "Other target")) %>%
    group_by(group) %>%
    summarise(n = n(), n_suppressive = sum(receptor_suppressive), .groups = "drop") %>%
    mutate(pct = 100 * n_suppressive / n, network = label)
}
summary_df <- bind_rows(build_summary(supp$responder, "Responder"),
                         build_summary(supp$nonresponder, "Non-responder"))
summary_df$group <- factor(summary_df$group, levels = c("Other target", "T-cell-directed"))
summary_df$network <- factor(summary_df$network, levels = c("Responder", "Non-responder"))

panel_D <- ggplot(summary_df, aes(group, pct, fill = network)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = paste0(n_suppressive, "/", n)),
            position = position_dodge(width = 0.7), vjust = -0.4, size = 2.8,
            family = PROJECT_FONT_FAMILY, color = "grey20") +
  scale_fill_manual(values = c(Responder = unname(PROJECT_COLORS["responder"]),
                                 `Non-responder` = unname(PROJECT_COLORS["non_responder"])),
                     name = NULL) +
  labs(title = wrap_text("D. Pre-specified suppressive-receptor enrichment test -- STATISTICAL RESULT", 48),
       subtitle = wrap_text(paste0(
         "Fisher's exact test, all scored edges (n=", nrow(supp$responder$annotated), " Responder / ",
         nrow(supp$nonresponder$annotated), " Non-responder). Responder: OR=",
         round(unname(supp$responder$fisher$estimate), 2), ", P=",
         format.pval(supp$responder$fisher$p.value, digits = 2), " (not significant). ",
         "Non-responder: OR=", round(unname(supp$nonresponder$fisher$estimate), 2), ", P=",
         format.pval(supp$nonresponder$fisher$p.value, digits = 2), " (not significant). ",
         "NEGATIVE FINDING in both networks."), 62),
       x = NULL, y = "% edges with GO-annotated\nsuppressive receptor") +
  theme_project() +
  theme(plot.subtitle = element_text(size = rel(0.68)))

# ==== Panel E: checkpoint-associated edges among significant results -- DESCRIPTIVE ========
# ONLY (not independently tested -- see header and README). Plain monospace text block,
# deliberately not a node-edge network diagram, to avoid visually overstating certainty for
# an observation that is explicitly not part of H4's evidence grade.
desc_edges <- bind_rows(
  supp$responder$annotated %>%
    filter(aggregate_rank < 0.05, target_is_tcell, receptor_suppressive) %>%
    mutate(network = "Responder"),
  supp$nonresponder$annotated %>%
    filter(aggregate_rank < 0.05, target_is_tcell, receptor_suppressive) %>%
    mutate(network = "Non-responder")
) %>%
  arrange(network, aggregate_rank) %>%
  mutate(row_label = sprintf("%-14s %-9s %-10s -> %-10s  rank=%.4f",
                              network, source, ligand.complex, receptor.complex, aggregate_rank))
desc_edges$y <- rev(seq_len(nrow(desc_edges)))

panel_E <- ggplot(desc_edges, aes(x = 0, y = y, label = row_label)) +
  geom_text(hjust = 0, family = "mono", size = 2.7, color = "grey20") +
  scale_x_continuous(limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, nrow(desc_edges) + 1)) +
  labs(title = wrap_text(
         "E. Checkpoint-associated T-cell-directed edges, significant subset -- DESCRIPTIVE OBSERVATION",
         48),
       subtitle = wrap_text(paste0(
         "Not independently tested -- noticed while inspecting panel D's significant-edge ",
         "subset (aggregate_rank<0.05) after the fact. Hypothesis-generating only; does ",
         "not change H4's evidence grade; may be revisited in H5 / 09_synthesis."), 62)) +
  theme_void() +
  theme(plot.title = element_text(face = "bold", size = rel(0.85), hjust = 0, color = "grey30"),
        plot.subtitle = element_text(color = "grey40", size = rel(0.62), hjust = 0,
                                      face = "italic", lineheight = 1.1),
        plot.margin = margin(10, 10, 10, 10),
        panel.background = element_rect(fill = "grey96", color = "grey70"))

bottom_row <- panel_D | panel_E

# ==== compose ================================================================================
figure4 <- panel_A / panel_B / panel_C / bottom_row +
  plot_layout(heights = c(1, 1.7, 0.9, 1.15)) +
  plot_annotation(
    title = "Figure 4. H4 - regulatory coherence and intercellular communication",
    subtitle = wrap_text(paste0(
      "Panel A (A-C): TF-activity, primary statistical result. Panel B (D-E): communication ",
      "network -- D is the formal statistical result, E is descriptive only."), 165),
    caption = wrap_text(paste0(
      "TF activity: 754 TFs tested, 56 significant FDR<0.05, Meff=31.3 (Nyholt 2004). Grade: Moderate. ",
      "Communication: pre-specified Fisher enrichment test (D) is a NEGATIVE FINDING in both networks -- ",
      "this is H4's formal communication result. Checkpoint edges (E) are a DESCRIPTIVE OBSERVATION only, ",
      "not independently tested, do not alter H4's evidence grade. Compartment-level TF-activity ",
      "exploratory follow-up reported separately in the module README, not shown here. ",
      "See 06_regulation_communication/README.md."), 150),
    theme = theme_project()
  )

save_figure(figure4, "figures/figure4_h4_tf_activity", width = 13, height = 19)
