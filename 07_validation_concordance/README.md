# Independent-Cohort Validation and Literature Concordance (H5)

**Status: H5 complete in full (H5a, H5b, H5c).** See `CHANGELOG.md`'s pre-registration entry
(2026-08-02) for the full design fixed before any of H5's results existed.

## Hypothesis

The recruitment programme identified in H1 generalises to independent cohorts (H5a, H5b)
and agrees quantitatively with published TAN biology (H5c).
**H5a**: H1's FDR<0.05 hits — LTB, CCL3, CCL4, CXCL13 — show response-associated
differential expression, in the same direction as H1, in two independent bulk RNA-seq
cohorts (GSE78220, Hugo et al.; GSE91061, Riaz et al.).
**H5b**: H4's two named, non-responder-elevated TF-activity modules (Module 1,
metabolic/nuclear-receptor; Module 2, E2F proliferation) show the same direction in both
cohorts.
**H5c**: H1's screened panel/hits show quantifiable overlap with published tumour-associated
neutrophil (TAN) marker sets (Wu et al. 2024, *Cell*; Guo et al. 2025; Wang et al. 2025).

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
statistical significance (FDR<0.05) — neither alone establishes replication. Applied
identically to H5b.

**H5b method (finalized here, consistent with rather than contradicting the
pre-registration)**: module membership is locked verbatim from H4
(`06_regulation_communication/README.md`) — Module 1 (21 TFs) and Module 2 (13 TFs) — not
re-derived. `decoupleR::run_ulm()` scores TF activity per sample in each cohort
(`minsize=5`), module score = mean activity across each module's scored members (coverage
reported, not assumed complete). Expected direction for both modules is positive (higher in
non-responder), per H4's own result — every member of both modules already shares this one
direction by construction, so no new reference calculation was needed.
**Statistical test**: `limma::lmFit`/`eBayes` directly on module scores, for **both**
cohorts — this is not an inconsistency with H5a's per-cohort data-type choice (limma vs
voom): that choice governs gene-level tests on raw/FPKM expression, whereas a TF-activity
module score is already a continuous, model-derived quantity once computed, exactly like
H4's own primary analysis (which used `limma` uniformly on activity scores regardless of the
underlying expression data). GSE91061's `run_ulm()` input matrix uses `edgeR` TMM+log-CPM
normalization (`cpm(dge, log=TRUE)`) — normalization prep, not the final test.

**H5c method: exploratory, capped a priori — grade ceiling fixed regardless of result.**
Three papers were identified as the real sources behind the pre-registration's "Wu 2024 /
Guo 2025 / Wang 2025" citations (literature search, not assumed): Wu et al. 2024 (*Cell*,
PMID 38447573), Guo et al. 2025 (*Funct Integr Genomics*, PMID 41068349), Wang et al. 2025
(*Comput Struct Biotechnol J*, PMID 41245889). Their marker sets were verified to genuinely
different depths, disclosed rather than hidden:
- **Wang 2025**: full text obtained (open access, PMC12613047). 13 genes explicitly reported
  as elevated markers of the paper's two tumor-enriched terminal neutrophil states (Neu_c7,
  Neu_c10): `CD83, HLA-DRA, CD274, RFX5, CCL3, VEGFA, MAP1LC3B, BHLHE40, LDHA, HES4, MAFG,
  PPARG, CXCR4`. (CXCR2/SELL are also reported but as *down*-regulated in these states —
  excluded, since a marker set should mean genes elevated in the state, not lost by it.)
- **Guo 2025**: abstract only (confirmed paywalled, no PMC full text). 4 genes named:
  `CXCR2, VNN2` (the paper's main immunosuppressive subpopulation), `BACH1, ATF2`
  (regulatory TFs from its gene regulatory network). Thinner than Wang 2025's set purely
  because of paywall access, not because the paper reports less biology.
- **Wu 2024**: **excluded from the quantitative test entirely.** Confirmed paywalled (direct
  fetch returned HTTP 403); confirmed zero gene symbols are named in its accessible abstract;
  confirmed NCBI's own curated PubMed-to-Gene links return nothing for this PMID. No gene set
  was substituted, approximated, or inferred for it — a genuine access constraint, disclosed
  as a limitation, not worked around.

**Test population**: H1's full externally-sourced screening panel (327 genes, recomputed
identically to `03_recruitment/03_h1_discovery_screen.R`'s own 3 msigdbr GO:MF terms — not a
new panel, cross-checked to match H1's own reported 327) and H1's 4 FDR<0.05 hits, each
tested against Wang's and Guo's marker sets separately (2 populations x 2 marker sets = 4
tests). **Test**: hypergeometric over-representation test plus Jaccard index, matching the
pre-registration's specified method. Universe = 55,737 genes present in the GSE120575
matrix (same convention as H4). BH correction applied across the 4 tests.

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

**H5b evidence.** TF-regulon coverage was near-complete in both cohorts: GSE78220 scored
21/21 Module 1 and 13/13 Module 2 members; GSE91061 scored 21/21 Module 1 and 12/13 Module 2
members (TLX2 not scored — regulon coverage below `minsize=5` in that cohort's gene set,
disclosed not hidden).

| Module | H4 expected direction | GSE78220 logFC (P) | GSE91061 logFC (P) | Concordant in both? | Significant in either? |
|---|---|---|---|---|---|
| Module 1 (metabolic/NR) | higher in non-responder | +0.169 (0.502) | **-0.269** (0.292) | No (GSE91061 reversed) | No |
| Module 2 (E2F) | higher in non-responder | +0.190 (0.134) | **-0.092** (0.458) | No (GSE91061 reversed) | No |

Full results: `results/h5b_tf_module_replication_combined.csv`
(`07_validation_concordance/06_h5b_tf_module_replication.R`).

**Per-module verdict, applying the identical pre-registered rubric**:

- **Module 1: Negative finding.** Reverses direction in GSE91061.
- **Module 2: Negative finding.** Reverses direction in GSE91061.

Both modules reverse specifically in GSE91061 — the same cohort where all three of H5a's
non-replicating genes (CCL3, CCL4, CXCL13) also reversed. This is reported here as a factual
cross-reference between two independent pre-registered confirmatory tests, not as a new
statistical test connecting them — no additional analysis was run to explain this recurring
pattern, consistent with the confirmatory-only scope of H5a and H5b.

**H5c evidence.**

| Population | Marker set | Overlap | Overlapping genes | P (hypergeometric) | FDR | Jaccard |
|---|---|---|---|---|---|---|
| H1 screening panel (327 genes) | Wang 2025 (13 genes) | 2 | CCL3, VEGFA | 0.00256 | **0.00513** | 0.006 |
| H1 screening panel (327 genes) | Guo 2025 (4 genes) | 0 | — | 1.00 | 1.00 | 0.000 |
| H1 FDR<0.05 hits (4 genes) | Wang 2025 (13 genes) | 1 | CCL3 | 0.00093 | **0.00373** | 0.063 |
| H1 FDR<0.05 hits (4 genes) | Guo 2025 (4 genes) | 0 | — | 1.00 | 1.00 | 0.000 |

Full results: `results/h5c_literature_concordance.csv`
(`07_validation_concordance/07_h5c_literature_concordance.R`).

Both Wang-2025 comparisons are statistically significant (FDR<0.05) — driven entirely by
**CCL3** (present in H1's panel, H1's hits, and Wang 2025's TAN marker set) and **VEGFA**
(present in H1's panel, a growth factor by GO annotation, present in Wang 2025's marker set
but not itself one of H1's response-associated hits). Guo 2025 shows zero overlap at either
population level — biologically unsurprising, since Guo's markers (`CXCR2, VNN2, BACH1,
ATF2`) are receptors and transcription factors, not secreted cytokines/chemokines/growth
factors, so they were never eligible to appear in H1's GO-defined screening panel in the
first place. **Per the pre-registration, this significance does NOT upgrade H5c's grade** —
it remains Exploratory regardless, because a set-overlap comparison is not a
response-outcome test.

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

**H5b interpretation** (same five steps):

1. **Statistical change.** 0 of 2 pre-specified modules replicate by the pre-registered
   direction+significance rule — both reverse direction in GSE91061, neither reaches
   significance in either cohort.
2. **Biological process.** Neither the metabolic/nuclear-receptor module nor the E2F
   proliferation module — both non-responder-elevated in the discovery cohort — show
   consistent cross-cohort behaviour at the module-activity level.
3. **Tumour immunology implication.** None claimed — two negative findings do not support an
   implication.
4. **Translational implication.** None drawn.
5. **Validating experiment.** Not applicable to a negative finding.

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

**H5c interpretation** (five steps; grade ceiling fixed a priori, not raised by significance):

1. **Statistical change.** H1's screening panel and its FDR<0.05 hits both show significant
   overlap (FDR<0.05) with Wang 2025's TAN marker set (driven by CCL3 and VEGFA); zero
   overlap with Guo 2025's set.
2. **Biological process.** CCL3 — one of H1's own significant, non-responder-elevated hits —
   is independently reported as a marker of Wang 2025's pro-angiogenic TAN state (Neu_c10).
   VEGFA, present in H1's broader screening panel, is also part of that same reported state.
3. **Tumour immunology implication.** A modest, literature-connectable concordance between
   H1's discovery and one independently published pan-cancer TAN atlas — stated as
   plausibility, matching the same standard already applied to H1's own LTB/TLS concordance
   and H4's IKZF3/BACH2 concordance, not as independent validation of either finding.
4. **Translational implication.** None drawn — an Exploratory, capped-a-priori concordance
   test does not support a translational claim on its own.
5. **Validating experiment.** Not proposed here; deferred to `09_synthesis` if this
   concordance is judged worth carrying forward alongside H5a/H5b's results.

## Limitations

Per the Negative Results Policy, three of four pre-specified negative findings are reported
in full, not downplayed.

- **3 of 4 pre-specified genes did not replicate** — CCL3, CCL4, CXCL13 all reverse direction
  in GSE91061 specifically. This is reported as a genuine result, not explained away.
- **"Reverses direction" should be read alongside the width of these estimates' confidence
  intervals (Figure 5A), not as a confidently-established opposite effect.** GSE91061's small
  Responder group (n=10) produces wide CIs that frequently cross zero — e.g. CXCL13's
  GSE91061 estimate spans roughly −4.3 to −0.7 log2FC. The pre-registered direction+
  significance rubric is applied correctly and its verdicts stand, but for CCL3 and CCL4
  specifically (CXCL13 reaches nominal significance, so is less ambiguous) the honest
  description is closer to "failed to confirm, underpowered" than "confidently contradicted."
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

**H5b limitations:**

- **Neither pre-specified module replicated** — both reverse direction in GSE91061
  specifically, the same cohort where H5a's genes also reversed. Reported as a genuine
  result.
- **TLX2 (Module 2) was not scored in GSE91061** — regulon coverage below `minsize=5` in that
  cohort's gene set; the module score there is the mean of 12, not 13, members. Disclosed,
  not treated as a discrepancy to fix.
- **Same GSE91061 small-Responder-group and cross-cohort therapy-composition caveats as
  H5a** apply here identically — pre-declared, not invoked post hoc.
- **H4's own conclusions are not reopened or reinterpreted** — H5b is its own finding,
  cross-referencing H4, same convention as H5a/H1.

**H5c limitations:**

- **Marker-set verification depth is asymmetric across the three cited papers, and this is
  reported transparently rather than hidden**: Wang 2025's 13-gene set is from full open-
  access text; Guo 2025's 4-gene set is abstract-only (paywalled); Wu 2024 contributes zero
  genes and is excluded from the quantitative test entirely (confirmed paywalled, confirmed
  no gene symbols in its accessible abstract, confirmed no NCBI-curated gene links for this
  PMID). This asymmetry reflects real access constraints, not a difference in how much
  biology each paper actually reports.
- **The significant overlap is driven by only 2 genes (CCL3, VEGFA) against a small,
  paywall-limited marker universe** — a real, literature-connectable signal, but a thin one;
  not treated as stronger evidence than its Exploratory grade already states.
- **Guo 2025's zero overlap does not mean no concordance exists** — its markers are
  receptors/TFs, categorically excluded from H1's secreted-factor-focused GO screening
  panel by construction, so this null result reflects panel scope, not biological
  disagreement. Stated as a limitation of the comparison, not a negative finding about Guo
  2025's biology.
- **A set-overlap test can never independently validate H1 or H4** — it is capped at
  Exploratory a priori regardless of its p-values, per the pre-registration.
- **If full supplementary marker tables for Guo 2025 or Wu 2024 become legitimately
  accessible in future**, this analysis can be updated with a new `CHANGELOG.md` entry
  recording the change — not a silent retroactive edit.

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
significance joint criterion.

**H5b evidence grade: Negative finding (both modules).** Neither H4's metabolic/
nuclear-receptor module nor its E2F proliferation module replicates by the pre-registered
rubric — both reverse direction in GSE91061. H4's own conclusions are unchanged; this is
H5b's own finding, cross-referencing H4.

**H5c evidence grade: Exploratory, fixed a priori** (per the pre-registration, not raised by
the statistically significant overlap with Wang 2025's marker set). H1's screening panel and
its FDR<0.05 hits show a modest, literature-connectable concordance with one independently
published pan-cancer TAN atlas (Wang 2025: CCL3, VEGFA), and no overlap with a second (Guo
2025, for reasons of panel scope, not disagreement). Wu 2024 could not be tested at all —
disclosed as a limitation, not a null result. This is the weakest-tier evidence type used
anywhere in this project, by design, and is reported as exactly that.

**H5 status overall — H5 is now complete in full (H5a, H5b, H5c).** One Exploratory
gene-level result (LTB), three gene-level Negative findings, two module-level Negative
findings, and one Exploratory literature-concordance result (significant but capped) — all
reported exactly as pre-registered, with no criteria relaxed, no post-hoc explanation
substituted for the pre-declared caveats, and no marker genes fabricated for papers that
could not be fully verified. No broader biological synthesis is drawn here — any such
synthesis belongs in `09_synthesis`, the next and final module.
