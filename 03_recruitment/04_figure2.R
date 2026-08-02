# Figure 2 (H1): unbiased recruitment-repertoire screen, ranked effect sizes,
# responder vs non-responder, patient-level. Built from results/h1_discovery_screen_ranked.csv
# (all 35 tested genes -- the full unbiased panel, not a cropped "top hits" view) plus a
# per-patient view of the FDR<0.05 hits so a reader can see the raw data behind the
# aggregate statistics, not just p-values.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(data.table)
})
source("R/theme_project.R")

ranked <- read.csv("results/h1_discovery_screen_ranked.csv")
ranked <- ranked %>%
  mutate(
    direction = ifelse(logFC > 0, "Higher in non-responder", "Higher in responder"),
    sig_tier  = case_when(
      adj.P.Val < 0.05 ~ "FDR < 0.05",
      adj.P.Val < 0.10 ~ "FDR < 0.10",
      TRUE ~ "Not significant"
    ),
    sig_tier = factor(sig_tier, levels = c("FDR < 0.05", "FDR < 0.10", "Not significant"))
  )

dir_colors <- c("Higher in non-responder" = unname(PROJECT_COLORS["non_responder"]),
                 "Higher in responder"     = unname(PROJECT_COLORS["responder"]))

# ==== Panel A: ranked effect sizes, ALL 35 tested genes (the full unbiased panel) =========
panel_A <- ggplot(ranked, aes(x = reorder(gene, -P.Value), y = logFC, fill = direction,
                                alpha = sig_tier)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 0, color = "grey40", linewidth = 0.3) +
  coord_flip() +
  scale_fill_manual(values = dir_colors, name = NULL) +
  scale_alpha_manual(values = c("FDR < 0.05" = 1, "FDR < 0.10" = 0.65, "Not significant" = 0.3),
                      name = NULL) +
  labs(title = "A. Ranked effect sizes, full tested panel (n = 35)",
       subtitle = "Sorted by significance, top to bottom. Positive = higher in non-responder.",
       x = NULL, y = "log2 fold change") +
  theme_project() +
  theme(axis.text.y = element_text(size = rel(0.75)), legend.position = "bottom")

# ==== Panel B: volcano, same 35 genes ======================================================
panel_B <- ggplot(ranked, aes(x = logFC, y = -log10(P.Value), color = direction, alpha = sig_tier)) +
  geom_point(size = 2.2) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey50", linewidth = 0.3) +
  ggrepel::geom_text_repel(
    data = subset(ranked, adj.P.Val < 0.10),
    aes(label = gene), size = 3, family = PROJECT_FONT_FAMILY, color = "grey20",
    show.legend = FALSE, seed = 1
  ) +
  scale_color_manual(values = dir_colors, guide = "none") +
  scale_alpha_manual(values = c("FDR < 0.05" = 1, "FDR < 0.10" = 0.8, "Not significant" = 0.35),
                      guide = "none") +
  labs(title = "B. Effect size vs significance (volcano)",
       subtitle = "Dashed line: nominal p = 0.05. Labels: FDR < 0.10.",
       x = "log2 fold change", y = expression(-log[10]("p-value"))) +
  theme_project()

# ==== Panel C: per-patient raw values for the FDR<0.05 hits ================================
# Recomputes pseudobulk for just these 4 genes from cached data -- deterministic reproduction
# of what 03_h1_discovery_screen.R already computed internally, not a new analysis; shown here
# purely so raw per-patient values are visible behind the aggregate statistics.
meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient <- sub("^(Pre|Post)_", "", meta[[pat_col]])
pre <- meta[meta$timepoint == "Pre" & meta[[resp_col]] %in% c("Responder", "Non-responder"), ]

top_genes <- ranked$gene[ranked$adj.P.Val < 0.05]
patients  <- sort(unique(pre$patient))
gene_tpm  <- tpm[gene %in% top_genes]

pb_long <- do.call(rbind, lapply(patients, function(p) {
  pcells <- intersect(pre$title[pre$patient == p], colnames(gene_tpm))
  vals <- rowMeans(gene_tpm[, ..pcells])
  data.frame(patient = p, gene = gene_tpm$gene, log2tpm = log2(vals + 1),
             response = unique(pre[[resp_col]][pre$patient == p]))
}))
pb_long$gene <- factor(pb_long$gene, levels = top_genes[order(match(top_genes, ranked$gene))])

panel_C <- ggplot(pb_long, aes(response, log2tpm, color = response)) +
  geom_jitter(width = 0.12, size = 2.2, alpha = 0.85) +
  stat_summary(fun = mean, geom = "crossbar", width = 0.35, color = "grey30", linewidth = 0.3) +
  facet_wrap(~gene, nrow = 1, scales = "free_y") +
  scale_color_manual(values = c(Responder = unname(PROJECT_COLORS["responder"]),
                                  `Non-responder` = unname(PROJECT_COLORS["non_responder"])),
                      guide = "none") +
  labs(title = "C. Per-patient pseudobulk values, FDR < 0.05 hits",
       subtitle = "Every point is one patient (n = 19) -- checking these aren't outlier-driven",
       x = NULL, y = "log2(pseudobulk TPM + 1)") +
  theme_project() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# ==== compose ================================================================================
figure2 <- (panel_A | panel_B) / panel_C +
  plot_layout(heights = c(1.4, 1)) +
  plot_annotation(
    title = "Figure 2. H1 - unbiased recruitment-repertoire discovery screen",
    caption = "35 genes tested (327-gene GO-sourced panel, pre-specified detection filter). 4 significant at FDR<0.05. Grade: Moderate (H5 provides independent validation). See 03_recruitment/README.md.",
    theme = theme_project()
  )

save_figure(figure2, "figures/figure2_h1_discovery_screen", width = 12, height = 10)
