# Experimental Translation (Module 08)

**Status: complete.** This module is exempt from the six-heading (Hypothesis → Analysis →
Evidence → Interpretation → Limitations → Conclusion) template per the frozen architecture
(`CONTINUATION_BRIEF.md` §2) — it proposes validation for findings established elsewhere, it
does not test a hypothesis of its own.

**Scope rule (binding, applied throughout):** one proposed validation experiment per
computational finding graded **Moderate or Strong** in `results/evidence_ledger.tsv` —
**no more, no fewer**. Exploratory and Negative-finding entries (H2-secondary, H4-secondary,
H4-communication, H5a's CCL3/CCL4/CXCL13, H5b, H5c) are explicitly excluded — proposing
experimental validation for an Exploratory or negative result would misrepresent its own
stated confidence. No new biology, mechanism, or hypothesis is introduced anywhere in this
module — every validation below tests exactly the finding already recorded in the
referenced ledger row, via a more direct experimental modality, nothing more.

**Wording note (added 2026-08-02, after independent peer review; see `03_recruitment/README.md`
addendum #1 and root `README.md`):** the phrase "recruitment-programme" below refers to H1's
discovered immune-compartment secretory programme, using the module's original working label —
it is not a claim that the programme is neutrophil-specific, which a post-hoc audit found this
dataset cannot support. The validation proposals themselves are unaffected by this wording
correction.

Four ledger rows meet the Moderate/Strong threshold: `H0` (Strong), `H1` (Moderate),
`H2` (Moderate, primary compartment-attribution component only — its secondary component is
Exploratory and is excluded), `H4` (Moderate, TF-activity component only — its secondary and
communication components are Exploratory/Negative and are excluded).

---

## H0 → Validation of the neutrophil-depletion protocol artefact

| | |
|---|---|
| **Computational finding** (`evidence_ledger.tsv` row `H0`, grade **Strong**) | Neutrophils are depleted to near-completeness in public melanoma scRNA-seq (GSE120575, GSE72056) by CD45+ FACS sorting plus Smart-seq2 plate-picking — a protocol artefact, not evidence of biological absence from the tumours. |
| **Proposed validation** | A non-excluding profiling protocol on fresh melanoma biopsies: (a) conventional or spectral flow cytometry with a neutrophil-inclusive gating scheme (CD45+CD15+CD66b+CD16+), which does not depend on the fragile live-cell sorting/plate-picking steps implicated in the depletion; or (b) fixed-cell scRNA-seq chemistry (e.g. fixed/methanol-compatible droplet profiling), which similarly avoids the live-sort fragility step. |
| **Readout** | Proportion of CD15+CD66b+ cells among CD45+ live cells (flow cytometry); presence and proportion of a transcriptionally distinct neutrophil cluster (canonical markers: `CEACAM8`, `MPO`, `ELANE`, `FCGR3B`, `CSF3R`) in fixed-chemistry scRNA-seq. |
| **Prediction** | If H0's protocol-artefact interpretation is correct, a non-excluding protocol on the same tumour type should recover neutrophils at proportions consistent with flow-cytometry-based melanoma literature (not the single-digit absolute cell counts observed in GSE120575/GSE72056). |
| **Falsification criterion** | If neutrophils remain undetectable (comparably rare, <1% of CD45+ cells) even under a protocol that does not depend on the implicated fragile steps, this would falsify H0's protocol-artefact interpretation and instead support genuine biological depletion — directly contradicting this project's H0 conclusion, not merely qualifying it. |

## H1 → Validation of the recruitment-programme discovery hits

| | |
|---|---|
| **Computational finding** (`evidence_ledger.tsv` row `H1`, grade **Moderate**) | LTB, CCL3, CCL4, and CXCL13 show pre-treatment, patient-level pseudobulk expression differences by ICB response in the GSE120575 discovery cohort (LTB higher in responders; CCL3, CCL4, CXCL13 higher in non-responders). |
| **Proposed validation** | Multiplex immunofluorescence or RNAscope (RNA in situ hybridization) for the same four genes on an independent pre-treatment melanoma biopsy cohort with documented RECIST response, quantified per unit tissue area — a direct protein/transcript-level, tissue-resolved readout, distinct from the bulk-RNA-seq modality already used in H5a. |
| **Readout** | Per-marker staining intensity (IF) or transcript dot count (RNAscope) per mm² of tissue, correlated with response status. |
| **Prediction** | LTB signal higher in responder tissue; CCL3, CCL4, CXCL13 signal higher in non-responder tissue, matching H1's discovery-cohort direction. |
| **Falsification criterion** | For any individual marker, a null or reversed direction in an adequately powered independent tissue cohort would mean that marker's H1 finding is not corroborated at the protein/transcript-in-tissue level. (Context, not a substitute for this proposal: H5a already tested bulk-RNA-seq replication for these same 4 genes and found CCL3/CCL4/CXCL13 did not replicate and LTB was Exploratory-only — this IF/RNAscope validation targets a genuinely different modality and readout, not a repeat of H5a.) |

## H2 → Validation of compartment-specific ligand attribution

| | |
|---|---|
| **Computational finding** (`evidence_ledger.tsv` row `H2`, grade **Moderate**, primary compartment-attribution component only) | H1's hits decompose by cellular source: `CCL3`→Myeloid, `TYMP`/`GPI`→Myeloid, `CCL4`/`CCL4L2`/`CD320`→NK, `LTB`→B cell, `CXCL13`→T cell. |
| **Proposed validation** | Multiplex immunofluorescence co-staining each ligand with its attributed compartment's canonical marker on the same tissue sections (`CCL3`+`CD68`/`CD15`; `CCL4`+`CD56`/`NKp46`; `LTB`+`CD20`; `CXCL13`+`CD3`/`CD4`) — or compartment-sorted (flow-sorted) bulk RNA-seq/qPCR for these specific genes in each sorted population. |
| **Readout** | Co-localization proportion (% of ligand+ cells that are also compartment-marker+) via IF; or relative per-compartment expression level via sorted-population qPCR/RNA-seq. |
| **Prediction** | Each ligand's expression/co-localization should be highest specifically in its attributed compartment (e.g. `CCL3` predominantly in `CD68+` myeloid cells, not `CD20+` B cells). |
| **Falsification criterion** | If a ligand shows no enrichment in its attributed compartment relative to the others (e.g. `CCL3` shows no myeloid-specific co-localization), this would falsify that specific compartment-attribution call from H2. |

## H4 → Validation of TF-regulatory coherence

| | |
|---|---|
| **Computational finding** (`evidence_ledger.tsv` row `H4`, grade **Moderate**, TF-activity component only) | The recruitment programme is regulatorily coherent: TF activity (inferred via `decoupleR::run_ulm()`, not directly measured) organizes into ~31 effective independent programs / 13 correlated modules, dominated by an E2F proliferation module and a metabolic/nuclear-receptor module (both elevated in non-responders), opposed by a lymphocyte-differentiation module (`IKZF3`/`BACH2`/`SATB2`, elevated in responders). |
| **Proposed validation** | Direct TF-occupancy measurement — CUT&RUN or ChIP-seq for representative TFs from each named module (`E2F1` for the proliferation module; `SREBF1`/`PPARA` for the metabolic module; `IKZF3`/`BACH2` for the lymphocyte module) on matched pre-treatment biopsies stratified by response; or ATAC-seq footprinting at the same TF motifs, as a lighter-weight alternative. |
| **Readout** | TF binding-site occupancy or chromatin accessibility at each TF's CollecTRI-defined target-gene promoters, compared between responder and non-responder tumours. |
| **Prediction** | `E2F1` and `SREBF1`/`PPARA` occupancy/accessibility at their target genes should be higher in non-responder tumours; `IKZF3`/`BACH2` occupancy should be higher in responder tumours — matching the inferred activity-score direction. |
| **Falsification criterion** | If direct occupancy/accessibility shows no response-associated difference, or a difference opposite to the inferred activity score, for a given TF, this would falsify that TF's specific regulatory-coherence claim from H4. (Context, not a substitute for this proposal: H5b already tested bulk-RNA-seq module-score replication for these same two modules and found neither replicated — this occupancy-based validation targets mechanism directly, a genuinely different question from a second expression-based association test.) |

---

## Explicitly not proposed (and why)

Per the scope rule above, the following ledger entries are **not** given validation
proposals, stated here for completeness/auditability rather than silently omitted:

- **H2 secondary** (Exploratory) — regulation-vs-abundance mismatch finding; Exploratory
  grade does not meet the Moderate/Strong threshold.
- **H4 secondary** (Exploratory) — compartment-level TF-activity follow-up; same reasoning.
- **H4 communication** (Exploratory, Negative finding) — a negative pre-specified test does
  not warrant a validating experiment; its Descriptive observation (checkpoint-pair pattern)
  is explicitly a Hypothesis for later synthesis, not evidence, and is addressed (if at all)
  in `09_synthesis`, not here.
- **H5a** (Exploratory for LTB; Negative finding for CCL3/CCL4/CXCL13) — the LTB validation
  proposed above (under H1) already covers this gene at the appropriate Moderate-grade tier;
  CCL3/CCL4/CXCL13's H5a Negative findings do not themselves warrant a new validation
  proposal (their H1 discovery-cohort finding, still Moderate, is what is validated above).
- **H5b** (Negative finding, both modules) — same reasoning as H4-communication.
- **H5c** (Exploratory, fixed a priori) — a literature-concordance set-overlap result does
  not warrant a validating experiment regardless of its p-values, per its own pre-registered
  grade ceiling.

## Reproducibility note

This module performs no computation — every entry above is stated directly from the
already-committed, already-verified evidence ledger, module READMEs, and figures. There is
nothing to rerun or verify for numerical reproducibility; the four findings referenced here
were already independently reproducibility-checked (exact rerun, diffed against committed
output) in their own modules (H0–H4).
