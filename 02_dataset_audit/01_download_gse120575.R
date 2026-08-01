# H0: neutrophil representation in public melanoma scRNA-seq is protocol-determined,
# not tumour-biology-determined. This script downloads the primary discovery dataset
# (Sade-Feldman et al., GSE120575) and records exactly what was retrieved, before any
# parsing assumptions are made.
#
# getGEOSuppFiles()'s auto-discovery returned NULL for this accession for reasons
# unrelated to network access or User-Agent (verified separately) -- downloading by
# explicit, GEO-confirmed URL is more robust anyway, since it doesn't depend on a
# remote directory-listing step succeeding.

accession <- "GSE120575"
base_url  <- "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE120nnn/GSE120575/suppl"
files     <- c(
  "GSE120575_Sade_Feldman_melanoma_single_cells_TPM_GEO.txt.gz",
  "GSE120575_patient_ID_single_cells.txt.gz"
)
dest_dir <- file.path("data", "raw", accession)
dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

dest_paths <- file.path(dest_dir, files)

for (i in seq_along(files)) {
  cat("Downloading", files[i], "...\n")
  download.file(
    file.path(base_url, files[i]),
    dest_paths[i],
    method = "libcurl",
    quiet  = FALSE
  )
}

# Fail loudly and immediately if anything didn't actually arrive, rather than let a
# missing file surface later as a confusing parse error.
missing <- dest_paths[!file.exists(dest_paths)]
if (length(missing) > 0) {
  stop("Missing after download: ", paste(missing, collapse = ", "))
}

manifest <- data.frame(
  file      = basename(dest_paths),
  path      = dest_paths,
  size_byte = file.info(dest_paths)$size,
  md5       = tools::md5sum(dest_paths),
  row.names = NULL
)
manifest_path <- file.path(dest_dir, "download_manifest.csv")
write.csv(manifest, manifest_path, row.names = FALSE)

cat("\n--- manifest written to", manifest_path, "---\n")
print(manifest)
# Lightweight structural peek: first 3 lines of each file. Does not load the full
# matrix -- this is what Step 2's parser will be written against.
for (f in dest_paths) {
  cat("\n=== ", basename(f), " (first 3 lines) ===\n", sep = "")
  con <- gzfile(f, "rt")
  print(readLines(con, n = 3))
  close(con)
}
