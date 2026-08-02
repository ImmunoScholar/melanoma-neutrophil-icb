# Independent-Cohort Validation and Literature Concordance (H5)

**Status: H5a complete and frozen. H5b (TF-module replication) and H5c (literature
concordance) are not yet run** — see `CHANGELOG.md`'s pre-registration entry
(2026-08-02) for the full design fixed before any of H5's results existed.

## Hypothesis

The recruitment programme identified in H1 generalises to independent cohorts (H5a, this
module's content so far) and agrees quantitatively with published TAN biology (H5c, not yet
run). H5b (not yet run) additionally tests whether H4's TF-activity modules replicate.
**H5a specifically**: H1's FDR<0.05 hits — LTB, CCL3, CCL4, CXCL13 — show
response-associated differential expression, in the same direction as H1, in two independent
bulk RNA-seq cohorts (GSE78220, Hugo et al.; GSE91061, Riaz et al.).

## Analysis

**Confirmatory, pre-registered in full before this script was run** (`CHANGELOG.md`,
2026-08-02): genes, cohorts, statistical methods, and the grading rubric were all fixed in
advance. No gene was added, dropped, or re-selected after seeing results.

**Cohorts** (dataset audit: `07_validation_concordance/01_download_data.R`,
`02_h5_dataset_audit.R`, `03_h5_join_key_and_mapping_check.R`):
- **GSE78220** (Hugo et al. 2016): 28 samples total; 1 on-treatment sample (Pt16) excluded —
  the series is not entirely pre-treatment despite its title, confirmed not assumed. **n=27
  pre-treatment (15 Responder / 12 Non-responder)**, binarized as Complete+Partial Response
  vs Progressive Disease (the original paper's own convention).
- **GSE91061** (Riaz et al. 2017): 109 samples (65 patients, pre+on-treatment); restricted to
  pre-treatment, response-labeled samples. **n=49 (10 Responder / 39 Non-responder)**, 2
  UNK excluded, binarized as PRCR vs PD+SD (the original paper's own convention). The small
  Responder group (n=10) is a pre-declared power constraint, stated before any test was run.

**Statistical method, forced by each cohort's actual verified data type, not a stylistic
choice**:
- GSE78220 (FPKM-only, no raw counts): `limma::lmFit`/`eBayes` on `log2(FPKM+1)` — same
  justification as H1's own method choice for GSE120575.
- GSE91061 (true raw integer counts confirmed present): `edgeR`/`voom` — the statistically
  correct tool for count data, chosen over forcing `limma`-on-FPKM for superficial
  cross-cohort uniformity.
- Both cohorts: background genes (beyond the 4 pre-specified) were included only so
  `eBayes`/`voom`'s variance moderation and normalization have a realistic gene population to
  work from — never examined or reported individually. The 4 pre-specified genes were
  force-included regardless of any expression filter, so they could never be silently
  dropped. Direction convention matches H1 exactly: positive logFC = higher in non-responder.
  BH correction applied across the 4 pre-specified genes, within each cohort.

**Standing rule (binding, added at the project owner's instruction, applied without
exception)**: a replication verdict requires **both** concordant effect direction **and**
statistical significance (FDR<0.05) — neither alone establishes replication.

## Evidence

| Gene | H1 (GSE120575) logFC | GSE78220 logFC (P) | GSE91061 logFC (P) | Concordant in both? | Significant in either? |
|---|---|---|---|---|---|
| LTB | -0.721 | -0.196 (0.662) | -1.370 (0.077) | Yes | No |
| CCL3 | +0.753 | +0.754 (0.059) | **-0.913** (0.087) | No (GSE91061 reversed) | No |
| CCL4 | +0.731 | +0.344 (0.512) | **-0.919** (0.092) | No (GSE91061 reversed) | No |
| CXCL13 | +0.864 | **-0.165** (0.839) | **-2.352** (0.015) | No (both reversed) | Yes (GSE91061 only) |

Full results: `results/h5a_gene_replication_combined.csv`
(`07_validation_concordance/04_h5a_gene_replication.R`).

**Per-gene verdict, applying the pre-registered rubric exactly, both criteria jointly**:

- **LTB: Exploratory.** Same direction (higher in responder) in both validation cohorts,
  reaching significance in neither.
- **CCL3: Negative finding.** Reverses direction in GSE91061.
- **CCL4: Negative finding.** Reverses direction in GSE91061.
- **CXCL13: Negative finding.** Reverses direction in both validation cohorts (and is the one
  case that also reaches nominal significance in GSE91061 — significance in the *wrong*
  direction is explicitly not replication, per the standing rule).

A technical check (not a new statistical test) was run before accepting these direction
reversals as real: verified they are not an artefact of a coding error by confirming LTB — 
processed by the exact same code path in GSE91061 as CCL3/CCL4/CXCL13 — produces a direction
that *does* match H1 and published TLS biology. A systematic sign-flip bug would affect all
four genes identically, not three of four selectively. Sample sizes and response tallies in
the script output also match the pre-registered audit numbers exactly. The reversals are
treated as a genuine result.

## Interpretation

1. **Statistical change.** 1 of 4 pre-specified genes (LTB) shows direction-consistent,
   non-significant replication across two independent cohorts. 3 of 4 (CCL3, CCL4, CXCL13)
   fail to replicate by the pre-registered direction+significance rule, each reversing
   direction specifically in GSE91061.
2. **Biological process.** The lymphocyte-organisational signal (LTB, B-cell-derived per H2)
   shows the most consistent cross-cohort behaviour of H1's four hits, weakly. The
   myeloid/NK-derived chemotactic axis (CCL3, CCL4) and the T-cell-derived CXCL13 do not
   replicate in this pre-registered test.
3. **Tumour immunology implication.** None claimed for CCL3/CCL4/CXCL13 — a negative finding
   does not support an implication. For LTB, the direction consistency is noted but remains
   below the significance bar in both external cohorts; no implication is claimed beyond
   "not contradicted."
4. **Translational implication.** None drawn — three of four pre-specified negative findings
   and one non-significant exploratory result do not support a translational claim at this
   stage.
5. **Validating experiment.** Not applicable — a negative/exploratory replication result does
   not warrant a proposed validating experiment; deferred to `08_experimental_translation`
   only if `09_synthesis` finds independent corroborating context.

**Pre-declared interpretive caveats** (fixed at pre-registration, restated here as
context — not offered as post-hoc explanations for the specific pattern observed):

- The therapy-type composition of each validation cohort differs from GSE120575's mixed
  composition and from each other (GSE78220: anti-PD-1 only; GSE91061: anti-CTLA4+anti-PD-1
  mixed) — a known, pre-declared risk to replication assessment, stated in the
  pre-registration before this analysis was run.
- GSE91061's Responder group (n=10) is small — a pre-declared power constraint, stated before
  this analysis was run.

These caveats were fixed in advance specifically so they could not be selectively invoked
after seeing which genes did or did not replicate — they apply to the whole pre-registered
test, not assembled after the fact to explain this particular pattern.

## Limitations

Per the Negative Results Policy, three of four pre-specified negative findings are reported
in full, not downplayed.

- **3 of 4 pre-specified genes did not replicate** — CCL3, CCL4, CXCL13 all reverse direction
  in GSE91061 specifically. This is reported as a genuine result, not explained away.
- **LTB's replication is Exploratory, not Moderate or Strong** — direction-consistent but
  non-significant in both cohorts; this does not upgrade H1's own grade for LTB, which
  remains Moderate in `03_recruitment/README.md`, unchanged.
- **GSE91061's small Responder group (n=10)** limits power for all four genes in that cohort
  specifically — pre-declared, not discovered after the fact.
- **Therapy-composition differences across all three cohorts** (GSE120575 mixed; GSE78220
  anti-PD-1 only; GSE91061 anti-CTLA4+anti-PD-1 mixed) were pre-declared as a risk to
  replication assessment and are not adjusted for — sample sizes in each cohort are too small
  to support a therapy-stratified model.
- **H1's own conclusions are not reopened or reinterpreted by this result** — H5a is its own
  finding, cross-referencing H1, per this project's standing rule that corrections/updates
  are new entries, never silent retroactive edits.

## Conclusion

**Evidence grade: Exploratory (LTB); Negative finding (CCL3, CCL4, CXCL13)** — reported
per-gene, not averaged into one grade, because the four pre-specified genes carry genuinely
different outcomes under the identical pre-registered test (same convention as H2's
primary/secondary split: different confidence levels get separate treatment, never combined
to smooth over the difference).

H1's discovery-cohort finding is not altered by this result. H5a's own conclusion is narrow
and stated exactly as the pre-registration specifies: one gene (LTB) shows a
direction-consistent but statistically inconclusive signal across two independent cohorts;
three genes (CCL3, CCL4, CXCL13) do not replicate by the pre-registered, direction-and-
significance joint criterion. No broader biological synthesis is drawn here — any such
synthesis, if warranted, belongs in `09_synthesis`, after H5 is complete in full.
