# Tumour-derived neutrophil recruitment and signalling programmes in melanoma immune checkpoint response

## Central question

Which tumour-derived neutrophil recruitment and functional signalling programmes distinguish
immune checkpoint responders from non-responders in human melanoma?

Discovery (module `03_recruitment`) screens the full secreted chemokine/cytokine/growth-factor
repertoire without prior restriction to any pathway. Only after the discovery ranking is fixed
and committed does interpretation (`09_synthesis`) ask, post hoc: *does the highest-ranked
programme converge on a therapeutically targetable axis?* No pathway is named or privileged in
the discovery analyses.

## Negative Results Policy

This project reports biologically meaningful negative findings with equal priority to positive
findings. Failure of a signalling programme to replicate, absence of recoverable neutrophils,
lack of external validation, disagreement with published studies, or non-significant results
are treated as informative biological or technical observations, not omitted. No analysis is
removed, rewritten, or downplayed solely because it produces a negative result. Every entry in
`results/evidence_ledger.tsv` carries a `result_direction` field (`positive` / `negative` /
`null`) so this is auditable, not asserted.

The policy has already been exercised: H0 returned a negative result (no recoverable neutrophil
population), which removed one planned hypothesis from the study. That outcome is reported as a
substantive finding in `02_dataset_audit/README.md`, not as a setback.

## Hypothesis map

| # | Hypothesis | Module | Figure | Status |
|---|---|---|---|---|
| H0 | Neutrophil representation in public melanoma scRNA-seq is determined by protocol and QC, not tumour biology | `02_dataset_audit` | 1 | **Complete — supported, Strong** |
| H1 | ICB-resistant melanomas exhibit enhanced neutrophil-recruitment signalling programmes | `03_recruitment` | 2 | **Complete — Moderate** |
| H2 | Neutrophil-recruiting signalling is compartment-restricted rather than uniformly distributed | `04_cellular_sources` | 3 | **Complete — Moderate/Exploratory** |
| H3 | TANs occupy reference-defined functional states; resistance associates with immunosuppressive rather than antigen-presenting programmes | `05_neutrophil_states` | — | **Omitted** — H0 established <20 recoverable neutrophils; see `CHANGELOG.md` |
| H4 | The recruitment programme is regulatorily coherent and its intercellular communication converges on T-cell suppression | `06_regulation_communication` | 4 | Not started |
| H5 | The programme generalises to independent cohorts and agrees quantitatively with published TAN biology | `07_validation_concordance` | 5 | Not started |
| — | Synthesis (not a hypothesis test) | `09_synthesis` | 6 | Not started |

Every module follows: **Hypothesis → Analysis → Evidence → Interpretation → Limitations →
Conclusion**, and every conclusion is graded Strong / Moderate / Exploratory in
`results/evidence_ledger.tsv`.

## Status

Architecture frozen 2026-08-01. Environment and repository scaffolding complete.

- **H0 (`02_dataset_audit`): complete.** Supported at Strong grade across two independent
  datasets (GSE120575, GSE72056). Result: neutrophils are depleted to near-completeness by
  CD45+ sorting plus Smart-seq2 plate-picking — single-digit recoverable candidates in both
  cohorts. This placed the project on the pre-specified `<20` branch of the failure-tolerant
  decision tree, omitting H3.
- **H1 (`03_recruitment`): complete, Moderate grade.**
  Patient-level pseudobulk (19 pre-treatment patients, GSE120575), unbiased screen of a
  327-gene GO-sourced chemokine/cytokine/growth-factor panel. 4 genes significant at FDR<0.05,
  top finding (LTB) concordant with published tertiary lymphoid structure biology — concordance,
  not independent validation; that remains H5's objective. Grade capped at Moderate pending
  H5's independent-cohort validation, not a gap in H1 itself. Full
  ranked table and stated limitations (therapy confound, panel attrition) in
  `03_recruitment/README.md`.
- **H2 (`04_cellular_sources`): complete.** Primary test
  (Moderate): 34 of 35 H1-tested genes show significant compartment restriction; H1's hits
  decompose into a myeloid/NK chemotactic axis (CCL3, TYMP, GPI, CCL4, CCL4L2, CD320) and a
  lymphocyte organisational axis (LTB from B cells, CXCL13 from T cells). Secondary test
  (Exploratory): regulation can be compartment-specific independent of where a gene is most
  abundant. Open gap, stated not hidden: Myeloid could not be tested for response-association
  at adequate power (3 usable responder patients), so CCL3/TYMP's myeloid origin for their H1
  response-association remains unconfirmed. Full results and limitations in
  `04_cellular_sources/README.md`.
- **H3–H5: H3 omitted (see above); H4–H5 not started.**

See `REPRODUCIBILITY.md` for exact reproduction instructions and `CHANGELOG.md` for every
post-freeze deviation and its justification.
