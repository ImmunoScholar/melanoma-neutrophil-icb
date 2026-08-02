# H5 (07_validation_concordance) Step 1: download the two bulk validation cohorts, by
# explicit, verified URL -- not GEOquery's directory-listing step, matching H0's own
# precedent (GEOquery's getGEOSuppFiles() returned NULL for GSE120575 for unrelated reasons,
# see REPRODUCIBILITY.md). URLs below were verified live (directory listing fetched and
# checked) before this script was written, not guessed from the standard GEO path pattern.
#
# GSE78220 (Hugo et al. 2016, Cell): 28 samples, anti-PD-1 (pembrolizumab), single FPKM
# matrix. Series title states "pre-treatment melanomas" -- appears to be pre-treatment-only,
# to be confirmed against every sample's own characteristics in the audit step, not assumed
# from the title alone.
# GSE91061 (Riaz et al. 2017, Cell): 65 patients, 109 samples (51 pre-treatment + 58
# on-treatment), anti-CTLA4 and anti-PD-1. Raw counts, FPKM, and rlog-transformed matrices
# all available -- which one(s) to use is a Step 2 (audit) decision, not decided here.

dir.create("data/raw/GSE78220", recursive = TRUE, showWarnings = FALSE)
dir.create("data/raw/GSE91061", recursive = TRUE, showWarnings = FALSE)

downloads <- list(
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE78nnn/GSE78220/suppl/GSE78220_PatientFPKM.xlsx",
       dest = "data/raw/GSE78220/GSE78220_PatientFPKM.xlsx"),
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE78nnn/GSE78220/matrix/GSE78220_series_matrix.txt.gz",
       dest = "data/raw/GSE78220/GSE78220_series_matrix.txt.gz"),
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE91nnn/GSE91061/suppl/GSE91061_BMS038109Sample.hg19KnownGene.fpkm.csv.gz",
       dest = "data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.fpkm.csv.gz"),
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE91nnn/GSE91061/suppl/GSE91061_BMS038109Sample.hg19KnownGene.raw.csv.gz",
       dest = "data/raw/GSE91061/GSE91061_BMS038109Sample.hg19KnownGene.raw.csv.gz"),
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE91nnn/GSE91061/suppl/GSE91061_BMS038109Sample_Cytolytic_Score_20161026.txt.gz",
       dest = "data/raw/GSE91061/GSE91061_Cytolytic_Score.txt.gz"),
  list(url = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE91nnn/GSE91061/matrix/GSE91061_series_matrix.txt.gz",
       dest = "data/raw/GSE91061/GSE91061_series_matrix.txt.gz")
)

manifest <- data.frame(file = character(), bytes = integer(), md5 = character())
for (d in downloads) {
  cat("Downloading:", d$url, "\n")
  download.file(d$url, d$dest, method = "libcurl", quiet = FALSE, mode = "wb")
  info <- file.info(d$dest)
  md5 <- tools::md5sum(d$dest)
  manifest <- rbind(manifest, data.frame(file = d$dest, bytes = info$size, md5 = unname(md5)))
}

cat("\n--- Download manifest ---\n")
print(manifest)
write.csv(manifest, "data/raw/h5_download_manifest.csv", row.names = FALSE)
cat("\nSaved: data/raw/h5_download_manifest.csv\n")
cat("Note: raw GEO downloads are gitignored (matching data/raw/ convention throughout this",
    "project) -- the manifest with checksums is what gets committed, per REPRODUCIBILITY.md.\n")
