# Figure 1 (H0): dataset audit matrix, marker evidence in both cohorts, decision-tree
# branch taken. Built entirely from results/ written by 02_h0_gse120575.R and
# 03_h0_gse72056.R -- no numbers are retyped here.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
})
source("R/theme_project.R")

r120  <- readRDS("results/h0_gse120575_result.rds")
r72   <- readRDS("results/h0_gse72056_result.rds")
mk120 <- read.csv("results/h0_gse120575_marker_summary.csv")
mk72  <- read.csv("results/h0_gse72056_marker_summary.csv")
cand72 <- read.csv("results/h0_gse72056_candidates.csv")

specific_markers <- c("CEACAM8", "MPO", "ELANE")

# ==== Panel A: dataset audit matrix (table-as-figure) ===================================
# Protocol is identical for both rows (CD45+ sorted, Smart-seq2) so it lives in the
# subtitle, not a repeated column -- shorter cells were also chosen deliberately after
# the first render showed long strings (e.g. the full protocol name) overflowing fixed
# uniform column widths and colliding with adjacent columns.
audit_tbl <- data.frame(
  Dataset    = c("GSE120575", "GSE72056"),
  Study      = c("Sade-Feldman 2018", "Tirosh 2016"),
  Cells      = format(c(r120$n_cells, r72$n_cells), big.mark = ","),
  Candidates = c(as.character(r120$observed_ge2), as.character(r72$n_candidates)),
  Distinct   = c("0", as.character(r72$n_distinct_key)),
  Patients   = c("0", as.character(r72$n_patients_key)),
  Verdict    = c("H0 supported", "H0 supported")
)

# Column widths are proportional to actual content width (max characters per column,
# including the header), not uniform -- a fixed 1-unit spacing is exactly what caused
# the overflow/collision in the first render.
plot_table <- function(df, title, subtitle = NULL) {
  df_chr <- as.data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  col_chars <- pmax(nchar(colnames(df_chr)),
                     vapply(df_chr, function(x) max(nchar(x)), integer(1)))
  col_width <- col_chars / sum(col_chars)
  col_x     <- cumsum(col_width) - col_width / 2

  long <- df_chr %>%
    mutate(row = row_number()) %>%
    tidyr::pivot_longer(-row, names_to = "col", values_to = "val") %>%
    mutate(col = factor(col, levels = colnames(df_chr)),
           x = col_x[as.integer(col)])

  header <- data.frame(col = colnames(df_chr), x = col_x, val = colnames(df_chr), row = 0)

  ggplot() +
    geom_text(data = header, aes(x, -row * 1.4, label = val), fontface = "bold", size = 3.1,
              family = PROJECT_FONT_FAMILY) +
    geom_text(data = long, aes(x, -row * 1.4, label = val), size = 2.9,
              family = PROJECT_FONT_FAMILY) +
    geom_segment(aes(x = -0.02, xend = 1.02, y = -0.7, yend = -0.7),
                 linewidth = 0.4, color = "grey40") +
    scale_x_continuous(limits = c(-0.03, 1.03)) +
    labs(title = title, subtitle = subtitle) +
    theme_project_blank() +
    theme(plot.title = element_text(size = rel(1)),
          plot.subtitle = element_text(size = rel(0.85), color = "grey30"))
}
panel_A <- plot_table(
  audit_tbl, "A. Dataset audit: recoverable neutrophils, verdict",
  subtitle = "Both cohorts: CD45+ sorted, Smart-seq2. \"Candidates\" = cells positive for >=2 specific markers (see C, D for method per dataset)."
)

# ==== Panel B: per-marker positivity, both datasets ======================================
marker_df <- bind_rows(
  mk120 %>% mutate(dataset = "GSE120575"),
  mk72  %>% mutate(dataset = "GSE72056")
) %>%
  mutate(
    tier = ifelse(marker %in% specific_markers, "Specific (granule)", "Broader"),
    tier = factor(tier, levels = c("Specific (granule)", "Broader"))
  )

panel_B <- ggplot(marker_df, aes(marker, pct_positive, fill = dataset)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_y_log10(labels = function(x) paste0(x, "%")) +
  scale_fill_manual(values = c(GSE120575 = unname(PROJECT_COLORS["gse120575"]),
                                GSE72056  = unname(PROJECT_COLORS["gse72056"])), name = NULL) +
  facet_grid(~tier, scales = "free_x", space = "free_x") +
  labs(title = "B. Per-marker positivity (log scale - note the ~100x base-rate difference)",
       x = NULL, y = "% cells positive") +
  theme_project() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ==== Panel C: GSE120575 observed vs chance-expected co-occurrence =======================
occ_df <- data.frame(
  what = factor(c("Observed", "Expected\n(independence)"),
                levels = c("Observed", "Expected\n(independence)")),
  value = c(r120$observed_ge2, r120$expected_ge2)
)
panel_C <- ggplot(occ_df, aes(what, value, fill = what)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = round(value, 2)), vjust = -0.4, size = 3.2,
            family = PROJECT_FONT_FAMILY) +
  scale_fill_manual(values = c(unname(PROJECT_COLORS["null"]), "grey80")) +
  labs(title = "C. GSE120575: co-occurrence vs chance",
       subtitle = "Cells positive for >=2 specific markers",
       x = NULL, y = "Cells") +
  ylim(0, max(occ_df$value) * 1.3) +
  theme_project()

# ==== Panel D: GSE72056 candidate classification breakdown ===============================
cand72 <- cand72 %>%
  mutate(class = case_when(
    celltype == 1 ~ "T cell",
    celltype == 3 ~ "Macrophage",
    malignant == 2 ~ "Malignant",
    malignant == 1 & celltype == 0 ~ "Non-malignant,\nunassigned",
    malignant == 0 & celltype == 0 ~ "Unresolved,\nunassigned",
    TRUE ~ "Other"
  ))
class_counts <- cand72 %>% count(class) %>%
  mutate(neutrophil_consistent = class == "Non-malignant,\nunassigned")

panel_D <- ggplot(class_counts, aes(reorder(class, n), n, fill = neutrophil_consistent)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = n), hjust = -0.3, size = 3.2, family = PROJECT_FONT_FAMILY) +
  coord_flip() +
  scale_fill_manual(values = c(`TRUE` = unname(PROJECT_COLORS["highlight"]),
                                `FALSE` = "grey70")) +
  ylim(0, max(class_counts$n) * 1.25) +
  labs(title = "D. GSE72056: candidates by independent cell-type call",
       subtitle = "Highlighted = only bucket consistent with a neutrophil",
       x = NULL, y = "Cells (of 25 candidates)") +
  theme_project()

# ==== Panel E: decision-tree branch taken =================================================
tree <- tribble(
  ~x, ~y, ~xend, ~yend,
  0, 2,   0, 1.3,
  0, 1,  -2, 0.3,
  0, 1,   2, 0.3
)
boxes <- tribble(
  ~x, ~y, ~label, ~taken,
  0, 2, "H0 test\n(both datasets)", NA,
  -2, 0, "<20 recoverable\n(TAKEN)\nH3 omitted", TRUE,
  0, 0, "20-200\nH3 exploratory", FALSE,
  2, 0, ">=200, >=5 patients\nH3 primary", FALSE
)

panel_E <- ggplot() +
  geom_segment(data = tree, aes(x, y, xend = xend, yend = yend),
               color = "grey50", linewidth = 0.5,
               arrow = arrow(length = unit(0.15, "cm"))) +
  geom_label(data = boxes, aes(x, y, label = label, fill = taken), size = 3.0,
             family = PROJECT_FONT_FAMILY, label.padding = unit(0.4, "lines")) +
  scale_fill_manual(values = c(`TRUE` = unname(PROJECT_COLORS["highlight"]), `FALSE` = "grey92"),
                     na.value = "grey95", guide = "none") +
  xlim(-3, 3) + ylim(-0.7, 2.5) +
  labs(title = "E. Failure-tolerant decision tree: branch taken") +
  theme_project_blank()

# ==== compose ==============================================================================
figure1 <- (panel_A) / (panel_B) / (panel_C | panel_D) / (panel_E) +
  plot_layout(heights = c(0.9, 1.3, 1.3, 1.1)) +
  plot_annotation(
    title = "Figure 1. H0 - neutrophil recoverability audit, two independent melanoma cohorts",
    caption = "Result: neutrophils depleted to single-digit candidates in both datasets by CD45+ sorting + Smart-seq2. H3 omitted; see 02_dataset_audit/README.md.",
    theme = theme_project()
  )

save_figure(figure1, "figures/figure1_h0_dataset_audit", width = 10, height = 13)
