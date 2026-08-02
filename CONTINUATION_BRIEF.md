# PROJECT CONTINUATION BRIEF

Generated 2026-08-02, at the H4 (`06_regulation_communication`) tool-installation stage.
This is the authoritative handoff document. A fresh session should read this in full before
taking any action, and should not re-derive or re-litigate any decision recorded here as frozen.

---

## 1. Project Overview

**Repository title (as it appears in `README.md`):** "Tumour-derived neutrophil recruitment
and signalling programmes in melanoma immune checkpoint response"

**Central biological question (FINAL, frozen, revision 3 — do not reword):**

> Which tumour-derived neutrophil recruitment and functional signalling programmes distinguish
> immune checkpoint responders from non-responders in human melanoma?

No pathway is named in this question. The CXCL8–CXCR1/2 axis is explicitly **banned from all
discovery analyses** and may only be raised post hoc in `09_synthesis`, after every discovery
ranking is already fixed and committed to git. This rule survived three separate design
refinement passes specifically to eliminate confirmation bias — it is the single most
carefully-protected rule in this project and must never be relaxed, even for "just a quick
technical check."

**Scientific motivation.** Neutrophil-to-lymphocyte ratio (NLR) is a well-established clinical
predictor of immune checkpoint blockade (ICB) failure in melanoma, but it is a peripheral blood
marker with no established tissue-level mechanism. Pan-cancer single-cell atlases (Wu et al.
*Cell* 2024; Guo et al. 2025; Wang et al. 2025) have mapped tumour-associated neutrophil (TAN)
states, but none are melanoma-specific, and melanoma TAN literature is nearly absent. This
project originally intended to fill that gap directly (map TAN states in melanoma scRNA-seq),
but that approach was abandoned after H0 (see §10) established that public melanoma scRNA-seq
datasets do not retain analyzable numbers of neutrophils. The project pivoted to measuring the
tumour-side **signalling that would recruit and shape neutrophils**, which is measurable in
exactly the datasets that lose the neutrophils themselves.

**Objectives.** Test, hypothesis by hypothesis (H0–H5, H3 omitted — see §2), whether a
neutrophil-recruitment and functional signalling programme (a) exists and differs by ICB
response (H1), (b) originates from identifiable cellular compartments (H2), (c) is regulatorily
coherent and structured as an intercellular communication network converging on T-cell
suppression (H4, in progress), (d) generalises to independent cohorts and published literature
(H5, not started), and (e) translates into biomarker/experimental proposals (`08`) and a
synthesised systems-level model (`09`).

**Why this project was designed this way.** Priya (the user) is building this as a PhD
application portfolio piece — see `[[user-profile]]` in Claude's memory system. The explicit
design brief (given verbatim at project start, still binding) demands: never fabricate results,
never skip computational steps, never assume code executed successfully, mentor-style
step-by-step guidance with biological AND computational rationale for every step, and a
repository that reads as a small rigorous translational research study, not a tutorial. Priya
performs all analysis execution herself, locally; Claude never assumes success without her
pasted output.

**Portfolio value.** Never stated inside the repository itself — per explicit user instruction,
no file may say the project was AI-generated or reference "closing profile gaps," CV value, etc.
The project must stand entirely on its own scientific merit in all repository-facing text.

---

## 2. Frozen Architecture

**Everything in this section is frozen as of 2026-08-01, after three design-refinement passes,
and confirmed unchanged through H0–H2's completion. Do not redesign any of it. Any deviation
requires a genuine technical or biological blocker and a `CHANGELOG.md` entry — never redesign
because something "would be more interesting."**

### Repository structure
```
melanoma-neutrophil-icb/
├── README.md                        Central question, hypothesis map, status, Negative Results Policy
├── CHANGELOG.md                     Every post-freeze deviation, with blocker + justification
├── REPRODUCIBILITY.md               System/package/dataset/runtime/gotcha record
├── CONTINUATION_BRIEF.md            This document
├── 01_background/README.md          Literature background (NOT six-heading format, see below)
├── 02_dataset_audit/                H0 — COMPLETE
├── 03_recruitment/                  H1 — COMPLETE
├── 04_cellular_sources/             H2 — COMPLETE
├── 05_neutrophil_states/README.md   H3 — OMITTED (template only, never populated)
├── 06_regulation_communication/     H4 — IN PROGRESS (this is where work resumes)
├── 07_validation_concordance/README.md   H5 — NOT STARTED
├── 08_experimental_translation/README.md NOT STARTED (NOT six-heading format)
├── 09_synthesis/README.md           NOT STARTED (NOT six-heading format)
├── R/
│   ├── neutrophil_markers.R         Shared H0 marker-detection functions
│   └── theme_project.R              Shared ggplot theme, palette, save_figure() wrapper
├── figures/                         figure1_h0..., figure2_h1..., figure3_h2... (.png + .svg each)
├── results/                         evidence_ledger.tsv + all per-module .csv/.rds outputs
├── data/raw/                        gitignored — GEO downloads, never committed
├── data/processed/                  gitignored — cached .rds objects (tpm.rds, meta.rds etc.)
├── renv.lock, renv/, .Rprofile      renv environment, P3M + Bioconductor mirrors configured
└── .gitignore
```

### Hypothesis map (from `README.md`, verbatim structure — figure numbers are load-bearing)

| # | Hypothesis | Module | Figure | Status |
|---|---|---|---|---|
| H0 | Neutrophil representation in public melanoma scRNA-seq is determined by protocol and QC, not tumour biology | `02_dataset_audit` | 1 | **Complete — Strong** |
| H1 | ICB-resistant melanomas exhibit enhanced neutrophil-recruitment signalling programmes | `03_recruitment` | 2 | **Complete — Moderate** |
| H2 | Neutrophil-recruiting signalling is compartment-restricted rather than uniformly distributed | `04_cellular_sources` | 3 | **Complete — Moderate/Exploratory** |
| H3 | TANs occupy reference-defined functional states; resistance associates with immunosuppressive rather than antigen-presenting programmes | `05_neutrophil_states` | — | **Omitted** (H0 <20 recoverable neutrophils) |
| H4 | The recruitment programme is regulatorily coherent and its intercellular communication converges on T-cell suppression | `06_regulation_communication` | 4 | **IN PROGRESS** |
| H5 | The programme generalises to independent cohorts and agrees quantitatively with published TAN biology | `07_validation_concordance` | 5 | Not started |
| — | Synthesis (not a hypothesis test) | `09_synthesis` | 6 | Not started |

Six figures total (not seven) — H3's omission means Fig 4 went to H4, Fig 5 to H5, Fig 6 to
synthesis. This renumbering is itself a logged, frozen decision (`CHANGELOG.md`).

### Module template (binding for modules 02–07 only)
Every hypothesis-testing module's `README.md` uses exactly these six headings, in this order:
**Hypothesis → Analysis → Evidence → Interpretation → Limitations → Conclusion.**

`01_background`, `08_experimental_translation`, and `09_synthesis` are explicitly **exempt**
from this template (logged spec clarification, `CHANGELOG.md`, 2026-08-01) — they state
background, propose validation, and synthesise across modules respectively, and forcing
Hypothesis/Evidence headings onto them would be empty ceremony.

### Interpretation framework (binding, every result, every module, no exceptions)
Five steps, in order, none skipped, never jumping from step 1 to step 4:
1. What changed statistically? (effect size + CI/FDR, unit of analysis stated)
2. Which biological process changed?
3. What might this imply for tumour immunology? (explicitly labelled as inference)
4. What is the translational/clinical implication? (explicitly labelled as hypothesis, never
   as finding)
5. What experiment would validate it? (cross-referenced to `08_experimental_translation`)

### Evidence hierarchy and grading
Every substantive conclusion decomposes into: **Observation → Interpretation → Biological
hypothesis → Clinical implication → Suggested validation**, recorded as one row in
`results/evidence_ledger.tsv` (tab-separated, 9 columns: `hypothesis, observation,
interpretation, biological_hypothesis, clinical_implication, suggested_validation,
result_direction, evidence_strength, justification`).

Grades:
- **Strong**: consistent direction in ≥2 independent datasets; patient-level statistics;
  survives multiple-testing correction; concordant with ≥1 independent published report.
- **Moderate**: significant at patient level with correction in discovery data, not yet
  externally replicated (or replicated with attenuated effect).
- **Exploratory**: descriptive, underpowered, uncorrected, or dependent on very few
  cells/patients.

**A conclusion not in the ledger does not appear in any README.** When a finding has
genuinely different confidence for two different claims (e.g. H2's primary vs. secondary
tests), it gets **two separate ledger rows**, never combined into one to average out the
confidence — this was done deliberately for H2 and is the expected pattern going forward.

### Failure-tolerant decision tree (already resolved for H3, pattern applies elsewhere)
```
H0 dataset audit → recoverable neutrophils?
  <20 (ACTUAL OUTCOME)  → H3 omitted, documented as protocol-driven limitation
  20–200                → H3 would have been exploratory only
  >=200, >=5 patients   → H3 would have been primary
```
No branch was allowed to produce a dead project; H1/H2/H4/H5 never depended on a single
recovered neutrophil.

### Negative Results Policy (binding, stated in root `README.md`)
Biologically meaningful negative findings are reported with equal priority to positive ones.
Failure to replicate, absence of a population, non-significant results, disagreement with
prior work — all are informative observations, never omitted or downplayed. The ledger's
`result_direction` column (`positive`/`negative`/`null`) makes this auditable, not just
asserted. **Already exercised twice**: H0's negative result (no neutrophils) drove H3's
omission; H2's secondary test openly reports that Myeloid's role in CCL3/TYMP could NOT be
confirmed (a stated gap, not hidden).

### Reproducibility policy
- `REPRODUCIBILITY.md` at root: System, Package management (with every known gotcha
  documented — see §6 and §10), Random seeds, Datasets (with checksums), Analysis order,
  Runtime (measured, never estimated), Figure regeneration, Fresh-clone reproduction sequence.
- Figures render via `ragg::agg_png` + `svglite` **exclusively** — base `png()`/cairo is not
  `renv`-pinned and is not byte-reproducible across machines. Enforced via `R/theme_project.R`'s
  `save_figure()` wrapper — always use it, never call `ggsave()` or base graphics devices
  directly.
- `renv`, snapshot type `all` (every package pinned, not just direct dependencies).

### Discovery discipline (binding, already stated above, restated for emphasis)
Discovery screens (H1's chemokine/cytokine panel, and whatever H4's TF/L-R analysis screens)
must be **unbiased and externally sourced** (e.g. GO gene sets via `msigdbr`, not hand-picked
gene lists) so panel composition cannot have been shaped — even unconsciously — by knowing
which genes would turn out significant. CXCL8/CXCR1/2 named nowhere before `09_synthesis`.

### Change control
Every deviation from this frozen architecture is logged in `CHANGELOG.md` with: what was
deviated from, the technical/biological blocker that forced it, and the justification for the
alternative. **Corrections to past errors are logged as new entries, not silently overwritten**
— the original error stays in the record (see H0's GSE72056 misclassification correction,
§10, as the template for how to do this).

### Standing process rules (from Claude's memory system, apply to every future turn)
- **Audit after every phase**: after every major analysis step/phase, re-read actual files
  (`git log`, `git ls-files`, READMEs, CHANGELOG, REPRODUCIBILITY, ledger) and verify claims
  against printed data, not against the earlier summary of it. This caught a material error
  once already (H0's GSE72056 miscount) and a figure bug twice (Fig 1, Fig 3).
- **Execution boundary**: pure infrastructure/tooling fixes (git plumbing, config, doc
  corrections, figure generation from already-committed results) — Claude may execute
  directly. Anything that is or touches new analysis (package installs, analysis code,
  anything producing a new scientific result) — Claude hands the code to Priya, she runs it,
  pastes output back. Never assume code executed successfully without her pasted output.
- **Figures are written AND run by Claude** (precedent set at Fig 1, confirmed through Fig 3)
  because they visualise already-committed, already-verified results — no new scientific
  claim. But **the rendered image must be inspected, and ideally cross-checked
  programmatically against the source CSV/ledger, before showing it to Priya** — "no error on
  render" is not sufficient evidence of correctness. This caught two real bugs (Fig 1 table
  column overlap; Fig 3 heatmap using `log(mean(x))` instead of the analysis's actual
  `mean(log(x))`, which flipped a near-tie compartment call).
- **Heredoc terminal pastes corrupt intermittently** — drop standalone closing braces,
  drop leading characters (e.g. "for" → "or"). Never assume a script that appears in the
  terminal transcript is what was actually saved; if execution fails with a syntax error,
  suspect paste corruption before suspecting logic.
- **UNC-path Windows-side file writes are not reliably visible to native WSL git processes.**
  Never write files that must be git-tracked correctly via the UNC path
  (`\\wsl.localhost\...`) directly — always write to the Windows scratchpad, then `cp` into
  the WSL filesystem via `wsl -d Ubuntu-24.04 -- cp ...`, then verify with `git status
  --porcelain` before committing.

---

## 3. Current Progress

### H0 (`02_dataset_audit`) — **COMPLETE**, Evidence grade: **Strong**
- **Objective**: determine whether neutrophils are recoverable from public melanoma scRNA-seq,
  before assuming either way.
- **Analyses completed**: marker co-occurrence test (CEACAM8/MPO/ELANE, the three most
  lineage-specific primary-granule genes) on GSE120575 (16,291 cells) and GSE72056 (4,645
  cells, independent cohort/lab/year/normalisation, scoped **only** to this replication).
- **Major findings**: GSE120575 — 1 cell positive for ≥2 specific markers vs. 0.14 expected by
  chance (exact subset-enumeration null). GSE72056 — 25 candidates; cross-referenced against
  the original authors' independent cell-type annotations (their panel has no neutrophil
  category): 12 T cells, 2 macrophages, 5 malignant, **4 non-malignant-and-unassigned** (2 of
  these share patient/well/sequencing-index — an apparent duplicate — leaving **3 distinct**),
  2 unresolved-unassigned.
- **Evidence grade**: Strong (replicated in 2 independent datasets; the rubric's
  patient-level-statistics/multiple-testing criteria don't literally apply to an
  existence/absence claim, and this mismatch is stated explicitly in the ledger rather than
  glossed over).
- **Caveats**: absolute TPM thresholds don't transfer across the two datasets (~100x base-rate
  difference), so GSE72056's replication used an orthogonal method (cell-type
  cross-reference), not an identical statistical test.
- **Files**: `02_dataset_audit/01_download_data.R`, `02_h0_gse120575.R`, `03_h0_gse72056.R`,
  `04_figure1.R`; `README.md`; `results/h0_gse120575_{marker_summary,cooccurrence,result}.*`,
  `results/h0_gse72056_{marker_summary,candidates,crosstab,result}.*`;
  `figures/figure1_h0_dataset_audit.{png,svg}`.
- **Decision-tree outcome**: <20 recoverable neutrophils → **H3 omitted**.
- **Remaining work**: none. Fully closed.

### H1 (`03_recruitment`) — **COMPLETE**, Evidence grade: **Moderate**
- **Objective**: unbiased discovery screen — does a secreted chemokine/cytokine/growth-factor
  programme differ between ICB responders and non-responders?
- **Analyses completed**: sanity check (19 pre-treatment, response-labeled patients, 10
  non-responder/9 responder, 163–452 cells each; response confirmed consistent per patient
  once restricted to pre-treatment — 2 patients, P28 and P4, have response labels that differ
  *cleanly by timepoint* in the raw metadata, not corrupted, resolved by the pre-treatment
  restriction). Gene panel: union of 3 `msigdbr` GO molecular-function terms
  (`GOMF_CYTOKINE_ACTIVITY`, `GOMF_CHEMOKINE_ACTIVITY`, `GOMF_GROWTH_FACTOR_ACTIVITY`), 327
  genes present in the matrix. Patient-level pseudobulk (mean TPM per patient), 35/327 genes
  passed a pre-specified detection filter (TPM>1 in ≥20% of patients). `limma::lmFit`/`eBayes`
  on `log2(pseudobulk TPM + 1)` (NOT `edgeR`/`voom` — see §10 for why).
- **Major findings**: 4 genes significant at FDR<0.05 — **LTB** (logFC −0.72, higher in
  responders, concordant with published tertiary lymphoid structure/TLS biology — concordance
  stated explicitly as NOT independent validation), **CCL3** (+0.75), **CCL4** (+0.73),
  **CXCL13** (+0.86) (all three higher in non-responders). 9 significant at FDR<0.10.
- **Evidence grade**: Moderate — capped below Strong because H1 has no cross-dataset
  replication of its own (GSE72056 was scoped to H0 only); H5 is where that replication would
  come from.
- **Caveats**: therapy-type confound found and reported, not adjusted for (n=19 too small) —
  anti-PD1 monotherapy skews non-responder (8/12), anti-CTLA4+PD1 combo skews responder (4/5).
  Substantial panel attrition (89% of 327 genes excluded by the pre-specified filter — kept as
  pre-specified despite the attrition, not loosened after seeing results). LTB vs. CXCL13
  directional tension flagged as an open question, explicitly not resolved in this module.
- **Files**: `03_recruitment/02_h1_sanity_check.R`, `03_h1_discovery_screen.R`,
  `04_figure2.R`; `README.md`; `results/h1_discovery_screen_{ranked.csv,summary.rds}`;
  `figures/figure2_h1_discovery_screen.{png,svg}`.
- **Remaining work**: none. Fully closed.

### H2 (`04_cellular_sources`) — **COMPLETE**, Evidence grades: **Moderate (primary) /
Exploratory (secondary)** — two separate ledger rows, deliberately not combined
- **Objective**: is H1's programme compartment-restricted, and — for its specific hits —
  which compartment carries the response-associated signal?
- **Analyses completed**: sanity check first (revealed Myeloid has only 3 usable responder
  patients of 11 total usable — a real power constraint that shaped a two-part design).
  **Primary test**: Kruskal-Wallis, patient-level pseudobulk, all 35 H1-tested genes, across
  T_cell/B_cell/Myeloid/NK (Mast/Malignant/Unassigned excluded — unusable cell counts; this
  doesn't split by response, so unaffected by Myeloid's power problem). **Secondary,
  pre-declared exploratory test**: within-compartment response comparison (same `limma` method
  as H1), restricted to T_cell/NK/B_cell (Myeloid excluded entirely) and to H1's 9 FDR<0.10
  hit genes.
- **Major findings**: Primary — **34 of 35 genes** significantly compartment-restricted
  (FDR<0.05); the one exception, RABEP1, is an intracellular trafficking protein, not a
  genuine secreted factor (a sensible exception, not a contradiction). H1's hits decompose:
  **LTB→B cell, CXCL13→T cell** (both lymphocyte-derived — this rules out a naive
  myeloid-vs-lymphocyte explanation for their directional tension but does NOT explain why
  they move oppositely, stated as still open); **CCL3/TYMP/GPI→Myeloid**;
  **CCL4/CCL4L2/CD320→NK**. Secondary — 7 of 27 tests significant at FDR<0.05; notably, the
  compartment carrying the significant response-difference is not always the
  dominant-expression compartment (CCL4: NK-dominant in magnitude, but T_cell carries the
  significant response signal; same pattern for LTB, dominant in B_cell but significant in
  T_cell) — a genuinely non-obvious secondary finding (regulation ≠ abundance).
- **Evidence grades**: Primary Moderate (same "no cross-dataset replication of its own"
  reasoning as H1). Secondary Exploratory (pre-declared, reduced power).
- **Caveats**: Myeloid's role in CCL3/TYMP's H1 response-association could **not** be confirmed
  at adequate power — stated as an open gap, not hidden. `B_cell.CCL4L2` result is degenerate
  (zero expression/variance in B cells; `logFC=0`, `P=1.0` exactly — limma's "zero sample
  variances" warning), explicitly flagged as uninformative rather than a genuine null.
- **Files**: `04_cellular_sources/01_h2_sanity_check.R`, `02_h2_compartment_attribution.R`,
  `03_figure3.R`; `README.md`; `results/h2_{compartment_specificity,
  within_compartment_response}.csv`; `figures/figure3_h2_cellular_sources.{png,svg}`.
- **Remaining work**: none. Fully closed.

### H3 (`05_neutrophil_states`) — **OMITTED**
Blank six-heading template only; never populated. This is correct and final — do not attempt
to populate it. The omission itself is the H0-driven finding, documented in `CHANGELOG.md` and
`README.md`.

### H4 (`06_regulation_communication`) — **IN PROGRESS, tool-installation stage only, no data
analysis yet run**
- **Objective**: is the recruitment programme regulatorily coherent (TF activity) and does its
  intercellular communication (ligand–receptor) structure converge on T-cell suppression?
- **What's actually been done so far** (this is the critical section — read carefully):
  1. `decoupleR` (Bioconductor) installed successfully via `renv::install("bio::decoupleR")`.
  2. `liana` (GitHub `saezlab/liana`) installed successfully — this was the install flagged as
     genuinely risky back in Phase 1 (heavy dependency tree via `OmnipathR`, `CellChat`,
     `basilisk`, ~60 packages total) and it went cleanly, no compile failures.
  3. Tool smoke test (`06_regulation_communication/00_tool_smoke_test.R`) hit a **real,
     external, currently-unresolved upstream bug**: `decoupleR::get_collectri()` fails because
     `OmnipathR` tries to resolve the organism name against
     `https://www.ensembl.org/info/about/species.html`, which now returns 404/403. Confirmed
     via web research as a known, currently-unfixed issue reported in `github.com/saezlab/
     decoupleR` issues #153 and #162, `github.com/saezlab/OmnipathR` issue #117, and
     `github.com/saezlab/CollecTRI` issue #19 — **no official fix exists as of this session**.
  4. **Plan A tried and FAILED**: passing `organism = 9606` (NCBI taxonomy ID for human)
     instead of the string `"human"` — documented as a valid alternative input type, but it
     still hits the same internal static-table fallback and the same
     `"argument is of length zero"` error inside `unnest_evidences()`. **Do not retry Plan A —
     it is confirmed not to work.**
  5. **Plan B SUCCEEDED**: downloaded CollecTRI directly from its own Zenodo archive (record
     `8222799`, file `human_prior_tri.csv`, the data release accompanying Müller-Dott et al.
     2023, MD5 `3cea7605838b07e19c8b2ad87b746f87`), completely bypassing `OmnipathR`/Ensembl.
     42,595 rows, columns `source`, `target`, `mor` (mode of regulation, +1/−1). Saved to
     `data/raw/collectri_human_prior_tri.csv` (correctly gitignored, not committed).
  6. `liana`'s tool check succeeded independently and cleanly (not affected by the same
     Ensembl issue): `show_resources()` lists 19 named resources; `select_resource
     ("Consensus")` returned 4,701 ligand-receptor pairs with correctly-cased human gene
     symbols (e.g. `LGALS9`, `PTPRC`, `MET`, `CD44`).
- **CRITICAL UNRESOLVED ISSUE — resolve this FIRST in the next session**: the gene symbols in
  the downloaded `human_prior_tri.csv` (`Myc`, `Spi1`, `Smad3`, `Smad4`, `Tert`, `Bglap`,
  `Jun`, `Stat5a`, `Stat5b`, `Il2`) are in **Title Case**, which is the **mouse** gene symbol
  convention — human gene symbols should be all-uppercase (`MYC`, `SPI1`, `SMAD3`, etc., as
  every gene in our own matrix already is, e.g. `LTB`, `CXCL13`). Despite the filename
  `human_prior_tri.csv`, this needs to be verified before use: either (a) this Zenodo record
  is mislabeled/actually mouse data and a different, genuinely human-cased CollecTRI source
  must be found, or (b) there is a legitimate explanation (unlikely for TF nomenclature, but
  not yet ruled out). **If used as-is against our human matrix's uppercase gene symbols, this
  network would silently fail to match almost anything — a near-total, non-obvious failure,
  not an error message.** Do not proceed to any TF-activity analysis until this is resolved.
- **Also unresolved**: `renv.lock` changes from the `decoupleR` and `liana` installs — commit
  status not confirmed as of this document. Check `git status` first; if uncommitted, that's
  legitimate infrastructure to commit directly (per the execution boundary) once verified
  correct.
- **Not yet designed**: the actual H4 analysis. TF activity (via `decoupleR`, once CollecTRI
  is properly sourced) can likely run directly on the pseudobulk structures already built for
  H1/H2 (patient-level or compartment-level `log2(TPM+1)` matrices) — no new data engineering
  needed there. Ligand–receptor analysis via `liana` is a bigger open design question: `liana`
  typically expects a `Seurat` or `SingleCellExperiment` object with per-cell expression and
  cluster/compartment labels, and **no such object has been built yet** — all work so far has
  used plain `data.table`/`data.frame` structures (`tpm.rds`, `meta.rds`,
  `gse120575_compartment_calls.csv`). Converting these into a `Seurat` object (or checking
  whether `liana` accepts a lighter-weight matrix + vector-of-labels input without the full
  `Seurat` wrapper) is real remaining design work for the next session, to be done with a
  sanity check first, matching the established pattern.
- **Files so far**: `06_regulation_communication/00_tool_smoke_test.R` only. No README
  content written yet (still blank six-heading template). No results, no figure.

### H5 (`07_validation_concordance`) — **NOT STARTED**
Blank six-heading template only. Will use GSE78220 (Hugo) and GSE91061 (Riaz) bulk cohorts,
neither downloaded yet (see §7).

### `08_experimental_translation` — **NOT STARTED**
Blank template (not six-heading format — proposes validation for findings established
elsewhere). Some content already anticipated in module READMEs (e.g. H0's suggested validation
of a non-excluding protocol) but nothing written in this module itself yet.

### `09_synthesis` — **NOT STARTED**
Blank template (not six-heading format). This is where the CXCL8–CXCR1/2 post-hoc question is
finally asked, and where the systems-level mechanistic Figure 6 gets built.

---

## 4. Scientific Findings So Far

*(Consolidated from §3; presented here specifically to prevent overstatement in future
sessions. Every finding below is exactly as strong as stated — no stronger.)*

1. **Neutrophils are not recoverable from public melanoma scRNA-seq at any usable scale.**
   Statistical evidence: co-occurrence at chance level (GSE120575) / cell-type-annotation
   cross-reference showing 3–4 genuinely plausible but vanishingly rare candidates (GSE72056).
   Interpretation: CD45+ sort + Smart-seq2 plate-picking depletes neutrophils, consistent with
   their known fragility — a protocol artefact, not evidence about the tumours. Limitations:
   existence claim, not a differential-expression claim; ledger criteria partially inapplicable,
   stated explicitly. Confidence: **Strong**. Externally validated: yes, by design (2 datasets
   is the validation). Awaiting further validation: no, this line of inquiry is closed.

2. **LTB (lymphotoxin-β) is elevated pre-treatment in ICB responders**, patient-level pseudobulk,
   GSE120575, FDR=0.00025 (the strongest H1 hit by a wide margin). Biological interpretation:
   concordant with published tertiary lymphoid structure (TLS) literature — **stated explicitly
   as biological plausibility, not independent validation** (Priya's own refinement, now
   verbatim in both `03_recruitment/README.md` and the ledger). Traces to the **B-cell**
   compartment (H2 primary test), with the significant response-difference specifically
   detectable in the **T-cell** compartment (H2 secondary test) — abundance and regulation are
   not co-located. Confidence: **Moderate**. Externally validated: no. Awaiting validation:
   yes, explicitly H5's role (Hugo/Riaz bulk cohorts).

3. **CCL3, CCL4, CXCL13 are elevated pre-treatment in ICB non-responders**, same dataset/method,
   FDR=0.047 each. CXCL13 traces to T cells (H2), same compartment as LTB, but opposite response
   direction — **this tension is explicitly flagged as unresolved**, not explained away; ruled
   out one explanation (myeloid vs. lymphocyte source) without finding the real one. CCL3 traces
   to Myeloid, CCL4 to NK (with T-cell carrying CCL4's significant response-difference).
   Confidence: **Moderate** (CCL3/CXCL13/CCL4 primary), **Exploratory** (their
   compartment-specific response attribution). Not externally validated; awaiting H5.

4. **The recruitment programme is almost universally compartment-restricted** (34/35 tested
   genes, Kruskal-Wallis FDR<0.05) — stated with the caveat that this is expected, not
   surprising, given four genuinely distinct immune lineages were compared; the informative
   content is *which* compartment dominates for each gene, not *that* restriction exists.
   Confidence: **Moderate**. Not externally validated.

5. **Myeloid's role in the CCL3/TYMP response-association is unconfirmed**, not negative —
   explicitly a power limitation (3 usable responder patients), not a tested-and-failed result.
   This is a stated gap, to be revisited if a future dataset or method allows.

No finding above should be described, in this project or in any summary of it, as more certain
than the grade assigned. In particular: nothing yet supports any claim about the CXCL8–CXCR1/2
axis specifically — that question has not been asked yet, by design.

---

## 5. Repository State

- **Directory structure**: as in §2, fully matches what's on disk as of the last commit.
- **Important scripts**: listed per-module in §3. Shared: `R/neutrophil_markers.R`,
  `R/theme_project.R`.
- **Important output files**: `results/evidence_ledger.tsv` (5 rows: header + H0 + H1 + H2
  primary + H2 secondary), `results/h0_*`, `results/h1_*`, `results/h2_*`,
  `results/gse120575_compartment_calls.csv`.
- **README status**: root `README.md` fully current (hypothesis map + status section reflect
  H0/H1/H2 complete, H3 omitted, H4 in progress not yet reflected there — **update this when
  H4 produces its first real result**). Module READMEs: `01_background` written in full;
  `02`/`03`/`04` written in full (six-heading); `05` blank (correct, omitted); `06` still blank
  template (H4 not yet documented); `07`/`08`/`09` blank templates (not started).
- **Evidence ledger status**: current through H2 (5 data rows). H4 will add at least one more
  row once it produces a real result.
- **Figure status**: Figures 1, 2, 3 complete, committed, verified (both visually and, for
  Fig 3, programmatically cross-checked against source data). Figure 4 (H4) not yet started.
- **CHANGELOG status**: current through the H0 GSE72056 correction, the script consolidation,
  and the H2 documentation — no entries yet for H4's tool-installation issues (the Ensembl/
  CollecTRI problem and its Zenodo workaround **should get a CHANGELOG entry** once resolved
  and used in a real analysis — this is exactly the kind of external, blocking issue the
  changelog exists to record).
- **REPRODUCIBILITY status**: current through H2. Needs updating once H4's tools/workarounds
  are finalized (the Ensembl `get_collectri()` failure and Zenodo fallback belong in the
  "Package management" gotchas list, matching the style already used for the `fread`
  2GB-string issue, the `vroom` buffer issue, etc.).
- **Git status**: as of the last confirmed commit, **28 commits** through H2's completion
  (`7d21236`, "Mark H2 fully complete now Figure 3 exists"). Since then, `decoupleR` and
  `liana` were installed (real `renv.lock` changes) but **commit status is unconfirmed** —
  check `git status --porcelain` first thing in the next session. `00_tool_smoke_test.R` also
  likely uncommitted.
- **Total commits**: 28 confirmed + at least the two package installs pending verification.

---

## 6. Computational Environment

- **Operating system**: Windows 11, with WSL2 running Ubuntu 24.04.4 LTS ("noble").
- **Host machine**: hostname `DESKTOP-OT1LJUD`, user `priya`. 6 cores, 10 GB RAM available to
  WSL2 (established as a real constraint — a full-matrix `is.na()` sweep on the GSE120575
  cache was OOM-killed; per-gene/per-subset operations are fine).
- **R version**: 4.6.1 "Happy Hop".
- **Python**: not used anywhere in this project (deliberately — R/Seurat ecosystem only, per
  the original project brief).
- **Package management**: `renv`, snapshot type `all`, P3M noble binaries for CRAN, P3M
  Bioconductor mirror configured in `.Rprofile` (with the documented harmless "error code 22"
  bootstrap warning — see §10). GitHub packages install directly via `renv::install("owner/
  repo")`.
- **renv status**: consistent as of H2's completion (`renv::status()` clean). Unconfirmed
  post-`decoupleR`/`liana` install — verify and commit first thing.
- **Important installed packages** (beyond base Seurat/tidyverse/Bioconductor stack from
  Phase 1): `GEOquery`, `msigdbr`, `patchwork`, `limma`, `decoupleR` (newly installed),
  `liana` + its ~60 dependencies including `OmnipathR`, `CellChat`, `basilisk` (newly
  installed, installed cleanly despite flagged risk).
- **Repository location**: `~/melanoma-neutrophil-icb` on the WSL2 **native Linux filesystem**
  (explicitly NOT under `/mnt/c` — WSL2 I/O across that boundary is slow and was avoided from
  project start).
- **Known installation issues**:
  - Bioconductor "error code 22" bootstrap warning on first install in any fresh library —
    harmless, self-resolves once `BiocManager` installs mid-call. Documented, do not
    re-investigate.
  - `decoupleR::get_collectri()` fails due to an external Ensembl URL change (§3/§10) —
    unresolved upstream, worked around via a static Zenodo download, but that download's gene
    symbol casing needs verification before use (§3, critical flag).
- **Expected execution workflow** (established, unchanged pattern):
  1. Claude writes an R script to a heredoc, gives it to Priya as a `cat > file <<'EOF' ...
     EOF` block followed by `Rscript --no-restore --no-save file`.
  2. Priya runs it in her Ubuntu terminal, pastes the full output back.
  3. Claude reads the output carefully (never assumes success), diagnoses any error using
     real evidence (web research for external/library bugs, not guessing), and either fixes
     directly (if infrastructure) or hands back corrected code (if analysis).
  4. Once a script's output is verified correct, Claude commits the script + its results
     (using the scratchpad+cp pattern for any file Claude itself needs to write, never raw
     UNC-path writes for anything git-tracked).
  5. Documentation (module README, evidence ledger, root README status) is written by Claude
     directly and deployed via the safe scratchpad+cp pattern, verified with `git status
     --porcelain` before committing.
  6. Figures are written AND run by Claude (see §2's standing rules), verified visually and
     ideally programmatically against source data, sent to Priya via `SendUserFile`, then
     committed.
  7. After every module completes, a consistency audit is performed (§2) before moving to the
     next module.

---

## 7. Dataset Status

| Accession | Purpose | Downloaded | Preprocessing | Quality | Role |
|---|---|---|---|---|---|
| **GSE120575** (Sade-Feldman et al. 2018) | Primary discovery | Yes, checksummed | Fully cached (`data/processed/GSE120575/{meta,tpm}.rds`); TPM column-typing bug found and fixed (§10); 55,738 genes x 16,291 cells | High — verified join key, verified compartment composition, verified response/patient/timepoint parsing including a genuine (non-corrupting) response-label-differs-by-timepoint quirk for 2 patients | **Primary discovery dataset for H0, H1, H2, and (planned) H4** |
| **GSE72056** (Tirosh et al. 2016) | H0 replication only | Yes, checksummed | Fully cached (`data/processed/GSE72056/{meta,tpm_log}.rds`); values are `log2(TPM/10+1)`, NOT raw TPM — back-transform required for any threshold comparison | High for its scoped purpose; explicitly NOT scoped for use beyond H0 | **H0 replication only — do not reuse elsewhere** (Priya's explicit scoping rule: additional datasets only where they demonstrably strengthen the project) |
| **GSE115978** (Jerby-Arnon et al.) | Considered, dropped | No | N/A | N/A | **Out of scope entirely** — no role in the locked module structure, dropped 2026-08-01 |
| **GSE78220** (Hugo et al.) | Bulk validation | **Not yet downloaded** | N/A | Unverified | Planned for **H5** |
| **GSE91061** (Riaz et al.) | Bulk validation | **Not yet downloaded** | N/A | Unverified | Planned for **H5** |
| **TCGA-SKCM** | Prognostic context | Not touched | N/A | N/A | Mentioned for `09_synthesis`/prognostic framing only, not yet designed in detail |
| **CollecTRI** (Müller-Dott et al. 2023) | TF-target regulon for H4 | Downloaded via Zenodo fallback (`data/raw/collectri_human_prior_tri.csv`) | **NOT yet usable — gene symbol casing needs verification (§3, critical)** | Unverified | Planned for **H4**, blocked pending casing resolution |
| **LIANA Consensus resource** | Ligand-receptor pairs for H4 | Loaded in-session (not a downloaded file, fetched via package function) | Verified correct (human-cased gene symbols, 4,701 pairs) | High | Ready for **H4** once the Seurat/input-format question is resolved |

---

## 8. Remaining Roadmap

Ordered, starting exactly where the project stands.

### Step 1 — Resolve the CollecTRI gene-symbol-casing issue (BLOCKING)
- **Objective**: confirm whether `data/raw/collectri_human_prior_tri.csv` (from Zenodo record
  8222799) is genuinely human data with unusual casing, or is actually mouse data mislabeled,
  and obtain a network with correctly-cased human gene symbols either way.
- **Expected outputs**: a verified, correctly-human-cased CollecTRI network object, ready to
  feed to `decoupleR`'s TF activity functions.
- **Dependencies**: none — can start immediately.
- **Estimated difficulty**: Low-to-moderate — likely just needs `toupper()` if it turns out
  CollecTRI's convention is genuinely title-case regardless of species (needs verifying
  against the original paper/database, not assumed), or finding a different, unambiguous
  source if it's actually mouse data.
- **Deliverable**: verified network, documented in `CHANGELOG.md` and `REPRODUCIBILITY.md`
  (the whole Ensembl/`get_collectri()`/Zenodo saga belongs there as a package-management
  gotcha, matching the style of every other documented gotcha in this project).

### Step 2 — Commit pending infrastructure state
- **Objective**: verify and commit the `decoupleR`/`liana` `renv.lock` changes and
  `00_tool_smoke_test.R`.
- **Expected outputs**: clean `git status`, new commit(s).
- **Dependencies**: Step 1 should inform whether the smoke test script itself needs revision
  before committing (it currently ends in a state where Plan A is known to fail — worth
  simplifying to just the working Plan B path once confirmed).
- **Estimated difficulty**: Low — mechanical, Claude can do this directly (infrastructure).

### Step 3 — Design H4's data structures (sanity check, matching established pattern)
- **Objective**: determine (a) whether existing pseudobulk structures suffice for
  `decoupleR` TF-activity analysis, or need reshaping; (b) what input format `liana` actually
  requires — a full `Seurat`/`SingleCellExperiment` object, or a lighter-weight
  matrix-plus-labels input — and build whichever is needed from the existing `tpm.rds`/
  `meta.rds`/`gse120575_compartment_calls.csv`.
- **Expected outputs**: a short diagnostic script (Priya runs it) confirming data
  compatibility before any real analysis is designed around an assumption.
- **Dependencies**: Steps 1–2 complete.
- **Estimated difficulty**: Moderate — `liana`'s input requirements are the main unknown;
  worth checking its documentation/vignette structure empirically (via a minimal test) rather
  than assuming.

### Step 4 — H4 primary analysis: TF activity
- **Objective**: test whether the recruitment programme is "regulatorily coherent" — i.e.
  driven by a coherent, identifiable set of transcription factors, not scattered noise.
- **Expected outputs**: `decoupleR`-based TF activity scores (likely `run_ulm()` or similar)
  on patient-level and/or compartment-level pseudobulk, tested for association with response,
  same statistical discipline as H1/H2 (patient-level units, BH-FDR, `limma`-style testing
  where a differential comparison is needed).
- **Dependencies**: Steps 1–3.
- **Estimated difficulty**: Moderate.

### Step 5 — H4 secondary analysis: ligand-receptor communication network
- **Objective**: test whether the recruitment programme's intercellular communication
  structure converges on T-cell suppression, using `liana`'s consensus ligand-receptor
  resource on the compartment-labeled single-cell data.
- **Expected outputs**: a communication network (sender compartment → receiver compartment,
  weighted by L-R evidence), interpreted for whether it converges on T-cell-directed edges.
- **Dependencies**: Step 3 (input format resolved).
- **Estimated difficulty**: Moderate-to-high — this is the most methodologically novel part
  of the remaining project.

### Step 6 — Document H4 (README, evidence ledger, root README status update)
- Standard pattern, matching H0/H1/H2 exactly.

### Step 7 — Build Figure 4 (H4)
- Standard pattern: Claude writes and runs it, verifies visually and programmatically against
  committed results, sends to Priya, commits.

### Step 8 — Audit checkpoint
- Standard consistency audit before moving to H5, per the standing rule.

### Step 9 — H5 (`07_validation_concordance`)
- **Objective**: does the programme generalise to independent bulk cohorts, and agree
  quantitatively with published TAN literature (Wu 2024, Guo 2025, Wang 2025 marker sets —
  Jaccard/hypergeometric/rank-correlation concordance, per the frozen spec's "quantified, not
  narrative" literature-concordance requirement)?
- **Expected outputs**: download and verify GSE78220 and GSE91061 (not yet touched — full
  download-and-audit cycle needed, matching H0's dataset-audit discipline); signature scoring
  of H1's frozen ranking in these bulk cohorts against clinical response; quantified
  literature concordance.
- **Dependencies**: H4 complete (H5 validates the whole programme, not just H1's piece).
- **Estimated difficulty**: High — new datasets, new deconvolution/signature-scoring methods,
  the literature-concordance quantification is genuinely new work.

### Step 10 — `08_experimental_translation`
- **Objective**: for every finding that reached Moderate or Strong, propose the logical
  experimental validation (already partially anticipated in module READMEs — consolidate and
  formalize).
- **Dependencies**: H1–H5 complete.
- **Estimated difficulty**: Low-to-moderate — mostly synthesis and writing, per the frozen
  spec's table format (finding → proposed validation → readout → falsification criterion).

### Step 11 — `09_synthesis`
- **Objective**: the post-hoc CXCL8–CXCR1/2 question, finally asked; the systems-level
  mechanistic model (Figure 6); full evidence ledger review.
- **Dependencies**: everything else complete.
- **Estimated difficulty**: High — this is the capstone integration step.

---

## 9. Working Principles

Every future response in this project must:

1. **Maintain scientific restraint** — never claim more than the evidence grade supports;
   "concordant with" is not "validated by"; "suggests" is not "proves."
2. **Distinguish observation from interpretation from hypothesis** at every step — use the
   five-step interpretation framework (§2) literally, every time, no skipping.
3. **Never overclaim** — when in doubt, grade down (Exploratory over Moderate, Moderate over
   Strong), and say why.
4. **Preserve the frozen architecture exactly** — §2 is not open for renegotiation. If
   something in §2 seems wrong given new information, that itself is a "genuine blocker"
   requiring a `CHANGELOG.md` entry and explicit discussion with Priya, not a silent redesign.
5. **Document every deviation** in `CHANGELOG.md`, including the blocker and justification,
   the moment it happens — not retroactively.
6. **Prioritise reproducibility** — every gotcha, every fix, every runtime, goes in
   `REPRODUCIBILITY.md`. Figures via `ragg`/`svglite` only. Seeds recorded when introduced.
7. **Maintain evidence grading discipline** — every substantive claim gets a ledger row; two
   claims with different confidence get two rows, never one averaged row.
8. **Preserve hypothesis-driven structure** — every module answers its stated hypothesis, no
   more, no less; don't let one module quietly answer another's question (e.g. H1 must not
   pre-decide H2's compartment-attribution question, and did not).
9. **Respect the execution boundary** — infrastructure fixes direct, analysis steps to Priya,
   always.
10. **Verify, don't assume** — for external library bugs, research the actual issue (as was
    done for the Ensembl/`get_collectri()` problem) rather than guess-patching repeatedly. For
    figures, cross-check programmatically against source data, not just visually. For scripts
    that appear to run cleanly, still question whether "no error" means "correct."
11. **Do not expand scope** — the frozen spec explicitly excludes RNA velocity, trajectory
    inference, extra ML/deep models, spatial transcriptomics, additional datasets beyond those
    specified, CNV inference, and survival ML. Do not propose any of these.
12. **Keep the CXCL8–CXCR1/2 discipline absolute** — it is not discussed, tested, or even
    checked for "technical completeness" before `09_synthesis`. This has been maintained
    strictly for four modules running; do not be the one to break it.

---

## 10. Important Lessons Learned

*(Preserved so they are never re-litigated or re-discovered the hard way.)*

1. **Why the central question was changed (through 3 revisions)**: the original wording named
   the CXCL8–CXCR1/2 axis directly ("...does the axis emerge as the dominant mechanism?"),
   which — even framed as a post-hoc question — implicitly primed the discovery phase toward a
   pre-chosen answer. Removed entirely from the question; the axis may only be raised in
   `09_synthesis`, after discovery is complete and committed.

2. **Why discovery and interpretation were separated**: same reasoning as above, generalized —
   any named pathway/gene in a discovery screen's design risks (even unconscious) shaping of
   the panel or the reporting toward that pathway. Solved structurally: externally-sourced gene
   panels (GO terms via `msigdbr`), full ranked tables committed to git before any discussion
   of "interesting" hits, and a hard rule never to comment on specific genes' significance
   before the full table is committed.

3. **Why the recovery audit became H0**: the project originally intended to map TAN cell
   states directly in melanoma scRNA-seq. Before committing to that design, an empirical check
   (which became H0) established that public melanoma scRNA-seq datasets do not retain
   analyzable neutrophil numbers (CD45+ sort + Smart-seq2 plate-picking depletes them near
   completely). This is why the project pivoted from "map TAN states" (H3, ultimately omitted)
   to "measure the tumour-side signalling that would recruit them" (H1 onward) — the pivot
   was driven by real data, not by a priori design choice, and was validated by testing on TWO
   independent datasets, not assumed from one.

4. **Why evidence grading was introduced**: to prevent the natural tendency to describe any
   statistically significant result as more certain than it actually is, especially in a
   single-cohort discovery study. The grading rubric (Strong/Moderate/Exploratory) and its
   specific criteria force an explicit accounting of what's actually been shown (single-cohort
   significance) vs. what would need external replication to claim more.

5. **Why the Negative Results Policy was added**: to make it structurally impossible to quietly
   drop an inconvenient finding (H0's absence-of-neutrophils result, H2's inability to confirm
   Myeloid's role) — every finding, positive or negative, gets a ledger row with a
   `result_direction` field, and the root README explicitly states the policy has already been
   exercised, with examples, rather than existing only as an abstract promise.

6. **Why GSE120575's TPM-only status required a different statistical approach**: `edgeR`/
   `voom` are built around count-based negative-binomial/mean-variance modelling; GSE120575 was
   deposited on GEO as TPM only (no raw counts available), so those tools would be statistically
   invalid on this data. `limma`'s original `lmFit`/`eBayes` workflow (predating the RNA-seq
   count extensions) is the correct tool for continuous, pre-normalised expression data — this
   was caught by actually checking the data format rather than defaulting to "the standard
   scRNA-seq pseudobulk pipeline," which would have been a real, if commonly-made, error.

7. **Why `read_tsv()`'s default type-guessing is dangerous for wide files**: `readr` samples
   only the first ~1000 rows to guess column types; GSE120575 has 55,738 gene rows, so the
   guess was unrepresentative and silently typed cell columns as `character`. Every H0 script
   was accidentally safe (`as.numeric()` wrapped every access), but H2's compartment-audit
   code, which needed bulk numeric operations (`mean()` across genes), was not, and surfaced
   the bug as silent `NA` output with only a warning — not a hard error. Explicit `col_types`
   is now mandatory for any script reading this file, and the fix also happened to speed up
   parsing 4x (36 min → 8.8 min) by skipping the guessing pass entirely.

8. **Why absolute expression thresholds don't transfer across independently-processed public
   datasets**: the same `TPM > 1` threshold on the same 3 genes gave a ~100x different baseline
   positivity rate between GSE120575 and GSE72056 — different labs, years, and normalisation
   pipelines put "TPM" on genuinely different practical scales. Any future cross-dataset
   comparison in this project must use relative/rank-based or orthogonal-annotation methods,
   never a shared absolute cutoff.

9. **Why H2 was split into a primary (attribution) and secondary (exploratory,
   response-within-compartment) test rather than one combined analysis**: the sanity check
   revealed Myeloid had only 3 usable responder patients — testing "is myeloid CCL3 different
   by response" at that power would have been fragile and easily overstated. Splitting the
   design let the well-powered attribution question (does compartment matter at all) proceed
   unaffected by Myeloid's specific weakness, while honestly quarantining the underpowered
   response-comparison question as explicitly exploratory, with Myeloid excluded from it
   entirely rather than included and downplayed.

10. **Why "no error" is not sufficient verification for a figure**: caught twice. Figure 1's
    table had text genuinely overlapping (columns sized by a fixed unit width rather than
    actual content length) despite rendering without any R error. Figure 3's compartment
    heatmap used a different aggregation formula (`log(mean(x))`) than the actual committed
    analysis (`mean(log(x))`) — mathematically different by Jensen's inequality — which flipped
    a near-tie dominant-compartment call (FAM3C) and would have silently contradicted the
    already-written module README. Both were caught only by actually reading the rendered
    image and, for Figure 3, writing a standalone script to cross-check every displayed value
    against the committed source CSV. This is now the standard: verify the actual output
    against actual committed data, never trust "it rendered" as sufficient.

11. **Why the H0 GSE72056 correction matters as a process example**: an early draft of H0's
    interpretation claimed "zero candidates were non-malignant-and-unclassified" when the true
    number was 4 (later refined to 3 distinct after resolving a duplicate). The error was
    caught by a deliberate audit (re-reading the actual printed cross-tabulation instead of
    trusting the prior summary), fixed by re-deriving the correct numbers from cached data with
    a fresh verification script, and the correction was **logged as a new CHANGELOG entry**
    documenting what was wrong, how it was found, and what changed — the original incorrect
    claim was not silently edited away. This is the template for how any future correction in
    this project must be handled.

12. **Why `get_collectri()`'s failure was researched, not guessed at**: after Plan A (taxonomy
    ID) failed a second time, the temptation would be to keep trying random parameter
    variations. Instead, the actual GitHub issues for `decoupleR`, `OmnipathR`, and `CollecTRI`
    were read to confirm this is a known, currently-unresolved external problem (Ensembl
    changed their site), and a genuinely independent, verified alternative data source (the
    paper's own Zenodo archive) was found and used instead. The lesson generalizes: when a
    well-established tool fails in an unexpected way, check whether it's a known upstream issue
    before assuming a mistake in project-side code.

---

## 11. Immediate Next Step

# RESUME HERE

The next session should do exactly this, in this order, with no other action first:

1. **Read this entire document.** Do not begin work from a summary or from partial context.

2. **Run `git status --porcelain` and `git log --oneline -5`** (or ask Priya to) to confirm
   the actual current repository state matches §5 above — specifically, confirm whether the
   `decoupleR`/`liana` `renv.lock` changes are committed or still pending.

3. **Resolve the CollecTRI gene-symbol-casing question (§8, Step 1) before anything else
   H4-related.** This is a genuine, unresolved, potentially analysis-invalidating data-quality
   question — not yet a confirmed bug, but not yet cleared either. Investigate whether
   `human_prior_tri.csv` from Zenodo record 8222799 is genuinely mouse-cased human data (in
   which case `toupper()` on the `source`/`target` columns may be a legitimate, verifiable fix
   — but confirm this is actually correct for TF nomenclature before applying it, don't assume)
   or whether a different, unambiguous human CollecTRI source is needed.

4. **Only after Step 3 is resolved**, proceed to §8's Step 2 onward (commit infrastructure,
   design H4's data structures with a sanity check, then the actual TF-activity and
   ligand-receptor analyses).

5. **Maintain every principle in §9 without exception**, and do not re-open any decision
   marked frozen in §2. If something in §2 genuinely needs to change, say so explicitly to
   Priya and log it in `CHANGELOG.md` — do not silently redesign.

The project is in good standing: 28 confirmed commits, three fully-complete and internally
consistent hypothesis modules (H0 Strong, H1 Moderate, H2 Moderate/Exploratory), one correctly
and honestly omitted module (H3), and one module (H4) paused at a real, externally-caused,
now-understood technical blocker with a working path forward already identified. Nothing is
broken; nothing needs to be redone; the next session simply needs to pick up exactly where
this one paused.
