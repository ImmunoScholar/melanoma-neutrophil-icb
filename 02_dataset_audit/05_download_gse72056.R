# H0 replication: download GSE72056 (Tirosh et al.) -- independent CD45+-sorted,
# Smart-seq2 melanoma cohort. If the null co-occurrence result seen in GSE120575
# replicates here, H0's evidence grade upgrades from Moderate to Strong.

accession <- "GSE72056"
base_url  <- "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE72nnn/GSE72056/suppl"
file      <- "GSE72056_melanoma_single_cell_revised_v2.txt.gz"
dest_dir  <- file.path("data", "raw", accession)
dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
dest_path <- file.path(dest_dir, file)

cat("Downloading", file, "...\n")
download.file(file.path(base_url, file), dest_path, method = "libcurl", quiet = FALSE)

stopifnot(file.exists(dest_path))

manifest <- data.frame(
  file = file, path = dest_path,
  size_byte = file.info(dest_path)$size,
  md5 = tools::md5sum(dest_path),
  row.names = NULL
)
write.csv(manifest, file.path(dest_dir, "download_manifest.csv"), row.names = FALSE)
cat("\n--- manifest ---\n")
print(manifest)
# Peek at the first 15 lines -- this is a single combined file, structure not yet
# confirmed (Tirosh et al.'s format is known to sometimes embed cell-type/malignancy
# annotation as leading rows rather than a separate metadata file, but verify, don't assume).
cat("\n--- first 15 lines ---\n")
con <- gzfile(dest_path, "rt")
lines <- readLines(con, n = 15)
close(con)
for (i in seq_along(lines)) {
  cat(i, ": ", substr(lines[i], 1, 200), "\n", sep = "")
}
