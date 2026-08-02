# Resolution of the CollecTRI gene-symbol-casing issue (see CONTINUATION_BRIEF.md).
#
# decoupleR::get_collectri() fails because OmnipathR's organism-resolution step depends on
# https://www.ensembl.org/info/about/species.html, which now 404s (external, unresolved
# upstream bug: github.com/saezlab/decoupleR #153/#162, OmnipathR #117, CollecTRI #19).
# The Zenodo static-file fallback tried previously (data/raw/collectri_human_prior_tri.csv)
# turned out to be mouse-orthology-cased (Myc, Spi1, Smad3...) despite its filename -- verified
# by direct comparison against the OmniPath REST API's genuinely human-cased output for the
# same edges (Myc->Tert vs MYC->TERT, etc.). That file should not be used.
#
# Fix: query OmniPath's REST API directly via HTTP. This bypasses OmnipathR's R-side organism
# lookup entirely (no R package call involved), and OmniPath's native data is human by default
# -- no orthology translation step is triggered, which is exactly what was failing.
url <- paste0(
  "https://omnipathdb.org/interactions?",
  "resources=CollecTRI&genesymbols=1&format=tsv"
)
dest <- "data/raw/collectri_human_omnipath_api.tsv"
dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
download.file(url, dest, method = "libcurl", quiet = FALSE)

raw <- read.delim(dest, stringsAsFactors = FALSE)
# read.delim's type-guessing does not coerce "True"/"False" strings to logical (only exact
# "TRUE"/"FALSE" is auto-detected), so these two columns arrive as character -- coerce
# explicitly before using them as a logical mask.
raw$consensus_stimulation <- as.logical(raw$consensus_stimulation)
raw$consensus_inhibition  <- as.logical(raw$consensus_inhibition)
stopifnot(
  "consensus_stimulation/consensus_inhibition failed to parse as logical (unexpected values)" =
    !anyNA(raw$consensus_stimulation) && !anyNA(raw$consensus_inhibition)
)
cat("Raw rows:", nrow(raw), "| columns:", paste(colnames(raw), collapse = ", "), "\n")
print(head(raw))
# --- verify casing directly, don't assume the fix worked ---
sample_genes <- c("MYC", "TERT", "SPI1", "BGLAP", "SMAD3", "JUN", "LTB", "CXCL13")
cat("\nSample genes present (upper-case, matching our matrix's convention):\n")
present <- sample_genes %in% c(raw$source_genesymbol, raw$target_genesymbol)
print(setNames(present, sample_genes))
stopifnot("Expected uppercase human symbols not found -- casing not actually fixed" = all(present))
# --- reformat to decoupleR's expected network shape: source, target, mor ---
net <- raw[raw$consensus_stimulation | raw$consensus_inhibition, ]
net$mor <- ifelse(net$consensus_stimulation, 1, -1)
net <- data.frame(
  source = net$source_genesymbol,
  target = net$target_genesymbol,
  mor    = net$mor
)
net <- unique(net)
cat("\nFinal network:", nrow(net), "edges,", length(unique(net$source)), "unique TFs\n")

# Sources (TFs) must be fully uppercase -- decoupleR matches these directly against our
# expression matrix's row names, and a non-uppercase TF would silently fail to match.
stopifnot("Non-uppercase TF (source) symbols found -- would silently fail to match the matrix" =
  all(net$source == toupper(net$source)))

# Targets are allowed a small set of legitimately non-uppercase identifiers: HGNC's own
# "open reading frame" convention keeps "orf" lowercase (e.g. C9orf72, a real official human
# symbol, not a casing error), and CollecTRI/OmniPath also includes miRNA targets under
# miRBase's "hsa-miR-*" convention (a separate naming system from HGNC gene symbols). Neither
# is mouse data or a bug -- verified by inspecting the actual non-uppercase target values
# (06_regulation_communication/01b_collectri_casing_diagnostic.R), documented in CHANGELOG.md.
#
# Any non-uppercase target NOT matching one of those two known-legitimate patterns is a data
# anomaly, not a casing convention -- confirmed for the one case found here ("Mgu", target
# UniProt P10746) by querying UniProt directly: P10746 is UROS (uroporphyrinogen-III synthase),
# and "Mgu" is not a valid symbol for it under any nomenclature. Rather than guess a fix (e.g.
# assuming it should read "UROS") or silently keep a known-bad symbol, that specific edge is
# dropped and reported. A large number of such anomalies would indicate a systemic problem and
# is guarded against via stopifnot; a single-digit count is treated as an isolated upstream
# data artefact, documented in CHANGELOG.md.
target_bad <- net$target != toupper(net$target)
target_known_pattern <- grepl("^C[0-9]+orf[0-9]+$", net$target) | grepl("^hsa-", net$target)
anomalous <- target_bad & !target_known_pattern
cat("Non-uppercase targets:", sum(target_bad),
    "| of which explained (HGNC 'orf' or miRBase 'hsa-miR' convention):",
    sum(target_bad & target_known_pattern),
    "| unexplained anomalies:", sum(anomalous), "\n")
stopifnot(
  "Too many unexplained non-uppercase targets to treat as isolated artefacts -- investigate before dropping" =
    sum(anomalous) <= 5
)
if (sum(anomalous) > 0) {
  cat("Dropping", sum(anomalous), "row(s) with unexplained anomalous target symbol(s):\n")
  print(net[anomalous, ])
  net <- net[!anomalous, ]
}

saveRDS(net, "data/processed/collectri_human_verified.rds")
cat("\nSaved to data/processed/collectri_human_verified.rds -- this is the network to use for H4.\n")
# Old, incorrectly-cased file is no longer needed
if (file.exists("data/raw/collectri_human_prior_tri.csv")) {
  file.remove("data/raw/collectri_human_prior_tri.csv")
  cat("Removed the superseded mouse-cased Zenodo file.\n")
}
