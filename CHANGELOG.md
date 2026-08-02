# Changelog

Project architecture was frozen on 2026-08-01 after three design-refinement passes. From that
point, this file records every deviation from the frozen specification, with the technical or
biological blocker that forced it and the justification for the alternative chosen. Additions
made merely because they were interesting are not permitted (see `README.md`, scope freeze).

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
