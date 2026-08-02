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
# "TRUE"/"FALSE" is auto-detected), so these columns arrive as character -- coerce explicitly
# before using them as a logical mask.
for (col in c("is_stimulation", "is_inhibition", "consensus_stimulation", "consensus_inhibition")) {
  raw[[col]] <- as.logical(raw[[col]])
}
stopifnot(
  "is_stimulation/is_inhibition/consensus_* failed to parse as logical (unexpected values)" =
    !anyNA(raw$is_stimulation) && !anyNA(raw$is_inhibition) &&
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
# Replicates decoupleR::get_collectri(organism="human", split_complexes=FALSE)'s own canonical
# post-processing exactly (confirmed by reading its source, not guessed), since that is the
# published, reference way this network is meant to be built -- we are only substituting the
# raw-data source (OmniPath REST API instead of the broken OmnipathR/Ensembl path), not
# inventing a different network. Two things this replicates that our first draft skipped, and
# which explain the "repeated edges" error decoupleR::run_ulm() raised on that draft:
#  1. Complex sources (raw `source` column contains "COMPLEX", e.g. "COMPLEX:P17275_P17535")
#     are collapsed to two composite TF labels, "AP1" (JUN/FOS-containing complexes) and
#     "NFKB" (REL/NFKB-containing complexes) -- not kept as literal complex-partner strings
#     like "JUNB_JUND". Complexes matching neither pattern have no defined replacement in
#     decoupleR's own logic and become NA; we drop those explicitly (a disclosed, deliberate
#     improvement over decoupleR's own code, which does not filter them, since a NA-labelled
#     "TF" cannot be a meaningful decoupleR::run_ulm() output row).
#  2. Rows are deduplicated on (source, target) alone, keeping the first occurrence
#     (`dplyr::distinct(.keep_all = TRUE)`-equivalent), not on the full (source, target, mor)
#     triple as our first draft did. The two conventions differ exactly when the same
#     (source, target) pair has conflicting mor across rows -- which happens 126 times in this
#     data (e.g. JUN->ABCB1 reported as both +1 and -1 by different underlying evidence/
#     complex-derived rows) and is real: pleiotropic TFs like JUN/NFKB1/RELA are genuinely
#     reported as both activating and repressing the same target across different curated
#     source studies. decoupleR's own reference behaviour is to keep whichever row appears
#     first, not to resolve or average the conflict -- replicated here rather than inventing
#     an alternative resolution rule.
is_complex <- grepl("COMPLEX", raw$source, fixed = TRUE)
interactions <- raw[!is_complex, c("source_genesymbol", "target_genesymbol", "is_stimulation")]
complexes    <- raw[ is_complex, c("source_genesymbol", "target_genesymbol", "is_stimulation")]

complexes$source_genesymbol <- ifelse(
  grepl("JUN", complexes$source_genesymbol) | grepl("FOS", complexes$source_genesymbol), "AP1",
  ifelse(grepl("REL", complexes$source_genesymbol) | grepl("NFKB", complexes$source_genesymbol),
         "NFKB", NA_character_)
)
n_complex_dropped <- sum(is.na(complexes$source_genesymbol))
cat("\nComplex rows:", nrow(complexes),
    "| collapsed to AP1/NFKB:", nrow(complexes) - n_complex_dropped,
    "| dropped (unmatched complex pattern, no decoupleR-defined replacement):",
    n_complex_dropped, "\n")
complexes <- complexes[!is.na(complexes$source_genesymbol), ]

combined <- rbind(interactions, complexes)
combined <- combined[!duplicated(combined[, c("source_genesymbol", "target_genesymbol")]), ]
net <- data.frame(
  source = combined$source_genesymbol,
  target = combined$target_genesymbol,
  mor    = ifelse(combined$is_stimulation, 1, -1)
)
cat("\nFinal network:", nrow(net), "edges,", length(unique(net$source)), "unique TFs\n")
stopifnot(
  "Repeated (source, target) pairs remain after deduplication -- fix did not work" =
    !anyDuplicated(net[, c("source", "target")])
)

# Sources (TFs) must be fully uppercase -- decoupleR matches these directly against our
# expression matrix's row names, and a non-uppercase TF would silently fail to match.
stopifnot("Non-uppercase TF (source) symbols found -- would silently fail to match the matrix" =
  all(net$source == toupper(net$source)))

# Targets are allowed a small set of legitimately non-uppercase identifiers: HGNC's own
# "open reading frame" convention keeps "orf" lowercase (e.g. C9orf72, a real official human
# symbol, not a casing error), and CollecTRI/OmniPath also includes miRNA targets under
# miRBase's "hsa-miR-*" convention (a separate naming system from HGNC gene symbols). Neither
# is mouse data or a bug -- verified by inspecting the actual non-uppercase target values,
# documented in CHANGELOG.md.
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
