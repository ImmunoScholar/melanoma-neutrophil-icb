# H0, step 2 of 3: test the primary discovery cohort (GSE120575, Sade-Feldman et al.)
# for recoverable neutrophils.
#
# H0 asks whether neutrophil representation is set by protocol rather than tumour biology.
# GSE120575 is CD45+ FACS-sorted and Smart-seq2 plate-picked -- neutrophils are CD45+, so
# they are not excluded by the sort gate itself; the question is whether they survive the
# dissociation, cryopreservation and plate-picking that these protocols require.
#
# The test is co-occurrence across three primary-granule markers, not per-gene positivity:
# a real neutrophil expresses the granule programme coordinately, whereas ambient RNA from
# lysed neutrophils contaminating other cells' lysates produces scattered, independent hits.

library(data.table)
library(readr)
source("R/neutrophil_markers.R")

raw_dir   <- "data/raw/GSE120575"
proc_dir  <- "data/processed/GSE120575"
meta_gz   <- file.path(raw_dir,  "GSE120575_patient_ID_single_cells.txt.gz")
tpm_gz    <- file.path(raw_dir,  "GSE120575_Sade_Feldman_melanoma_single_cells_TPM_GEO.txt.gz")
tpm_txt   <- file.path(proc_dir, "GSE120575_TPM.txt")
meta_rds  <- file.path(proc_dir, "meta.rds")
tpm_rds   <- file.path(proc_dir, "tpm.rds")

dir.create(proc_dir,  recursive = TRUE, showWarnings = FALSE)
dir.create("results", recursive = TRUE, showWarnings = FALSE)

# ---- load (cached after first run; the parse is ~36 min, see REPRODUCIBILITY.md) --------
if (file.exists(meta_rds) && file.exists(tpm_rds)) {
  cat("Loading from cache...\n")
  meta <- readRDS(meta_rds)
  tpm  <- readRDS(tpm_rds)
} else {
  # The metadata file is a GEO submission template, not a plain table: ~19 lines of
  # boilerplate precede the header, and a shared-protocol section (partly non-UTF-8)
  # FOLLOWS the per-cell rows. Bound the read by structure at both ends rather than
  # assuming fixed line numbers.
  raw_lines  <- readLines(gzfile(meta_gz, "rt"))
  header_idx <- grep("^Sample name\t", raw_lines, useBytes = TRUE)
  stopifnot(length(header_idx) == 1)

  data_start <- header_idx + 1
  data_end   <- data_start
  while (data_end <= length(raw_lines) &&
         grepl("^Sample [0-9]+\t", raw_lines[data_end], useBytes = TRUE)) {
    data_end <- data_end + 1
  }
  data_end <- data_end - 1

  meta <- read.delim(
    text = paste(c(raw_lines[header_idx], raw_lines[data_start:data_end]), collapse = "\n"),
    header = TRUE, stringsAsFactors = FALSE, check.names = FALSE
  )

  # The decompressed matrix is 4.5GB, exceeding R's ~2.1GB single-string limit: both
  # data.table::fread() and base gzfile() fail on it. readr::read_tsv() streams instead.
  if (!file.exists(tpm_txt)) {
    cat("Decompressing (one-time)...\n")
    stopifnot(system2("gunzip", c("-k", "-c", shQuote(tpm_gz)), stdout = tpm_txt) == 0)
  }
  cat("Parsing TPM matrix (~36 min on 6 cores / 10GB)...\n")
  t0  <- Sys.time()
  tpm <- read_tsv(tpm_txt, show_col_types = FALSE, progress = FALSE)
  cat("read_tsv wall time:", round(difftime(Sys.time(), t0, units = "secs"), 1), "sec\n")
  setDT(tpm)
  setnames(tpm, 1, "gene")

  saveRDS(meta, meta_rds)
  saveRDS(tpm,  tpm_rds)
}

cat("Metadata:", nrow(meta), "cells\n")
cat("Expression:", nrow(tpm), "genes x", ncol(tpm) - 1, "cells\n")

resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)[1]
cat("\nResponse distribution:\n"); print(table(meta[[resp_col]], useNA = "ifany"))

# ---- integrity check: expression and metadata must describe the same cells -------------
tpm_cells <- setdiff(colnames(tpm), "gene")
stopifnot(identical(tpm_cells, meta$title))
cat("\nJoin key verified: expression columns and metadata rows match exactly, same order.\n")

# ---- H0 test ---------------------------------------------------------------------------
# Values are TPM, so no transform is needed to make the threshold physically meaningful.
pos_all      <- marker_positivity(tpm, NEUTROPHIL_MARKERS)
pos_specific <- marker_positivity(tpm, NEUTROPHIL_MARKERS_SPECIFIC)

summary_all <- marker_summary(pos_all)
cat("\n--- per-marker positivity ---\n"); print(summary_all)

cat("\n--- co-occurrence, all", nrow(pos_all), "markers ---\n")
print(cooccurrence_distribution(pos_all))

cat("\n--- co-occurrence, specific granule markers only ---\n")
dist_specific <- cooccurrence_distribution(pos_specific)
print(dist_specific)

observed <- sum(colSums(pos_specific) >= 2)
expected <- expected_cooccurrence(pos_specific, k = 2)
cat("\nCells positive for >=2 specific markers:\n")
cat("  observed:", observed, "\n")
cat("  expected under independence:", round(expected, 3), "\n")
cat("  ratio:", round(observed / expected, 2), "\n")

write.csv(summary_all,   "results/h0_gse120575_marker_summary.csv", row.names = FALSE)
write.csv(dist_specific, "results/h0_gse120575_cooccurrence.csv",   row.names = FALSE)

saveRDS(
  list(dataset = "GSE120575", n_cells = ncol(pos_specific),
       observed_ge2 = observed, expected_ge2 = expected),
  "results/h0_gse120575_result.rds"
)
cat("\nResults written to results/\n")
