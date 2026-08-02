# H4 communication analysis, continued: does T-cell-directed communication show enrichment
# for immunosuppression-associated receptors, and does this differ Responder vs Non-responder?
# Uses the confirmed structure from 07_h4_lr_communication.R (aggregate_rank column verified
# present, not assumed).
#
# Receptor panel is externally sourced (msigdbr GO:BP terms matching a pattern, not a
# hand-picked gene list) -- same discipline as H1's cytokine/chemokine panel. All matched GO
# term names are printed for transparency/audit, not silently unioned.
#
# Unit of analysis, stated plainly: EDGES within one network, not patients. Each response
# group produced exactly one pooled network (see 07's header comment) -- the Fisher's exact
# test below is a legitimate test of enrichment WITHIN a network, but comparing the two
# networks' results to each other is inherently descriptive, not an inferential
# Responder-vs-Non-responder hypothesis test the way H1/H2/H4-TF-activity are. This module's
# documentation will state this distinction explicitly, not blur it with the rest of H4.
#
# Discovery-discipline reminder: CXCL8/CXCR1/2 receive no special commentary here, whether or
# not they appear in the unbiased edge tables below.

suppressPackageStartupMessages(library(msigdbr))

agg_responder    <- readRDS("results/h4_lr_responder_aggregated.rds")
agg_nonresponder <- readRDS("results/h4_lr_nonresponder_aggregated.rds")

# --- externally-sourced immunosuppression-associated receptor panel ---
go_bp <- msigdbr(species = "Homo sapiens", collection = "C5", subcollection = "GO:BP")
matched_terms <- unique(go_bp$gs_name[grepl("NEGATIVE_REGULATION_OF.*T_CELL", go_bp$gs_name)])
cat("Matched GO:BP terms (pattern: NEGATIVE_REGULATION_OF.*T_CELL):\n")
print(matched_terms)
stopifnot("No matching GO terms found -- pattern needs revision, do not proceed on an empty panel" =
  length(matched_terms) > 0)

suppression_genes <- unique(go_bp$gene_symbol[go_bp$gs_name %in% matched_terms])
cat("\nSuppression-associated receptor panel:", length(suppression_genes), "genes",
    "(union of", length(matched_terms), "GO:BP terms)\n")

# --- annotate each network's edges: does the receptor (any subunit, for complexes) fall in
#     the externally-sourced panel? ---
annotate_network <- function(agg, label) {
  receptor_genes <- strsplit(agg$receptor.complex, "_", fixed = TRUE)
  agg$receptor_suppressive <- vapply(receptor_genes, function(g) any(g %in% suppression_genes), logical(1))
  agg$target_is_tcell <- agg$target == "T_cell"

  cat("\n=== ", label, " ===\n")
  cat("Total edges:", nrow(agg), "| T-cell-directed:", sum(agg$target_is_tcell),
      "| suppressive-receptor edges:", sum(agg$receptor_suppressive), "\n")

  tab <- table(TargetIsTcell = agg$target_is_tcell, SuppressiveReceptor = agg$receptor_suppressive)
  print(tab)
  ft <- fisher.test(tab)
  cat("Fisher's exact test (T-cell-directed x suppressive-receptor):",
      "OR =", round(unname(ft$estimate), 3), "| P =", format.pval(ft$p.value, digits = 3), "\n")

  sig <- agg[agg$aggregate_rank < 0.05, ]
  cat("Significant edges (aggregate_rank<0.05):", nrow(sig),
      "| of which T-cell-directed:", sum(sig$target_is_tcell),
      "| of which T-cell-directed AND suppressive-receptor:",
      sum(sig$target_is_tcell & sig$receptor_suppressive), "\n")
  if (sum(sig$target_is_tcell & sig$receptor_suppressive) > 0) {
    cat("Significant T-cell-directed suppressive-receptor edges:\n")
    print(sig[sig$target_is_tcell & sig$receptor_suppressive,
              c("source", "target", "ligand.complex", "receptor.complex", "aggregate_rank")])
  }

  list(annotated = agg, fisher = ft, contingency = tab)
}

result_responder    <- annotate_network(agg_responder, "Responder network")
result_nonresponder <- annotate_network(agg_nonresponder, "Non-responder network")

cat("\n=== Descriptive cross-network comparison (NOT an inferential R-vs-NR test --",
    "each network is a single pooled unit, see header) ===\n")
cat("Responder: OR =", round(unname(result_responder$fisher$estimate), 3),
    "| P =", format.pval(result_responder$fisher$p.value, digits = 3), "\n")
cat("Non-responder: OR =", round(unname(result_nonresponder$fisher$estimate), 3),
    "| P =", format.pval(result_nonresponder$fisher$p.value, digits = 3), "\n")

saveRDS(list(matched_terms = matched_terms, suppression_genes = suppression_genes,
             responder = result_responder, nonresponder = result_nonresponder),
        "results/h4_lr_suppression_enrichment.rds")
cat("\nSaved: results/h4_lr_suppression_enrichment.rds\n")
