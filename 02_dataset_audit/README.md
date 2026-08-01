# Dataset Audit (H0)

## Hypothesis
Neutrophil representation in public melanoma scRNA-seq is determined by protocol and
quality-control choices, not by tumour biology — specifically, CD45+ FACS sorting followed by
Smart-seq2 plate-picking systematically excludes neutrophils, given their well-documented ex
vivo fragility, high endogenous RNase content, and short half-life.

## Analysis
Two independent, protocol-matched (CD45+ sorted, Smart-seq2) human melanoma scRNA-seq datasets
were tested for recoverable neutrophils in their **unfiltered** expression matrices, using a
panel of eight canonical human neutrophil markers (FCGR3B, CSF3R, CEACAM8, MPO, ELANE, FUT4,
S100A8, S100A9), with three primary-granule genes (CEACAM8, MPO, ELANE) treated as the most
lineage-specific subset. A single marker is uninformative — genuine neutrophils express the
granule programme coordinately — so the test is **co-occurrence** across the specific subset,
not per-gene positivity.

- **GSE120575** (Sade-Feldman et al. 2018): 16,291 cells, 48 samples, 30 patients paired
  pre/post ICB. Co-occurrence tested against a chance-level null computed from each marker's
  observed individual positivity rate.
- **GSE72056** (Tirosh et al. 2016): 4,645 cells, independent cohort, independent processing
  (different year, lab, and normalization: `log2(TPM/10+1)`, back-transformed to
  TPM-equivalent). Absolute-threshold comparability between the two datasets was found NOT to
  hold (see Limitations), so replication used an orthogonal check instead: cross-referencing
  co-occurrence candidates against cell-type annotations made independently by the original
  authors using their own T/B/Macrophage/Endothelial/CAF/NK panel — a panel which notably
  contains **no neutrophil category**, so a genuine neutrophil would appear as non-malignant
  and unassigned.

Unit of analysis: individual cells. Appropriate here because this module tests for the
*existence* of a population, not a differential-expression claim across patients; patient-level
pseudobulk is used from H1 onward, where group comparison is the actual test.

## Evidence

**GSE120575.** All eight markers detected. Positivity split into two tiers — broader markers
(FCGR3B, CSF3R, S100A8, S100A9) positive in 5.5–7.9% of cells, primary-granule markers
(CEACAM8, MPO, ELANE) in only 0.1–0.4%. Of 16,291 cells, **1** was positive for ≥2 of the 3
specific markers against a chance expectation of **~0.14** under independence; **0** were
positive for all three.

**GSE72056.** All eight markers detected. Individual positivity for the 3 specific markers was
far higher in absolute terms (45.9% of cells positive for ≥1), ruling out a like-for-like
chance comparison. 25 of 4,645 cells (0.5%) were positive for ≥2 specific markers. Cross-tabulating
those 25 against the original authors' independent annotations:

| `malignant` \ `celltype` | 0 (unassigned) | 1 (T cell) | 3 (macrophage) |
|---|---|---|---|
| 0 (unresolved) | 2 | 1 | 0 |
| 1 (non-malignant) | **4** | 11 | 2 |
| 2 (malignant) | 5 | 0 | 0 |

19 of 25 carry a confident alternative identity (12 T cells, 2 macrophages, 5 malignant).
**4 cells are non-malignant and unassigned** — the profile a genuine unrecognised neutrophil
would present. Two of these four share patient, plate well and sequencing index
(`cy88_cd_45_pos_H12_S480` and `CY88CD45POS_2_H12_S480`; duplicate signature `H12S480`
confirmed), i.e. an apparent duplicate entry — leaving **3 distinct candidates**, drawn from
only 2 patients (CY88, CY89). A further 2 unassigned cells have unresolved malignancy status.

## Interpretation

1. **What changed statistically.** GSE120575: co-occurrence at chance level (1 observed vs
   ~0.14 expected). GSE72056: 3 distinct non-malignant unassigned candidates among 4,645 cells
   (0.06%), from 2 patients — plus up to 2 more of unresolved status.
2. **Which biological process.** These two datasets differ, and it matters. In GSE120575 the
   signal is statistically indistinguishable from ambient/technical noise — most plausibly free
   RNA from neutrophils lysed during dissociation contaminating unrelated cells' lysates. In
   GSE72056, by contrast, a small number of cells are genuinely *consistent with* neutrophil
   identity and should not be dismissed as noise. What the two share is not "no neutrophil
   signal" but that the **recoverable number is negligible** — single digits, insufficient to
   define or map a cell state under any method.
3. **Tumour-immunology implication.** CD45+ sorting followed by Smart-seq2 plate-picking
   depletes neutrophils to near-completeness in both cohorts, despite neutrophils being CD45+
   and therefore not excluded by the sort gate itself. The loss is attributable to the
   downstream handling these protocols require (dissociation, plate-picking, and in
   GSE120575's case cryopreservation) rather than to absence from the tumours — a conclusion
   consistent with independent published characterisation of neutrophil loss in scRNA-seq.
4. **Translational implication.** None directly. This is a data-availability finding about
   which public resources can answer which questions, not a biological claim about melanoma.
5. **Validating experiment.** Not applicable to this finding, which concerns data availability
   rather than tissue biology — logged as such rather than skipped. See
   `08_experimental_translation` for how neutrophil biology would be assessed experimentally
   using a protocol that does not exclude them (e.g. fixed-cell chemistries, or flow cytometry
   which does not depend on transcript recovery at all).

## Limitations

Per the Negative Results Policy this negative finding is reported with the same weight as a
positive one, and is not treated as a setback — it is the evidence that determines how the
rest of the study is weighted.

- **An earlier version of this document stated that zero candidates fell into the
  non-malignant-unassigned category. That was incorrect** — the correct count is 4 (3 after
  resolving an apparent duplicate). The error arose from conflating `celltype == 0` with
  "malignant," when only 5 of the 11 `celltype == 0` candidates were in fact malignant. The
  correction does not change H0's conclusion or the decision-tree branch (3–4 cells remains
  far below the `<20` threshold), but it does change the interpretation from "entirely noise"
  to "a negligible number of plausible neutrophils." Corrected 2026-08-01 following an audit;
  see `CHANGELOG.md`.
- **Absolute TPM thresholds do not transfer across independently-processed public datasets.**
  The same `TPM > 1` threshold on the same three genes gave a ~100x difference in baseline
  positivity between GSE120575 (0.1–0.4%) and GSE72056 (45.9% for ≥1 marker). This is a real
  methodological finding (recorded in `REPRODUCIBILITY.md`), not an artefact to paper over: it
  means the two datasets could not be tested by identical statistics, and replication relied
  on an orthogonal, dataset-appropriate check.
- This module tests for the **existence** of a recoverable population. It does not exclude
  that a small number of true neutrophils are present — indeed GSE72056 suggests a handful
  are — only that no population large or confident enough to analyse exists.
- Two datasets were tested. A third (GSE115978) was deliberately excluded: replication past
  n=2 does not move the evidence grade under this project's own criteria, so it would add
  cost against a one-week budget for no marginal rigour. See `CHANGELOG.md`.

## Conclusion

**H0 is supported. Evidence grade: Strong.**

Grade justification, stated against this project's own rubric rather than assumed: the rubric
defines Strong as *"consistent direction in ≥2 independent datasets; patient-level statistics;
survives multiple-testing correction; concordant with ≥1 independent published report."* Two of
those four criteria — patient-level statistics and multiple-testing correction — were written
for the differential-expression claims in H1–H5 and **do not meaningfully apply to an
existence/absence claim**. The grade therefore rests on the two that do apply: consistent
direction across two independent, independently-processed datasets, and concordance with
published characterisation of neutrophil loss in droplet and plate-based scRNA-seq. This
mismatch is stated explicitly rather than glossed, so a reader can judge the grade themselves.

**Decision-tree branch taken:** fewer than 20 defensibly-recoverable neutrophils in either
dataset (1 in GSE120575; 3–4 in GSE72056). Per the frozen failure-tolerant design,
`05_neutrophil_states` (H3) is **omitted**, documented here as a protocol-driven limitation
rather than a project failure. Analytical weight shifts to H1, H2, H4 and H5 — none of which
require a single recovered neutrophil, since they test the tumour-side recruitment programme,
its cellular sources, its regulatory logic, and its external validation.
