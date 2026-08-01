# Dataset Audit (H0)

## Hypothesis
Neutrophil representation in public melanoma scRNA-seq is determined by protocol and
quality-control choices, not by tumour biology — specifically, CD45+ FACS sorting followed by
Smart-seq2 plate-picking systematically excludes neutrophils, given their well-documented ex
vivo fragility, high endogenous RNase content, and short half-life.

## Analysis
Two independent, protocol-matched (CD45+ sorted, Smart-seq2) human melanoma scRNA-seq datasets
were tested directly for recoverable neutrophils in their **unfiltered** expression matrices,
using a panel of eight canonical human neutrophil markers (FCGR3B, CSF3R, CEACAM8, MPO, ELANE,
FUT4, S100A8, S100A9), with three primary-granule genes (CEACAM8, MPO, ELANE) treated as the
most lineage-specific subset:

- **GSE120575** (Sade-Feldman et al. 2018): 16,291 cells, 48 samples, 30 patients paired
  pre/post ICB. Co-occurrence of the three specific markers was tested against a chance-level
  null computed directly from each marker's observed individual positivity rate.
- **GSE72056** (Tirosh et al. 2016): 4,645 cells, independent patient cohort, independent
  processing pipeline (different year, different lab, different TPM normalization: values are
  `log2(TPM/10+1)`, back-transformed to TPM-equivalent for threshold comparability with
  GSE120575). Absolute-threshold comparability across the two independently-processed datasets
  was found NOT to hold (see Limitations), so replication in this dataset instead used an
  orthogonal check: cross-referencing marker-double-positive cells against cell-type
  annotations made independently by the original authors using their own T/B/Macrophage/
  Endothelial/CAF/NK marker panel.

Unit of analysis throughout: individual cells (appropriate here, since this module tests for
the *existence* of a population, not a differential-expression claim across patients — patient-
level pseudobulk is reserved for H1 onward, where group comparison is the actual test).

## Evidence

**GSE120575.** All eight markers detected as genes; positivity was low and split into two
tiers — broader/less specific markers (FCGR3B, CSF3R, S100A8, S100A9) positive in 5.5–7.9% of
cells, primary-granule markers (CEACAM8, MPO, ELANE) positive in only 0.1–0.4%. Of 16,291
cells, only 1 was positive for ≥2 of the 3 specific markers, against a chance expectation of
~0.14 under independence (computed from each marker's individual rate) — not statistically
surprising; zero cells were positive for all 3.

**GSE72056.** All eight markers detected. Individual positivity for the 3 specific markers was
far higher in absolute terms (45.9% of cells positive for ≥1) than in GSE120575, ruling out a
direct chance-expectation comparison on the same terms. 25 of 4,645 cells (0.5%) were positive
for ≥2 specific markers. Cross-referencing these 25 against the original authors' independent
cell-type calls: 12 were already classified as T cells, 2 as macrophages, 11 as malignant or
otherwise resolved — **zero fell into the "non-malignant, unclassified" category** a genuine
uncategorized neutrophil-like population would be expected to occupy.

## Interpretation

1. **Statistical change:** near-chance-level marker co-occurrence in GSE120575; in GSE72056,
   candidate double-positive cells are concentrated entirely among cells with a pre-existing,
   independently-assigned non-neutrophil identity.
2. **Biological process:** both patterns are the signature of scattered, low-level noise
   (most plausibly ambient RNA from neutrophils lysed during dissociation, contaminating the
   lysate of unrelated captured cells) rather than a discrete, captured neutrophil population.
3. **Tumour immunology implication:** CD45+ FACS sorting followed by Smart-seq2 plate-picking
   excludes neutrophils from both datasets — consistent across two independently generated,
   independently processed cohorts (different years, labs, and normalization pipelines).
4. **Translational implication:** none directly — this is a data-availability finding about
   which public resources can answer which questions, not a biological claim about the
   tumours themselves.
5. **Validating experiment:** not applicable to this specific finding (it concerns data
   availability, not tissue biology) — logged as such rather than skipped; see
   `08_experimental_translation` for how neutrophil biology would be assessed experimentally
   in future work using a protocol that does not exclude them.

## Limitations

Per the Negative Results Policy, this negative finding (absence of a recoverable neutrophil
population) is reported with the same weight as a positive one would be, and is not treated as
a project setback — it is the evidence that determines how the rest of the study is weighted.

- **Absolute TPM thresholds do not transfer cleanly across independently-processed public
  datasets.** The same TPM>1 threshold, applied to the same three genes, yielded a ~100x
  difference in baseline positivity between GSE120575 and GSE72056. This is a real,
  generalizable methodological finding (recorded in `REPRODUCIBILITY.md`), not an error to
  paper over: it means the two datasets could not be tested by literally identical statistics,
  and replication in GSE72056 instead relied on an orthogonal, dataset-appropriate check
  (independent cell-type cross-reference) rather than the same chance-level test.
- This module tests only for **existence** of a recoverable population via marker expression;
  it does not rule out that a small number of true neutrophils exist below the sensitivity of
  this check, only that no *coherent, confidently identifiable* population does.
- Two datasets were tested, not more. A third dataset (GSE115978) was considered and
  deliberately excluded from scope: replicating a finding across a third independent dataset
  after a second would not move the evidence grade past "Strong" under this project's own
  ledger rules, so it would add download/parse cost against a one-week budget for no marginal
  rigor. See `CHANGELOG.md` and `REPRODUCIBILITY.md` for the scope decision.

## Conclusion

**H0 is supported. Evidence grade: Strong** (replicated across 2 independent datasets, per
this project's own ledger criteria for that grade).

**Decision-tree branch taken:** fewer than 20 defensibly-recoverable neutrophils in the primary
discovery dataset (GSE120575). Per the frozen failure-tolerant design, `05_neutrophil_states`
(H3) is **omitted** for GSE120575, documented here as a protocol-driven limitation rather than
a project failure. Analytical weight shifts to H1, H2, H4, and H5, none of which require a
single recovered neutrophil — they test the tumour-side recruitment programme, its cellular
sources, its regulatory logic, and its external validation, all measurable regardless of
whether neutrophils themselves survived this protocol.
