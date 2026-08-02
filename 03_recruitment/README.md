# Recruitment Signalling Discovery (H1)

## Hypothesis
ICB-resistant melanomas exhibit enhanced neutrophil-recruitment signalling programmes,
detectable as differential expression of secreted chemokines, cytokines, and growth factors
between non-responders and responders. Screened without restriction to any named pathway —
discovery is unbiased across the full panel; interpretation against the CXCL8-CXCR1/2 axis
specifically is deferred to `09_synthesis`, after the ranking below is fixed.

## Analysis

**Sample.** GSE120575, pre-treatment cells only (post-treatment excluded to avoid the
treatment-effect confound — immune composition changes as a direct consequence of therapy,
which would conflate "tumours that were always going to respond" with "effects of therapy
having already worked"). 19 patients, 10 non-responder / 9 responder, 163-452 cells each,
5,928 cells total. Compartment-unrestricted (whole immune infiltrate) — compartment
attribution is H2's question, not H1's.

**Panel.** Union of three GO molecular function gene sets (`GOMF_CYTOKINE_ACTIVITY`,
`GOMF_CHEMOKINE_ACTIVITY`, `GOMF_GROWTH_FACTOR_ACTIVITY`, via `msigdbr`) — externally sourced
and pre-defined, not hand-selected, so the panel's composition cannot have been shaped by
knowing which genes would turn out significant. 327 of these genes are present in the
GSE120575 matrix.

**Pseudobulk.** Mean TPM per gene per patient, across that patient's cells. Genes with TPM>1
in fewer than 20% of patients (4 of 19) were dropped before testing — 35 of 327 genes passed,
set as a pre-specified criterion, not adjusted after seeing results.

**Model.** `log2(pseudobulk TPM + 1) ~ response`, fit via `limma::lmFit`/`eBayes` (not
`voom`/`edgeR`: GSE120575 is deposited as TPM only, no raw counts are available from GEO for
this dataset, and count-based mean-variance modelling is not valid on pre-normalised
continuous data — `limma`'s original workflow, designed for exactly this data type, is the
correct tool here). Benjamini-Hochberg FDR across all 35 tested genes. Direction convention:
positive logFC = higher in non-responders (associated with resistance).

**Unit of analysis:** patients (n=19), not cells — avoids the pseudo-replication that
per-cell testing would introduce.

## Evidence

35 genes tested. 4 significant at FDR<0.05: LTB (logFC -0.72, FDR 0.00025, higher in
responders), CCL3 (logFC +0.75, FDR 0.047), CCL4 (logFC +0.73, FDR 0.047), CXCL13 (logFC
+0.86, FDR 0.047). 9 significant at FDR<0.10 (adding TYMP, CCL4L2, GPI, CD320, FAM3C). Full
ranked table: `results/h1_discovery_screen_ranked.csv`.

**Confound check (reported, not adjusted for):** therapy type is unevenly distributed across
response groups — anti-PD1 monotherapy patients skew non-responder (8/12), anti-CTLA4+PD1
combination patients skew responder (4/5). n=19 does not comfortably support an added
covariate; this table is retained as an explicit caveat rather than adjusted away.

## Interpretation

1. **Statistical change.** 4 genes pass FDR<0.05 out of 35 tested (11%), well above the 5%
   expected by chance under the null, though with a small tested panel this alone is weak
   evidence of enrichment — the individual gene-level significance is the stronger claim.
2. **Biological process.** Two directions, not yet reconciled. LTB — central to lymphoid
   tissue organisation and tertiary lymphoid structure (TLS) formation — is elevated in
   responders. CCL3, CCL4 (monocyte/macrophage-attracting chemokines) and CXCL13 (canonically
   also part of the TLS/B-cell-follicular axis) are elevated in non-responders. CXCL13 running
   opposite to LTB, despite both being associated with the same TLS programme in the
   literature, is flagged as an open question rather than resolved here — it may reflect a
   different cellular source or a non-organised context for CXCL13 in this cohort, which H2
   (compartment attribution) and H4 (communication network) are positioned to address, not
   something bulk pseudobulk can settle alone.
3. **Tumour immunology implication.** The observed direction of LTB expression is concordant
   with previous reports linking lymphotoxin signalling and tertiary lymphoid structures to
   favourable immunotherapy response. This concordance increases the biological plausibility
   of the finding but should not be interpreted as independent validation. Formal validation
   remains the objective of H5, using external cohorts.
4. **Translational implication.** Not stated yet — premature ahead of H2 (source), H4
   (network context) and H5 (independent-cohort validation).
5. **Validating experiment.** Deferred to `08_experimental_translation`, once findings from
   subsequent modules are in and can be evaluated together rather than gene-by-gene here.

**Post-hoc audit addendum (2026-08-02, added after independent peer review; a dataset
measurement-capacity audit, not a new discovery finding).** An independent review of the whole
project raised a specific, checkable question: are LTB, CCL3, CCL4, and CXCL13 — the genes H1
actually found — genuinely *neutrophil*-recruitment factors, or is "neutrophil recruitment"
being used more loosely than the underlying biology supports? None of the four is a canonical
neutrophil chemoattractant (LTB/CXCL13 are lymphoid-organisation/TLS factors; CCL3/CCL4 signal
via CCR1/CCR5/CCR8, not the CXCR1/2 axis). `03_recruitment/05_neutrophil_specificity_audit.R`
checked this directly, using **only** H1's own already-computed panel-construction and
detection-filter logic (reproduced exactly, `stopifnot`-verified against H1's own committed
327-gene panel and 35-gene detection counts before checking anything new) — no gene was tested
against the response labels, no p-value was computed, this is a data-availability audit in the
same category as H0, not a new hypothesis test:

- Of the 8 canonical neutrophil chemoattractants checked (CXCL1, CXCL2, CXCL3, CXCL5, CXCL6,
  PPBP/CXCL7, CXCL8, CSF3 — the ELR⁺-CXC/CXCR1-2 axis plus G-CSF), **CXCL8 is absent from the
  expression matrix entirely**; the other 7 are present and are members of H1's 327-gene panel,
  but **all 7 fail H1's own 20%-detection filter by a wide margin** (5 of 7 detected in 0/19
  patients; the other 2 in 1/19 and 2/19). **Zero of the 8 ever entered H1's tested 35-gene
  table.** Full results: `results/neutrophil_chemoattractant_panel_audit.csv`.
- **Interpretation:** this is not an ambiguous or borderline result. Read alongside H0's own
  finding (near-zero neutrophil-marker co-occurrence at the cell level in this exact dataset,
  `02_dataset_audit/README.md`), it is a second, independent line of evidence for the *same*
  underlying constraint, at a different level: if the cells that predominantly produce this
  chemoattractant repertoire are depleted by CD45⁺-sorting plus Smart-seq2 plate-picking, the
  transcripts they would produce should also be near-undetectable in pseudobulk — which is
  exactly what is observed. This is not itself a new biological finding about melanoma; it
  corroborates H0's protocol-driven depletion conclusion and defines what this dataset could
  and could not measure.
- **Scope consequence for H1 (stated plainly, not softened):** H1's actual discovered
  programme cannot be described as "neutrophil recruitment" — the canonical neutrophil-
  recruitment repertoire was never statistically testable in this data, for the same
  protocol-driven reason H0 already established at the cell level. This is carried into
  `09_synthesis`'s revised framing of the project's central question and title.

## Limitations

Per the Negative Results Policy, both the confound and the panel attrition below are stated
plainly, not minimised.

- **Therapy-type confound**, described above under Analysis/Evidence — not adjustable given
  sample size, retained as an explicit limitation on causal interpretation.
- **Substantial panel attrition**: 292 of 327 candidate genes (89%) were excluded by the
  pre-specified detection filter before testing. This reflects real sensitivity limits of
  Smart-seq2 pseudobulk averaged across a T-cell-dominated sample (69% of cells, see
  `03_recruitment/01_compartment_audit.R`) rather than a flaw in the filter itself, but it
  means the discovery screen had substantially less statistical reach than the nominal
  327-gene panel size might suggest.
- **No cross-dataset replication available to H1 directly** — GSE72056 was scoped to H0
  replication only (see `CHANGELOG.md`). External validation is H5's role, using the Hugo and
  Riaz bulk ICB cohorts.
- **Modest sample size** (n=19) is typical for single-cell-derived clinical cohorts of this
  kind (comparable to the original Sade-Feldman analysis of the same data) but limits power
  for effects smaller than what's reported here.
- **H1's programme is not neutrophil-specific, and this dataset cannot test whether it is.**
  The post-hoc audit above (`05_neutrophil_specificity_audit.R`) found that none of the 8
  canonical neutrophil chemoattractants (CXCL1/2/3/5/6, PPBP, CXCL8, CSF3) clears H1's own
  detection filter — CXCL8 is absent from the matrix entirely, the other 7 are detected in at
  most 2 of 19 patients. LTB, CCL3, CCL4, and CXCL13 — the genes H1 actually found — are real,
  patient-level, multiply-corrected findings, but they are not evidence of a neutrophil-
  recruitment programme specifically; they describe a broader lymphoid-organisation/myeloid-NK
  chemotactic signature. This limitation is not adjustable within this dataset (same
  protocol-driven constraint as H0) and is carried into how the project's central question and
  title are framed in `09_synthesis`.

## Conclusion

**Discovery screen complete. Evidence grade: Moderate.** Patient-level statistics and
multiple-testing correction are satisfied; the top finding (LTB) is concordant with an
independent published mechanism. Grade is capped at Moderate rather than Strong because H1 has
no cross-dataset replication of its own — that is explicitly H5's role, not a gap in this
module. This grade will be revisited once H5 completes.

No hypothesis is rejected or confirmed at this stage regarding the specific biological
mechanism; H1 establishes *that* a signal exists and *what it ranks as*, unbiased. Its
biological interpretation continues in H2 (source), H4 (network), and H5 (validation).
