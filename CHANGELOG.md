# Changelog

## 2026-08-02 — Root README rewritten as a presentation pass

Presentation-only revision, no scientific content changed. The root README was restructured
from a chronological, module-by-module status narrative into a results-first summary: a short
overview, the evidence-synthesis figure, a single results table (hypothesis, test, result,
grade) linking to each module, a dataset table, one consolidated limitations paragraph, and a
pointer to `REPRODUCIBILITY.md`/`CHANGELOG.md` for full methodological and provenance detail.
No evidence grade, statistical result, or figure was altered; all removed detail remains in
the relevant module's own README. Reduced from ~2,230 to ~780 words.

## 2026-08-02 — Final whole-repository consistency audit and project freeze

Per `CONTINUATION_BRIEF.md` §8 Step 3, performed after Category B (above): re-read every
module README (`01_background` through `09_synthesis`), `results/evidence_ledger.tsv` in full,
this `CHANGELOG.md`, `REPRODUCIBILITY.md`, all six committed figures, the complete git log
(51 commits), `git status --porcelain`, and `renv::status()`.

**Found and fixed (two items, both documentation-only, no analysis touched):**
1. Root `README.md`'s own summary of `09_synthesis` (in the Status section) still read "H1
   (Moderate) and H2 primary (Moderate) establish a two-axis recruitment/organisation
   programme" — a paraphrase written before Category B that was not updated when
   `09_synthesis/README.md` itself was retitled to "immune-compartment signalling programme —
   not neutrophil-specific." Fixed to match, with a cross-reference to addendum #1.
2. `REPRODUCIBILITY.md`'s **Figure regeneration** and **Fresh-clone reproduction** sections
   had not been updated since H0 was the only completed module — the fresh-clone bash sequence
   stopped after H0's two scripts, and the figure-regeneration section was still marked
   "(pending)," despite the project now being complete through Module 09 with six committed
   figures. This predates Category B and was not something either A1, A2, or the Category B
   pass touched — caught only by this final whole-repository read-through, which is exactly
   why this audit step exists as a separate, deliberate pass rather than being assumed covered
   by the preceding, narrower changes. Fixed: both sections now cover the complete project
   (all module scripts in execution order, diagnostic/audit scripts explicitly marked as
   skippable, a per-figure dependency table for all six figures).

**Checked and confirmed already consistent (no changes needed):**
- `results/evidence_ledger.tsv`: 9 columns, 9 data rows + header, structurally intact; every
  grade/direction matches its originating module's Conclusion section and `09_synthesis`'s
  evidence map.
- `02_dataset_audit/README.md` and `05_neutrophil_states/README.md` (both untouched by Category
  B): no stale "tumour-derived" or unqualified neutrophil-recruitment language present.
- All six figures (`figures/*.png`/`*.svg`) render from already-verified scripts; none were
  regenerated during Category B (a deliberate choice, logged there), and none contains title
  text contradicting the revised framing.
- Full git history (51 commits, `2123a79`..`1f999dc`) is linear, no rewrites; `git status
  --porcelain` empty; `renv::status()` reports no issues.

**Project status: complete and frozen.** All nine planned modules
(`01_background`–`09_synthesis`) are finished, their claims are aligned with their evidence
(Category B), two evidence-grounded post-hoc audits (A1, A2) were incorporated rather than
left as open review comments, and this final audit found the repository internally
consistent apart from the two documentation gaps above, both now fixed. No further module,
analysis, or wording change is anticipated; any future work belongs in a new, separate
project phase, not a continuation of this one.

## 2026-08-02 — Category B: claims-versus-evidence wording alignment pass

**Not a new analysis, no evidence grade changed, no result reinterpreted** — this is a single,
coherent documentation update realigning the project's title, central question, and narrative
with what A1 and A2 (above) established with evidence. Every change below is traceable to A1,
A2, or an already-documented limitation; no analysis was rerun (figures were deliberately left
unregenerated — their titles reflect the modules' original working labels, same treatment as
each module's own unchanged `## Hypothesis` section, see below).

**Title and central question** (root `README.md`): retitled from "Tumour-derived neutrophil
recruitment and signalling programmes in melanoma immune checkpoint response" to "Immune-
compartment secretory and regulatory programmes associated with immune checkpoint response in
melanoma." Central question reworded correspondingly. Justification (both grounded in A1/H0,
not precaution) stated inline: (1) the canonical neutrophil-chemoattractant repertoire is
undetectable in this dataset (A1), so H1's actual finding cannot be called "neutrophil
recruitment"; (2) malignant cells are ~0.04% of GSE120575 (H0), so no finding here is
demonstrated to be tumour/malignant-cell-derived — everything is immune-compartment-derived.
The original title is preserved here and in git history, not erased. A "Framing note" added to
the Hypothesis map states explicitly that each module's own pre-registered `## Hypothesis`
text is left as a historical record, unrewritten — the correction lives in each module's
Interpretation/Limitations (A1/A2) and in this revised framing, not by silently editing what
was originally tested.

**`09_synthesis/README.md`** (the principal narrative document): added a top-of-module revision
note; §2.1 cross-referenced to A1; §2.2 retitled and expanded to state the immune-compartment/
not-neutrophil-specific/not-tumour-derived scope explicitly and to incorporate A2's
confound-adjustment finding; §2.5 rewritten to (a) state the immune-compartment scope
plainly, (b) state explicitly that H1/H2 primary/H4 primary are one cohort analysed through
complementary lenses, not three independent confirmations, and (c) present LTB as the one
comparatively robust hit among H1's four (robust to both H5a's external replication and A2's
confound-adjustment) without overstating this as external validation — CCL3/CCL4/CXCL13
stated as fragile to both checks. §4 (the CXCL8/CXCR1/2 post-hoc question) updated to cite
A1's more direct confirmation that CXCL8 is absent from the raw matrix entirely, not merely
filtered out. §5 (limitations rollup) gained explicit entries for: programme scope, cohort/
confound non-independence, temporal external validity (2014–2017 cohorts vs. current ICB
practice), untested alternative explanations (tumour burden, clinical covariates), and H2's
inherited (not re-verified) cell-type calls. §6 restated the revision plainly.

**Other modules touched (light, targeted, matching their own established Limitations-section
conventions):**
- `01_background/README.md`: §4 gained an addendum stating the recruitment-programme
  expectation was only partly borne out (immune-compartment signal detected; neutrophil-
  specific chemoattractant repertoire undetectable); §5's quoted central question updated to
  match root `README.md`, with the original wording preserved inline as a dated note.
- `07_validation_concordance/README.md`: added a Limitations bullet distinguishing "reversed
  direction, underpowered" from "confidently contradicted" for GSE91061's wide-CI estimates —
  the pre-registered rubric and its verdicts are unchanged, only the surrounding description is
  tightened.
- `04_cellular_sources/README.md`: added a Limitations bullet noting compartment attribution
  relies on the original study's cell-type calls, not independently re-verified.
- `08_experimental_translation/README.md`: added a wording note clarifying "recruitment-
  programme" there is the module's original working label, not a neutrophil-specificity claim;
  the validation proposals themselves are unaffected.
- `results/evidence_ledger.tsv`: H1's `biological_hypothesis` field reworded to remove
  "tumour-derived" and state the immune-compartment/not-neutrophil-specific scope explicitly,
  citing addendum #1. No other ledger field (direction, grade, justification) changed.

**Final consistency check performed before this commit** (per explicit project-owner
instruction): searched the full repository for "tumour-derived" and "neutrophil recruitment"
outside of already-corrected or clearly historical contexts; found and fixed one remaining
inconsistency (`01_background/README.md`'s own quoted central question, §5, had not been
updated to match root `README.md`). `CONTINUATION_BRIEF.md` was deliberately left unedited, as
a dated historical handoff snapshot, consistent with this project's standing rule that
corrections are new entries, never silent retroactive edits to a historical record.

## 2026-08-02 — Post-hoc robustness check: therapy-type confound adjustment on H1 (A2)

**Not a new hypothesis test, no new evidence-ledger row** — same peer-review response as A1
above. The review's second material concern: H1, H2's primary test, and H4's primary test all
run on the identical 19-patient cohort and share the identical, already-disclosed therapy-type
confound, so they should not be read as three independent confirmations of one signal.

**Method** (`03_recruitment/06_h1_therapy_sensitivity.R`): H1's exact, already-committed
327-gene panel and 35-gene detection-filter result were reused unchanged (`stopifnot`-verified
against H1's committed counts before touching anything), and the identical `limma` model was
refit with therapy type added as a covariate. The actual therapy×response contingency table
was printed and inspected before building anything on it (verify, don't assume) — therapy has
**three** levels in this cohort, not two as earlier prose implied: anti-CTLA4 alone (n=2),
anti-CTLA4+PD1 (n=5), anti-PD1 (n=12). All 19 patients had a usable label. No gene was added
to, or removed from, the tested panel; only the model changed.

**Result**: all 4 original H1 hits retain the same direction after adjustment (no sign
reversals). LTB remains significant (FDR 0.0034, effect size −0.62 vs. original −0.72). CCL3,
CCL4, and CXCL13 no longer clear FDR<0.05 (→0.095/0.108/0.109) though their point estimates
are largely preserved (e.g. CCL3: 0.753→0.735) — read as a power loss from the adjustment
(residual df 17→15, spent on a 3-level covariate with one 2-patient level), not a collapsed
effect. The significant-gene set also reshuffles, not just shrinks: TYMP becomes newly
significant (FDR 0.10→0.038) post-adjustment. Full comparison:
`results/h1_therapy_sensitivity_comparison.csv`.

**A limitation of the check itself, disclosed rather than glossed over**: this adjustment
cannot cleanly separate "CCL3/CCL4/CXCL13's original significance was partly confound-
inflated" from "this specific covariate adjustment is underpowered at n=19" — both remain
live, unadjudicated possibilities.

**A convergent pattern across two independent, unrelated checks, stated as a factual
observation**: LTB is robust to both H5a's external-cohort replication and this
therapy-adjustment; CCL3/CCL4/CXCL13 are fragile to both. **Disposition** (project owner's
explicit instruction): H1's Conclusion is tightened to state this asymmetry explicitly rather
than leave it implicit in a single Moderate grade — the letter grade itself is unchanged (this
is a robustness caveat on an already-valid test, not a new finding warranting reassessment).
Cross-referenced (one sentence each, not reopened) in `04_cellular_sources/README.md` and
`06_regulation_communication/README.md`'s Limitations, since both build on the identical
cohort/confound. Will be cited in `09_synthesis` when the Category B wording revision is
implemented.

## 2026-08-02 — Post-hoc audit: canonical neutrophil-chemoattractant detectability (A1)

**Not a new hypothesis test, no new evidence-ledger row** — this documents a data-availability
audit performed in response to an independent peer review of the full project (conducted
deliberately as a role-switch: Claude reviewed the finished repository as a skeptical outside
reviewer rather than its own architect). The review's single highest-priority concern was
construct validity: H1's discovered genes (LTB, CCL3, CCL4, CXCL13) are not canonical
neutrophil chemoattractants, so "neutrophil recruitment" in the project's central question and
title was an asserted label, never an empirically checked one.

**Method** (`03_recruitment/05_neutrophil_specificity_audit.R`): a fixed, pre-defined 8-gene
canonical neutrophil-chemoattractant panel (CXCL1, CXCL2, CXCL3, CXCL5, CXCL6, PPBP/CXCL7,
CXCL8, CSF3 — the ELR⁺-CXC/CXCR1-2 axis plus G-CSF; receptors excluded by the same
GO-ligand-activity-panel logic that already excluded CXCR1/2/Guo 2025's receptor markers
elsewhere in this project) was checked against H1's own already-computed panel-construction and
detection-filter logic, reproduced exactly from `03_h1_discovery_screen.R` and verified via
`stopifnot` to reproduce H1's own committed 327-gene panel and 35-gene detection count before
checking anything new. **No gene was tested against the response labels; no p-value was
computed anywhere in this script** — this is a retrospective inspection of measurement
capacity, in the same category as H0, not a new discovery analysis, and does not violate this
project's discovery discipline (no gene added to or removed from any tested panel).

**Result**: CXCL8 is absent from the GSE120575 matrix entirely. The other 7 canonical
neutrophil chemoattractants are present and are members of H1's 327-gene panel, but all 7 fail
H1's own 20%-detection filter by a wide margin (5 of 7 detected in 0/19 patients; the remaining
2 in 1/19 and 2/19). Zero of the 8 ever entered H1's tested 35-gene table. Full result:
`results/neutrophil_chemoattractant_panel_audit.csv`.

**Interpretation and disposition** (decided explicitly, not defaulted): this is **not** treated
as a new biological finding or given its own evidence-ledger row. It is documented in
`03_recruitment/README.md`'s Interpretation and Limitations sections as methodological support
for correctly scoping H1's own conclusion — H1's programme is real and stands at its existing
Moderate grade, but it is not a neutrophil-recruitment programme specifically, and this dataset
cannot test whether one exists (same protocol-driven constraint as H0, now confirmed at the
transcript level as well as the cell level). This finding will be cited in `09_synthesis` to
justify a Category-B (wording-only) revision to the project's central question and title —
tracked separately as its own logged change once implemented, not folded into this entry.


Project architecture was frozen on 2026-08-01 after three design-refinement passes. From that
point, this file records every deviation from the frozen specification, with the technical or
biological blocker that forced it and the justification for the alternative chosen. Additions
made merely because they were interesting are not permitted (see `README.md`, scope freeze).

## 2026-08-02 — Module 09 (`09_synthesis`) design confirmation and completion

**Not a deviation** — this documents the design-confirmation step for the project's final
module, matching the design-then-confirm pattern already used for H4's communication
component and H5's pre-registration.

**Design proposed, then refined by the project owner before implementation (binding
refinements, all incorporated):**
1. The synthesis narrative presents an evidence-weighted integration of H0-H5 first; the
   lack of external replication (H5a/H5b) is allowed to emerge from the grading in Section 2,
   not asserted as the module's headline framing.
2. Confirmed: no new evidence-ledger row. Module 09 integrates `results/evidence_ledger.tsv`,
   it does not extend it — matching Module 08's own precedent.
3. The CXCL8/CXCR1/CXCR2 check (README Section 4) is kept strictly retrospective: it reports
   only that these three molecules do not appear in H1's ranked screen, H4's TF-activity
   ranking, or H5c's overlap tables, framed explicitly as a post-hoc observation about this
   project's own analyses — not as evidence for or against the axis's biological role in
   melanoma or the clinical trials referenced in `01_background`.
4. Every synthesis statement (README Section 2) is built in the fixed order Observation ->
   Interpretation -> Biological hypothesis -> Clinical implication, so no claim outruns its
   supporting ledger grade.
5. Figure 6 was rebuilt as an evidence-driven systems model (not a conceptual illustration):
   every node/edge is read or re-derived programmatically from already-committed result
   tables (`h1_discovery_screen_ranked.csv`, `h2_compartment_specificity.csv`,
   `h4_tf_module_clustering.rds` re-cut at the same r>0.7 threshold already used in
   `06_regulation_communication/03c_h4_module_clustering.R`, `h5a_gene_replication_combined.csv`,
   `h5b_tf_module_replication_combined.csv`, `h5c_literature_concordance.csv`), with
   `stopifnot()` guards confirming the re-derived module memberships/gene counts match the
   already-documented figures before the script proceeds. Solid edges/borders = generated
   within this project; dashed = literature-derived or externally-unvalidated. Each tested
   node's H5 replication tag is computed from `h5a`/`h5b`'s own `concordant_direction`/
   `significant` columns, never asserted narratively.

**Implementation note.** Figure 6's first rendered draft had a genuine layout bug: fixed
per-tier box heights didn't scale with each node's actual (variable) label line count, so text
overflowed box boundaries and one literature node's computed y-position coincided exactly with
an unrelated module node's position, producing visible text/box overlap. Caught by visual
inspection before this node was shown to the project owner (this project's standing "verify
the rendered image, not just exit code" discipline, see `REPRODUCIBILITY.md`) — fixed by sizing
each box's height to its own label's line count and substantially widening inter-node spacing;
a second visual pass then caught one edge (`CCL3 -> Wang 2025 overlap node`) whose curvature
caused it to clip a neighbouring box's corner, fixed by adjusting that edge's curvature
direction and magnitude. Three total render/inspect cycles before the figure was accepted.

**Result.** `09_synthesis/README.md` (evidence map, evidence-weighted synthesis, Figure 6
description, the CXCL8/CXCR1/2 retrospective check, limitations rollup, conclusion) and Figure
6 are both complete. With this module done, all nine planned modules
(`01_background` through `09_synthesis`) are finished. No new evidence-ledger row was added,
per the design confirmation above. Remaining: a final whole-project consistency audit
(`CONTINUATION_BRIEF.md` SS8, Step 3).

## 2026-08-01 — Architecture frozen

- Central question finalised with no pathway named (revision 3).
- Repository structure locked: 9 hypothesis modules, Hypothesis→Analysis→Evidence→
  Interpretation→Limitations→Conclusion in every module README.
- Negative Results Policy adopted.
- Reproducibility checklist (`REPRODUCIBILITY.md`) required at repo root.
- Explicitly out of scope: RNA velocity, trajectory/pseudotime inference, additional ML/deep
  learning models, spatial transcriptomics, additional datasets beyond those specified in the
  dataset audit, CNV inference, survival ML.

## 2026-08-01 — Tooling fixes (not scientific deviations)

- `.Rprofile` initially sourced `renv/activate.R` before `renv::init()` had created it, causing
  every `Rscript` invocation (including `renv::init()` itself) to fail. Fixed by letting
  `renv::init()` append its own activation line after `options()` is set.
- Root documentation written via a Windows-side tool over `\\wsl.localhost\...` was not
  reliably visible to native WSL processes (git repeatedly reported no changes despite
  confirmed on-disk content). Resolved by writing through the Windows scratchpad and copying
  into the WSL filesystem with `cp` run inside the WSL session.
- Core package install surfaced five `error code 22` download failures against Bioconductor
  repository URLs, before `BiocManager` (itself one of the packages being installed) existed to
  resolve the `BioC_mirror` option. Investigated against `renv`'s documented Bioconductor
  resolution mechanism and confirmed via `renv.lock` that this is a harmless, self-resolving
  bootstrap-ordering warning. Documented in `REPRODUCIBILITY.md` rather than "fixed" — no
  working configuration was broken.
- `options(timeout = 600)` added to `.Rprofile`; the 60s default caused a genuine mid-transfer
  failure on GSE120575's 121 MB TPM matrix.
- Two distinct large-file reader limitations hit and documented in `REPRODUCIBILITY.md`:
  GSE120575's 4.5 GB decompressed matrix exceeds R's ~2.1 GB single-string limit (breaks
  `fread` and base `gzfile`; fixed with `readr::read_tsv`), and GSE72056 exceeds `vroom`'s
  default 128 KB line buffer (fixed with `VROOM_CONNECTION_SIZE`). Different files, different
  failure modes — not to be conflated.

## 2026-08-01 — Scope reduction: GSE115978 removed

**Deviation.** The frozen dataset list included GSE115978 (Jerby-Arnon et al.) as a "secondary
scRNA-seq" dataset. It has been removed from scope entirely.

**Justification.** GSE115978 was never assigned a role in the locked Analysis order or in any
of the nine hypothesis modules — it survived from an earlier design pass without a defined
purpose. The only role it could have served was H0 replication, which GSE72056 already
provides. Under this project's own evidence rubric, replicating a finding across a third
independent dataset after a second does not move the grade past "Strong," so processing it
would consume download/parse time against a one-week budget for zero marginal rigour. Rule
applied at the project owner's direction: pursue additional datasets only where they
demonstrably strengthen the project, never for completeness.

## 2026-08-01 — H3 (`05_neutrophil_states`) omitted

**Deviation.** The frozen specification designates H3 as conditional on the H0 dataset audit.
That condition has now resolved against it: H3 is omitted, and Figure 4 (its assigned figure)
is not produced. Remaining figures are renumbered so the sequence has no gap (H4→Figure 4,
H5→Figure 5, synthesis→Figure 6; six figures total rather than seven).

**Justification.** This is the frozen failure-tolerant decision tree operating exactly as
designed, not an unplanned change. H0 established fewer than 20 defensibly-recoverable
neutrophils in both tested datasets (1 in GSE120575; 3–4 in GSE72056), placing the project on
the pre-specified `<20` branch. Reference-guided mapping of single-digit cell counts onto a
ten-state published taxonomy would produce a result with no interpretable meaning. Per the
Negative Results Policy, the omission is documented as a substantive protocol-driven finding in
`02_dataset_audit/README.md`, not quietly dropped. Analytical weight shifts to H1, H2, H4 and
H5, none of which require a recovered neutrophil.

## 2026-08-01 — Clarification: six-heading template scope

**Deviation.** The frozen specification states that every module README follows
Hypothesis→Analysis→Evidence→Interpretation→Limitations→Conclusion "no exceptions." That rule
is applied to the hypothesis-testing modules (`02`–`07`) only.

**Justification.** `01_background` states background rather than testing a hypothesis;
`08_experimental_translation` proposes validation for findings established elsewhere; and
`09_synthesis` integrates across modules. Forcing "Hypothesis / Evidence" headings onto these
three would produce empty ceremony that obscures rather than clarifies. The original rule was
written with the hypothesis modules in mind and was over-broad. Each of the three affected
modules carries a note stating which structure it uses and why.

## 2026-08-01 — Correction to H0 evidence following audit

**What was wrong.** The first version of `02_dataset_audit/README.md` and the corresponding
`results/evidence_ledger.tsv` entry stated that, of the 25 GSE72056 marker-co-occurrence
candidates, "zero fell into the non-malignant, unclassified category." This was factually
incorrect. The correct count is **4** (3 after resolving an apparent duplicate: two candidates
share patient, plate well and sequencing index `H12S480`). The error arose from conflating
`celltype == 0` with "malignant" — only 5 of the 11 `celltype == 0` candidates were in fact
malignant.

**How it was found.** A scheduled consistency audit before starting Phase 3, which re-read the
printed cross-tabulation rather than relying on the earlier summary. The corrected counts were
then re-derived independently from the cached data
(`02_dataset_audit/07_verify_gse72056_candidates.R`) rather than accepted on a second reading.

**What changed as a result.** The interpretation moves from "the signal is entirely noise" to
"a negligible number of plausible neutrophils survive" — a materially different and more honest
biological claim, since the 3–4 unassigned non-malignant candidates are genuinely consistent
with neutrophil identity given the original panel contains no neutrophil category. H0's
conclusion, its Strong grade, and the decision-tree branch are all **unchanged**: 3–4 cells
remains far below the pre-specified `<20` threshold.

**Also corrected in the same pass.** The Strong grade justification now states explicitly that
two of the rubric's four criteria (patient-level statistics, multiple-testing correction) were
written for differential-expression claims and do not apply to an existence/absence claim,
rather than implying all four were satisfied.

## 2026-08-02 — Script consolidation (not a scientific deviation)

**Deviation.** `02_dataset_audit` accumulated seven scripts during development (three
debugging iterations of the same download/parse/test logic, arising from the fread-limit,
vroom-buffer, and metadata-structure problems documented above). Consolidated to three:
`01_download_data.R`, `02_h0_gse120575.R`, `03_h0_gse72056.R`, plus shared marker-detection
logic factored into `R/neutrophil_markers.R`.

**Justification.** Flagged in the pre-Phase-3 audit as a quality issue: the frozen spec caps
this module at ~10–20% of the repository, and a reader should see three scripts that tell one
clear story, not the sequence of failed attempts that produced them.

**Verification.** The consolidated scripts were run in full before the originals were removed.
Every number matched exactly: GSE120575 observed co-occurrence 1 (expected 0.14 under
independence, computed exactly by subset enumeration rather than the original's approximate
arithmetic); GSE72056 25 candidates, cross-tab identical, 4 non-malignant-unassigned, 1
duplicate, 3 distinct, 2 patients, 2 unresolved-unassigned — matching the corrected values
above exactly. No science changed; only the code that produces it.

## 2026-08-02 — GSE120575 cache regenerated: cell columns were mistyped as character

**Deviation.** `data/processed/GSE120575/tpm.rds`, produced by `02_h0_gse120575.R`, was
regenerated with an explicit `col_types` specification and the script was modified to assert
column numericness going forward.

**What was wrong.** `readr::read_tsv()`'s default type-guessing samples only the first ~1000
rows; this file has 55,738 gene rows, so the sample was unrepresentative and readr silently
typed cell columns as `character` rather than `double`. Discovered while building
`03_recruitment/01_compartment_audit.R`: a module-score computation using bulk `mean()` across
several genes returned 100% `NA` with warnings ("argument is not numeric or logical"), traced
via a minimal standalone reproduction (`03_recruitment/00_diagnose_subset.R`) to the underlying
column type, not a logic error in the new script.

**Why H0 was unaffected.** Every H0 script wrapped value access in `as.numeric()` at the point
of use, which silently and correctly converts `"9.13"` to `9.13` — so all of H0's arithmetic
was always on the right numbers. The cache itself was still wrong, and any future bulk numeric
operation (exactly what pseudobulk construction in H1 requires) would have silently misbehaved
rather than erroring clearly.

**Verification.** Cache regenerated with `col_types = cols(<first col> = col_character(),
.default = col_double())`, plus a `stopifnot()` asserting every cell column is numeric before
the script proceeds. `02_h0_gse120575.R` was rerun in full and reproduced H0's original results
exactly: observed co-occurrence 1, expected 0.14, identical per-marker positivity table,
identical co-occurrence distribution. H0's committed conclusions, grade, and decision-tree
branch are unaffected — this was a representation defect, not a data or results error. Parse
time also dropped from ~36 min to ~8.8 min, since explicit typing skips readr's guessing pass.

**Not fixed:** GSE72056's cache almost certainly has the same underlying issue (same
`read_tsv()` call pattern, 23,686 gene rows, no explicit `col_types`), but it is scoped to the
already-complete H0 replication only and not touched by any further module, so regenerating it
was not worth the cost. Documented in `REPRODUCIBILITY.md` rather than silently left unstated.

## 2026-08-02 — H4 tooling: CollecTRI resolved via OmniPath REST API, not Zenodo

**Deviation.** `decoupleR::get_collectri()` was unusable (see the tool-installation entry
below) and the initially-attempted Zenodo static-file fallback
(`data/raw/collectri_human_prior_tri.csv`, record 8222799, `human_prior_tri.csv`) was
discovered to be mouse-orthology-cased (`Myc`, `Spi1`, `Smad3`, `Tert`, `Bglap`...), not human,
despite its filename claiming otherwise. The network actually used for H4 was instead
downloaded directly from OmniPath's own REST API
(`https://omnipathdb.org/interactions?resources=CollecTRI&genesymbols=1&format=tsv`), which
bypasses `OmnipathR`'s broken Ensembl-dependent organism resolution entirely and returns
native, genuinely human-cased data.

**What was wrong (Zenodo).** `data/raw/collectri_human_prior_tri.csv` downloaded successfully
and had the expected `source`/`target`/`mor` shape, but its gene symbols were Title Case
(mouse/MGI convention), not the all-uppercase convention every gene in this project's own
expression matrices uses (e.g. `LTB`, `CXCL13`). Used as-is, this network would have silently
matched almost nothing against the matrix — a near-total, non-obvious failure with no error
message, not a crash. Confirmed by directly comparing specific edges (`Myc->Tert` in the
Zenodo file) against OmniPath's REST API output for the same edge (`MYC->TERT`, correctly
cased) — same biological edge, different casing, proving the Zenodo file's casing (not the
underlying biology) was the problem.

**Fix.** `06_regulation_communication/01_collectri_resolved.R` queries
`https://omnipathdb.org/interactions?resources=CollecTRI&genesymbols=1&format=tsv` directly
via `download.file()` — no R package call to `OmnipathR`/`decoupleR` is involved in this step,
so the broken Ensembl species-lookup is never invoked. An earlier draft of this script
additionally requested `&fields=extra_attrs,consensus_stimulation,consensus_inhibition,
consensus_direction`; OmniPath's API rejected this (`consensus_inhibition` is not a valid
`fields` value there) — the default response already includes
`consensus_stimulation`/`consensus_inhibition` without needing to request them, so the
`&fields=...` clause was removed entirely rather than corrected.

**Two further issues caught during verification, not assumed away:**
1. `read.delim()`'s default type-guessing left `consensus_stimulation`/`consensus_inhibition`
   as character `"True"`/`"False"` strings rather than logical (only the exact strings
   `"TRUE"`/`"FALSE"` are auto-detected), which crashed the `|` filter with "operations are
   possible only for numeric, logical or complex types." Fixed with an explicit
   `as.logical()` coercion, guarded by a `stopifnot(!anyNA(...))` so a future format change
   would halt loudly rather than silently drop rows to `NA`.
2. The script's own casing-verification step reported `All source/target symbols uppercase:
   FALSE` even after switching to the REST API — investigated rather than dismissed as noise.
   208 of 61,220 target symbols (never source/TF symbols) were genuinely non-uppercase:
   207 matched two known-legitimate human-nomenclature conventions (HGNC's `orf` genes, e.g.
   `C9orf72` — lowercase `orf` is the *correct* official casing, not an error; and miRBase's
   `hsa-miR-*` microRNA identifiers, a separate naming system from HGNC gene symbols). The
   208th, target `"Mgu"` on the `PPARA` edge, did not match either pattern; querying its
   underlying UniProt accession (`P10746`) directly confirmed it is **UROS**
   (uroporphyrinogen-III synthase) — `"Mgu"` is not a valid symbol for it under any
   nomenclature, an isolated upstream data artefact in OmniPath's `CollecTRI` export. Rather
   than guess a correction (e.g. assuming it should read `UROS`) or silently keep a
   known-wrong symbol, that single edge is dropped and reported by the script
   (`stopifnot(sum(anomalous) <= 5)` guards against this masking a larger systemic problem in
   a future re-download).

**Verification.** Final network: 61,219 edges, 1,192 unique TFs (all uppercase, verified),
saved to `data/processed/collectri_human_verified.rds`. The superseded mouse-cased Zenodo file
is removed by the script itself; `data/raw/` is gitignored regardless. Ready for `decoupleR`
TF-activity analysis (§8 Step 4 of `CONTINUATION_BRIEF.md`).

## 2026-08-01/02 — H4 tool installation: `decoupleR::get_collectri()` blocked by an external Ensembl outage

**Deviation.** `decoupleR::get_collectri()`, the documented way to obtain the CollecTRI
TF-target regulon, cannot be used. `OmnipathR` resolves the organism argument by scraping
`https://www.ensembl.org/info/about/species.html`, which now returns 404/403 — a known,
currently-unresolved upstream issue (`github.com/saezlab/decoupleR` issues #153, #162;
`github.com/saezlab/OmnipathR` issue #117; `github.com/saezlab/CollecTRI` issue #19),
confirmed via those issue trackers rather than assumed from the error message alone.

**Plan A tried and failed.** Passing `organism = 9606` (the NCBI taxonomy ID for human)
instead of the string `"human"` is a documented alternative input type, and was tried on the
theory it might skip the broken name-resolution path. It still routes through the same
internal static-table fallback and fails with `"argument is of length zero"` inside
`unnest_evidences()`. Do not retry this — confirmed not to work
(`06_regulation_communication/00_tool_smoke_test.R`).

**Resolution.** See the entry directly above — CollecTRI obtained via OmniPath's REST API,
completely independent of `OmnipathR`/`decoupleR`'s broken Ensembl-dependent path.
`decoupleR` itself is still used downstream for the TF-activity scoring functions, which
don't depend on the broken organism-resolution code path — only `get_collectri()`'s
convenience wrapper does.

**Not affected:** `liana`'s tool check (`show_resources()`, `select_resource("Consensus")`)
succeeded independently and cleanly on first try — this bug is specific to
`OmnipathR`'s organism-name resolution and does not touch `liana`'s ligand-receptor resource
loading.

## 2026-08-02 — Correction to CollecTRI network: replicate decoupleR's own complex/dedup logic

**What was wrong.** The CollecTRI resolution documented immediately above (OmniPath REST API
fetch) stated a final network of **61,219 edges, 1,192 unique TFs**. That number was produced
by a first-draft script that deduplicated on the full `(source, target, mor)` triple and kept
raw complex-partner strings (e.g. `"JUNB_JUND"`) as TF names. It was not yet used in any real
analysis when the error below was found, so no downstream result is affected.

**How it was found.** Building the H4 data structures (`CONTINUATION_BRIEF.md` §8, Step 3) and
running `decoupleR::run_ulm()` on real pseudobulk data — the first genuine use of this network
— failed immediately: `"Network contains repeated edges, please remove them."` Investigated
rather than patched blindly: 126 `(source, target)` pairs had rows with genuinely conflicting
`mor` (e.g. `JUN->ABCB1` reported as both `+1` and `-1`), confirmed real (not a parsing
artefact) by checking every duplicated pair's `mor` values directly. Rather than invent a
resolution rule, `decoupleR::get_collectri()`'s own source code was read
(`deparse(decoupleR::get_collectri)`) to find the published, reference way this exact network
is meant to be built.

**What was actually wrong with the first draft.** Two things it skipped that `get_collectri()`
does: (1) complex-derived sources (raw `source` column containing `"COMPLEX"`) are collapsed
to two composite TF labels, `AP1` (JUN/FOS-containing complexes) and `NFKB`
(REL/NFKB-containing complexes) — not kept as literal partner strings; complexes matching
neither pattern have no defined replacement in `get_collectri()`'s own logic and are dropped
here (a disclosed, deliberate difference from `get_collectri()`, which does not filter the
resulting NA rows — but a NA-labelled "TF" cannot be a meaningful `run_ulm()` output). (2)
Deduplication is on `(source, target)` alone, keeping the first occurrence
(`dplyr::distinct(.keep_all = TRUE)`-equivalent), not on the full triple — the two conventions
differ exactly when `mor` conflicts, which is real, documented TF biology (pleiotropic TFs
like JUN/NFKB1/RELA are genuinely reported as both activating and repressing the same target
across different curated source studies), not a data error.

**Fix.** `06_regulation_communication/01_collectri_resolved.R` rewritten to replicate
`get_collectri(organism = "human", split_complexes = FALSE)`'s canonical post-processing on
data fetched via the OmniPath REST API workaround, rather than inventing independent logic —
same underlying data source, same published resolution method, different (working) fetch
path only.

**Corrected final network:** 42,698 edges, 1,178 unique TFs (22,890 complex rows collapsed
entirely to `AP1`/`NFKB`, 0 complexes dropped for matching neither pattern — every complex in
this data contains JUN/FOS or REL/NFKB). One isolated anomalous target symbol (`"Mgu"`,
confirmed via UniProt to be a mismapped `PPARA` edge, see the entry above) dropped as before.
`decoupleR::run_ulm()` now runs cleanly with zero repeated-edge errors — verified directly, not
assumed, via an explicit `stopifnot(!anyDuplicated(net[, c("source","target")]))` guard added
to the script itself.

## 2026-08-02 — H4 data structures confirmed (Step 3 of CONTINUATION_BRIEF.md §8)

**Not a deviation — a design question resolved by direct testing rather than assumption**, per
`CONTINUATION_BRIEF.md` §8 Step 3's own instruction.

- **decoupleR TF-activity input.** H1's and H2's already-saved pseudobulk objects are **not**
  reusable for H4: both are restricted to narrow gene panels (H1: 327 msigdbr
  cytokine/chemokine/growth-factor genes; H2: H1's 35 tested hits only), and CollecTRI's
  regulons need broad target-gene coverage to score meaningfully (6,424 of 6,661 unique
  CollecTRI targets are present in the full transcriptome, vs. a small fraction of that in
  either narrow panel). A fresh whole-transcriptome patient-level pseudobulk is required
  instead — built with the same aggregation logic as H1 (mean TPM per patient, pre-treatment/
  response-labeled cells only) but over all genes. Confirmed working directly:
  `decoupleR::run_ulm()` ran cleanly on this pseudobulk (19 patients), scoring 754 unique TFs.
- **A single row of `data/processed/GSE120575/tpm.rds` (of 55,738) has a literal `NA` gene
  symbol** — confirmed isolated (0 duplicated gene symbols elsewhere, exactly 1 NA, 0 empty
  strings). Never surfaced in H0-H2 because every prior script filtered to specific named
  genes before any bulk numeric operation; only building a whole-transcriptome pseudobulk for
  H4 exposed it. Dropped (documented, isolated single row, matching the same discipline as
  the CollecTRI "Mgu" anomaly above), not guessed at.
- **liana L-R input.** Confirmed by reading `liana:::liana_prep.SingleCellExperiment`'s source
  directly, not assumed from documentation: `liana_wrap()` requires a `SingleCellExperiment`
  or `Seurat` object (no lighter matrix+labels input exists); `idents_col` takes a `colData`
  **column name string** directly (simpler than expected); the SCE must carry **both**
  `counts` and `logcounts` assays or `liana_prep()` stops immediately. This dataset has no raw
  counts (TPM-only, GEO-deposited — the same reason H1/H2 use `limma`, not `edgeR`/`voom`), so
  `counts` is populated with raw TPM as the closest available substitute — a real, documented
  limitation, flagged for review before Step 5's real analysis, not silently worked around. A
  `SingleCellExperiment` was built from the existing single-cell-resolution `tpm.rds` plus
  H2's compartment labels (`gse120575_compartment_calls.csv`), restricted to the same
  compartments H2 used (T_cell/B_cell/Myeloid/NK; Mast/Malignant/Unassigned excluded for
  unusable cell counts, matching H2's own precedent). Confirmed working directly on a small,
  seeded subsample (`liana_wrap(method = "natmi")` returned 3,240 real ligand-receptor
  results) — building the full 5,892-cell SCE with both required assays was OOM-killed on
  this machine's documented 10 GB WSL2 budget, so the format check uses a subsample; Step 5's
  real analysis needs its own memory strategy for the full dataset (one compartment/response
  group at a time, or a sparse matrix), left as a genuine open design question for that step.

**Files.** `06_regulation_communication/02_h4_sanity_check.R`. No results/figures — this is a
compatibility check only, no scientific claim is made here.

## 2026-08-02 — Pre-registration: H4 secondary compartment-level TF-activity analysis

**This entry is written before any H4 result exists** (Step 4's primary analysis has not yet
been run), specifically to make that timing auditable — the same discipline this project
already applies to CXCL8/CXCR1/2 (see `01_background`/`README.md`) and to H1's/H2's externally-
sourced discovery panels: a scope decision that could shape or be shaped by results is
recorded before the results exist, not after.

**Decision.** A compartment-level follow-up to H4's primary (patient-level) TF-activity
analysis is approved **in principle**, but only as a pre-specified **secondary/exploratory**
analysis, under all of the following binding conditions:

1. The patient-level TF-activity analysis (Step 4) must be complete and its ranked results
   committed to git **before** any compartment-level script is written or run.
2. Only TFs meeting Step 4's pre-defined significance threshold (FDR < 0.05, with FDR < 0.10
   TFs reported as a secondary tier — exactly matching H1's own convention) are eligible for
   compartment-level testing. **No additional discovery search is permitted** — the
   compartment-level analysis may not introduce, substitute, or expand the TF panel beyond
   Step 4's own locked hit list.
3. The compartment-level analysis is labelled **Exploratory/Secondary** everywhere it appears
   — evidence ledger, module README, figure, and interpretation — with its own ledger row(s),
   never merged into or averaged with the primary result's grade.
4. Its purpose is narrowly scoped: does the primary signal trace to a specific cellular
   compartment, and does it reinforce or contradict H2's already-established "regulation ≠
   abundance" pattern (LTB: B-cell-dominant expression, T-cell-significant response signal).
   It must not alter the central question, H4's primary conclusion, or any other module's
   conclusions.
5. If the primary Step 4 analysis yields very few or zero TFs at FDR < 0.05, **this secondary
   analysis is skipped entirely** — thresholds are not relaxed to manufacture eligible TFs.
6. If run, weak, inconsistent, or underpowered secondary results are reported honestly (per
   the Negative Results Policy) and remain supplementary — later modules (H5, `08`, `09`) are
   never redesigned around a secondary/exploratory finding.

**Justification.** Evaluated against a stricter benefit/cost framework at the project owner's
request (does it strengthen the central question rather than pad the repository; does it
increase novelty/translational value; would a PhD-selection reviewer reasonably expect it
after H2; does expected gain justify the added multiple-testing/interpretation burden; can it
be scoped as a small supplementary check rather than a new module). Conclusion: justified only
as a small, tightly-bounded, pattern-consistent follow-up mirroring H2's own primary/secondary
structure (H2 restricted its secondary test to H1's FDR<0.10 hit genes; this restricts its
secondary test to H4's own FDR<0.05 hit TFs, same logic, same discipline) — not as a
freestanding module. Rejected in its original, broader form (a full compartment x all-scored-
TFs sweep run alongside the primary analysis), which would have reopened a question H2 already
answered for raw expression without a comparably tight scope or trigger condition.

**Status.** Approval is conditional, not a commitment to run — whether this analysis actually
proceeds is decided after Step 4's primary result is locked, against condition 5 above.

## 2026-08-02 — H4 communication-network component complete: design decisions and a negative finding

**Deviation.** `liana::liana_wrap()`'s default 5-method usage (`natmi`, `connectome`, `logfc`,
`sca`, `cellphonedb`) was reduced to a 4-method consensus, excluding `cellphonedb`.

**Justification.** Measured, not guessed: `cellphonedb` (permutation-based) took 178 sec for a
200-cell test, extrapolating to ~87 min for one full-scale (5,892-cell) run — roughly 3 hours
across both response-split networks — with real memory risk on top (a `natmi`-only run
already touched 9.6 GB of this machine's 10 GB WSL2 budget under poor object hygiene in the
feasibility script, `06_h4_lr_feasibility.R`). The three remaining default methods
(`connectome`, `logfc`, `sca`) were individually timed and confirmed fast (9–16 sec on the
same 200-cell test, `06b_method_timing.R`) before being included. The full-scale gene-scope
restriction (LIANA Consensus's own 1,839-gene L-R universe, versus the full 55,737-gene
matrix) was verified, not assumed, to produce bit-identical `natmi` output (max absolute
difference = 0) before being relied upon.

**Also caught, not guessed at**: the LIANA Consensus resource's actual gene-symbol columns
are `source_genesymbol`/`target_genesymbol` (same convention as the CollecTRI raw
interactions table), not `ligand`/`receptor` as first assumed — the wrong guess failed loudly
(empty column selection) rather than silently, on the first run, before any downstream
computation used it.

**Result.** The pre-specified Fisher's exact enrichment test (T-cell-directed edges x
GO-annotated suppressive receptor, all scored edges, two response-split networks) is **not
significant in either network** (Responder OR=1.11, P=0.40; Non-responder OR=1.14, P=0.25) —
a negative finding, reported per the Negative Results Policy, and the formal basis of this
component's Exploratory grade in `results/evidence_ledger.tsv` (row `H4-communication`).

**Discovery-discipline note.** A checkpoint-pair pattern (CD86→CTLA4, multiple HLA-D*→LAG3,
LGALS9→HAVCR2, concentrated in the Non-responder network's significant-edge subset) was
noticed while inspecting the negative test's output. No follow-up statistical test was run on
this subset — doing so after seeing the pattern would be exactly the kind of result-contingent
test-shopping this project's discovery discipline exists to prevent (the same reasoning that
keeps CXCL8/CXCR1/2 out of discovery before `09_synthesis`). It is recorded as a **Descriptive
observation** / **Hypothesis for later synthesis** only, explicitly separated from the formal
Negative finding in the module README, evidence ledger, and Figure 4's caption — terminology
(Finding / Negative finding / Descriptive observation / Hypothesis for later synthesis) fixed
by explicit project-owner instruction and applied consistently.

**Figure 4 restructured**, not replaced: Panel A (unchanged, TF-activity) plus a new Panel B
(communication network) — D is the formal statistical result, E is the descriptive
observation, visually and textually distinguished (E uses a muted background and explicit
"DESCRIPTIVE OBSERVATION" labelling, not a node-edge network diagram, to avoid overstating an
untested pattern). Two real rendering bugs caught before sending to the project owner, not
assumed fine because "no error": Panel E's title overflowed past its half-width panel into
Panel D's space, and the overall caption was clipped at the figure's bottom edge — both fixed
with explicit `strwrap()`-based text wrapping (ggplot does not auto-wrap `plot.title`/
`plot.caption`/`plot.subtitle`), matching the exact failure mode already documented for
Figure 1.

**Files.** `06_regulation_communication/06_h4_lr_feasibility.R`, `06b_method_timing.R`,
`07_h4_lr_communication.R`, `07b_h4_lr_suppression_enrichment.R`;
`results/h4_lr_{responder,nonresponder}_aggregated.{csv,rds}`,
`results/h4_lr_suppression_enrichment.rds`; `06_regulation_communication/README.md` and
`figures/figure4_h4_tf_activity.{png,svg}` updated.

## 2026-08-02 — H4 formally frozen

**Decision.** H4 (`06_regulation_communication`) is closed. No further analysis, figures, or
evidence-ledger entries will be added to it. Reviewed against the standard "would this
weaken the manuscript/portfolio if left as-is" test before freezing, not assumed complete by
default:

- No essential analysis is missing — H0-H4 are each honestly scoped, with limitations already
  disclosed in their own READMEs rather than deferred silently.
- Two real, carried-forward methodological considerations for H5 (not H4 defects, but
  context H5's design must account for): (1) the therapy-type confound documented in H1/H2/H4
  is specific to GSE120575's therapy mix and will not match either H5 validation cohort's own
  (different) therapy composition — a genuine interpretive caveat for H5, not something to
  retrofit into H4; (2) H2's compartment attribution and H4's communication-network component
  both require single-cell resolution and are therefore **out of scope for H5 entirely** —
  bulk validation cohorts cannot test them, and H5 will not attempt to.

Any future observation relevant to H4 (from H5 or `09_synthesis`) is recorded in that module,
cross-referencing H4, not by reopening it.

## 2026-08-02 — H5 pre-registration (CONTINUATION_BRIEF.md §8, Step 9)

**Written after the dataset audit but before any hypothesis test is run**, per the project
owner's explicit sequencing: (1) dataset audit complete (below), (2) statistical methods
finalized against the verified data format (below), (3) this entry, (4) implementation next,
not before.

### Scope (fixed, not to expand)

H5 validates **H1's gene-level findings and H4's two named TF-activity modules only**. It
does **not** attempt to validate H2 (compartment attribution) or H4's communication
component — both require single-cell resolution unavailable in bulk cohorts; this is a hard
scope boundary, not an oversight. No additional exploratory analyses beyond the one
pre-declared exploratory component (H5c) are permitted unless a genuine methodological
blocker is encountered — scope is not to expand simply because it is possible.

### Dataset audit (complete, `07_validation_concordance/01_download_data.R`,
`02_h5_dataset_audit.R`, `03_h5_join_key_and_mapping_check.R`)

**GSE78220** (Hugo et al. 2016, *Cell*) — 28 samples total, FPKM only (no raw counts), gene
symbols already HGNC-style (no ID mapping needed). One sample (Pt16, on-treatment,
Progressive Disease) excluded — the series is not entirely pre-treatment despite its title,
confirmed rather than assumed. Join key: phenotype `title` (e.g. `Pt16`) does not match the
FPKM matrix's column names (`Pt16.baseline`) directly — verified, constructed via patient-ID
substring match. Response binarization (matching the original paper's own convention):
Responder = Complete Response + Partial Response; Non-responder = Progressive Disease.
**Final N: 27 pre-treatment (15 Responder / 12 Non-responder).**

**GSE91061** (Riaz et al. 2017, *Cell*) — 109 samples (65 patients, pre+on-treatment), true
raw integer counts available alongside FPKM and rlog matrices (verified: spot-checked
integer values). Gene IDs are Entrez, not symbols (verified: numeric IDs 1/10/100/1000/10000
map via `org.Hs.eg.db`, confirmed installed, to A1BG/NAT2/ADA/CDH2/AKT3 — correct, spot
checked). Join key: phenotype `title` matches expression-matrix column names exactly
(109/109) — patient ID extracted via regex (substring before first `_`), verified unique (no
duplicate patients) after restricting to pre-treatment. Response binarization (matching the
original paper's own convention): Responder = PRCR; Non-responder = PD + SD; Excluded = UNK.
**Final N: 49 pre-treatment usable (10 Responder / 39 Non-responder), 2 UNK excluded.** The
small Responder group (n=10) is a real, pre-declared power constraint, stated now before any
test is run — not discovered after and not a reason to relax thresholds (same handling as
H2's Myeloid power constraint).

### Statistical methods (finalized against the verified data above, not assumed beforehand)

- **GSE78220**: `limma::lmFit`/`eBayes` on `log2(FPKM+1)` — forced by data type (FPKM only,
  no raw counts), same justification already used for GSE120575 in H1.
- **GSE91061**: `edgeR`/`voom` on raw counts — the statistically correct tool given true
  count data is available here, rather than forcing `limma`-on-FPKM for superficial
  cross-cohort uniformity. This is the same principle that justified `limma` for GSE120575
  (the method follows the data's actual type, per cohort), applied honestly in the direction
  the data now points.
- **Direction convention**: matches H1 exactly — positive logFC = higher in non-responder.

### Standing rule (binding, added at the project owner's explicit instruction)

**A replication verdict requires BOTH concordant effect direction AND statistical
significance at the pre-defined threshold below — neither alone establishes replication.**
Fixed before any result is seen. A significant result in the wrong direction is not a
replication. A same-direction trend without significance is not a replication (it may be
reported as an inconclusive/non-replicating trend, not elevated further).

### H5a (confirmatory) — gene-level replication

**Hypothesis.** H1's FDR<0.05 hits (LTB, CCL3, CCL4, CXCL13) show response-associated
differential expression, same direction as H1, in GSE78220 and GSE91061.
**Test.** Per-cohort differential expression per gene (method above), patient-level units.
**Grades** (direction + significance jointly required for any positive tier):
- **Strong**: concordant direction AND significant (FDR<0.05) in **both** cohorts.
- **Moderate**: concordant direction in both cohorts AND significant in at least one.
- **Exploratory**: concordant direction in both cohorts, significant in neither (trend only).
- **Negative finding**: opposite direction in either cohort, regardless of significance.

### H5b (confirmatory) — TF-module replication

**Hypothesis.** H4's two major named modules (Module 1, metabolic/nuclear-receptor; Module 2,
E2F proliferation) show consistent response-association direction in both bulk cohorts.
**Test.** `decoupleR::run_ulm()` on each cohort's own bulk expression (already
sample-level, no pseudobulk aggregation needed), against the verified CollecTRI network,
module-level score only (mean/representative activity of each module's member TFs) — **not**
a 56-TF re-screen, which would be a new discovery search in validation data and is explicitly
excluded. Same grading tiers as H5a, same direction+significance joint rule.

### H5c (exploratory, capped a priori) — published TAN literature concordance

**Hypothesis.** H1's screened panel/hits show quantifiable overlap with published TAN marker
sets (Wu 2024, Guo 2025, Wang 2025).
**Test.** Hypergeometric/Jaccard overlap, externally-sourced marker lists.
**Grade ceiling: Exploratory, fixed a priori** — a set-overlap comparison is not a
response-outcome test and can never satisfy the Strong/Moderate tiers' patient-level-
statistics criterion, the same rubric caveat already applied to H0's existence claim.

### Confirmatory vs. exploratory (explicit, per the project owner's instruction)

H5a and H5b are **confirmatory**: pre-specified genes/modules, pre-specified tests,
pre-specified grading, no new discovery. H5c is the **only** exploratory component, capped at
Exploratory regardless of its numeric result, and does not feed back into H5a/H5b's grades.
No further exploratory analyses are permitted unless a genuine methodological blocker forces
one — and any such blocker will be logged here, with the blocker and justification, before
being acted on, matching this project's change-control discipline throughout.

## 2026-08-02 — H5c: literature identification and verified-depth marker sets

**Not a deviation** — this documents the literature-verification work behind H5c's marker
sets, per the pre-registration's requirement that the test use externally-sourced marker
lists, not hand-picked genes.

**Papers identified.** The pre-registration's "Wu 2024 / Guo 2025 / Wang 2025" citations were
resolved to specific, real papers via literature search (PubMed, Semantic Scholar), not
assumed from memory: Wu et al. 2024, *Cell* (PMID 38447573, 316 citations) — the pan-cancer
neutrophil antigen-presenting-state paper matching the brief's description exactly; Guo et
al. 2025, *Funct Integr Genomics* (PMID 41068349); Wang et al. 2025, *Comput Struct
Biotechnol J* (PMID 41245889, PMC12613047).

**Access verified, not assumed, per paper — asymmetric depth disclosed rather than hidden.**
Only Wang 2025 has open full text (PMC). Guo 2025 and Wu 2024 are paywalled — confirmed
directly (Wu 2024's DOI returned HTTP 403 on direct fetch), not inferred from journal
reputation. Marker genes were extracted only from what each paper's accessible text actually
names:
- Wang 2025 (full text): 13 genes, covering both of the paper's tumor-enriched terminal
  neutrophil states (Neu_c7, Neu_c10) — `CD83, HLA-DRA, CD274, RFX5, CCL3, VEGFA, MAP1LC3B,
  BHLHE40, LDHA, HES4, MAFG, PPARG, CXCR4`. Two additional reported genes (CXCR2, SELL) were
  deliberately excluded — the paper reports them as *down*-regulated in these states, and a
  "TAN marker set" should mean genes the state gains, not loses.
- Guo 2025 (abstract only): 4 genes — `CXCR2, VNN2, BACH1, ATF2`.
- Wu 2024: **zero genes accessible.** Checked three independent ways before concluding this,
  not assumed from the paywall alone: (1) direct fetch of the DOI returned HTTP 403; (2) the
  accessible abstract names no gene symbols for its "antigen-presenting program" (unlike
  Wang/Guo, whose abstracts do name specific genes); (3) NCBI's own curated PubMed-to-Gene
  cross-reference (`elink`, `pubmed_gene`) returns an empty result for this PMID. Excluded
  from the quantitative test entirely rather than approximated with a plausible-sounding
  gene list — explicitly instructed by the project owner: no marker set is fabricated or
  inferred for a paper that cannot be verified.

**If full supplementary marker tables for Guo 2025 or Wu 2024 become legitimately accessible
in future** (e.g. institutional access, author correspondence), H5c's marker sets can be
updated and the analysis rerun, with the change recorded here as a new entry — not a silent
edit to the existing result.

**Result** (see `07_validation_concordance/README.md` and `results/evidence_ledger.tsv`,
row `H5c`, for full detail): significant overlap with Wang 2025's set (H1 panel: CCL3, VEGFA,
FDR=0.005; H1 hits: CCL3, FDR=0.004), zero overlap with Guo 2025's set. Graded Exploratory,
fixed a priori — statistical significance does not upgrade this grade, per the pre-
registration's own rubric ceiling.
