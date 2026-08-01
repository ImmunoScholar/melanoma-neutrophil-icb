# Tumour-derived neutrophil recruitment and signalling programmes in melanoma immune checkpoint response

## Central question

Which tumour-derived neutrophil recruitment and functional signalling programmes distinguish
immune checkpoint responders from non-responders in human melanoma?

Discovery (module `03_recruitment`) screens the full secreted chemokine/cytokine/growth-factor
repertoire without prior restriction to any pathway. Only after the discovery ranking is fixed
and committed does interpretation (`09_synthesis`) ask, post hoc: *does the highest-ranked
programme converge on the therapeutically targetable CXCL8–CXCR1/2 axis?* No pathway is named
in the discovery analyses.

## Negative Results Policy

This project reports biologically meaningful negative findings with equal priority to positive
findings. Failure of a signalling programme to replicate, absence of recoverable neutrophils,
lack of external validation, disagreement with published studies, or non-significant results
are treated as informative biological or technical observations, not omitted. No analysis is
removed, rewritten, or downplayed solely because it produces a negative result. Every entry in
`results/evidence_ledger.tsv` carries a `result_direction` field (`positive` / `negative` /
`null`) so this is auditable, not asserted.

## Hypothesis map

| # | Hypothesis | Module | Figure |
|---|---|---|---|
| H0 | Neutrophil representation in public melanoma scRNA-seq is determined by protocol and QC, not tumour biology | `02_dataset_audit` | 1 |
| H1 | ICB-resistant melanomas exhibit enhanced neutrophil-recruitment signalling programmes | `03_recruitment` | 2 |
| H2 | Neutrophil-recruiting signalling is compartment-restricted rather than uniformly distributed | `04_cellular_sources` | 3 |
| H3 | TANs occupy reference-defined functional states; resistance associates with immunosuppressive rather than antigen-presenting programmes | `05_neutrophil_states` (conditional on H0) | 4 |
| H4 | The recruitment programme is regulatorily coherent and its intercellular communication converges on T-cell suppression | `06_regulation_communication` | 5 |
| H5 | The programme generalises to independent cohorts and agrees quantitatively with published TAN biology | `07_validation_concordance` | 6 |
| — | Synthesis (not a hypothesis test) | `09_synthesis` | 7 |

Every module follows: **Hypothesis → Analysis → Evidence → Interpretation → Limitations →
Conclusion**, and every conclusion is graded Strong / Moderate / Exploratory in
`results/evidence_ledger.tsv`.

## Status

Architecture frozen 2026-08-01. Environment and repository scaffolding complete. No analysis
has yet been run.

See `REPRODUCIBILITY.md` for exact reproduction instructions and `CHANGELOG.md` for any
post-freeze deviation and its justification.
