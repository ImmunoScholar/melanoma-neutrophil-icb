options(
  repos = c(P3M = "https://packagemanager.posit.co/cran/__linux__/noble/latest"),
  BioC_mirror = "https://packagemanager.posit.co/bioconductor",
  HTTPUserAgent = sprintf(
    "R/%s R (%s)",
    getRversion(),
    paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])
  ),
  # Default is 60s, too short for the ~120MB+ raw scRNA-seq/bulk matrices this project
  # downloads from GEO. 600s gives comfortable margin even on a slow connection.
  timeout = 600
)
source("renv/activate.R")
