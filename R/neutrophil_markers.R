# Shared marker definitions and neutrophil-detection functions (H0).
#
# Both melanoma cohorts are tested with identical marker definitions and identical
# logic, so that any difference between them reflects the data rather than the method.
# Sourced by 02_dataset_audit/02_h0_gse120575.R and 03_h0_gse72056.R.

# Canonical human neutrophil markers.
# The three "specific" markers are primary-granule genes: highly lineage-restricted, and
# expressed coordinately as part of one differentiation programme. A genuine neutrophil
# should express several together, so CO-OCCURRENCE across this subset is the meaningful
# test -- single-marker positivity is uninformative and readily produced by ambient RNA.
NEUTROPHIL_MARKERS <- c(
  "FCGR3B", "CSF3R", "CEACAM8", "MPO", "ELANE", "FUT4", "S100A8", "S100A9"
)
NEUTROPHIL_MARKERS_SPECIFIC <- c("CEACAM8", "MPO", "ELANE")

# TPM threshold for calling a cell positive for a marker.
# NOTE: absolute thresholds do NOT transfer across independently-normalised datasets
# (see REPRODUCIBILITY.md) -- this is retained for within-dataset comparison only, never
# for cross-dataset comparison of raw positivity rates.
TPM_POSITIVE_THRESHOLD <- 1

#' Build a markers x cells logical matrix of positivity
#'
#' @param expr data.table with a `gene` column and one column per cell
#' @param markers character vector of gene symbols to test
#' @param transform function applied to values before thresholding; use identity for
#'   TPM data, or a back-transform for log-scaled data so the threshold means the
#'   same physical quantity in both datasets
#' @return logical matrix, rows = markers found, cols = cells
marker_positivity <- function(expr, markers, transform = identity) {
  found <- intersect(markers, expr$gene)
  if (length(found) == 0) {
    stop("None of the requested markers are present in the expression matrix.")
  }
  cells <- setdiff(colnames(expr), "gene")
  mat <- t(vapply(
    found,
    function(g) transform(as.numeric(expr[gene == g, ..cells][1, ])) > TPM_POSITIVE_THRESHOLD,
    logical(length(cells))
  ))
  colnames(mat) <- cells
  mat
}

#' Per-marker positivity summary
#' @return data.frame with one row per marker
marker_summary <- function(pos_mat) {
  data.frame(
    marker      = rownames(pos_mat),
    n_positive  = rowSums(pos_mat),
    n_cells     = ncol(pos_mat),
    pct_positive = round(100 * rowSums(pos_mat) / ncol(pos_mat), 3),
    row.names   = NULL
  )
}

#' Expected number of cells positive for >= k markers, under independence
#'
#' The null this tests: if each marker's positivity were statistically independent of
#' the others (i.e. scattered noise rather than a coordinated granule programme), how
#' many cells would show >= k of them by chance alone? Computed exactly by enumerating
#' all subsets rather than by simulation, so the number is deterministic.
#'
#' @param pos_mat logical marker x cell matrix
#' @param k minimum number of positive markers
#' @return expected cell count under the independence null
expected_cooccurrence <- function(pos_mat, k = 2) {
  p <- rowSums(pos_mat) / ncol(pos_mat)
  m <- length(p)
  idx <- seq_len(m)
  prob_at_least_k <- 0
  # enumerate every subset of markers, sum P(exactly that subset positive) where |subset| >= k
  for (size in k:m) {
    for (subset in combn(idx, size, simplify = FALSE)) {
      prob_at_least_k <- prob_at_least_k +
        prod(p[subset]) * prod(1 - p[setdiff(idx, subset)])
    }
  }
  prob_at_least_k * ncol(pos_mat)
}

#' Distribution of how many markers each cell is positive for
cooccurrence_distribution <- function(pos_mat) {
  tab <- table(factor(colSums(pos_mat), levels = 0:nrow(pos_mat)))
  data.frame(
    n_markers_positive = as.integer(names(tab)),
    n_cells            = as.integer(tab),
    row.names          = NULL
  )
}
