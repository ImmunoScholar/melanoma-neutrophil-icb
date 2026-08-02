# Smoke test, retry after the Ensembl-dependency failure. get_collectri() failed because
# OmnipathR tries to resolve the organism name "human" against
# https://www.ensembl.org/info/about/species.html, which now 404s -- a known, currently
# unresolved upstream issue (github.com/saezlab/decoupleR issues #153, #162;
# github.com/saezlab/OmnipathR issue #117; github.com/saezlab/CollecTRI issue #19).
#
# Plan A: get_collectri() also accepts an NCBI Taxonomy ID directly (human = 9606), which
# may skip the broken name-resolution path entirely -- documented, not a guess.
# Plan B, only if Plan A fails: download CollecTRI directly from its own Zenodo archive
# (the paper's static data release, published alongside Muller-Dott et al. 2023),
# completely independent of OmnipathR/Ensembl.
#
# HISTORICAL RECORD, kept as originally run -- not simplified. Plan A failed (below) and
# Plan B "succeeded" in the sense of downloading without error, but its output was later
# discovered to be mouse-orthology-cased (Myc, Spi1, Smad3...), not human, despite the
# filename. Neither plan is the method actually used for H4 -- see
# 06_regulation_communication/01_collectri_resolved.R, which queries OmniPath's REST API
# directly instead, and CHANGELOG.md for the full resolution story. This file is preserved
# as-is because it accurately documents what was tried and found at the time, per this
# project's rule that corrections are logged as new entries, not silent rewrites of history.

suppressPackageStartupMessages({
  library(decoupleR)
  library(liana)
})
cat("--- decoupleR: CollecTRI via NCBI taxid (Plan A) ---\n")
net <- tryCatch(
  get_collectri(organism = 9606, split_complexes = FALSE),
  error = function(e) { cat("Plan A failed:", conditionMessage(e), "\n"); NULL }
)
if (is.null(net)) {
  cat("\n--- Plan B: static CollecTRI download from Zenodo (independent of OmnipathR) ---\n")
  url  <- "https://zenodo.org/records/8222799/files/human_prior_tri.csv?download=1"
  dest <- "data/raw/collectri_human_prior_tri.csv"
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  download.file(url, dest, method = "libcurl", quiet = FALSE)
  net <- read.csv(dest)
  cat("\nDownloaded. Raw structure (peeking before assuming format):\n")
  str(net)
  print(head(net))
} else {
  cat("Plan A succeeded.\n")
}

if (!is.null(net)) {
  cat("\nCollecTRI obtained:", nrow(net), "rows. Columns:", paste(colnames(net), collapse = ", "), "\n")
}
cat("\n--- liana: listing available ligand-receptor resources ---\n")
print(show_resources())

cat("\n--- liana: loading the Consensus resource ---\n")
resource <- select_resource("Consensus")
cat("Consensus resource:", nrow(resource[[1]]), "ligand-receptor pairs\n")
print(head(resource[[1]]))
