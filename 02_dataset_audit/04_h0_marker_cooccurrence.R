# H0 continued: do the neutrophil-marker-positive cells overlap across markers (a real
# small population) or are they scattered/independent (consistent with ambient RNA
# contamination from lysed neutrophils rather than a discrete cell population)?
#
# This also caches the parsed TPM matrix + metadata to data/processed/GSE120575/*.rds
# so the 36-minute load only has to happen once more, not on every future script.
library(data.table)
library(readr)

meta_path  <- "data/raw/GSE120575/GSE120575_patient_ID_single_cells.txt.gz"
tpm_gz     <- "data/raw/GSE120575/GSE120575_Sade_Feldman_melanoma_single_cells_TPM_GEO.txt.gz"
tpm_txt    <- "data/processed/GSE120575/GSE120575_TPM.txt"
meta_cache <- "data/processed/GSE120575/meta.rds"
tpm_cache  <- "data/processed/GSE120575/tpm.rds"

dir.create("data/processed/GSE120575", recursive = TRUE, showWarnings = FALSE)
if (file.exists(meta_cache) && file.exists(tpm_cache)) {
  cat("Loading from cache (skipping the 36-minute parse)...\n")
  meta <- readRDS(meta_cache)
  tpm  <- readRDS(tpm_cache)
} else {
  raw_lines  <- readLines(gzfile(meta_path, "rt"))
  header_idx <- grep("^Sample name\t", raw_lines, useBytes = TRUE)
  stopifnot(length(header_idx) == 1)

data_start <- header_idx + 1
  data_end   <- data_start
  while (data_end <= length(raw_lines) && grepl("^Sample [0-9]+\t", raw_lines[data_end], useBytes = TRUE)) {
    data_end <- data_end + 1
  }
  data_end <- data_end - 1

meta <- read.delim(
    text = paste(c(raw_lines[header_idx], raw_lines[data_start:data_end]), collapse = "\n"),
    header = TRUE, stringsAsFactors = FALSE, check.names = FALSE
  )
if (!file.exists(tpm_txt)) {
    status <- system2("gunzip", args = c("-k", "-c", shQuote(tpm_gz)), stdout = tpm_txt)
    stopifnot(status == 0)
  }

cat("Parsing TPM matrix, ~36 minutes expected...\n")
  t0  <- Sys.time()
  tpm <- read_tsv(tpm_txt, show_col_types = FALSE, progress = FALSE)
  cat("read_tsv wall time:", round(difftime(Sys.time(), t0, units = "secs"), 1), "sec\n")
  setDT(tpm)
  setnames(tpm, colnames(tpm)[1], "gene")
saveRDS(meta, meta_cache)
  saveRDS(tpm, tpm_cache)
  cat("Cached to", meta_cache, "and", tpm_cache, "\n")
}
# --- build a cells x markers matrix of TPM>1 indicators ---
markers <- c("FCGR3B", "CSF3R", "CEACAM8", "MPO", "ELANE", "FUT4", "S100A8", "S100A9")
specific_markers <- c("CEACAM8", "MPO", "ELANE")  # most lineage-restricted, primary granule

marker_tpm <- tpm[gene %in% markers]
setkey(marker_tpm, gene)
marker_tpm <- marker_tpm[markers]  # enforce consistent row order

cell_ids <- colnames(tpm)[-1]
pos_mat  <- t(sapply(markers, function(g) {
  vals <- as.numeric(marker_tpm[gene == g, -1, with = FALSE])
  vals > 1
}))
colnames(pos_mat) <- cell_ids

n_pos <- colSums(pos_mat)
cat("\n--- distribution: number of the 8 markers positive per cell ---\n")
print(table(n_pos))
n_pos_specific <- colSums(pos_mat[specific_markers, ])
cat("\n--- distribution: number of the 3 SPECIFIC (granule) markers positive per cell ---\n")
print(table(n_pos_specific))

candidate_cells <- cell_ids[n_pos_specific >= 2]
cat("\nCells positive for >=2 of the 3 specific markers:", length(candidate_cells), "\n")

if (length(candidate_cells) > 0) {
  pat_col <- grep("patinet ID|patient ID", colnames(meta), ignore.case = TRUE, value = TRUE)
  candidate_meta <- meta[meta$title %in% candidate_cells, c("title", pat_col, "characteristics: response")]
  cat("\nCandidate cells, by patient/timepoint (checking for batch clustering):\n")
  print(candidate_meta)
  cat("\nPatient/timepoint distribution of candidates:\n")
  print(table(candidate_meta[[pat_col]]))
} else {
  cat("\nNo cells meet the >=2 specific-marker threshold.\n")
}
