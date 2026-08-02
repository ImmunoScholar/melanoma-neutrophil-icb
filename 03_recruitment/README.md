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

## Conclusion

**Discovery screen complete. Evidence grade: Moderate.** Patient-level statistics and
multiple-testing correction are satisfied; the top finding (LTB) is concordant with an
independent published mechanism. Grade is capped at Moderate rather than Strong because H1 has
no cross-dataset replication of its own — that is explicitly H5's role, not a gap in this
module. This grade will be revisited once H5 completes.

No hypothesis is rejected or confirmed at this stage regarding the specific biological
mechanism; H1 establishes *that* a signal exists and *what it ranks as*, unbiased. Its
biological interpretation continues in H2 (source), H4 (network), and H5 (validation).
