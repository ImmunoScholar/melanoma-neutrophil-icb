# H0: neutrophil representation in GSE120575 is protocol-determined (CD45+ sort +
# Smart-seq2 plate-picking excludes neutrophils), not evidence of their biological
# absence from the tumours. This script loads the real data and tests it directly.

library(data.table)
library(readr)
meta_path <- "data/raw/GSE120575/GSE120575_patient_ID_single_cells.txt.gz"
tpm_gz    <- "data/raw/GSE120575/GSE120575_Sade_Feldman_melanoma_single_cells_TPM_GEO.txt.gz"
tpm_txt   <- "data/processed/GSE120575/GSE120575_TPM.txt"
# --- metadata: bounded to the real per-cell sample rows, verified working ---
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
cat("Metadata:", nrow(meta), "rows x", ncol(meta), "cols\n")
resp_col <- grep("response", colnames(meta), ignore.case = TRUE, value = TRUE)
cat("Response column:", resp_col, "\n")
print(table(meta[[resp_col]], useNA = "ifany"))
# --- TPM matrix: 4.5GB decompressed, exceeding R's ~2.1GB single-string limit,
# which is what fread/gzfile hit. readr::read_tsv() streams/memory-maps rather
# than materialising the file as one contiguous string, avoiding that ceiling.
dir.create(dirname(tpm_txt), recursive = TRUE, showWarnings = FALSE)
if (!file.exists(tpm_txt)) {
  cat("\nDecompressing TPM matrix (one-time)...\n")
  status <- system2("gunzip", args = c("-k", "-c", shQuote(tpm_gz)), stdout = tpm_txt)
  stopifnot(status == 0)
}
cat("Decompressed size:", round(file.info(tpm_txt)$size / 1e6, 1), "MB\n")
t0  <- Sys.time()
tpm <- read_tsv(tpm_txt, show_col_types = FALSE, progress = FALSE)
cat("read_tsv wall time:", round(difftime(Sys.time(), t0, units = "secs"), 1), "sec\n")
setDT(tpm)

first_col <- colnames(tpm)[1]
cat("First column name as read:", first_col, "\n")
setnames(tpm, first_col, "gene")
cat("TPM matrix:", nrow(tpm), "genes x", ncol(tpm) - 1, "cells\n")
# --- join key alignment ---
tpm_cells  <- colnames(tpm)[-1]
meta_cells <- meta$title
cat("\nCells in TPM but not in metadata:", sum(!tpm_cells %in% meta_cells), "\n")
cat("Cells in metadata but not in TPM:", sum(!meta_cells %in% tpm_cells), "\n")
cat("Exact match, same order:", identical(tpm_cells, meta_cells), "\n")
# --- H0 test: canonical human neutrophil markers, unfiltered matrix, all cells ---
neutrophil_markers <- c("FCGR3B", "CSF3R", "CEACAM8", "MPO", "ELANE", "FUT4", "S100A8", "S100A9")

cat("\n--- H0 test: neutrophil marker presence/expression, all", ncol(tpm) - 1, "cells ---\n")
for (g in neutrophil_markers) {
  row <- tpm[gene == g]
  if (nrow(row) == 0) {
    cat(sprintf("%-10s NOT PRESENT as a row in the matrix\n", g))
  } else {
    vals <- as.numeric(row[1, -1, with = FALSE])
    cat(sprintf(
      "%-10s present | max TPM=%.2f | mean TPM=%.3f | cells with TPM>1: %d/%d (%.1f%%)\n",
      g, max(vals), mean(vals), sum(vals > 1), length(vals), 100 * mean(vals > 1)
    ))
  }
}
