# CANONICAL PROJECT CONTINUATION DOCUMENT

Generated 2026-08-02, at the second context-limit handoff, immediately after Module 08
(`08_experimental_translation`) was completed and frozen at commit `db7b959`. **This document
completely replaces every previous handoff document, including the prior
`CONTINUATION_BRIEF.md` (generated at the H4 tool-installation stage) and this file's own
earlier content.** A fresh session should read this document in full before taking any
action, and should not re-derive, re-litigate, or re-run any decision or result recorded here
as complete. Only `09_synthesis` remains.

---

## 1. Project Identity

- **Final project title** (as it appears in root `README.md`): "Tumour-derived neutrophil
  recruitment and signalling programmes in melanoma immune checkpoint response."
- **Frozen central biological question** (revision 3, final, never reworded): *Which
  tumour-derived neutrophil recruitment and functional signalling programmes distinguish
  immune checkpoint responders from non-responders in human melanoma?*
- **Current phase**: all hypothesis-testing modules (H0–H5) and the translation module (08)
  are complete. Only `09_synthesis` remains before the project as a whole is finished.
- **Current module**: none active — `08_experimental_translation` was just frozen.
  `09_synthesis` has not been started.
- **Current implementation step**: awaiting the start of `09_synthesis` — no script written,
  no design proposed yet for that module.

---

## 2. Frozen Architecture

Everything below is frozen as of 2026-08-01 (three design-refinement passes) and confirmed
unchanged through H0–H5 and Module 08's completion. Do not redesign any of it. Any deviation
requires a genuine technical or biological blocker and a `CHANGELOG.md` entry — never
redesign because something "would be more interesting."

### Repository structure (matches disk exactly, verified 2026-08-02)
```
melanoma-neutrophil-icb/
├── README.md                        Central question, hypothesis map, status, Negative Results Policy
├── CHANGELOG.md                     Every post-freeze deviation, with blocker + justification
├── REPRODUCIBILITY.md               System/package/dataset/runtime/gotcha record
├── CONTINUATION_BRIEF.md            This document (canonical, supersedes all prior versions)
├── 01_background/README.md          Literature background (NOT six-heading format)
├── 02_dataset_audit/                H0 — COMPLETE, Strong
├── 03_recruitment/                  H1 — COMPLETE, Moderate
├── 04_cellular_sources/             H2 — COMPLETE, Moderate (primary) / Exploratory (secondary)
├── 05_neutrophil_states/README.md   H3 — OMITTED (template only, never populated)
├── 06_regulation_communication/     H4 — COMPLETE, Moderate (TF-activity) / Exploratory (secondary) / Exploratory-Negative (communication)
├── 07_validation_concordance/       H5 — COMPLETE, Exploratory/Negative throughout (H5a/H5b/H5c)
├── 08_experimental_translation/     COMPLETE — 4 validation proposals, NOT six-heading format
├── 09_synthesis/README.md           NOT STARTED (NOT six-heading format) — ONLY REMAINING MODULE
├── R/
│   ├── neutrophil_markers.R         Shared H0 marker-detection functions
│   └── theme_project.R              Shared ggplot theme, palette, save_figure() wrapper
├── figures/                         figure1..figure5 (.png + .svg each), 5 of 6 frozen figures done
├── results/                         evidence_ledger.tsv (10 rows) + all per-module .csv/.rds outputs
├── data/raw/                        gitignored — GEO downloads, never committed
├── data/processed/                  gitignored-adjacent cache (.rds objects committed per project convention: tpm.rds, meta.rds, collectri_human_verified.rds etc.)
├── renv.lock, renv/, .Rprofile      renv environment, P3M + Bioconductor mirrors configured
└── .gitignore                       ignores data/raw/, omnipathr-log/
```

### Hypothesis map (verbatim from `README.md`, figure numbers load-bearing)

| # | Hypothesis | Module | Figure | Status |
|---|---|---|---|---|
| H0 | Neutrophil representation in public melanoma scRNA-seq is determined by protocol and QC, not tumour biology | `02_dataset_audit` | 1 | **Complete — Strong** |
| H1 | ICB-resistant melanomas exhibit enhanced neutrophil-recruitment signalling programmes | `03_recruitment` | 2 | **Complete — Moderate** |
| H2 | Neutrophil-recruiting signalling is compartment-restricted rather than uniformly distributed | `04_cellular_sources` | 3 | **Complete — Moderate/Exploratory** |
| H3 | TANs occupy reference-defined functional states; resistance associates with immunosuppressive rather than antigen-presenting programmes | `05_neutrophil_states` | — | **Omitted** — H0 established <20 recoverable neutrophils |
| H4 | The recruitment programme is regulatorily coherent and its intercellular communication converges on T-cell suppression | `06_regulation_communication` | 4 | **Complete — Moderate (TF-activity) / Negative finding (communication)** |
| H5 | The programme generalises to independent cohorts and agrees quantitatively with published TAN biology | `07_validation_concordance` | 5 | **Complete — Exploratory/Negative findings throughout** |
| — | `08_experimental_translation` (not a hypothesis test) | `08_experimental_translation` | — | **Complete** — 4 validation proposals, one per Moderate/Strong ledger entry |
| — | Synthesis (not a hypothesis test) | `09_synthesis` | 6 | **NOT STARTED — next and final module** |

Six figures total (H3's omission renumbered Fig 4→H4, Fig 5→H5, Fig 6→synthesis) — this
renumbering is itself a logged, frozen decision (`CHANGELOG.md`, 2026-08-01).

### Module template (binding for modules 02–07 only)
Every hypothesis-testing module's `README.md` uses exactly: **Hypothesis → Analysis →
Evidence → Interpretation → Limitations → Conclusion**, in that order.
`01_background`, `08_experimental_translation`, and `09_synthesis` are explicitly **exempt**
(logged spec clarification, `CHANGELOG.md`, 2026-08-01).

### Interpretation framework (binding, every result, every module, no exceptions)
Five steps, in order, none skipped:
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
  cells/patients; also the FIXED CEILING for any set-overlap/literature-concordance test
  (H5c), regardless of how significant its p-values are, because such a test cannot satisfy
  the patient-level-statistics criterion above — this ceiling is asserted a priori, not
  discovered after seeing results.

**Discovery vs. confirmatory discipline (binding, extended through H5)**: H1's original
discovery screen used an externally-sourced gene panel (msigdbr GO terms), never a
hand-picked list. H5a/H5b are **confirmatory**, not new discovery — they test the exact,
already-locked genes/modules H1/H4 already found significant; no new gene or TF was added or
dropped after seeing H5's results. H5c's literature marker sets are externally sourced from
real, cited papers (identified via literature search, not fabricated) — see §9 for the
verification-depth story. **A standing rule added by the project owner at H5's
pre-registration and applied without exception since**: a replication verdict requires BOTH
concordant effect direction AND statistical significance at the pre-defined threshold —
neither alone establishes replication.

### Failure-tolerant decision tree (already resolved for H3, pattern applied nowhere else so far)
```
H0 dataset audit → recoverable neutrophils?
  <20 (ACTUAL OUTCOME)  → H3 omitted, documented as protocol-driven limitation
  20–200                → H3 would have been exploratory only
  >=200, >=5 patients   → H3 would have been primary
```

### Negative Results Policy (binding, stated in root `README.md`)
Biologically meaningful negative findings are reported with equal priority to positive ones.
The `result_direction` column (`positive`/`negative`/`null`) makes this auditable. **Exercised
repeatedly, not just once**: H0 (no neutrophils → H3 omitted), H2 secondary (Myeloid's role
unconfirmed, stated as a gap not hidden), H4 communication (Fisher's test genuinely negative
in both networks, stated plainly, NOT rescued by the descriptive checkpoint-pair observation),
H5a (3 of 4 genes fail replication, direction reversal in GSE91061), H5b (both TF modules fail
replication, same GSE91061 reversal pattern).

### Reproducibility policy
- `REPRODUCIBILITY.md` at root: System, Package management (every known gotcha documented),
  Random seeds, Datasets (with checksums), Analysis order, Runtime (measured, never
  estimated), Figure regeneration, Fresh-clone reproduction sequence.
- Figures render via `ragg::agg_png` + `svglite` **exclusively**, through
  `R/theme_project.R`'s `save_figure()` wrapper — never `ggsave()` or base graphics directly.
- `renv`, snapshot type `all`. **`renv::status()` verified clean after every commit in this
  project, without exception, including every commit in this session.**
- **Standing practice, exercised repeatedly this session**: after any script believed
  complete, rerun it from scratch and `diff` against the already-committed output before
  treating it as locked. Every H4/H5 primary/secondary script in this session was verified
  this way (byte-identical rerun), not merely assumed correct because it ran without error.

### Discovery discipline (binding, restated for emphasis)
Discovery screens must be **unbiased and externally sourced** (e.g. GO gene sets via
`msigdbr`, not hand-picked gene lists). **CXCL8/CXCR1/2 named nowhere before `09_synthesis`**
— this discipline has now been maintained across FIVE completed modules (H1–H5) plus Module
08, including through a case (H4's communication component) where a genuinely interesting,
literature-connectable pattern (checkpoint-pair edges) was found post hoc and deliberately
**not** given a follow-up statistical test, specifically to preserve this discipline. The
same reasoning was invoked again at H5c to justify excluding Wu et al. 2024 rather than
approximating its marker set.

### Change control
Every deviation from this frozen architecture is logged in `CHANGELOG.md` with: what was
deviated from, the technical/biological blocker that forced it, and the justification.
**Corrections to past errors are logged as new entries, not silently overwritten.** This
project now has an extensive, exercised track record of this discipline (see §9).

### Standing process rules (apply to every future turn, unchanged from prior handoff, re-confirmed through this entire session)
- **Audit after every phase**: after every major analysis step, re-read actual files/output
  and verify claims against printed data, not against an earlier summary. Caught real issues
  repeatedly this session (see §9).
- **Execution boundary**: pure infrastructure/tooling fixes — Claude executes directly.
  Anything that is or touches new analysis (package installs, analysis code, anything
  producing a new scientific result, or real external data acquisition) — Claude hands the
  code to Priya, she runs it, pastes output back. Never assume success without her pasted
  output. **Figures are written AND run by Claude** (no new scientific claim), but the
  rendered image must be visually inspected and cross-checked against source data before
  sending — this caught real rendering bugs multiple times this session (see §9).
- **Heredoc/paste corruption risk**: never assume a script that appears in a terminal
  transcript is what was actually saved.
- **UNC-path Windows-side file writes are not reliably visible to native WSL git
  processes, AND — new lesson from this session — editing the WSL file directly via the
  `\\wsl.localhost\...` UNC path can itself succeed, but a SUBSEQUENT `cp` from a
  stale/unedited scratchpad copy onto that same WSL path will silently overwrite the correct
  edit with the stale one.** The safe pattern, used consistently for the rest of this
  session after the mistake was caught: **always edit the scratchpad copy first, verify the
  edit landed in the scratchpad file with `grep`/`Read`, THEN `cp` it into the WSL
  filesystem, THEN verify again in WSL with `grep`/`git diff`** — never edit the WSL UNC path
  directly and then risk a stale overwrite.
- **`data.table`'s `..` prefix only reliably resolves a bare variable name**, not a compound
  expression like `..cell_meta$cell` — assign to a plain variable first.
- **ggplot does not auto-wrap `plot.title`/`plot.subtitle`/`plot.caption`** — long text
  overflows panel edges or collides with neighbouring panels uncorrected. This bit Figure 1
  (original discovery), Figure 4 (twice, in this session), and Figure 5 (in this session).
  The fix, applied consistently: a local `wrap_text <- function(x, width) paste(strwrap(x,
  width = width), collapse = "\n")` helper, applied to every title/subtitle/caption in a
  multi-panel figure, sized per-panel-width. **Always visually re-render and inspect after
  any figure change** — "no error" was never sufficient evidence.
- **Windows PowerShell/Bash tool path quoting**: `MSYS_NO_PATHCONV=1` prefix needed before
  `wsl -- cp` calls with `/mnt/c/...`-style paths, or Git Bash's MSYS path-conversion mangles
  them.

---

## 3. Complete Implementation History

*(Chronological, every milestone from project start through this session's end. Earlier
milestones — H0 through H4 tool-installation — are condensed relative to their original
handoff detail since they are fully closed and their own module READMEs are the durable
record; this session's H4 completion through Module 08 is recorded in full detail since now
current.)*

### Milestone: Environment and scaffolding (2026-07-31 to 2026-08-01)
- `renv` initialised (P3M noble binaries, Bioconductor mirror, snapshot type `all`).
- Repository scaffolded per the frozen hypothesis-module structure.
- Root documentation populated: hypothesis map, Negative Results Policy, reproducibility
  skeleton.
- Commits: `2123a79` through `93d7118`.

### Milestone: H0 — dataset audit (2026-08-01) — **COMPLETE, Strong**
- **Objective**: determine whether neutrophils are recoverable from public melanoma
  scRNA-seq before assuming either way.
- **Datasets**: GSE120575 (Sade-Feldman, 16,291 cells, primary), GSE72056 (Tirosh, 4,645
  cells, H0-replication-only scope).
- **Key technical fixes along the way**: GEO download via explicit checksummed URLs (not
  `GEOquery::getGEOSuppFiles()`, which returned NULL); `readr::read_tsv()` required for
  GSE120575's 4.5GB decompressed matrix (`fread`/base `gzfile` hit R's 2^31-1 byte
  single-string limit); explicit `col_types` required (readr's type-guessing samples only
  ~1000 rows, silently mistyped cell columns as character in this 55,738-row file);
  `vroom`'s 128KB connection buffer too small for GSE72056, fixed via
  `VROOM_CONNECTION_SIZE`.
- **Method**: marker co-occurrence test (CEACAM8/MPO/ELANE) via exact subset-enumeration
  null (GSE120575) and cell-type cross-reference against original authors' annotations
  (GSE72056) — different methods per dataset because absolute TPM thresholds don't transfer
  across independently-processed cohorts (~100x base-rate difference, itself a documented
  finding).
- **Result**: GSE120575 — 1 cell positive for ≥2 markers vs 0.14 expected by chance.
  GSE72056 — 25 candidates, cross-referenced: 12 T cells, 2 macrophages, 5 malignant, 4
  non-malignant-and-unassigned (2 share patient/well/index, apparent duplicate → 3 distinct),
  2 unresolved.
- **Correction logged, not silently fixed**: an early draft claimed 0 non-malignant-
  unassigned candidates; audit found the true number was 4 (3 distinct). Corrected via a new
  `CHANGELOG.md` entry, not a silent edit.
- **Decision-tree outcome**: <20 recoverable neutrophils → **H3 omitted**.
- **Scripts** (consolidated from 7 debugging-era scripts to 3, byte-verified before removing
  originals): `02_dataset_audit/01_download_data.R`, `02_h0_gse120575.R`, `03_h0_gse72056.R`,
  `04_figure1.R`. Shared: `R/neutrophil_markers.R`.
- **Figure 1** committed, visually + programmatically verified.
- Ledger row: `H0`, `negative`, `Strong`.
- Commits: `29c35f9` through `816bb55`, correction at `a08355b`, consolidation at `33470a7`.

### Milestone: H1 — recruitment discovery screen (2026-08-01) — **COMPLETE, Moderate**
- **Objective**: unbiased discovery of a secreted chemokine/cytokine/growth-factor programme
  differing by ICB response.
- **Method**: 19 pre-treatment, response-labeled patients (10 NR/9 R), 327-gene GO-sourced
  panel (msigdbr `GOMF_CYTOKINE_ACTIVITY`/`GOMF_CHEMOKINE_ACTIVITY`/
  `GOMF_GROWTH_FACTOR_ACTIVITY`), 35 genes passed a pre-specified TPM>1-in-≥20%-of-patients
  filter, patient-level pseudobulk, `limma::lmFit`/`eBayes` on `log2(TPM+1)` (NOT
  `edgeR`/`voom` — GSE120575 is TPM-only, no raw counts, so count-based NB modelling would be
  statistically invalid; this reasoning becomes directly relevant again at H5 for choosing
  per-cohort methods).
- **Result**: 4 genes FDR<0.05 — **LTB** (logFC −0.721, FDR 0.000246, higher in responders,
  concordant with published TLS/lymphotoxin biology — concordance, not validation, refined
  wording logged separately at commit `d3e5433`), **CCL3** (+0.753, FDR 0.0466), **CCL4**
  (+0.731, FDR 0.0466), **CXCL13** (+0.864, FDR 0.0466), all three higher in non-responders.
- **Caveats stated, not hidden**: therapy-type confound (anti-PD1 monotherapy skews
  non-responder 8/12, anti-CTLA4+PD1 combo skews responder 4/5); 89% panel attrition
  (pre-specified filter, not loosened after seeing results); LTB-vs-CXCL13 directional
  tension flagged as unresolved.
- **Scripts**: `03_recruitment/02_h1_sanity_check.R`, `03_h1_discovery_screen.R`,
  `04_figure2.R`. Results: `results/h1_discovery_screen_ranked.csv`,
  `h1_discovery_screen_summary.rds`. **Figure 2** committed.
- Ledger row: `H1`, `positive`, `Moderate`.
- Commits: `13aa230` through `8c62d55`.

### Milestone: H2 — cellular sources (2026-08-01) — **COMPLETE, Moderate (primary) /
Exploratory (secondary)**
- **Objective**: is H1's programme compartment-restricted, and which compartment carries
  each specific response-associated signal?
- **Primary test**: Kruskal-Wallis, patient-level pseudobulk, all 35 H1-tested genes across
  T_cell/B_cell/Myeloid/NK (Mast/Malignant/Unassigned excluded, unusable counts). **34/35
  significant** (FDR<0.05); sole exception RABEP1 (intracellular trafficking protein, not a
  secreted factor — sensible, not a contradiction). Decomposition: LTB→B cell,
  CXCL13→T cell, CCL3/TYMP/GPI→Myeloid, CCL4/CCL4L2/CD320→NK.
- **Secondary, pre-declared exploratory test**: within-compartment response comparison
  (`limma`, same method as H1), restricted to T_cell/NK/B_cell (Myeloid excluded — only 3
  usable responder patients) and H1's 9 FDR<0.10 hits. **7/27 significant**. Notable,
  genuinely non-obvious finding: the compartment carrying the significant response-signal is
  not always the dominant-expression compartment (CCL4: NK-dominant magnitude, T-cell-
  significant signal; LTB: B-cell-dominant magnitude, T-cell-significant signal) —
  "regulation ≠ abundance," a theme that recurs at H4 (TF-module compartment secondary) and
  H5c.
- **Scripts**: `04_cellular_sources/01_h2_sanity_check.R`, `02_h2_compartment_attribution.R`,
  `03_figure3.R`. **Figure 3** committed (caught and fixed a real bug: heatmap used
  `log(mean(x))` instead of the analysis's actual `mean(log(x))`, which had flipped a
  near-tie compartment call for FAM3C — found only by cross-checking the rendered figure
  against source CSV, not by "no error").
- Ledger row: `H2`, `positive`, `Moderate (primary); Exploratory (secondary)` — two
  confidences in one row's justification field, never averaged.
- Commits: `1382d76` through `7d21236`.

### Milestone: H4 tool installation and CollecTRI resolution (2026-08-01/02) — infrastructure
- `decoupleR` and `liana` installed cleanly (liana's ~60-package dependency tree, flagged as
  risky at project start, installed without incident).
- **`decoupleR::get_collectri()` blocked**: `OmnipathR`'s organism-resolution scrapes
  `ensembl.org/info/about/species.html`, which now 404s — confirmed via actual GitHub issue
  trackers (`decoupleR` #153/#162, `OmnipathR` #117, `CollecTRI` #19) as a known,
  currently-unresolved external bug, not a local misconfiguration. Passing `organism=9606`
  (NCBI taxid) does **not** work around it (confirmed by direct test, still fails inside
  `unnest_evidences()` — do not retry).
- **First fallback (Zenodo record 8222799) failed silently at first glance**: downloaded
  successfully, correct `source/target/mor` shape, but gene symbols were Title-Case
  (`Myc`, `Spi1` — mouse/MGI convention), not uppercase HGNC, despite the filename
  `human_prior_tri.csv`. Confirmed via direct edge comparison (`Myc->Tert` in the Zenodo
  file vs `MYC->TERT` from OmniPath's own REST API for the identical edge). **This file must
  never be used.**
- **Working fix**: query OmniPath's REST API directly
  (`https://omnipathdb.org/interactions?resources=CollecTRI&genesymbols=1&format=tsv`),
  bypassing `OmnipathR`/Ensembl entirely. One draft bug caught before final use: an
  `&fields=...` clause including `consensus_inhibition` as a requested field value was
  rejected by the API (the default response already includes it) — removed.
- **Casing/redundancy verification, not assumed**: 208/61,220 initial target symbols were
  non-uppercase — investigated, not dismissed: 207 matched two legitimate HGNC/miRBase
  conventions (`Corf` genes, `hsa-miR-*`), 1 (`Mgu`, target UniProt P10746) was a genuine
  isolated OmniPath data artefact — confirmed via direct UniProt lookup (P10746 = UROS, not
  `Mgu` under any nomenclature) — dropped, not guess-fixed.
- **Repeated-edges bug found by decoupleR::run_ulm() itself**, not by inspection: first-draft
  network deduplicated on the full `(source,target,mor)` triple, not `(source,target)` alone,
  and kept literal complex-partner strings (`JUNB_JUND`) as TF names. Root cause found by
  reading `decoupleR::get_collectri()`'s own source (not guessed): canonical processing
  collapses `COMPLEX:`-prefixed sources to `AP1`/`NFKB`, and deduplicates on `(source,target)`
  keeping first occurrence. Replicated exactly. **Final verified network: 42,698 edges,
  1,178 TFs** (`data/processed/collectri_human_verified.rds`).
- Also found and fixed: a literal `NA` gene-symbol row in `tpm.rds` (of 55,738), isolated,
  dropped with a `stopifnot(n_dropped<=5)` guard.
- Commits: `7a266f1`, `a5183ff`, plus supporting `1eb7469` (pre-registration of the H4
  secondary compartment TF-activity follow-up, written before any H4 result existed).

### Milestone: H4 primary — patient-level TF-activity (2026-08-02) — **COMPLETE, Moderate**
- **Method**: same 19-patient cohort as H1/H2, whole-transcriptome patient-level pseudobulk
  (H1's/H2's own pseudobulk objects are gene-panel-restricted, unusable for TF-activity
  scoring — confirmed, not assumed, at the Step-3 sanity-check stage), `decoupleR::run_ulm
  (minsize=5)` against the verified CollecTRI network, 754 TFs scored, `limma` (same
  discipline as H1/H2), direction convention identical to H1 (positive = higher in
  non-responder).
- **Result**: 56/754 significant at FDR<0.05 (148 at FDR<0.10). 48/56 higher in
  non-responders.
- **Audit before accepting, not just "no error"**: 41% of all 754 TFs at raw P<0.1 (vs ~10%
  null-expected) — investigated, traced to genuine regulon redundancy (correlated TF
  families: E2F1–5, IRF2/3/5/6/7/8/9, SP1/2/3, STAT1/3/5B), not a technical artefact. Same
  therapy-type confound as H1 reproduces exactly (same cohort).
- **Module-clustering characterization added** (not a discovery search — a post-hoc
  characterization of the primary result's own structure): hierarchical clustering +
  Nyholt (2004) eigenvalue-based effective-independent-test count. **56 nominal hits collapse
  to Meff = 31.3 effective independent programs**, 13 correlated modules at r>0.7. Named:
  **Module 1** (21 TFs, NR-elevated, metabolic/nuclear-receptor: `SREBF1, BACH1, SREBF2,
  KLF15, PARK7, TFAP2A, DNMT1, CEBPA, PPARA, PDX1, ESR1, NR1H4, NFE2L2, VDR, CEBPZ, EP300,
  SP3, EHF, CEBPE, SP2, MNT`), **Module 2** (13 TFs, NR-elevated, E2F proliferation: `TLX2,
  OLIG2, STOX1, SMARCA1, E2F5, SIM2, E2F4, E2F1, E2F3, POU1F1, ARID3B, E2F2, HCFC1`), Module
  4 (3 TFs, R-elevated: `SNAI2, CTBP1, ZFX`), **Module 5** (3 TFs, R-elevated,
  lymphocyte-differentiation: `IKZF3, SATB2, BACH2` — plausibility-only concordance with
  published T-cell-exhaustion-restraint biology).
- **Scripts**: `06_regulation_communication/03_h4_tf_activity.R`, `03b_h4_audit.R`,
  `03c_h4_module_clustering.R`. Reproducibility verified by exact rerun (IDENTICAL) before
  documentation.
- **Figure 4** (3 panels at this stage: A volcano, B module-correlation heatmap, C
  per-patient representative scores) committed.
- Ledger row: `H4`, `positive`, `Moderate`.
- Commits: `682be13`, `24816be`, `9200163`.

### Milestone: H4 secondary — compartment-level TF-activity follow-up (2026-08-02) —
**COMPLETE, Exploratory**
- Pre-registered BEFORE this script was run (commit `1eb7469`), restricted strictly to the
  primary's 56 locked TFs (enforced in code: `stopifnot(length(hit_tfs) == 56)` reading the
  committed primary CSV, no re-threshold).
- **Result**: 51/168 tests significant, but 43/56 (76.8%) in T_cell alone vs NK 5/56 (8.9%),
  B_cell 3/56 (5.4%). **Audited, not accepted at face value**: T_cell correlates r=0.887 with
  the primary whole-sample signal and shares its exact patient count (19/19) — both explained
  by T cells being 69% of whole-sample composition (documented in H1's own README) — **not
  treated as independent evidence**. NK/B_cell hits (despite far lower power) are the
  informative component: NK (`ZNF395, SREBF1, IRF3, TLX2, IRF2`, all NR-elevated, Module
  1/6-associated); B_cell (`ZFX, IKZF3, IKZF2`, all R-elevated, IKZF3 in Module 5) — echoes
  H2's own B-cell/LTB finding, extended from expression to TF activity.
- **Scripts**: `05_h4_secondary_compartment_tf_activity.R`, `05b_secondary_audit.R`,
  `05c_tcell_redundancy_check.R`.
- Ledger row: `H4-secondary`, `positive`, `Exploratory` — separate row, not combined with
  primary, not promoted into Figure 4.
- Commit: `62b94cf`, root README update `ec10ee0`.

### Milestone: H4 communication network (2026-08-02) — **COMPLETE, Negative finding /
Exploratory**
- **Feasibility-checked before real analysis** (`06_h4_lr_feasibility.R`, `06b_method_
  timing.R`): gene-restriction to LIANA Consensus's 1,839-gene universe proven bit-identical
  to full 55,737-gene matrix (`natmi`, max diff = 0); `cellphonedb` measured at ~87 min
  extrapolated full-scale (178 sec/200 cells) plus real OOM risk (natmi alone touched 9.6GB
  of 10GB budget under poor hygiene) — **excluded from the method consensus on these
  measured grounds**; `connectome`/`logfc`/`sca` individually timed and confirmed cheap
  (9–16 sec/200 cells) before inclusion.
- **Real analysis**: two response-split networks (Responder 2,823 edges; Non-responder 3,477
  edges), 4-method LIANA consensus (`natmi, connectome, logfc, sca`) via
  `liana_aggregate()`. Pre-specified Fisher's exact test (T-cell-directed edges × GO-
  annotated suppressive receptor, 293-gene panel via `msigdbr`, 27 GO:BP terms matched by
  pattern and printed in full) — **NOT significant in either network** (Responder OR=1.11
  P=0.40; Non-responder OR=1.14 P=0.25). **This is H4's formal communication result, a
  genuine negative finding, reported plainly.**
- **Descriptive observation, deliberately NOT given a follow-up test**: while inspecting the
  significant-edge subset (`aggregate_rank<0.05`), a checkpoint-pair pattern was noticed
  (`CD86→CTLA4`, multiple `HLA-D*→LAG3`, `LGALS9→HAVCR2`, concentrated in the Non-responder
  network: 21/76 T-cell-directed significant edges vs Responder's 6/40). **No new
  statistical test was run on this subset** — doing so would violate the same discovery
  discipline that keeps CXCL8/CXCR1/2 out of discovery. Recorded only as a **Descriptive
  observation / Hypothesis for later synthesis**, explicitly not evidence, does not change
  the grade.
- **Terminology fixed by explicit project-owner instruction, applied consistently
  throughout this project since**: **Finding** (pre-specified statistical support) /
  **Negative finding** (pre-specified test did not support) / **Descriptive observation**
  (unbiased pattern noticed after analysis, not itself tested) / **Hypothesis for later
  synthesis** (may be revisited in H5/09_synthesis, not claimed as evidence now).
- **Scripts**: `06_h4_lr_feasibility.R`, `06b_method_timing.R`, `07_h4_lr_communication.R`,
  `07b_h4_lr_suppression_enrichment.R`.
- **Figure 4 restructured (not replaced)**: Panel A (unchanged, TF-activity) + new Panel B
  (D = statistical result/negative finding, E = descriptive observation, muted styling, no
  node-edge diagram, to avoid overstating an untested pattern). **Two real rendering bugs
  caught and fixed before sending to Priya**: Panel E's title overflowing into Panel D's
  space, and the overall caption clipped at the figure edge — both fixed via the `wrap_text`
  helper (see §2's standing rules).
- Ledger row: `H4-communication`, `null`, `Exploratory`.
- Commit: `67ab8e8`.

### Milestone: H4 formally frozen; H5 dataset audit + pre-registration (2026-08-02)
- **Critical review performed before freezing H4** (per explicit request): no essential
  analysis missing; two real carryover considerations noted for H5 (therapy-mix mismatch
  between discovery/validation cohorts; H2/H4-communication out of scope for bulk data,
  since both require single-cell resolution) rather than reopening H4.
- **H5 dataset audit, real URLs verified live before writing any download script** (matching
  H0's own discipline): **GSE78220** (Hugo et al. 2016, *Cell*) — 28 samples, FPKM-only
  (single `GSE78220_PatientFPKM.xlsx`), gene symbols already HGNC. One on-treatment sample
  (Pt16, Progressive Disease) excluded despite the series title claiming "pre-treatment" —
  confirmed via each sample's own `biopsy time:ch1` field, not assumed from the title.
  **Final: n=27 (15 Responder [CR+PR] / 12 Non-responder [PD])**. Join key (`title`→FPKM
  column) required construction (`Pt16`→`Pt16.baseline`), verified not assumed.
  **GSE91061** (Riaz et al. 2017, *Cell*) — 109 samples/65 patients, true raw integer counts
  confirmed present (spot-checked) alongside FPKM/rlog. Gene IDs are Entrez, not symbols —
  mapped via `org.Hs.eg.db` (confirmed installed, spot-checked correct: 1→A1BG, 10→NAT2,
  100→ADA). Response binarized per the original paper's own convention (Responder=PRCR,
  Non-responder=PD+SD, Excluded=UNK). **Final: n=49 (10 Responder / 39 Non-responder)**, 2
  UNK excluded. Join key (`title`) matched FPKM/raw columns exactly (109/109) — verified, not
  assumed, precisely BECAUSE GSE78220's didn't.
- **Statistical methods finalized against the verified data, not decided beforehand**:
  GSE78220 (FPKM-only) → `limma::lmFit`/`eBayes` on `log2(FPKM+1)` (same justification as
  H1's own GSE120575 method choice); GSE91061 (true raw counts available) →
  `edgeR`/`voom` — the statistically correct tool for count data, chosen over forcing
  `limma`-on-FPKM for superficial cross-cohort uniformity, the SAME principle that justified
  `limma` for GSE120575 applied honestly in the direction the data actually points.
- **Standing rule added by the project owner, binding henceforth**: replication requires
  BOTH concordant direction AND significance — neither alone establishes replication.
- **Pre-registration recorded in `CHANGELOG.md` BEFORE any H5 result existed**: H5a
  (confirmatory, gene-level, H1's 4 hits), H5b (confirmatory, TF-module-level, H4's 2 named
  modules, module-score ONLY — explicitly not a 56-TF re-screen), H5c (exploratory,
  literature concordance, grade capped a priori regardless of result).
- **Packages newly required**: `readxl` (GSE78220's xlsx), `org.Hs.eg.db` (GSE91061's Entrez
  mapping) — both confirmed already resolvable via `renv::install()`, no lockfile conflict.
- Scripts: `07_validation_concordance/01_download_data.R`, `02_h5_dataset_audit.R`,
  `03_h5_join_key_and_mapping_check.R`.
- Commit: `72a8dcf`.

### Milestone: H5a — confirmatory gene-level replication (2026-08-02) — **COMPLETE**
- **Result** (both criteria, direction AND significance, applied jointly per the standing
  rule): **LTB — Exploratory** (concordant direction in both GSE78220 and GSE91061, P=0.662
  and P=0.077, neither significant). **CCL3 — Negative finding** (concordant in GSE78220
  P=0.059, but reverses in GSE91061 P=0.087). **CCL4 — Negative finding** (same pattern,
  GSE78220 P=0.512, GSE91061 reversed P=0.092). **CXCL13 — Negative finding** (reverses in
  BOTH cohorts; GSE91061 reversal is nominally significant, P=0.015, in the WRONG direction —
  explicitly not replication per the standing rule).
- **Technical sanity check performed, not just accepted**: confirmed not a coding bug by
  checking that LTB — processed by the identical code path in GSE91061 as CCL3/CCL4/CXCL13 —
  produces the CORRECT expected direction; a systematic sign-flip bug would affect all four
  genes, not select three.
- Background genes (beyond the 4 pre-specified) force-included in both cohorts' `eBayes`
  fits regardless of expression filters, so the 4 test genes could never be silently dropped.
- **Script**: `07_validation_concordance/04_h5a_gene_replication.R`. Reproducibility verified
  (exact rerun, IDENTICAL) before documentation.
- **Figure 5 created** (Panel A: gene-level forest plot, 3 rows per gene — H1 discovery +
  2 validation cohorts, 95% CI, filled=P<0.05).
- Ledger row: `H5a`, `null`, `Exploratory (LTB); Negative finding (CCL3, CCL4, CXCL13)`.
- Commit: `b71b767`.

### Milestone: H5b — confirmatory TF-module replication (2026-08-02) — **COMPLETE, both
Negative findings**
- **Method**: H4's Module 1 (21 TFs) and Module 2 (13 TFs) membership copied verbatim from
  H4's own README, not re-derived. `decoupleR::run_ulm()` per cohort (GSE91061's input via
  `edgeR` TMM+log-CPM normalization prep), **`limma` on module scores for BOTH cohorts** —
  a deliberate, justified departure from H5a's per-cohort method choice: a TF-activity score
  is already a continuous, model-derived quantity once computed (matching H4's own primary
  method), so the data-type-driven choice that governs gene-level tests doesn't apply here.
- **Coverage near-complete**: GSE78220 scored 21/21 and 13/13; GSE91061 scored 21/21 and
  12/13 (TLX2 below `minsize=5` regulon coverage in that cohort — disclosed, not hidden).
- **Result**: **Module 1 — Negative finding** (GSE78220 concordant P=0.502, GSE91061 reversed
  P=0.292). **Module 2 — Negative finding** (GSE78220 concordant P=0.134, GSE91061 reversed
  P=0.458). Both reverse specifically in GSE91061 — the same cohort where all three of
  H5a's non-replicating genes also reversed. **Reported as a factual cross-reference between
  two independent pre-registered confirmatory tests — no new statistical test was run to
  explain this recurring pattern**, consistent with H5a/H5b's confirmatory-only scope.
- **Script**: `06_h5b_tf_module_replication.R`. Reproducibility verified (exact rerun,
  IDENTICAL).
- **Figure 5 extended** (not replaced) with Panel B (module-level forest plot, same
  grammar, including an H4-discovery-cohort reference point computed from H4's own committed
  summary object, not a new analysis). Output file renamed `figure5_h5_validation` (old
  `figure5_h5a_gene_replication` files removed via `git rm`). One real bug caught and fixed:
  the H4-discovery reference point initially rendered grey (color-mapping key mismatch,
  `"GSE120575 (H4 discovery)"` vs `"GSE120575 (H1 discovery)"`) — fixed, verified visually.
- Ledger row: `H5b`, `null`, `Negative finding (Module 1); Negative finding (Module 2)`.
- Commit: `b55ce91`.

### Milestone: H5c — literature concordance (2026-08-02) — **COMPLETE, Exploratory (fixed a
priori)**
- **Real papers identified via literature search** (PubMed, Semantic Scholar — not assumed
  from memory) behind the pre-registration's "Wu 2024/Guo 2025/Wang 2025" citations: **Wu et
  al. 2024**, *Cell* (PMID 38447573, 316 citations) — pan-cancer neutrophil
  antigen-presenting-state paper, matches the brief's description exactly. **Guo et al.
  2025**, *Funct Integr Genomics* (PMID 41068349). **Wang et al. 2025**, *Comput Struct
  Biotechnol J* (PMID 41245889, PMC12613047).
- **Marker-set verification depth is asymmetric, disclosed transparently per explicit
  project-owner instruction, not hidden**: **Wang 2025** — full open-access text obtained,
  13 genes explicitly reported as elevated in the paper's two tumor-enriched terminal
  neutrophil states (Neu_c7, Neu_c10): `CD83, HLA-DRA, CD274, RFX5, CCL3, VEGFA, MAP1LC3B,
  BHLHE40, LDHA, HES4, MAFG, PPARG, CXCR4` (CXCR2/SELL deliberately excluded — reported as
  DOWN-regulated in these states, not markers of them). **Guo 2025** — abstract only
  (confirmed paywalled), 4 genes: `CXCR2, VNN2, BACH1, ATF2`. **Wu 2024** — **excluded from
  the quantitative test entirely**, confirmed three independent ways: direct DOI fetch
  returned HTTP 403; zero gene symbols named in its accessible abstract (unlike Wang/Guo);
  NCBI's own curated PubMed-to-Gene cross-reference (`elink`) returns empty for this PMID.
  **No gene was fabricated or inferred to fill this gap**, per explicit instruction.
- **Test**: hypergeometric over-representation + Jaccard, H1's 327-gene screening panel
  (recomputed identically to H1's own script, cross-checked to match its reported 327) and
  H1's 4 FDR<0.05 hits, each against Wang's and Guo's sets (universe = 55,737 genes,
  GSE120575). BH correction across the 4 tests.
- **Result**: **significant overlap with Wang 2025** — H1 panel: overlap=2 (`CCL3, VEGFA`),
  FDR=0.00513; H1 hits: overlap=1 (`CCL3`), FDR=0.00373. **Zero overlap with Guo 2025** at
  either level (biologically sensible: Guo's markers are receptors/TFs, categorically
  outside H1's secreted-factor-focused GO panel by construction, not a disagreement).
  **Graded Exploratory regardless of the significant p-values** — fixed a priori per the
  pre-registration, since a set-overlap test cannot satisfy the Strong/Moderate tiers'
  patient-level-statistics criterion.
- **Script**: `07_h5c_literature_concordance.R`. Reproducibility verified (exact rerun,
  IDENTICAL).
- **No figure** — H5c is exploratory, not confirmatory, and Figure 5 was deliberately kept
  restricted to confirmatory results only (H5a/H5b), matching the same restraint already
  applied to H4's secondary/exploratory components.
- Ledger row: `H5c`, `positive`, `Exploratory (fixed a priori, not raised by significance)`.
- Commit: `6d23543`.

### Milestone: Module 08 — experimental translation (2026-08-02) — **COMPLETE**
- **Scope rule, strictly applied**: one validation proposal per Moderate/Strong ledger entry,
  no more no fewer. Four qualify: `H0` (Strong), `H1` (Moderate), `H2` (Moderate, primary
  component only), `H4` (Moderate, TF-activity component only). Six entries explicitly
  excluded with stated justification, not silently omitted: H2-secondary, H4-secondary,
  H4-communication, H5a's CCL3/CCL4/CXCL13 (LTB's validation is already covered under H1, at
  the correct Moderate tier), H5b, H5c.
- **Each entry follows the fixed template exactly**: Computational finding → Proposed
  validation → Readout → Prediction → Falsification criterion, referencing its exact ledger
  row and grade, introducing no new biology or hypothesis:
  - **H0**: non-excluding protocol (flow cytometry or fixed-chemistry scRNA-seq) to test the
    protocol-artefact interpretation directly, with an explicit falsification criterion (if
    neutrophils remain undetectable even under a non-excluding protocol, this falsifies H0's
    conclusion).
  - **H1**: multiplex IF/RNAscope for LTB/CCL3/CCL4/CXCL13 on an independent tissue cohort —
    a genuinely different modality from H5a's already-completed bulk-RNA-seq replication,
    not a repeat of it.
  - **H2**: IF co-staining or sorted-population qPCR to test each ligand's cellular-source
    attribution (CCL3+myeloid marker, CCL4+NK marker, LTB+CD20, CXCL13+CD3/CD4) directly.
  - **H4**: CUT&RUN/ChIP-seq or ATAC-seq footprinting for representative TFs from each named
    module (E2F1; SREBF1/PPARA; IKZF3/BACH2), testing occupancy directly rather than
    re-testing expression-inferred activity — genuinely distinct from H5b's already-completed
    (negative) bulk-RNA-seq module-score replication.
- No new evidence-ledger rows (this module makes no graded claim of its own). No computation
  performed (nothing to reproducibility-check — every fact stated is drawn from already-
  verified upstream results).
- Commit: `db7b959`.

---

## 4. Repository State (exact, verified 2026-08-02, post-Module-08)

- **Git status**: clean (`git status --porcelain` empty).
- **Total commits**: 46 (`git rev-list --count HEAD`).
- **Latest commit**: `db7b959` "Module 08 complete: experimental translation proposals".
- **`renv::status()`**: "No issues found — the project is in a consistent state." (verified
  after every commit this session, without exception).
- **Directory tree**: see §2's repository structure block — matches disk exactly as of this
  writing (verified via `find`).
- **Figures completed (5 of 6 frozen figures)**: `figure1_h0_dataset_audit`,
  `figure2_h1_discovery_screen`, `figure3_h2_cellular_sources`, `figure4_h4_tf_activity`
  (now 2-part: Panel A TF-activity, Panel B communication), `figure5_h5_validation` (now
  2-part: Panel A gene-level H5a, Panel B module-level H5b). **Figure 6 (synthesis) is the
  only figure not yet started** — belongs to `09_synthesis`.
- **README status**: root `README.md` fully current through Module 08. All module READMEs
  (`02`–`08`) fully written and current. `09_synthesis/README.md` still the blank
  (non-six-heading) template.
- **Evidence ledger status** (`results/evidence_ledger.tsv`, 9 columns, 10 data rows + header,
  11 lines total): `H0` (negative, Strong), `H1` (positive, Moderate), `H2` (positive,
  Moderate primary/Exploratory secondary), `H4` (positive, Moderate), `H4-secondary`
  (positive, Exploratory), `H4-communication` (null, Exploratory), `H5a` (null, Exploratory
  LTB/Negative finding others), `H5b` (null, Negative finding both modules), `H5c` (positive,
  Exploratory fixed a priori). Module 08 added no new row (by design).
- **CHANGELOG.md status**: current through H5c's literature-identification entry and Module
  08's implicit documentation (Module 08 itself needed no CHANGELOG entry — it deviated from
  nothing, per its own scope rule).
- **REPRODUCIBILITY.md status**: current through H5's dataset table (GSE78220/GSE91061 rows
  fully populated with checksums/verification notes) and gotchas (LIANA resource columns,
  data.table `..` syntax, colData/assay rownames, OOM constraints, readxl/org.Hs.eg.db new
  packages, GSE78220/GSE91061 join-key verification, GSE78220's misleading series title).
- **Important scripts, by module** (all listed in §2's tree; none need repeating here in
  full — see that block for the authoritative file list).
- **Important shared functions**: `R/theme_project.R` (`PROJECT_COLORS`,
  `PROJECT_PALETTE_CATEGORICAL/SEQUENTIAL/DIVERGING`, `theme_project()`,
  `theme_project_blank()`, `save_figure()`); `R/neutrophil_markers.R` (H0 marker-detection
  logic, shared by `02_h0_gse120575.R`/`03_h0_gse72056.R`).
- **Key cached data objects** (`data/processed/`, committed despite the `data/` naming
  suggesting otherwise — only `data/raw/` is actually gitignored): `GSE120575/{meta,tpm}.rds`
  (55,737 genes × 16,291 cells after NA-row removal), `GSE72056/{meta,tpm_log}.rds`,
  `collectri_human_verified.rds` (42,698 edges, 1,178 TFs, verified human-cased).

---

## 5. Scientific Results So Far

*(Every finding stated exactly as strong as its ledger grade — no stronger. Observation /
Interpretation / Hypothesis / Clinical implication kept strictly separate throughout, per the
five-step interpretation framework.)*

### H0 — Strong
**Observation**: neutrophil-specific marker co-occurrence (CEACAM8/MPO/ELANE) is at
chance level in GSE120575 (1 cell vs 0.14 expected); GSE72056 yields only 3–4 plausible,
unassigned candidates after cross-referencing original authors' annotations.
**Interpretation**: neutrophils are depleted to near-completeness by the CD45+-sort +
Smart-seq2 plate-picking protocol common to both datasets.
**Hypothesis**: this is a protocol artefact, not evidence about tumour biology.
**Clinical implication**: none stated — this is a data-availability finding.
**Evidence grade**: Strong (replicated across 2 independent, independently-processed
datasets; rubric's patient-level/multiple-testing criteria explicitly noted as
partially inapplicable to an existence claim, stated not glossed over).

### H1 — Moderate
**Observation**: LTB, CCL3, CCL4, CXCL13 differ significantly (FDR<0.05) between responders
and non-responders, pre-treatment, patient-level pseudobulk, GSE120575.
**Interpretation**: a tumour-derived recruitment/lymphoid-organisation signalling programme
differs by ICB response, detectable pre-treatment.
**Hypothesis**: LTB's direction is concordant with published TLS/lymphotoxin biology
(stated as plausibility, not validation).
**Clinical implication**: deferred (was, at the time, pending H2/H4/H5 — now H2/H4/H5 are
complete; see below for what they added).
**Evidence grade**: Moderate (no cross-dataset replication of its own at the time; H5a has
since tested this directly — result: LTB Exploratory-consistent, CCL3/CCL4/CXCL13 Negative
finding in external cohorts, reported in H5's own module, NOT retroactively changing H1's
grade here).

### H2 — Moderate (primary) / Exploratory (secondary)
**Observation**: 34/35 H1-tested genes show significant compartment restriction; H1's hits
decompose into myeloid/NK (CCL3/TYMP/GPI→Myeloid, CCL4/CCL4L2/CD320→NK) and lymphocyte
(LTB→B cell, CXCL13→T cell) axes. Secondary: 7/27 within-compartment response tests
significant, with regulation not always co-located with abundance (CCL4, LTB).
**Interpretation**: the recruitment programme is not one undifferentiated signal — it
decomposes into a myeloid/NK chemotactic axis and a lymphocyte-organisational axis.
**Hypothesis**: these two axes differentially associate with resistance vs response.
**Clinical implication**: none stated, deferred to H4/H5 (now complete — see below).
**Evidence grade**: Moderate (primary, no cross-dataset replication of its own); Exploratory
(secondary, reduced power, Myeloid excluded entirely).

### H4 — Moderate (TF-activity) / Exploratory (secondary) / Exploratory-Negative (communication)
**Observation (TF-activity)**: 56/754 TFs FDR<0.05, collapsing to Meff=31.3 effective
programs / 13 modules — two large non-responder-elevated modules (E2F proliferation;
metabolic/nuclear-receptor) opposed by a smaller responder-elevated module (IKZF3/BACH2/
SATB2, lymphocyte-differentiation).
**Interpretation**: the recruitment programme is regulatorily coherent — a small number of
correlated, plausible regulatory programs, not undirected noise.
**Hypothesis**: IKZF3/BACH2's association with response is plausible given their published
role in restraining T-cell exhaustion (stated as plausibility, not validation).
**Observation (communication)**: pre-specified Fisher's test for T-cell-directed,
suppressive-receptor-enriched edges is NOT significant in either response-split network.
**Interpretation**: this specific, pre-specified test does not detect convergence on
T-cell suppression at this sample size — a genuine negative result.
**Hypothesis (Descriptive observation only, NOT evidence)**: a checkpoint-pair pattern
(CD86→CTLA4, HLA-D*→LAG3, LGALS9→HAVCR2) noticed post hoc in the Non-responder network's
significant edges is biologically plausible but explicitly not tested — a Hypothesis for
later synthesis only.
**Clinical implication**: none stated for either component.
**Evidence grades**: Moderate (TF-activity primary); Exploratory (secondary compartment
follow-up); Exploratory/Negative finding (communication network) — H5b has since tested the
TF-activity modules' replication directly (result: both Negative findings in external
cohorts, reported in H5's own module, NOT retroactively changing H4's grade here).

### H5 — Exploratory/Negative findings throughout
**Observation (H5a)**: LTB direction-consistent (not significant) in both GSE78220/GSE91061;
CCL3/CCL4/CXCL13 reverse direction specifically in GSE91061.
**Observation (H5b)**: both TF-activity modules reverse direction specifically in GSE91061.
**Observation (H5c)**: significant overlap between H1's panel/hits and Wang et al. 2025's
TAN marker set (CCL3, VEGFA); zero overlap with Guo et al. 2025's set.
**Interpretation**: H1's/H4's discovery-cohort findings do not replicate in two independent
bulk cohorts, with a consistent pattern of reversal specifically in GSE91061 (noted as a
factual cross-reference across H5a/H5b, not further tested). A modest literature-connectable
concordance exists with one independently published pan-cancer TAN atlas.
**Hypothesis**: none advanced beyond what is stated — GSE91061's small Responder group
(n=10) and its different therapy composition from the discovery cohort are pre-declared,
plausible (not tested) contributors to the reversal pattern.
**Clinical implication**: none drawn from any H5 component.
**Evidence grades**: Exploratory (H5a's LTB); Negative finding (H5a's CCL3/CCL4/CXCL13,
H5b's both modules); Exploratory fixed a priori (H5c, regardless of its significant
p-values).

### Remaining uncertainties carried into `09_synthesis`
- The CXCL8–CXCR1/2 axis has been named nowhere in this project — `09_synthesis` is where
  it may finally be asked, post hoc, using the accumulated evidence ledger only.
- The overall systems-level picture (does the evidence, taken together across H1–H5,
  converge on any particular axis or mechanism?) has not yet been synthesized — this is
  `09_synthesis`'s explicit job, using only what's already in the evidence ledger, no new
  analyses.
- Module 08's four proposed validations are unexecuted (by design — this project is
  computational only; Priya performs no wet-lab work herself, these are portfolio-piece
  proposals, not pending tasks).

---

## 6. Dataset Register

| Accession | Platform | Purpose | Preprocessing | Analyses completed | Analyses remaining | Limitations | Importance |
|---|---|---|---|---|---|---|---|
| **GSE120575** (Sade-Feldman 2018) | Smart-seq2 scRNA-seq | Primary discovery, all of H0–H4 | Fully cached (`meta.rds`/`tpm.rds`, 55,737 genes × 16,291 cells post NA-row removal); explicit `col_types`, verified join key | H0, H1, H2, H4 primary+secondary+communication | None planned — fully exploited | TPM-only (no raw counts, forces `limma` not `edgeR`/`voom` for this cohort); therapy-type confound (documented, not adjustable at n=19); 69% T-cell composition (explains H4-secondary's T_cell non-independence) | Central to the entire project |
| **GSE72056** (Tirosh 2016) | Smart-seq2 scRNA-seq | H0 replication ONLY | Cached (`meta.rds`/`tpm_log.rds`, values are `log2(TPM/10+1)`, back-transform required) | H0 replication | None planned — explicitly scoped to H0 only | Absolute TPM thresholds don't transfer from GSE120575 (~100x base-rate difference) — used cell-type cross-reference instead | H0's Strong grade requires ≥2 independent datasets |
| **GSE115978** (Jerby-Arnon) | scRNA-seq | Considered, dropped | N/A | None | None — out of scope | N/A | Dropped 2026-08-01, no marginal value beyond GSE72056 |
| **GSE78220** (Hugo 2016) | Bulk RNA-seq (FPKM only) | H5a/H5b validation cohort 1 | Downloaded, checksummed, audited: n=27 pre-treatment (15R/12NR) after excluding 1 on-treatment sample; join key constructed (title→FPKM column suffix) | H5a (gene-level), H5b (module-level) | None planned | FPKM-only forces `limma` not `edgeR`/`voom`; anti-PD-1-only therapy (differs from discovery cohort's mix) | H5's first independent replication cohort |
| **GSE91061** (Riaz 2017) | Bulk RNA-seq (raw counts + FPKM + rlog) | H5a/H5b validation cohort 2 | Downloaded, checksummed, audited: n=49 pre-treatment usable (10R/39NR) after excluding 2 UNK; Entrez→symbol mapped via `org.Hs.eg.db` | H5a (gene-level, `edgeR`/`voom`), H5b (module-level, TMM+log-CPM input to `run_ulm`) | None planned | Small Responder group (n=10, pre-declared power constraint); anti-CTLA4+anti-PD-1 mixed therapy (differs from GSE78220 and partially from discovery cohort); both H5a and H5b's non-replications trace specifically to this cohort | H5's second independent replication cohort; the cohort where all H5a/H5b reversals occur |
| **CollecTRI** (Müller-Dott 2023, via OmniPath REST API) | TF-target regulon | H4 primary/secondary, H5b, H5c-adjacent tooling | Verified human-cased, deduplicated per `get_collectri()`'s own canonical logic: 42,698 edges, 1,178 TFs (`data/processed/collectri_human_verified.rds`) | Used throughout H4 and H5b | None planned | One isolated data artefact (`Mgu`→UROS mismap) found and dropped | Backbone of all TF-activity analyses |
| **LIANA Consensus resource** | Ligand-receptor pairs | H4 communication component | Loaded in-session (not a downloaded file); gene-restricted to 1,839-gene universe for memory efficiency, verified bit-identical to full-gene version | Used in H4 communication (both response-split networks) | None planned | N/A | H4's communication network backbone |
| **Wang et al. 2025** (PMID 41245889) | Published pan-cancer neutrophil atlas (literature, not a dataset download) | H5c marker set | Full text obtained (PMC12613047); 13 genes extracted | Used in H5c | None planned | N/A — most complete of the three H5c sources | H5c's primary marker set, source of its significant overlap finding |
| **Guo et al. 2025** (PMID 41068349) | Published pan-cancer neutrophil atlas (literature) | H5c marker set | Abstract only (paywalled); 4 genes extracted | Used in H5c | Could be updated if full text becomes accessible (would require a new CHANGELOG entry) | Thin marker set purely due to paywall, disclosed | H5c's secondary marker set (zero overlap found) |
| **Wu et al. 2024** (PMID 38447573, *Cell*) | Published pan-cancer neutrophil atlas (literature) | H5c — attempted, excluded | Paywalled (confirmed HTTP 403); zero gene symbols accessible by any method checked | None — excluded from the quantitative test | Could be added if full text/supplementary tables become accessible (new CHANGELOG entry required) | Zero gene-level data accessible; disclosed as a limitation, not approximated | Named in the pre-registration but contributes nothing testable currently |

---

## 7. Current Position

- **Active module**: none. `08_experimental_translation` was just completed and frozen at
  commit `db7b959`. `09_synthesis` has not been started — no file in that module has been
  touched beyond its blank template.
- **Active script**: none.
- **Files currently being edited**: none — working tree is clean.
- **Last successful outputs**: `08_experimental_translation/README.md` (4 validation
  proposals, committed); root `README.md` (updated to reflect Module 08 complete,
  committed).
- **Latest git commit**: `db7b959` "Module 08 complete: experimental translation proposals".
- **Unfinished work**: none within Modules 02–08. `09_synthesis` is entirely unstarted.
- **Expected immediate next action**: design (not yet implement) `09_synthesis` — the
  systems-level synthesis model and the post-hoc CXCL8–CXCR1/2 question, using ONLY the
  accumulated evidence ledger (10 rows) — no new analyses, no new datasets, no new figures
  beyond Figure 6.

---

## 8. Remaining Roadmap

Only one module remains.

### Step 1 — Design `09_synthesis` (design only, do not implement yet)
- **Objective**: propose the exact scope and structure of the final synthesis module before
  writing anything, matching this project's established design-then-confirm pattern (used
  for H4's communication component, H5's pre-registration, and Module 08's scope rule).
- **Required inputs**: the full `results/evidence_ledger.tsv` (10 rows) — no new data.
- **Expected outputs**: a design proposal (in chat, not yet in a file) covering: (a) how the
  systems-level model synthesizes H1–H5's findings (likely a qualitative/schematic
  integration, given no module supports a quantitative meta-analytic combination across
  such heterogeneous evidence types); (b) the exact post-hoc procedure for asking whether
  the evidence converges on CXCL8–CXCR1/2 — this axis has never been named or tested
  anywhere in the project, so `09_synthesis` must state clearly whether it is now testing it
  for the first time (using only already-committed results, e.g. checking whether CXCL8,
  CXCR1, or CXCR2 appear anywhere in H1's ranked table, H4's TF-activity results, or H5c's
  overlap tables) or merely discussing it narratively; (c) Figure 6's content and scope.
- **Dependencies**: none — can start immediately.
- **Expected figure**: Figure 6 (synthesis) — the sixth and final frozen figure.
- **Expected evidence grade**: `09_synthesis` is explicitly NOT a hypothesis test (exempt
  from six-heading format and from ledger grading, per the frozen architecture) — no new
  ledger row is anticipated, matching Module 08's own precedent, but this should be
  confirmed with Priya during design, not assumed.
- **Expected git commit**: none yet — this step is design-only.

### Step 2 — Implement `09_synthesis` (only after Step 1's design is confirmed)
- **Objective**: write the synthesis module's content (likely a README-only module, possibly
  with a small script if the CXCL8/CXCR1/2 check requires querying already-committed result
  tables — but this would not be new analysis in the discovery sense, since it only inspects
  already-locked, already-committed data).
- **Expected outputs**: `09_synthesis/README.md` (full content replacing the blank
  template), Figure 6, possibly a small script if needed to build Figure 6 or query the
  CXCL8/CXCR1/2 question (to be determined during Step 1's design).
- **Dependencies**: Step 1's design confirmed by Priya.
- **Expected git commit(s)**: at least one, likely following the same pattern as every other
  module — script(s) run and verified (by Priya if new analysis, by Claude if pure
  documentation/figure-from-already-committed-data), README written, root README updated,
  everything committed together as one closed unit, reproducibility verified if any
  computation is involved.

### Step 3 — Final project-wide audit and closure
- **Objective**: once `09_synthesis` is complete, perform a final whole-project audit
  (matching the standing "audit after every phase" rule, applied here at the largest
  possible scope) — re-read every module's README, the full evidence ledger, CHANGELOG, and
  REPRODUCIBILITY.md, and confirm internal consistency across the entire finished project.
- **Dependencies**: Step 2 complete.
- **Expected outputs**: possibly a final CHANGELOG entry noting project completion; no new
  scientific content.
- **Expected git commit**: a final closing commit, if any inconsistency is found and fixed;
  otherwise this may require no commit at all if the audit finds everything already
  consistent.

---

## 9. Important Decisions and Lessons

*(Preserved so they are never re-litigated or re-discovered the hard way. Organized by
theme, spanning the entire project, not just this session.)*

### Discovery discipline and scope control
1. **CXCL8–CXCR1/2 removed from the central question through 3 revisions** — naming any
   pathway, even post hoc, risked priming discovery toward a pre-chosen answer. Now
   maintained across FIVE completed hypothesis modules plus Module 08 without exception,
   including the H4-communication case where a genuinely tempting follow-up test was
   deliberately not run.
2. **Every discovery/confirmatory panel is externally sourced**: H1's msigdbr GO panel, H4's
   CollecTRI network + decoupleR's own minsize rule, H5a/H5b's genes/modules locked from
   already-committed primary results (not re-selected), H5c's marker sets from real,
   identified papers (not fabricated to fill gaps).
3. **Scope-expansion requests are evaluated against explicit criteria before being
   accepted, not by default**: the H4 compartment-secondary follow-up was approved only
   after being reframed from a broad "compartment × all-TF sweep" (rejected, ~3.7/10) to a
   narrow, precedent-matching secondary tier (accepted, ~6.8/10). The pattern: present a
   scored evaluation against explicit criteria (scientific gain vs. complexity, novelty,
   portfolio value, risk), let the human decide, never expand by default.
4. **Post-hoc observations are labeled, never silently promoted**: the H4 checkpoint-pair
   pattern is a Descriptive observation / Hypothesis for later synthesis, explicitly not
   evidence, explicitly not given a follow-up test — this exact discipline is the model for
   how `09_synthesis` must eventually handle the CXCL8/CXCR1/2 question too.

### Statistical method choices
5. **`limma` over `edgeR`/`voom` for GSE120575 and GSE78220**: both are FPKM/TPM-only (no
   raw counts), so count-based negative-binomial modelling would be statistically invalid —
   a data-availability-driven choice, not a general preference.
6. **`edgeR`/`voom` for GSE91061**: true raw counts ARE available there, so the same
   principle (method follows verified data type) points the other way — a deliberate,
   justified departure from naive cross-cohort methodological uniformity, decided only
   after the dataset audit confirmed the actual data type, not before.
7. **`limma` on TF-activity module scores for BOTH H5b cohorts, regardless of each cohort's
   underlying expression-data type**: once `decoupleR::run_ulm()` produces a continuous,
   model-derived score, the gene-level data-type distinction no longer applies — matching
   H4's own primary-analysis precedent.
8. **A replication verdict requires BOTH concordant direction AND significance** (H5's
   standing rule, added explicitly by the project owner) — a significant result in the
   wrong direction is not replication; a same-direction trend without significance is not
   replication either. Applied identically to H5a and H5b.
9. **Set-overlap/literature-concordance tests are capped at Exploratory a priori**,
   regardless of their p-values — the same rubric caveat already used for H0's existence
   claim, now also applied to H5c. A significant hypergeometric p-value does not mean the
   evidence grade rises.
10. **Module-clustering/effective-test-count characterization (Nyholt 2004) is not a new
    discovery search** — it is a post-hoc characterization of an ALREADY-LOCKED primary
    result's own internal structure (H4's 56 hits → Meff=31.3), added specifically because
    the raw result showed unexpected redundancy. This is methodologically distinct from,
    and does not violate, the discovery-discipline rule against re-selecting a discovery
    panel after seeing results.

### Real, external technical blockers (verified via source/issue-tracker reading, never guessed)
11. **`decoupleR::get_collectri()`'s Ensembl dependency is broken externally** — confirmed
    via actual GitHub issue trackers, not assumed from the error message. The taxid
    workaround (Plan A) was tried and confirmed NOT to work — do not retry it.
12. **A downloaded "human" data file can be mislabeled** — the Zenodo CollecTRI fallback was
    genuinely mouse-cased despite its filename; verified by direct edge-level comparison
    against a known-correct source, not assumed from the file's metadata.
13. **Not every non-uppercase gene symbol is a casing bug** — HGNC's `orf` convention and
    miRBase's `hsa-miR-*` convention are both legitimately non-uppercase; verified by
    checking the actual non-uppercase values against known nomenclature conventions before
    concluding anything was wrong.
14. **LIANA's Consensus resource uses `source_genesymbol`/`target_genesymbol` columns**, not
    `ligand`/`receptor` as might be guessed from `liana_wrap()`'s OUTPUT structure — a wrong
    guess here failed loudly (empty selection) rather than silently, confirmed by printing
    actual column names before relying on any assumption.
15. **`liana_prep()` requires BOTH `counts` and `logcounts` assays** — confirmed by reading
    the function's actual source code, not from documentation alone (which didn't state this
    explicitly).
16. **`cellphonedb` is measurably far more expensive than LIANA's other default methods** —
    quantified (178 sec/200 cells vs 9–30 sec for the others) before deciding to exclude it,
    not assumed from its permutation-based design alone.
17. **A GEO series' title can misdescribe its own sample composition** — GSE78220's title
    claims "pre-treatment melanomas" but one of its 28 samples is on-treatment; caught by
    checking each sample's own `biopsy time:ch1` field, not trusting the series-level
    description.
18. **A paper's paywall status must be confirmed directly** (HTTP fetch, not assumed from
    journal reputation) before concluding no data is accessible — done for both Guo 2025 and
    Wu 2024 before excluding/limiting their marker sets.

### Reproducibility and tooling gotchas (full list also in `REPRODUCIBILITY.md`)
19. `data.table`'s `..` prefix only reliably resolves a bare variable name.
20. `SingleCellExperiment`/`SummarizedExperiment` requires `colData` row names to exactly
    match assay column names.
21. Building large dense matrices without clearing prior large objects first can hit this
    machine's 10GB WSL2 ceiling even when the final matrix itself is small — fixed by
    restricting to the minimum necessary gene set BEFORE building any per-group structure,
    not after.
22. ggplot does not auto-wrap long titles/subtitles/captions — this caused real, visible
    rendering bugs THREE separate times across this project (Figure 1, Figure 4 twice,
    Figure 5) and is now a standing pre-emptive check applied to every new multi-panel
    figure, not just a reactive fix.
23. Editing a file via its WSL UNC path directly, then later `cp`-ing an unedited scratchpad
    copy onto that same path, silently reverts the edit — caught once in this session
    (Figure 5's color-mapping fix), the safe pattern (edit scratchpad → verify → cp → verify
    again) has been followed for every file operation since.
24. A GEO series matrix's phenotype-table `title` field does not always match its expression
    matrix's column names directly (GSE78220 needed a constructed join key; GSE91061's
    matched exactly) — always verify this explicitly, never assume based on one cohort's
    behaviour transferring to another.

### Process and collaboration patterns established
25. **Design-then-confirm, applied consistently for every non-trivial decision**: H4's
    communication-network design (gene-scope, method choice, response-split design, GO-based
    suppression-panel design) was proposed in full before any script was written; H5's
    entire pre-registration was recorded in `CHANGELOG.md` before implementation began;
    Module 08's scope rule was established before any proposal was drafted.
26. **Audit-before-lock, applied after every primary/secondary/exploratory result**: H4
    primary's 41%-raw-P<0.1 audit, H4-secondary's T_cell-redundancy audit, H5a's
    technical-sanity check, H2's audit-driven correction — this is not a one-time rule, it
    is exercised every single time a new result is produced.
27. **One module fully documented and committed before the next begins**, without exception,
    even when the next step's design is already known (e.g. H5a fully closed before H5b
    began; H4 primary fully closed before its secondary began).
28. **Corrections and updates are new entries, never silent retroactive edits** — exercised
    for H0's GSE72056 miscount, and stated explicitly as the governing principle every time
    a later module's result might seem to bear on an earlier module's conclusion (e.g. H5a
    does not retroactively change H1's grade; H5b does not retroactively change H4's grade).

---

## 10. Project Standards

These rules govern all remaining work and must not be relaxed without an explicit,
documented, genuine blocker:

- **Hypothesis-first workflow**: every module states its hypothesis before any analysis is
  designed; `09_synthesis` and `01_background`/`08_experimental_translation` are the only
  exceptions, by frozen design, not by default.
- **Evidence grading**: Strong/Moderate/Exploratory, with the fixed criteria in §2 — never
  invent a new tier, never let a small p-value override a pre-declared grade ceiling (H5c).
- **Interpretation discipline**: the five-step framework, every substantive result, no
  skipping from statistical change directly to clinical implication.
- **Reproducibility**: every script that produces a committed result must be rerun from
  scratch and diffed against its committed output before being treated as final — this has
  been done for every H4/H5 script without exception and must continue for `09_synthesis`.
- **Documentation standards**: six-heading template for hypothesis modules; README, ledger,
  figure (if any), and root README updated together, as one committed unit, per module.
- **Git discipline**: new commits, never amended (except immediately after a failed
  pre-commit hook); commit messages explain why, not just what; `renv::status()` clean
  before every commit.
- **Negative-results policy**: negative and null findings reported with equal weight and
  detail as positive ones — exercised repeatedly, not just promised.
- **Scientific restraint**: "concordant with" is never "validated by"; "suggests" is never
  "proves"; grade down when in doubt, and say why.
- **No scope expansion by default**: every expansion this session (H4 compartment-secondary,
  H4-communication's design) was evaluated against explicit criteria and approved
  individually — this is the model for any future expansion request, including anything
  that might arise during `09_synthesis`.

---

## 11. RESUME FROM HERE

The next session should do exactly this, in this order, with no other action first:

1. **Read this entire document.** Do not begin work from a summary or from partial context,
   and do not re-open `CONTINUATION_BRIEF.md`'s prior versions — this document supersedes
   all of them completely.

2. **Verify the actual repository state matches §4 above** — run `git status --porcelain`
   (expect clean) and `git log --oneline -3` (expect `db7b959` as the latest commit) before
   assuming anything. This is the standing "verify, don't assume" discipline applied to the
   handoff itself.

3. **Begin designing `09_synthesis` — design only, do not write any script or README content
   yet.** Present a design proposal covering:
   - How the systems-level model integrates H1–H5's findings (10 evidence-ledger rows,
     spanning Strong/Moderate/Exploratory/Negative across positive/negative/null
     directions) — almost certainly a qualitative/schematic synthesis, not a new
     quantitative meta-analysis, given how heterogeneous the evidence types are (single-cell
     discovery, TF-activity inference, bulk-cohort replication, literature concordance).
   - The exact, disciplined procedure for the post-hoc CXCL8–CXCR1/2 question: check
     whether CXCL8, CXCR1, or CXCR2 appear anywhere in the ALREADY-COMMITTED result tables
     (H1's ranked screen, H4's TF-activity ranked table, H5c's overlap tables) — this is
     inspecting already-locked data, not new discovery, and should be framed that way
     explicitly, distinguishing "did this axis already appear in evidence we already
     generated" from "let's go test this axis now" (the latter would violate the discovery
     discipline this project has maintained for five modules running).
   - Figure 6's scope and content (the final frozen figure).
   - Whether `09_synthesis` produces any new evidence-ledger row at all (Module 08's own
     precedent — no new row for a non-hypothesis-testing module — should inform this, but
     confirm explicitly with Priya rather than assume it carries over identically).

4. **Wait for Priya's explicit confirmation of the design** before writing any file — this
   matches every prior module's pattern in this project without exception.

5. **Only after design confirmation**, implement `09_synthesis`, following the same
   discipline as every prior module: any new computation (even simply querying already-
   committed tables, if it produces a new interpretive claim) should be considered against
   the execution boundary; write the README and Figure 6; update the root README; verify
   `renv::status()`; commit as one closed unit; verify reproducibility if any script was
   run.

6. **Risks to watch for specifically in `09_synthesis`**: (a) the temptation to let the
   CXCL8/CXCR1/2 question become a new discovery search rather than a disciplined,
   backward-looking inspection of already-committed evidence — this is the single most
   carefully-protected rule in the entire project and must not be the place it finally
   breaks; (b) the temptation to overstate what the accumulated evidence shows, given that
   most of H4/H5's components are Exploratory or Negative findings — the synthesis must be
   as restrained as every individual module has been, not more confident merely because it
   is the final module; (c) remember the file-editing gotcha (§2, §9 item 23) — always
   verify edits landed in the scratchpad copy before `cp`-ing to WSL, and verify again after.

The project is in excellent standing: 46 commits, six hypothesis modules (H0–H5) fully
complete and internally consistent, one correctly and honestly omitted (H3), Module 08
complete with exactly the validation proposals its scope rule allows, and a clean, fully
reproducible repository throughout. Nothing is broken; nothing needs to be redone; the next
session simply needs to design and then build the final synthesis module.
