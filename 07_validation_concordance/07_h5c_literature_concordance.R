# H5c (exploratory, capped a priori): does H1's screened panel/hits show quantifiable
# overlap with published TAN marker sets? Pre-registered in CHANGELOG.md before this script
# was written: grade ceiling is Exploratory regardless of result (a set-overlap comparison is
# not a response-outcome test, cannot satisfy Strong/Moderate's patient-level-statistics
# criterion -- same rubric caveat already applied to H0's existence claim).
#
# MARKER SET PROVENANCE -- verified to genuinely different depths, disclosed here rather than
# hidden, per explicit project-owner instruction. No gene was inferred or fabricated for any
# paper beyond what its accessible text names.
#
#  - Wang et al. 2025 (Comput Struct Biotechnol J, PMID 41245889, PMC12613047) -- FULL TEXT
#    verified (open access via PMC). TAN states = Neu_c7 + Neu_c10 (the paper's own
#    tumor-tissue-enriched terminal states). 13 genes explicitly named as elevated markers of
#    these states: CD83 (pan-TAN hallmark), HLA-DRA, CD274 (PD-L1), RFX5 (MHC-II regulator) --
#    Neu_c7; CCL3, VEGFA, MAP1LC3B, BHLHE40, LDHA, HES4, MAFG, PPARG -- Neu_c10; CXCR4 (up in
#    both, senescence axis). CXCR2/SELL are also reported but as DOWN-regulated in these
#    states -- excluded here since a "TAN marker set" should mean genes characteristic of
#    (elevated in) the TAN state, not genes it loses.
#  - Guo et al. 2025 (Funct Integr Genomics, PMID 41068349) -- ABSTRACT ONLY (paywalled, no
#    PMC full text available). 4 genes explicitly named: CXCR2, VNN2 (the paper's main
#    immunosuppressive subpopulation, "CXCR2+VNN2+ Neu"), BACH1, ATF2 (regulatory TFs
#    identified via their gene regulatory network). Markedly thinner than Wang 2025's set
#    purely because of paywall access, not because the paper reports less biology -- stated
#    explicitly as a limitation.
#  - Wu et al. 2024 (Cell, PMID 38447573, 316 citations) -- EXCLUDED FROM THE QUANTITATIVE
#    TEST ENTIRELY. Confirmed paywalled (direct fetch returned HTTP 403); confirmed zero
#    genes are named in the accessible abstract for its "antigen-presenting program" (unlike
#    Wang/Guo, whose abstracts do name specific genes); confirmed NCBI's own curated
#    PubMed-to-Gene links return nothing for this PMID. This is a genuine access constraint,
#    not a discovery-shaping choice -- no gene set is substituted or approximated for it.
#
# Test population: H1's full externally-sourced screening panel (327 genes, same 3 msigdbr
# GO:MF terms H1 itself used -- recomputed identically here, not a new panel) AND H1's 4
# FDR<0.05 hits, each tested against Wang's and Guo's marker sets separately (2 populations x
# 2 marker sets = 4 tests). Hypergeometric test (over-representation) plus Jaccard index
# (simple overlap proportion), matching the pre-registration's specified method. BH correction
# applied across the 4 tests. Universe = genes present in the GSE120575 expression matrix
# (55,737 genes, same convention as H4), the pool from which any gene in this project's
# pipeline could have been drawn.

suppressPackageStartupMessages({
  library(data.table)
  library(msigdbr)
})

tpm <- readRDS("data/processed/GSE120575/tpm.rds")
tpm <- tpm[!is.na(gene)]
universe <- tpm$gene
universe_size <- length(universe)
cat("Universe (genes present in GSE120575 matrix):", universe_size, "\n")

# --- H1's screening panel, recomputed identically to 03_recruitment/03_h1_discovery_screen.R
#     (same 3 GO:MF terms, same intersection with the matrix) -- not a new panel ---
go_mf <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:MF")
panel_sets <- c("GOMF_CYTOKINE_ACTIVITY", "GOMF_CHEMOKINE_ACTIVITY", "GOMF_GROWTH_FACTOR_ACTIVITY")
h1_panel <- unique(go_mf$gene_symbol[go_mf$gs_name %in% panel_sets])
h1_panel <- intersect(h1_panel, universe)
cat("H1 screening panel (recomputed):", length(h1_panel), "genes",
    "(H1's own script reported 327 -- cross-check this matches)\n")

h1_ranked <- read.csv("results/h1_discovery_screen_ranked.csv")
h1_hits <- h1_ranked$gene[h1_ranked$adj.P.Val < 0.05]
cat("H1 FDR<0.05 hits:", paste(h1_hits, collapse = ", "), "\n")

# --- marker sets, verified provenance as documented in the header ---
wang_2025_tan <- c("CD83", "HLA-DRA", "CD274", "RFX5", "CCL3", "VEGFA", "MAP1LC3B",
                   "BHLHE40", "LDHA", "HES4", "MAFG", "PPARG", "CXCR4")
guo_2025_tan  <- c("CXCR2", "VNN2", "BACH1", "ATF2")

marker_sets <- list(Wang2025 = wang_2025_tan, Guo2025 = guo_2025_tan)
h1_populations <- list(H1_screening_panel = h1_panel, H1_FDR05_hits = h1_hits)

cat("\nMarker set coverage in universe:\n")
for (nm in names(marker_sets)) {
  ms <- marker_sets[[nm]]
  present <- intersect(ms, universe)
  cat(" ", nm, ":", length(present), "of", length(ms), "genes present in universe",
      "| missing:", paste(setdiff(ms, universe), collapse = ", "), "\n")
}

# --- hypergeometric + Jaccard, for each (population x marker set) combination ---
results <- data.frame()
for (pop_name in names(h1_populations)) {
  pop <- intersect(h1_populations[[pop_name]], universe)
  for (marker_name in names(marker_sets)) {
    ms <- intersect(marker_sets[[marker_name]], universe)
    overlap_genes <- intersect(pop, ms)
    k <- length(pop)          # population size (draws)
    m <- length(ms)           # "successes" available (marker set size)
    n <- universe_size - m    # "failures" available
    x <- length(overlap_genes)
    p_hyper <- phyper(x - 1, m, n, k, lower.tail = FALSE)
    jaccard <- length(overlap_genes) / length(union(pop, ms))
    results <- rbind(results, data.frame(
      population = pop_name, marker_set = marker_name,
      population_size = k, marker_set_size = m, overlap = x,
      overlap_genes = paste(overlap_genes, collapse = "; "),
      p_hyper = p_hyper, jaccard = jaccard
    ))
  }
}
results$fdr <- p.adjust(results$p_hyper, method = "BH")
cat("\n--- H5c overlap results (Wu 2024 excluded -- see header) ---\n")
print(results[, c("population", "marker_set", "population_size", "marker_set_size",
                   "overlap", "p_hyper", "fdr", "jaccard")])
cat("\nOverlapping genes by combination:\n")
for (i in seq_len(nrow(results))) {
  cat(" ", results$population[i], "x", results$marker_set[i], ":",
      ifelse(results$overlap_genes[i] == "", "(none)", results$overlap_genes[i]), "\n")
}

cat("\nEvidence grade: EXPLORATORY, fixed a priori regardless of this result (pre-registered,",
    "CHANGELOG.md) -- a set-overlap comparison is not a response-outcome test.\n")
cat("Wu et al. 2024 (Cell, PMID 38447573) excluded from this quantitative test -- confirmed",
    "paywalled, zero gene symbols named in its accessible abstract, zero NCBI-curated",
    "PubMed-to-Gene links. Documented as a limitation, not approximated.\n")

saveRDS(list(results = results, h1_panel = h1_panel, h1_hits = h1_hits,
             marker_sets = marker_sets, universe_size = universe_size),
        "results/h5c_literature_concordance.rds")
write.csv(results, "results/h5c_literature_concordance.csv", row.names = FALSE)
cat("\nSaved: results/h5c_literature_concordance.csv, results/h5c_literature_concordance.rds\n")
