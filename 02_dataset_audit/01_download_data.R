# H0, step 1 of 3: acquire the raw data.
#
# Downloads the two melanoma scRNA-seq cohorts used to test H0 and records a checksummed
# manifest for each, so that dataset provenance is evidenced rather than asserted.
#
# Files are fetched by explicit, GEO-verified URL rather than via GEOquery::getGEOSuppFiles(),
# which returns NULL for GSE120575 (see REPRODUCIBILITY.md). Explicit URLs also remove a
# dependency on a remote directory-listing step that can fail silently.

datasets <- list(
  GSE120575 = list(
    base = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE120nnn/GSE120575/suppl",
    files = c(
      "GSE120575_Sade_Feldman_melanoma_single_cells_TPM_GEO.txt.gz",
      "GSE120575_patient_ID_single_cells.txt.gz"
    )
  ),
  GSE72056 = list(
    base = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE72nnn/GSE72056/suppl",
    files = "GSE72056_melanoma_single_cell_revised_v2.txt.gz"
  )
)

for (accession in names(datasets)) {
  spec     <- datasets[[accession]]
  dest_dir <- file.path("data", "raw", accession)
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  dest_paths <- file.path(dest_dir, spec$files)

  for (i in seq_along(spec$files)) {
    if (file.exists(dest_paths[i])) {
      cat("Already present, skipping:", spec$files[i], "\n")
      next
    }
    cat("Downloading", spec$files[i], "...\n")
    # options(timeout = 600) is set in .Rprofile; the 60s default is too short for the
    # ~120MB GSE120575 matrix and truncates it mid-transfer.
    download.file(file.path(spec$base, spec$files[i]), dest_paths[i],
                  method = "libcurl", quiet = FALSE)
  }

  missing <- dest_paths[!file.exists(dest_paths)]
  if (length(missing) > 0) {
    stop("Missing after download: ", paste(missing, collapse = ", "))
  }

  manifest <- data.frame(
    file      = basename(dest_paths),
    size_byte = file.info(dest_paths)$size,
    md5       = tools::md5sum(dest_paths),
    row.names = NULL
  )
  write.csv(manifest, file.path(dest_dir, "download_manifest.csv"), row.names = FALSE)
  cat("\n--- ", accession, " manifest ---\n", sep = "")
  print(manifest)
  cat("\n")
}
