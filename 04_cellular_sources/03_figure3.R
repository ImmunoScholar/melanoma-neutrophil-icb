# Figure 3 (H2): cellular sources of the recruitment programme -- which compartment each
# gene traces to (primary test, all 35 genes + a detail heatmap for H1's hits), and where
# the response-associated regulation actually lives (secondary test), including cases where
# abundance and regulation are NOT co-located (CCL4, LTB).

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(data.table)
})
source("R/theme_project.R")

kw <- read.csv("results/h2_compartment_specificity.csv")
secondary <- read.csv("results/h2_within_compartment_response.csv")
h1_hits <- c("LTB", "CCL3", "CCL4", "CXCL13", "TYMP", "CCL4L2", "GPI", "CD320", "FAM3C")

comp_colors <- c(T_cell = unname(PROJECT_COLORS["responder"]),
                  B_cell = unname(PROJECT_COLORS["gse72056"]),
                  Myeloid = unname(PROJECT_COLORS["non_responder"]),
                  NK = unname(PROJECT_COLORS["gse120575"]))

# ==== Panel A: primary test, all 35 genes, compartment restriction significance =========
kw <- kw %>%
  mutate(dominant_compartment = factor(dominant_compartment, levels = names(comp_colors)),
         is_hit = gene %in% h1_hits)

panel_A <- ggplot(kw, aes(x = reorder(gene, fdr), y = -log10(fdr), fill = dominant_compartment)) +
  geom_col(aes(alpha = is_hit), width = 0.7) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey40", linewidth = 0.3) +
  scale_fill_manual(values = comp_colors, name = "Dominant\ncompartment") +
  scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.45), guide = "none") +
  coord_flip() +
  labs(title = "A. Compartment restriction, full tested panel (n = 35)",
       subtitle = "Bold bars: H1's FDR<0.10 hits. Dashed line: FDR = 0.05. 34/35 genes restricted.",
       x = NULL, y = expression(-log[10]("FDR"))) +
  theme_project() +
  theme(axis.text.y = element_text(size = rel(0.7)))

# ==== Panel B: heatmap, H1's hits x compartment, mean pseudobulk expression =============
# Recomputed from cached data -- deterministic reproduction of what 02_h2_compartment_
# attribution.R already computed internally, not a new analysis; shown for display only.
meta <- readRDS("data/processed/GSE120575/meta.rds")
tpm  <- readRDS("data/processed/GSE120575/tpm.rds")
compartments <- read.csv("results/gse120575_compartment_calls.csv")

pat_col  <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
meta$timepoint <- ifelse(grepl("^Pre", meta[[pat_col]]), "Pre",
                   ifelse(grepl("^Post", meta[[pat_col]]), "Post", NA))
meta$patient <- sub("^(Pre|Post)_", "", meta[[pat_col]])
meta_sub <- meta[, c("title", "patient", "timepoint", resp_col)]
pre <- meta_sub[meta_sub$timepoint == "Pre" & meta_sub[[resp_col]] %in% c("Responder", "Non-responder"), ]
pre <- merge(pre, compartments, by.x = "title", by.y = "cell", all.x = TRUE)

gene_tpm <- tpm[gene %in% h1_hits]
cell_ids <- colnames(gene_tpm)[-1]

heat_data <- do.call(rbind, lapply(names(comp_colors), function(comp) {
  sub <- pre[pre$compartment_call == comp, ]
  counts <- table(sub$patient)
  usable <- names(counts)[counts >= 10]
  pb <- sapply(usable, function(p) {
    pcells <- intersect(sub$title[sub$patient == p], cell_ids)
    rowMeans(gene_tpm[, ..pcells])
  })
  rownames(pb) <- gene_tpm$gene
  # log EACH patient's pseudobulk value first, THEN average across patients -- must match
  # 02_h2_compartment_attribution.R's method exactly (mean of logs, not log of mean; these
  # differ, and differed enough to flip the dominant call for a near-tie case, FAM3C).
  pb_log <- log2(pb + 1)
  data.frame(gene = gene_tpm$gene, compartment = comp, mean_log2tpm = rowMeans(pb_log))
}))
heat_data$compartment <- factor(heat_data$compartment, levels = names(comp_colors))
heat_data <- heat_data %>%
  group_by(gene) %>%
  mutate(is_dominant = mean_log2tpm == max(mean_log2tpm)) %>%
  ungroup()
heat_data$gene <- factor(heat_data$gene, levels = kw$gene[kw$gene %in% h1_hits])

panel_B <- ggplot(heat_data, aes(compartment, gene, fill = mean_log2tpm)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(data = subset(heat_data, is_dominant), label = "★", color = "white", size = 4) +
  scale_fill_gradientn(colors = PROJECT_PALETTE_SEQUENTIAL, name = "Mean\nlog2(TPM+1)") +
  labs(title = "B. Where H1's hits are expressed",
       subtitle = "★ = dominant compartment (highest mean pseudobulk expression)",
       x = NULL, y = NULL) +
  theme_project()

# ==== Panel C: secondary test -- response-association by compartment, abundance vs =======
# regulation mismatch highlighted for CCL4 and LTB specifically.
secondary <- secondary %>%
  mutate(compartment = factor(compartment, levels = names(comp_colors)),
         sig = adj.P.Val < 0.05,
         mismatch = (gene == "CCL4" & compartment != "NK") | (gene == "LTB" & compartment != "B_cell"))

panel_C <- ggplot(secondary, aes(logFC, gene, color = compartment)) +
  geom_vline(xintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_point(aes(size = sig, shape = mismatch), alpha = 0.85) +
  scale_color_manual(values = comp_colors, name = "Compartment") +
  scale_size_manual(values = c(`TRUE` = 3.5, `FALSE` = 2), guide = "none") +
  scale_shape_manual(values = c(`TRUE` = 17, `FALSE` = 16),
                      labels = c(`TRUE` = "Abundance/regulation mismatch", `FALSE` = "Consistent"),
                      name = NULL) +
  labs(title = "C. Where the response-signal actually lives (exploratory)",
       subtitle = "Large points: FDR<0.05. Triangles: compartment differs from panel B's dominant compartment.",
       x = "log2 fold change (within-compartment, non-responder vs responder)", y = NULL) +
  theme_project()

# ==== compose ==============================================================================
figure3 <- panel_A / (panel_B | panel_C) +
  plot_layout(heights = c(1.3, 1)) +
  plot_annotation(
    title = "Figure 3. H2 - cellular sources of the recruitment programme",
    caption = "Primary test: 34/35 genes compartment-restricted (Kruskal-Wallis). Secondary test: exploratory, Myeloid excluded (see 04_cellular_sources/README.md).",
    theme = theme_project()
  )

save_figure(figure3, "figures/figure3_h2_cellular_sources", width = 13, height = 11)
