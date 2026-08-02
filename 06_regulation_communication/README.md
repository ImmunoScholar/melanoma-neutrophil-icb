# Regulatory Coherence of the Recruitment Programme (H4)

**Status: H4 complete — both components run (TF-activity: primary + secondary; communication
network: primary).** This README uses four consistent terms throughout, matching the project
owner's explicit instruction: **Finding** (supported by a pre-specified statistical analysis),
**Negative finding** (a pre-specified analysis did not support the tested effect), **Descriptive
observation** (an unbiased pattern noticed after analysis, not itself statistically tested
within H4), and **Hypothesis for later synthesis** (may be revisited in H5/`09_synthesis`, not
claimed as evidence here).

## Hypothesis

The recruitment programme identified in H1 and attributed to specific cellular compartments
in H2 is regulatorily coherent — i.e. driven by an identifiable set of transcription factors
whose inferred activity differs systematically between ICB responders and non-responders —
rather than reflecting scattered, uncoordinated transcriptional noise.

## Analysis

**Network.** CollecTRI transcription factor-target regulons, obtained via OmniPath's REST API
(`decoupleR::get_collectri()` is blocked by an external Ensembl outage — see `CHANGELOG.md`),
processed to replicate `get_collectri()`'s own canonical logic exactly (complex sources
collapsed to `AP1`/`NFKB`, deduplicated on `(source, target)` keeping first occurrence).
Verified human-cased, 42,698 edges, 1,178 TFs (`data/processed/collectri_human_verified.rds`).

**Sample.** Same 19 pre-treatment, response-labeled patients as H1/H2 (10 non-responder / 9
responder). Whole-transcriptome patient-level pseudobulk (mean TPM per gene per patient,
`log2(TPM+1)`) — not H1's or H2's gene-panel-restricted pseudobulk, which lack the broad
target-gene coverage TF-activity scoring needs (327 and 35 genes respectively, versus 6,424 of
6,661 unique CollecTRI targets present in the full transcriptome). One row of the underlying
`tpm.rds` cache (of 55,738) carries a literal `NA` gene symbol — an isolated artefact, dropped
(see `CHANGELOG.md`).

**TF activity.** `decoupleR::run_ulm(minsize = 5)` — the network plus decoupleR's own
minimum-regulon-size rule define the tested panel, not us; no TF is named or excluded by hand,
matching this project's discovery-discipline requirement. 754 TFs scored per patient.

**Statistical test.** `limma::lmFit`/`eBayes` on the TF x patient activity-score matrix,
patient-level units, Benjamini-Hochberg FDR across all 754 tested TFs — same method and
discipline as H1/H2. Direction convention matches H1 exactly: positive logFC = higher in
non-responder (associated with resistance).

**Module-clustering characterization.** A pre-registered analysis step is not a discovery
search and does not require pre-specification the way a gene panel does — this is a
post-hoc characterization of the primary result's own internal structure, added because the
raw result showed substantial redundancy (below). Two complementary, non-arbitrary methods
were applied to the 56 FDR<0.05 hits' activity-score correlation across the 19 patients:
hierarchical clustering (average linkage, multiple cut heights reported rather than one
chosen cutoff) and Nyholt's (2004, *Am J Hum Genet*) eigenvalue-based effective-number-of-
independent-tests statistic.

**Secondary, exploratory test (compartment-level) — pre-registered in `CHANGELOG.md` before
any H4 result existed.** Restricted strictly to the primary's own 56 locked FDR<0.05 TFs (read
directly from the committed `results/h4_tf_activity_ranked.csv`, asserted `== 56` in code — no
new discovery search). T_cell/NK/B_cell tested; Myeloid excluded, same justification as H2's
own secondary test (only 3 usable responder patients, re-verified here rather than assumed
unchanged). Whole-transcriptome pseudobulk built per compartment per patient (same >=10-cell
threshold as H2), `decoupleR::run_ulm()` run per compartment, then subset to the locked 56
TFs before any testing. `limma`, same direction convention, Benjamini-Hochberg FDR pooled
globally across all 168 tests (3 compartments x 56 TFs), matching H2's secondary-test
convention exactly.

**Communication network (H4's second, co-primary component).** Tests whether intercellular
ligand-receptor structure converges on T-cell-directed edges, and whether this differs by
response. Design confirmed against real, measured feasibility data before writing the real
analysis (`06_h4_lr_feasibility.R`, `06b_method_timing.R`), not assumed:

- **Gene scope**: restricted to LIANA Consensus's own L-R gene universe (1,839 of 1,893 genes
  present in our matrix) — proven bit-identical to the full 55,737-gene matrix for `natmi`'s
  output (max absolute difference = 0), so this is a scope reduction to what LIANA actually
  needs, not a shortcut. Cuts assay memory from ~5.25 GB to ~173 MB.
- **Method**: 4-method consensus (`natmi`, `connectome`, `logfc`, `sca`) aggregated via
  `liana_aggregate()` — LIANA's own standard multi-method usage. `cellphonedb` excluded, with
  measured justification: ~87 min extrapolated full-scale runtime (178 sec for a 200-cell
  test) and real memory risk (`natmi` alone touched 9.6 GB of this machine's 10 GB budget
  under poor object hygiene in the feasibility script).
- **Response split**: two separate networks (Responder-only cells, Non-responder-only cells),
  pooled across patients within each group — a general property of how LIANA operates on
  pooled cells, not a project-specific shortcut. Every compartment x response cell count
  clears LIANA's `min_cells=5` floor by a wide margin (minimum: Myeloid-Responder, 87 cells).
- **Compartments**: T_cell, B_cell, Myeloid, NK (same as H2/H4-secondary; Mast/Malignant/
  Unassigned excluded for unusable counts).
- **Suppression-receptor panel**: externally sourced via `msigdbr` (GO:BP terms matching
  `NEGATIVE_REGULATION_OF.*T_CELL`, 27 terms, printed in full for audit, unioned to 293
  genes) — same discipline as H1's GO-sourced cytokine panel, not a hand-picked checkpoint
  gene list.
- **Pre-specified test**: Fisher's exact test per network, all scored edges — `target ==
  T_cell` (yes/no) x `receptor in suppression panel` (yes/no, any subunit for complexes).
  This is the ONLY statistical test run on this network; no follow-up test was run after
  inspecting results (see Evidence).
- **Unit of analysis, stated plainly**: EDGES within one network, not patients. Each response
  group produces exactly one pooled network — a Responder-vs-Non-responder *network*
  comparison is inherently descriptive, unlike H1/H2/H4-TF-activity's patient-level
  inferential tests. The Fisher's test above is a legitimate significance test, but only of
  enrichment *within* one network.
- **Discovery-discipline reminder**: CXCL8/CXCR1/2 receive no special commentary anywhere in
  this analysis, whether or not they appear in the unbiased edge tables.

## Evidence

**Primary result.** 56 of 754 TFs significant at FDR<0.05 (148 at FDR<0.10). 48/56 higher in
non-responders, 8/56 higher in responders — directionally consistent with H1's own hits (3 of
4 H1 genes higher in non-responder). Full ranked table:
`results/h4_tf_activity_ranked.csv`.

**Audit before treating this as final.** Raw p-values showed marked enrichment (41% of all
754 tested TFs at raw P<0.1, versus ~10% expected under a true null) — investigated rather
than accepted at face value (`06_regulation_communication/03b_h4_audit.R`). Three checks:

- *p-value shape*: enrichment traced to regulon redundancy, not a technical artefact — TF
  families sharing overlapping CollecTRI target genes (E2F1–5, IRF2/3/5/6/7/8/9, SP1/2/3,
  STAT1/3/5B) appear together with consistent direction, which is expected when correlated
  regulators are tested, not evidence of a confound.
- *Therapy-type confound*: the same imbalance H1 already documented in this cohort reproduces
  exactly (anti-PD1 monotherapy: 8 non-responder/4 responder; anti-CTLA4+PD1 combo: 1
  non-responder/4 responder) — restated here since it applies to any analysis of this
  19-patient cohort, not a new problem, but not adjustable at this sample size either.
- *Effect sizes*: max |t| = 5.54 (df = 17) among significant TFs — unremarkable, no sign of
  leakage or a trivial separation artefact.

**Module-clustering result.** The 56 nominal hits collapse to **Meff = 31.3 effective
independent regulatory programs** (Nyholt), organizing into **13 correlated modules at
r>0.7** (6 modules of size >1, 7 singleton/unclustered TFs). Two large, coherent
non-responder-elevated modules dominate:

- **Module 1** (21 TFs, all higher in non-responder): `SREBF1, BACH1, SREBF2, KLF15, PARK7,
  TFAP2A, DNMT1, CEBPA, PPARA, PDX1, ESR1, NR1H4, NFE2L2, VDR, CEBPZ, EP300, SP3, EHF, CEBPE,
  SP2, MNT` — a broad, data-driven cluster spanning nuclear-receptor/metabolic regulators
  (SREBF1/2, PPARA, NR1H4, VDR), oxidative-stress response (NFE2L2, PARK7), and myeloid
  differentiation (CEBPA/CEBPE/CEBPZ family). Heterogeneous enough that it should be read as
  one correlated statistical unit rather than a single named pathway.
- **Module 2** (13 TFs, all higher in non-responder): `TLX2, OLIG2, STOX1, SMARCA1, E2F5,
  SIM2, E2F4, E2F1, E2F3, POU1F1, ARID3B, E2F2, HCFC1` — dominated by the canonical E2F
  cell-cycle/proliferation family (E2F1–5), a well-established, biologically coherent
  signature.

Two smaller modules are directionally opposite (higher in responder) and worth naming
individually rather than only as counts:

- **Module 4** (3 TFs, higher in responder): `SNAI2, CTBP1, ZFX`.
- **Module 5** (3 TFs, higher in responder): `IKZF3, SATB2, BACH2` — IKZF3 and BACH2 are
  established regulators of lymphocyte differentiation and, for BACH2 specifically, of
  T-cell-exhaustion restraint. Their association with response is a plausible, literature-
  connectable signal, stated here as biological plausibility only, not independent
  validation (same standard applied to H1's LTB/TLS concordance).

Full clustering output: `results/h4_tf_module_clustering.rds`
(`06_regulation_communication/03c_h4_module_clustering.R`).

**Secondary test result.** 51 of 168 tests significant at global FDR<0.05 — but concentrated
overwhelmingly in T_cell (43/56 TFs tested, a 76.8% hit rate) versus NK (5/56, 8.9%) and
B_cell (3/56, 5.4%). Audited before treating this as informative, not accepted at face value
(`06_regulation_communication/05b_secondary_audit.R`, `05c_tcell_redundancy_check.R`):

| Compartment | Usable patients | Hit rate (of 56) | Correlation with primary whole-sample logFC |
|---|---|---|---|
| T_cell | 19 (= full primary cohort) | 76.8% (43) | r = 0.887 |
| NK | 16 | 8.9% (5) | r = 0.76 |
| B_cell | 11 | 5.4% (3) | r = 0.634 |

T_cell's result is **not treated as an independent finding**: T cells are 69% of the
whole-sample composition (`03_recruitment/README.md`), so the T_cell-compartment pseudobulk
is compositionally close to the whole-sample pseudobulk that produced these 56 TFs as hits in
the first place — T_cell has the same patient count as the primary analysis itself (19/19)
and the highest correlation with the primary signal (r=0.887) of the three compartments. High
T_cell significance is expected largely by construction, not evidence of T-cell-specific
regulation.

The informative component is **NK (5 TFs) and B_cell (3 TFs)**, which reach significance
despite substantially lower power and weaker correlation with the primary signal:

- **NK**: `ZNF395` (logFC +0.95), `SREBF1` (+1.09), `IRF3` (+1.15), `TLX2` (+0.78), `IRF2`
  (+1.16) — all higher in non-responder, all members of the primary's non-responder-elevated
  Module 1 or Module 6.
- **B_cell**: `ZFX` (logFC -1.67), `IKZF3` (-1.74), `IKZF2` (-1.98) — all higher in responder;
  IKZF3 is a member of the primary's responder-elevated Module 5 (lymphocyte-differentiation
  cluster).

**Communication network result — NEGATIVE FINDING.** The pre-specified Fisher's exact test
does not support suppressive-receptor enrichment among T-cell-directed edges, in either
network:

| Network | Edges | T-cell-directed suppressive / total | Other-target suppressive / total | OR | P |
|---|---|---|---|---|---|
| Responder | 2,823 | 98/656 (14.9%) | 296/2,167 (13.7%) | 1.11 | 0.40 |
| Non-responder | 3,477 | 139/844 (16.5%) | 389/2,633 (14.7%) | 1.14 | 0.25 |

This is reported exactly as it is, per the Negative Results Policy: T-cell-directed
communication is **not** statistically enriched for GO-annotated suppressive receptors
relative to communication directed elsewhere, in this data, at this sample size. This
negative finding is the formal H4 communication result and is the basis of this component's
conclusion.

**Descriptive observation (NOT independently tested).** While inspecting the subset of
statistically significant edges (`aggregate_rank<0.05`) from the negative-finding test above,
a pattern was noticed: the Non-responder network's significant T-cell-directed edges include
21/76 (27.6%) with a GO-annotated suppressive receptor, versus the Responder network's 6/40
(15.0%) — and several of the Non-responder-specific ones are established immune checkpoint
interactions that emerged from the unbiased GO panel, not a hand-picked list: `CD86→CTLA4`,
multiple `HLA-D*→LAG3` pairs (MHC-II presented to the LAG3 checkpoint receptor), `LGALS9→
HAVCR2` (Galectin-9/TIM-3). **No additional statistical test was run on this subset** — doing
so after noticing the pattern would be exactly the kind of result-contingent test-shopping
this project's discovery discipline exists to prevent (the same reasoning that keeps
CXCL8/CXCR1/2 out of discovery). This is stated here as a **Descriptive observation** and a
**Hypothesis for later synthesis** only — see `results/h4_lr_suppression_enrichment.rds` for
the full edge list, reproduced in Figure 4 Panel E.

## Interpretation

1. **Statistical change.** 56/754 TFs (7.4%) significant at FDR<0.05, patient-level units,
   BH-corrected — comparable in proportion to H1's own screen (4/35, 11.4%). Characterized
   further as ~31 effective independent signals / 13 correlated modules, not 56 independent
   findings.
2. **Biological process.** The recruitment programme is regulatorily coherent, not scattered
   noise: it organizes into a small number of correlated programs, dominated by a
   proliferation/cell-cycle axis (E2F module) and a broad metabolic/nuclear-receptor axis,
   both elevated in non-responders, opposed by a smaller lymphocyte-differentiation axis
   (IKZF3/BACH2/SATB2) elevated in responders.
3. **Tumour immunology implication.** A coordinated shift toward proliferative and metabolic
   transcriptional programmes in non-responder tumours, opposed by lymphocyte-differentiation
   regulators in responders, is consistent with — though does not on its own establish — a
   more actively expanding, less lymphocyte-organized tumour-immune state in resistance. This
   is a pattern across correlated TFs, not a mechanism; H4's second component (ligand-receptor
   communication, not yet run) is where sender-receiver structure would actually be tested.
4. **Translational implication.** Not stated yet — appropriately deferred to `08_experimental_
   translation`, pending H4's communication-network component and H5's independent-cohort
   validation.
5. **Validating experiment.** Deferred to `08_experimental_translation`. TF-activity inference
   from bulk/pseudobulk expression is itself indirect; direct validation (e.g. ChIP or ATAC-
   based TF occupancy, or perturbation of E2F/SREBF activity in a relevant model) is noted
   here rather than acted on prematurely.

**Secondary, exploratory interpretation** (compartment-level, same five steps, applied only
to the NK/B_cell result — T_cell is excluded from substantive interpretation per the audit
above):

1. **Statistical change.** 8 of 56 locked TFs significant at global FDR<0.05 outside T_cell
   (5 NK, 3 B_cell), despite those compartments carrying 16 and 11 usable patients
   respectively (versus T_cell's 19) and weaker correlation with the primary signal.
2. **Biological process.** The two non-T_cell compartments implicate different halves of the
   primary's module structure: NK's hits are non-responder-elevated metabolic/IRF-axis TFs
   (Module 1/6); B_cell's hits are responder-elevated lymphocyte-differentiation TFs (Module
   5, including IKZF3). This echoes H2's own finding that B cells carry a
   lymphocyte-organisational, response-associated signal (LTB), now extended from raw
   expression to inferred regulatory activity.
3. **Tumour immunology implication.** A B-cell-localized lymphocyte-differentiation
   regulatory signal accompanying response, alongside an NK-localized component of the
   broader non-responder-elevated metabolic programme, is consistent with — but does not
   establish — compartment-specific regulatory contributions layered underneath the dominant
   whole-sample (largely T-cell-driven) signal.
4. **Translational implication.** Not stated — explicitly deferred; per the pre-registration,
   this exploratory result does not alter H4's primary conclusion or any other module's
   conclusions.
5. **Validating experiment.** Deferred to `08_experimental_translation`. If independently
   corroborated by H5 or the communication-network component, revisit in `09_synthesis`; not
   acted on prematurely from this result alone.

**Communication network interpretation** (same five steps, applied to the pre-specified test
only — the checkpoint-pair pattern is a Descriptive observation, addressed separately below,
not folded into this inferential interpretation):

1. **Statistical change.** Fisher's exact test, all scored edges: OR≈1.1 in both networks,
   P=0.40 (Responder) and P=0.25 (Non-responder) — neither reaches significance. A Negative
   finding.
2. **Biological process.** Communication directed at T cells is not, in this data, more
   enriched for GO-annotated suppressive receptors than communication directed at other
   compartments. This does not mean no such signalling exists — it means this specific,
   unbiased, pre-specified test does not detect a differential enrichment at this sample
   size.
3. **Tumour immunology implication.** None claimed from this test — a negative result does
   not support an implication about T-cell suppression convergence.
4. **Translational implication.** None — explicitly not drawn from a negative finding.
5. **Validating experiment.** Not applicable to a negative finding; if the Descriptive
   observation below is independently corroborated (H5, or a future, adequately-powered
   dataset), a validating experiment could be proposed at that point, not now.

**Descriptive observation interpretation** (Hypothesis for later synthesis, explicitly not
evidence):

The checkpoint-pair pattern (CD86→CTLA4, HLA-D*→LAG3, LGALS9→HAVCR2 concentrated in the
Non-responder network's significant T-cell-directed edges) is biologically plausible — these
are established, literature-recognized immune checkpoint interactions, and their emergence
from an unbiased GO-based panel (not hand-picked) is itself methodologically reassuring. But
it was noticed post hoc, is not statistically tested within H4, and must not be read as
evidence of differential checkpoint signalling. It is carried forward as a **Hypothesis for
later synthesis**: worth checking against H5's independent cohorts or revisiting in
`09_synthesis`, not asserted here.

## Limitations

Per the Negative Results Policy, the audit findings above are reported in full rather than
omitted because they complicate a clean narrative.

- **Therapy-type confound, not adjustable at n=19** — identical to H1's documented confound
  (same cohort): anti-PD1 monotherapy skews non-responder, anti-CTLA4+PD1 combo skews
  responder. Any TF whose activity happens to track therapy type rather than response
  specifically cannot be distinguished from a true response-associated signal at this sample
  size.
- **TF-activity scores are not independent tests.** Reporting "56 significant TFs" without the
  module-clustering context would overstate the finding — the real informational content is
  closer to Meff≈31 independent signals / a handful of correlated regulatory modules.
- **No cross-dataset replication of its own**, same constraint as H1/H2 — GSE72056 was scoped
  to H0 replication only. External validation remains H5's role.
- **TF activity is inferred, not measured.** `decoupleR::run_ulm()` estimates activity from
  target-gene expression patterns; it is not a direct measurement of TF binding or occupancy.

**Secondary test limitations**, per the Negative Results Policy stated in full rather than
downplayed:

- **T_cell's result is excluded from substantive interpretation.** Its high hit rate is
  explained by T cells' 69% share of the whole-sample composition and by T_cell having the
  same patient count as the primary analysis (19/19) — not treated as evidence of
  T-cell-specific biology.
- **NK and B_cell hits are a small-N exploratory result** (5 and 3 TFs respectively, out of
  56 tested), themselves at reduced power (16 and 11 usable patients). Genuinely informative
  but not substantial.
- **Same therapy-type confound and same cohort as the primary result** — not an independent
  sample, not adjustable at this size.
- **Not independently validated** — remains H5's role if pursued further.
- **Per the pre-registration conditions**, this result does not alter H4's primary
  conclusion or any other module's conclusions, and is not promoted into Figure 4 or any
  other main-narrative figure — see `figures/figure4_h4_tf_activity` caption for the
  cross-reference.

**Communication network limitations**, stated in full rather than downplayed:

- **Network-level comparison is inherently descriptive, not inferential.** Each response
  group produces exactly one pooled network — there is no per-patient replicate at the
  network level, unlike every other statistical test in this project. The Fisher's test is a
  legitimate test of enrichment *within* one network; comparing the two networks' results to
  each other is not a patient-level hypothesis test.
- **Patient pooling within each network** is a general property of how LIANA (and most L-R
  tools) operate on pooled single cells, not a project-specific compromise — but it means a
  disproportionately cell-rich patient could shape a network's edges more than a
  cell-sparse one, unaddressed by the current design.
- **`cellphonedb` excluded from the consensus**, on measured runtime/memory grounds (see
  Analysis) — the reported result is a 4-method, not 5-method, LIANA consensus.
- **Same therapy-type confound and same cohort** as every other H4/H1/H2 analysis, not
  adjustable at this size.
- **The Descriptive observation is exactly that** — not independently tested, not part of
  this component's evidence grade, and must not be conflated with the pre-specified Negative
  finding above when this module is summarized elsewhere (root `README.md`, evidence ledger).

## Conclusion

**Primary result: evidence grade Moderate.** Patient-level statistics and multiple-testing
correction are satisfied; the module-clustering characterization adds honest specificity
(Meff≈31, not 56) rather than inflating the finding; one hit cluster (IKZF3/BACH2/SATB2) is
concordant with independently published lymphocyte-differentiation biology, stated as
plausibility, not validation. Capped at Moderate rather than Strong for the same reason as
H1/H2: no cross-dataset replication of its own, and TF activity here is inferred rather than
directly measured. The recruitment programme is regulatorily coherent in the sense tested
here — a small number of correlated, plausible regulatory programs, not undirected noise —
but this is one component of H4, not the whole hypothesis.

**Secondary compartment-level result: evidence grade Exploratory** — graded separately, not
combined with the primary, matching H2's precedent for genuinely different confidence
levels. T_cell's contribution to this result is not treated as independent evidence (see
Limitations). The NK (5 TFs) and B_cell (3 TFs) hits, though few and reduced-power, are
directionally consistent with and extend the primary's module structure — B cells carrying
the responder-elevated lymphocyte-differentiation signal (IKZF3/IKZF2/ZFX), echoing H2's own
B-cell/LTB finding — and are reported as supporting evidence, not promoted further, per the
pre-registered conditions. May be revisited in `H5` or `09_synthesis` if independently
corroborated; not acted on further from this result alone.

**Communication network result: Negative finding (pre-specified test); Descriptive
observation (checkpoint-pair pattern) carried forward as a Hypothesis for later synthesis
only.** The pre-specified Fisher's exact enrichment test does not support T-cell-directed
communication being enriched for GO-annotated suppressive receptors, in either network
(Responder OR=1.11 P=0.40; Non-responder OR=1.14 P=0.25) — reported plainly as a negative
result, per the Negative Results Policy, and this is the basis of this component's
conclusion. A checkpoint-pair pattern noticed in the significant-edge subset afterward
(CD86→CTLA4, HLA-D*→LAG3, LGALS9→HAVCR2, concentrated in the Non-responder network) is
biologically plausible but was **not independently tested** and does **not** change this
grade — stated explicitly as a Descriptive observation / Hypothesis for later synthesis, to
be revisited only if independently corroborated in H5 or `09_synthesis`.

**Overall H4 status: complete.** H4's hypothesis has two components: TF-activity regulatory
coherence (Finding, Moderate grade — the recruitment programme is regulatorily coherent) and
communication-network convergence on T-cell suppression (Negative finding — not supported by
the pre-specified test, in this data, at this sample size). Both are now tested and
documented to the same standard as H0–H2, with a pre-registered secondary follow-up
(Exploratory) and an explicitly-labeled, untested descriptive observation carried forward
for later synthesis. H4 does not conclude with a single uniform verdict — it concludes with
one supported Finding and one Negative finding, reported with equal honesty, per this
project's Negative Results Policy.
