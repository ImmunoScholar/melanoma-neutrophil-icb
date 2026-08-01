# Shared visual identity for every figure in this project. Sourced by each figure
# script rather than duplicated, so a palette or typography change propagates
# everywhere at once and Figure 1 and Figure N read as one continuous document.
#
# Figures render via ragg::agg_png() and svglite::svglite() only -- base png()/cairo
# is not pinned by renv and is not byte-reproducible across machines, see
# REPRODUCIBILITY.md ("Package management").

suppressPackageStartupMessages({
  library(ggplot2)
})

# ---- palette --------------------------------------------------------------------------
# Colourblind-safe (Okabe-Ito derived). Semantic meaning is fixed project-wide: once a
# colour means "Responder" in one figure, it means "Responder" in every figure.

PROJECT_COLORS <- c(
  responder     = "#0072B2",  # blue
  non_responder = "#D55E00",  # vermillion
  gse120575     = "#009E73",  # bluish green
  gse72056      = "#CC79A7",  # reddish purple
  positive      = "#0072B2",  # matches results/evidence_ledger.tsv result_direction
  negative      = "#D55E00",
  null          = "#999999",
  neutral       = "#56B4E9",
  highlight     = "#E69F00"
)

PROJECT_PALETTE_CATEGORICAL <- unname(c(
  PROJECT_COLORS["responder"], PROJECT_COLORS["non_responder"],
  PROJECT_COLORS["gse120575"], PROJECT_COLORS["gse72056"],
  PROJECT_COLORS["highlight"], PROJECT_COLORS["neutral"], "#F0E442", "#999999"
))

PROJECT_PALETTE_SEQUENTIAL <- c("#F7FBFF", "#08306B")
PROJECT_PALETTE_DIVERGING  <- c(PROJECT_COLORS["negative"], "#F7F7F7", PROJECT_COLORS["positive"])

# ---- typography -------------------------------------------------------------------------
# ragg's backend (systemfonts) needs the family actually installed on the rendering
# machine. Checked once here with a safe fallback, rather than erroring per-figure.

PROJECT_FONT_FAMILY <- local({
  available <- tryCatch(systemfonts::system_fonts()$family, error = function(e) character(0))
  preferred <- c("Arial", "Helvetica", "Liberation Sans", "DejaVu Sans")
  hit <- preferred[preferred %in% available]
  if (length(hit) > 0) hit[1] else "sans"
})

# ---- theme --------------------------------------------------------------------------------

theme_project <- function(base_size = 11) {
  theme_minimal(base_size = base_size, base_family = PROJECT_FONT_FAMILY) +
    theme(
      plot.title      = element_text(face = "bold", size = rel(1.1), hjust = 0),
      plot.subtitle   = element_text(color = "grey30", size = rel(0.95), hjust = 0),
      plot.caption    = element_text(color = "grey50", size = rel(0.75), hjust = 1),
      axis.title      = element_text(size = rel(0.95)),
      axis.text       = element_text(color = "grey20"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey92", linewidth = 0.3),
      legend.title    = element_text(size = rel(0.9), face = "bold"),
      legend.text     = element_text(size = rel(0.85)),
      legend.position = "right",
      strip.text       = element_text(face = "bold", size = rel(0.9)),
      strip.background = element_blank(),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Minimal variant for schematic/diagram panels (decision trees, audit tables) that
# need no axes at all, but must still inherit the same font and margins.
theme_project_blank <- function(base_size = 11) {
  theme_project(base_size) +
    theme(
      axis.text = element_blank(), axis.title = element_blank(),
      axis.ticks = element_blank(), panel.grid = element_blank()
    )
}

# ---- save wrapper ---------------------------------------------------------------------
# ragg::agg_png + svglite exclusively, per the project's byte-reproducibility commitment.

save_figure <- function(plot, path_stub, width = 10, height = 8, dpi = 300) {
  dir.create(dirname(path_stub), recursive = TRUE, showWarnings = FALSE)

  ragg::agg_png(paste0(path_stub, ".png"), width = width, height = height,
                units = "in", res = dpi)
  print(plot)
  grDevices::dev.off()

  svglite::svglite(paste0(path_stub, ".svg"), width = width, height = height)
  print(plot)
  grDevices::dev.off()

  cat("Saved:", paste0(path_stub, ".png"), "and .svg\n")
  invisible(path_stub)
}
