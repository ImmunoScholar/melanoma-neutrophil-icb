# Immune-compartment secretory and regulatory programmes associated with immune checkpoint response in melanoma

**Title and central question revised 2026-08-02**, after an independent peer review of the
completed project and two evidence-grounded post-hoc audits (`03_recruitment/README.md`,
addenda #1–#2; `CHANGELOG.md`). This is a wording-alignment revision only — no analysis was
rerun, no evidence grade changed, and no module's tested hypothesis or result was altered.
The original title ("Tumour-derived neutrophil recruitment and signalling programmes...") is
preserved in `CHANGELOG.md` and in git history, not silently erased.

## Central question

Which immune-compartment-derived secretory and regulatory programmes distinguish immune
checkpoint responders from non-responders in human melanoma?

**Why "neutrophil recruitment" and "tumour-derived" were removed from the title (evidence, not
caution):**
- This project was motivated by tumour-associated-neutrophil (TAN) biology and the
  neutrophil-to-lymphocyte ratio's clinical association with checkpoint failure (see
  `01_background`). `02_dataset_audit` (H0) established that neutrophils are not recoverable
  as cells in this dataset (CD45⁺-sort + Smart-seq2 plate-picking depletion). A post-hoc audit
  (`03_recruitment/README.md` addendum #1) subsequently found that the canonical
  neutrophil-recruitment chemoattractant repertoire (CXCL1/2/3/5/6/8, PPBP, CSF3) is **also
  undetectable at the transcript level** in this same dataset — 0 of 8 clear H1's own
  detection filter. H1's actually-discovered programme (LTB, CCL3, CCL4, CXCL13) is real,
  patient-level, and multiply-corrected, but it is a lymphoid-organisational and myeloid/NK
  chemotactic signature — **not a demonstrated neutrophil-recruitment programme**. The title
  now describes what was measured, not what originally motivated measuring it.
- **"Tumour-derived" is likewise not supported**: `02_dataset_audit` found malignant cells at
  ~0.04% of GSE120575 (6 of 16,291 cells) — too few to analyse. Every finding in this project
  (H1, H2, H4) is attributed to immune-lineage compartments (T cell, B cell, Myeloid, NK), not
  to malignant-cell output. The programmes described here are produced *within* the tumour
  microenvironment's immune infiltrate, not demonstrated to originate from tumour cells
  themselves.

Discovery (module `03_recruitment`) screens the full secreted chemokine/cytokine/growth-factor
repertoire without prior restriction to any pathway. Only after the discovery ranking is fixed
and committed does interpretation (`09_synthesis`) ask, post hoc: *does the highest-ranked
programme converge on a therapeutically targetable axis?* No pathway is named or privileged in
the discovery analyses. **H1, H2's primary test, and H4's primary test all run on the
identical 19-patient discovery cohort and share its identical, disclosed therapy-type
confound** (`03_recruitment/README.md` addendum #2) — they are three complementary analytical
lenses on one cohort, not three independent confirmations of one signal; a post-hoc
confound-adjustment found this asymmetric across H1's own hits (LTB robust; CCL3/CCL4/CXCL13
fragile), detailed in `09_synthesis/README.md`.

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
| H4 | The recruitment programme is regulatorily coherent and its intercellular communication converges on T-cell suppression | `06_regulation_communication` | 4 | **Complete — Moderate (TF-activity) / Negative finding (communication)** |
| H5 | The programme generalises to independent cohorts and agrees quantitatively with published TAN biology | `07_validation_concordance` | 5 | **Complete — Exploratory/Negative findings throughout** |
| — | Synthesis (not a hypothesis test) | `09_synthesis` | 6 | **Complete — integrates the existing ledger, adds no new row** |

Every module follows: **Hypothesis → Analysis → Evidence → Interpretation → Limitations →
Conclusion**, and every conclusion is graded Strong / Moderate / Exploratory in
`results/evidence_ledger.tsv`.

**Framing note (added 2026-08-02):** the hypothesis statements above are reproduced exactly as
originally pre-registered and tested — they are a historical record, not rewritten to match
the revised title. H1's tested hypothesis used "neutrophil-recruitment" as its working label;
what H1 actually found (LTB, CCL3, CCL4, CXCL13) was subsequently audited and found not to be
neutrophil-specific (`03_recruitment/README.md` addendum #1). This does not change what was
tested or its result — it changes how the result should be *described*. See the revised
Central Question above and `09_synthesis/README.md` for the corrected framing.

## Status

Architecture frozen 2026-08-01. Environment and repository scaffolding complete.

- **H0 (`02_dataset_audit`): complete.** Supported at Strong grade across two independent
  datasets (GSE120575, GSE72056). Result: neutrophils are depleted to near-completeness by
  CD45+ sorting plus Smart-seq2 plate-picking — single-digit recoverable candidates in both
  cohorts. This placed the project on the pre-specified `<20` branch of the failure-tolerant
  decision tree, omitting H3.
- **H1 (`03_recruitment`): complete, Moderate grade — but not uniform across its 4 hits.**
  Patient-level pseudobulk (19 pre-treatment patients, GSE120575), unbiased screen of a
  327-gene GO-sourced chemokine/cytokine/growth-factor panel. 4 genes significant at FDR<0.05,
  top finding (LTB) concordant with published tertiary lymphoid structure biology — concordance,
  not independent validation. H5a has now tested independent-cohort replication for all 4 hits
  (see below) — H1's own Moderate grade is unchanged by that result, reported separately in
  `07_validation_concordance/README.md`, not by reopening this module. **Two post-hoc audits,
  added after independent peer review (`03_recruitment/README.md` addenda #1–#2):** (1) the
  canonical neutrophil-chemoattractant repertoire is undetectable in this dataset (0/8 clear
  H1's own detection filter) — H1's programme is real but is not neutrophil-specific; (2) a
  therapy-type confound-adjustment found LTB robust (still FDR<0.05, similar effect size) while
  CCL3/CCL4/CXCL13 are not (effect sizes preserved, but power lost) — converging with H5a's own
  external-replication asymmetry. Full ranked table and all stated limitations in
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
- **H4 (`06_regulation_communication`): complete.** TF-activity component: Moderate grade.
  Patient-level pseudobulk (same 19 pre-treatment patients as H1/H2), `decoupleR::run_ulm()`
  against a verified CollecTRI network (42,698 edges, 1,178 TFs), 754 TFs scored. 56
  significant at FDR<0.05 — but reported alongside a module-clustering characterization
  (hierarchical clustering + Nyholt 2004 effective-test count) showing this collapses to ~31
  effective independent regulatory programmes, not 56 independent findings. Two large modules
  elevated in non-responders (a canonical E2F proliferation cluster; a broader
  metabolic/nuclear-receptor cluster) are opposed by a smaller module elevated in responders
  (IKZF3/BACH2/SATB2 — established lymphocyte-differentiation regulators, stated as
  plausibility, not validation). Same therapy-type confound H1 documented (same cohort)
  applies here too, restated rather than assumed already covered.
  **Secondary/exploratory follow-up** (pre-registered, `CHANGELOG.md`): restricted to the
  primary's 56 locked TFs, compartment-level (T_cell/NK/B_cell). T_cell's result (43/56 hits)
  is not treated as independent evidence — it correlates strongly with the primary
  whole-sample signal (r=0.887) and shares its patient count, both explained by T cells being
  69% of whole-sample composition. The informative component is NK (5 TFs) and B_cell (3
  TFs), reaching significance despite lower power — B cells specifically carry a
  responder-elevated lymphocyte-differentiation signal (IKZF3), echoing H2's own B-cell/LTB
  finding. Graded Exploratory, separate ledger row, not promoted into Figure 4.
  **Communication network component: Negative finding.** Pre-specified Fisher's exact test
  (T-cell-directed edges x GO-annotated suppressive receptor, LIANA 4-method consensus,
  response-split networks) does not support enrichment in either network (Responder OR=1.11
  P=0.40; Non-responder OR=1.14 P=0.25) — reported plainly per the Negative Results Policy. A
  checkpoint-pair pattern noticed afterward in the significant-edge subset (CD86→CTLA4,
  HLA-D*→LAG3, LGALS9→HAVCR2, concentrated in the Non-responder network) was **not**
  independently tested and is carried forward only as a Descriptive observation / Hypothesis
  for later synthesis — explicitly not evidence, does not change this component's grade.
  Figure 4 now integrates both components (Panel A: TF-activity; Panel B: communication,
  with the statistical result and the descriptive observation visually and textually
  distinguished). Full results and limitations in `06_regulation_communication/README.md`.
- **H5 (`07_validation_concordance`): complete.** H5a, H5b, and H5c all done. Pre-registered
  in `CHANGELOG.md` before any result existed: statistical method chosen per cohort's
  verified data type (`limma` on FPKM for GSE78220, n=27 pre-treatment; `edgeR`/`voom` on raw
  counts for GSE91061, n=49 pre-treatment usable). Replication verdict (H5a/H5b) required
  BOTH concordant direction AND significance, fixed in advance.
  **H5a** (H1's 4 FDR<0.05 genes, confirmatory): **LTB — Exploratory** (direction-consistent
  in both cohorts, significant in neither). **CCL3, CCL4, CXCL13 — Negative finding** (each
  reverses direction in GSE91061 specifically).
  **H5b** (H4's 2 named non-responder-elevated TF-activity modules, confirmatory,
  module-level score only — not a 56-TF re-screen): **both modules — Negative finding** (both
  reverse direction in GSE91061, the same cohort where H5a's genes also reversed — noted as a
  factual cross-reference between two independent confirmatory tests, not tested further).
  **H5c** (published TAN literature concordance, exploratory and capped a priori
  regardless of result): three real papers behind the pre-registration's citations were
  identified via literature search — Wu et al. 2024 (*Cell*), Guo et al. 2025, Wang et al.
  2025 — and their marker sets verified to genuinely different depths, disclosed not hidden
  (Wang 2025: 13 genes, full text; Guo 2025: 4 genes, abstract only; Wu 2024: zero genes
  accessible by any method checked, excluded entirely, not approximated). Significant overlap
  with Wang 2025's set (H1's panel and its hits both include CCL3; the panel also includes
  VEGFA), zero overlap with Guo 2025's — **graded Exploratory regardless**, per the
  pre-registration's fixed rubric ceiling.
  All results reported exactly as the pre-registration specifies, per the Negative Results
  Policy — not reinterpreted, not explained away, no marker genes fabricated. Pre-declared
  caveats (GSE91061's small Responder group, n=10; differing therapy composition across all
  three cohorts) are stated as context fixed before these analyses were run. H1's and H4's
  own conclusions and grades are unchanged. Full results, Figure 5 (Panel A: H5a; Panel B:
  H5b — H5c is not shown in a figure, consistent with its exploratory tier), and limitations
  in `07_validation_concordance/README.md`.
- **`08_experimental_translation`: complete.** Not a hypothesis-testing module (exempt from
  the six-heading template, per the frozen architecture) — proposes experimental validation
  for every Moderate/Strong ledger entry, one each, no new biology introduced: **H0** (Strong)
  — non-excluding protocol (flow cytometry / fixed-chemistry scRNA-seq) to test whether
  neutrophil absence is protocol artefact, as concluded, or genuine depletion. **H1**
  (Moderate) — multiplex IF/RNAscope for LTB/CCL3/CCL4/CXCL13 on an independent tissue
  cohort. **H2** (Moderate, primary component) — IF co-staining or sorted-population
  qPCR to test each ligand's compartment attribution directly. **H4** (Moderate,
  TF-activity component) — CUT&RUN/ChIP-seq or ATAC-seq footprinting for representative TFs
  from each named module, to test occupancy directly rather than infer activity from
  expression. Exploratory and Negative-finding entries (H2-secondary, H4-secondary,
  H4-communication, H5a's non-LTB genes, H5b, H5c) are explicitly not given validation
  proposals, stated and justified in `08_experimental_translation/README.md` rather than
  silently omitted. No new evidence-ledger rows — this module makes no graded claim of its
  own.

- **`09_synthesis`: complete.** Not a hypothesis-testing module (exempt from the six-heading
  template, per the frozen architecture) and **adds no new evidence-ledger row** — it
  integrates H0-H5's already-graded findings, it does not extend them. Evidence-weighted
  synthesis (Section 2 of `09_synthesis/README.md`) is organized in the fixed order
  Observation -> Interpretation -> Biological hypothesis -> Clinical implication throughout,
  so no statement outruns its supporting grade: H1 (Moderate) and H2 primary (Moderate)
  establish a two-axis recruitment/organisation programme (myeloid/NK chemotactic; lymphocyte
  organisational); H4 primary (Moderate) shows this is accompanied by a regulatorily coherent,
  honestly-characterized TF layer (Meff=31.3 independent programs, not 56); H5's confirmatory
  tests (H5a/H5b) found the non-LTB components do not clear this project's own pre-declared
  external-replication bar (Negative finding, concentrated specifically in GSE91061), which
  constrains the programme's external generalisability without invalidating the internally
  consistent, patient-level, multiply-corrected discovery work that produced it. **Figure 6**
  (evidence-driven systems model, `09_synthesis/01_figure6_synthesis_model.R`) renders this
  H1-H2-H4 structure directly from already-committed result tables — every node/edge
  traceable to a graded finding, solid vs. dashed distinguishing project-generated results
  from literature-derived/externally-unvalidated links, with each tested node's H5
  replication status computed (not asserted) from `h5a`/`h5b`'s own committed columns.
  **The pre-registered CXCL8/CXCR1/CXCR2 post-hoc check** (Section 4 of the module README):
  none of the three appears in H1's ranked screen, H4's TF-activity ranking, or H5c's overlap
  tables — reported strictly as a retrospective observation about what this project's own
  analyses surfaced, explicitly not as evidence for or against the axis's biological role or
  the ongoing clinical trials referenced in `01_background`. Full synthesis, limitations
  rollup, and the CXCL8 check's exact scope caveats in `09_synthesis/README.md`.

With Module 09 complete, all nine planned modules are finished; the only remaining step is a
final whole-project consistency audit (`CONTINUATION_BRIEF.md` SS8, Step 3).

See `REPRODUCIBILITY.md` for exact reproduction instructions and `CHANGELOG.md` for every
post-freeze deviation and its justification.
