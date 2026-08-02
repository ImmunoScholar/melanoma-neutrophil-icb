# Synthesis (Module 09)

**Status: complete.** This module is exempt from the six-heading (Hypothesis -> Analysis ->
Evidence -> Interpretation -> Limitations -> Conclusion) template per the frozen architecture
(`CONTINUATION_BRIEF.md` SS2) — like `01_background` and `08_experimental_translation`, it
tests no hypothesis of its own. It performs no new statistical analysis: every number below is
read or re-derived (by the exact method its source module already used and committed, e.g.
`cutree()` at the same r>0.7 cutoff already documented in
`06_regulation_communication/03c_h4_module_clustering.R`) directly from
`results/evidence_ledger.tsv` and the already-committed per-module result tables. **No new
evidence-ledger row is added by this module** — it integrates the existing ledger, it does not
extend it.

---

## 1. Evidence map

Every completed ledger row, in the order the modules were run. This table is the basis for
everything that follows — no claim below goes further than what is graded here.

| Hypothesis | Module | Result direction | Evidence grade | One-line observation |
|---|---|---|---|---|
| H0 | `02_dataset_audit` | negative | **Strong** | Neutrophil-specific marker co-occurrence at chance level in GSE120575 (1 vs 0.14 expected); 3-4 plausible unassigned candidates in GSE72056 — both consistent with protocol-driven depletion, not biological absence. |
| H1 | `03_recruitment` | positive | **Moderate** | LTB, CCL3, CCL4, CXCL13 differ by ICB response pre-treatment (GSE120575, patient-level pseudobulk, FDR<0.05). |
| H2 (primary) | `04_cellular_sources` | positive | **Moderate** | 34/35 H1-tested genes show significant compartment restriction; H1's hits decompose into a myeloid/NK axis (CCL3, CCL4) and a lymphocyte axis (LTB, CXCL13). |
| H2 (secondary) | `04_cellular_sources` | positive | Exploratory | Regulation is not always co-located with dominant-expression compartment (CCL4, LTB). |
| H3 | `05_neutrophil_states` | — | **Omitted** | H0 established <20 recoverable neutrophils; not tested. |
| H4 (TF-activity) | `06_regulation_communication` | positive | **Moderate** | 56/754 TFs FDR<0.05, collapsing to Meff=31.3 independent programs / 13 modules; two non-responder-elevated modules (metabolic/nuclear-receptor, 21 TFs; E2F proliferation, 13 TFs) opposed by one responder-elevated module (lymphocyte-differentiation: IKZF3, BACH2, SATB2). |
| H4 (secondary) | `06_regulation_communication` | positive | Exploratory | T-cell signal is compositionally redundant with the whole-sample primary result (r=0.887); NK and B-cell signals are the informative, lower-power component. |
| H4 (communication) | `06_regulation_communication` | null | Exploratory | Pre-specified Fisher's test for T-cell-directed suppressive-receptor enrichment is not significant in either response-split network. |
| H5a | `07_validation_concordance` | null | Exploratory (LTB) / Negative finding (CCL3, CCL4, CXCL13) | LTB direction-consistent but non-significant in two external cohorts; CCL3/CCL4/CXCL13 reverse direction specifically in GSE91061. |
| H5b | `07_validation_concordance` | null | Negative finding (both modules) | Both H4 non-responder-elevated modules reverse direction in GSE91061, the same cohort where H5a's genes reversed. |
| H5c | `07_validation_concordance` | positive | Exploratory (fixed a priori) | Significant overlap between H1's panel/hits and Wang et al. 2025's published TAN marker set (CCL3, VEGFA); zero overlap with Guo et al. 2025's set. |

---

## 2. Systems synthesis

This section integrates H0-H5 exactly as graded above. Every paragraph is built in the fixed
order **Observation -> Interpretation -> Biological hypothesis -> Clinical implication**, with
each level explicitly labelled so the synthesis never states more than its supporting grade
allows. Grades are restated inline rather than assumed carried over from Section 1.

### 2.1 Data availability sets the frame (H0, Strong)

**Observation.** Neutrophil-specific marker co-occurrence is at chance level in GSE120575 and
yields only 3-4 plausible candidates in GSE72056 (Strong, 2/2 independent datasets).
**Interpretation.** CD45+ FACS sorting plus Smart-seq2 plate-picking depletes neutrophils to
near-completeness in both public cohorts used in this project.
**Biological hypothesis.** This is a protocol artefact, not evidence that melanoma tumours lack
neutrophils.
**Clinical implication.** None drawn — this is a data-availability finding, not a biological
claim. Its consequence for the rest of this project is structural: single-cell neutrophil-state
biology (H3) could not be assessed, and every downstream finding (H1-H5) is necessarily about
the CD45+ immune infiltrate as a whole, not about neutrophils directly.

### 2.2 A two-axis recruitment/organisation programme (H1 + H2, Moderate)

**Observation.** Four genes differ by ICB response pre-treatment (H1, Moderate): LTB (higher in
responders), CCL3/CCL4/CXCL13 (higher in non-responders). These decompose by cellular source
(H2 primary, Moderate) into a myeloid/NK-derived axis (CCL3 from Myeloid, CCL4 from NK) and a
lymphocyte-derived axis (LTB from B cells, CXCL13 from T cells) — with LTB and CXCL13 moving in
opposite directions despite both being lymphocyte-derived (an unresolved tension, not smoothed
over). H2's secondary result (Exploratory) adds that regulation is not always co-located with
where a gene is most abundant.
**Interpretation.** The recruitment programme identified by H1 is not one undifferentiated
signal; it separates into a chemotactic axis and a lymphoid-organisational axis, each with a
distinct, identifiable cellular source.
**Biological hypothesis.** LTB's direction is concordant with published tertiary-lymphoid-
structure/lymphotoxin biology (literature-derived plausibility, not validation — see Figure 6's
dashed edge). CXCL13's opposite direction despite the same canonical TLS association remains an
open question this project did not resolve.
**Clinical implication.** None stated at this stage — deferred to 2.4 once H4/H5's contribution
is incorporated.

### 2.3 A regulatorily coherent but incompletely resolved TF programme (H4, Moderate/Exploratory)

**Observation.** TF-activity inference (H4 primary, Moderate) finds 56/754 TFs significant,
honestly characterized as ~31 effective independent programs (Meff=31.3, Nyholt 2004) rather
than 56 independent findings — collapsing to two non-responder-elevated modules (metabolic/
nuclear-receptor; E2F proliferation) opposed by one responder-elevated module (lymphocyte-
differentiation: IKZF3, BACH2, SATB2). The communication-network component (Exploratory, null)
found no significant enrichment of T-cell-directed suppressive signalling in either
response-split network — a genuine negative result, not a failure to look. A descriptive,
untested observation (checkpoint-pair edges concentrated in the non-responder network) is
carried forward as a hypothesis for future work only, per this project's discovery discipline.
**Interpretation.** The expression-level programme identified in H1/H2 is accompanied by a
small number of correlated, plausible transcriptional programmes, not undirected noise — but
this project's own pre-specified test for T-cell-suppressive communication did not find
statistical support.
**Biological hypothesis.** IKZF3/BACH2's association with the responder-elevated module is
plausible given their published role restraining T-cell exhaustion (literature-derived
plausibility, not validation).
**Clinical implication.** None stated — deferred to 2.4.

### 2.4 Independent-cohort and literature context (H5, mixed grades)

**Observation.** H5a (confirmatory, per-gene): LTB is direction-consistent but non-significant
in both GSE78220 and GSE91061 (Exploratory). CCL3, CCL4, and CXCL13 reverse direction
specifically in GSE91061 (Negative finding). H5b (confirmatory, per-module): both H4
non-responder-elevated modules also reverse specifically in GSE91061 (Negative finding). H5c
(exploratory, capped a priori): H1's panel and its hits show significant overlap with Wang et
al. 2025's independently published pan-cancer TAN marker set via CCL3/VEGFA, and no overlap
with Guo et al. 2025's set (whose markers are categorically outside H1's secreted-factor-focused
panel by construction, not a disagreement).
**Interpretation.** Applying this project's own standing rule (replication requires BOTH
concordant direction AND significance), the CCL3/CCL4/CXCL13/module-level components of the
programme do not replicate in either external bulk cohort tested, with a specific,
reproducible reversal pattern in GSE91061 across two independent confirmatory tests (H5a and
H5b). LTB's direction is the most consistent across all three cohorts (GSE120575, GSE78220,
GSE91061) though it has not itself reached external significance. A modest, literature-
connectable concordance exists with one independently published TAN atlas (Wang 2025).
**Biological hypothesis.** GSE91061's smaller responder group (n=10) and differing therapy
composition across the three cohorts are pre-declared, plausible — not tested — contributors to
the reversal pattern; no further test was run on this specific question, consistent with H5a/
H5b's confirmatory-only scope.
**Clinical implication.** None drawn from H5 alone — see 2.5 for how this constrains, rather
than negates, the programme's overall standing.

### 2.5 Evidence-weighted integration

Taken together, and weighted exactly by the grades in Section 1 — not by which result is most
recent or most striking — this project establishes an internally consistent, patient-level,
multiply-corrected discovery finding (H1, Moderate) with a clear cellular-source decomposition
(H2 primary, Moderate) and a coherent, honestly-characterized regulatory layer (H4 primary,
Moderate). The programme's generalisation to independent cohorts is presently limited: two
pre-registered confirmatory tests (H5a, H5b) found the non-LTB components do not clear the
project's own pre-declared replication bar, and this outcome is reported with the same weight as
any other finding, per the Negative Results Policy — it constrains the programme's external
generalisability without invalidating the internally-consistent, multiply-corrected discovery
and attribution work that produced it (H1/H2/H4 remain Moderate; H5's results do not retroactively
change those grades, consistent with how each module has always treated later results). LTB is
the one component whose direction has been consistent across every cohort examined in this
project (GSE120575, GSE78220, GSE91061), though not yet significant externally — the closest
this project comes to a cross-cohort-consistent finding, stated at exactly that strength and no
further.

---

## 3. Figure 6: evidence-driven systems model

Figure 6 (`figures/figure6_synthesis_model.png`/`.svg`, built by
`09_synthesis/01_figure6_synthesis_model.R`) renders Section 2's H1-H2-H4 structure as a node/
edge diagram. Every node and edge is programmatically read or re-derived from already-committed
result tables (`results/h1_discovery_screen_ranked.csv`, `h2_compartment_specificity.csv`,
`h4_tf_module_clustering.rds`, `h5a_gene_replication_combined.csv`,
`h5b_tf_module_replication_combined.csv`, `h5c_literature_concordance.csv`,
`evidence_ledger.tsv`) — nothing is hand-typed from memory of module prose, specifically to
prevent transcription drift between this figure and the modules it summarizes.

**Encoding** (fixed, confirmed before implementation): node fill = responder-elevated (blue) /
non-responder-elevated (vermillion) / attribution-layer-neutral (grey, for H2 compartments,
which are not themselves directional); solid border/edge = a finding generated within this
project; dashed border/edge = literature-derived or externally-unvalidated. Each tested node
carries a bracketed H5 replication tag computed directly from h5a/h5b's own
`concordant_direction`/`significant` columns (`[H5: Exploratory]`, `[H5: Negative finding]`, or
`[H5: not tested]` for the lymphocyte-differentiation module, which H5b did not test).

**Deliberately not diagrammed** (to avoid overstating their confidence, matching Module 08's own
"explicitly not proposed" precedent): H0 and H3 (not part of this ligand/regulatory network);
H2-secondary, H4-secondary, and H4-communication (all Exploratory or Negative-finding) — their
full, unabridged treatment is Section 2 and their own module READMEs, not this figure.

---

## 4. The CXCL8-CXCR1/2 question (strictly retrospective)

This project's central question was written, and its discovery/confirmatory panels were
constructed, without ever naming CXCL8, CXCR1, or CXCR2 — maintained across five completed
hypothesis modules (H1-H5) plus Module 08 specifically to prevent priming discovery toward a
pre-chosen, clinically fashionable answer (SX-682 and BMS-986253, both CXCL8-CXCR1/2-axis
therapies, are in active melanoma trials, see `01_background`).

Per the pre-registered procedure (`CONTINUATION_BRIEF.md` SS11), this is now checked once,
post hoc, by inspecting only already-committed tables — not a new discovery search:

- `results/h1_discovery_screen_ranked.csv` (35 detected genes out of H1's 327-gene panel):
  **CXCL8, CXCR1, CXCR2 do not appear.**
- `results/h4_tf_activity_ranked.csv` (754 scored TFs): **CXCL8, CXCR1, CXCR2 do not appear**
  (none of the three is annotated as a transcription factor in CollecTRI in the first place,
  so their absence here reflects the TF-activity method's scope, not a tested-and-negative
  result).
- `results/h5c_literature_concordance.csv` (H1's panel/hits vs. Wang 2025/Guo 2025 marker
  sets): **CXCL8, CXCR1, CXCR2 do not appear** in the overlap genes of either comparison.

**This is reported strictly as a post-hoc observation about what this project's own analyses
surfaced, not as evidence for or against the CXCL8-CXCR1/2 axis's biological role in melanoma
ICB resistance, and not as commentary on the ongoing clinical trials.** CXCL8 was not part of
H1's GO-sourced secreted-factor panel by construction (it is annotated as a chemokine but the
panel's detection filter — TPM>1 in >=20% of patients — is what actually determines inclusion in
the *scored* 35, and CXCL8 did not clear that pre-specified bar in this cohort); CXCR1/CXCR2 are
receptors, outside a secreted-factor screen's scope by design; none of the three is a
transcription factor, so H4's TF-centric method could never surface them regardless of their
true activity. **The correct reading is narrow: this axis did not emerge from this project's
specific discovery and confirmatory analyses, which had specific, pre-declared scope
limitations of their own — this says nothing about whether the axis is biologically present or
absent in melanoma ICB resistance more broadly.**

---

## 5. Limitations (rollup, not repetition)

Each item below is stated once here for a whole-project view; full detail remains in its
originating module's own Limitations section.

- **Cohort and confound structure.** All of H1/H2/H4 share the same 19-patient GSE120575
  cohort and its therapy-type confound (anti-PD-1 monotherapy skews non-responder; anti-CTLA4+
  PD-1 combination skews responder), not adjustable at this sample size. This confound is
  structural to the discovery cohort, not specific to any one module.
- **External replication.** H5a/H5b's Negative findings are concentrated specifically in
  GSE91061 (the smaller-responder-group, differently-therapy-composed cohort) across two
  independent confirmatory tests — a real, reproducible pattern, reported factually (Section
  2.4), not explained away.
- **H3 omission.** Single-cell neutrophil-state biology could not be assessed in either public
  dataset used (H0, Strong) — this is a data-availability limitation of the specific public
  cohorts analysed, not evidence about neutrophil states in melanoma generally.
- **Indirect regulatory inference.** H4's TF-activity scores are inferred from expression via
  CollecTRI/decoupleR, not measured directly (e.g. by ChIP/CUT&RUN/ATAC) — `08_experimental_
  translation` proposes exactly this direct-occupancy validation.
- **Literature-concordance ceiling.** H5c's set-overlap test is capped at Exploratory a priori
  regardless of its p-values, per its own pre-registration — a significant overlap does not
  constitute independent validation.
- **Scope of the CXCL8-CXCR1/2 check (Section 4).** A negative result in three specific,
  differently-scoped tables (a secreted-factor screen, a TF-activity ranking, and two marker-set
  overlaps) does not constitute a test of the CXCL8-CXCR1/2 axis's biological role — no such
  targeted test was run in this project, by design.

---

## 6. Conclusion

This module adds no new computational result and no new evidence-ledger row. It integrates
H0-H5's already-graded findings into one evidence-weighted narrative (Section 2), renders that
structure as a single traceable figure (Section 3, Figure 6), answers the pre-registered
CXCL8-CXCR1/2 question exactly as scoped (Section 4), and consolidates the project's stated
limitations (Section 5). With this module complete, all nine planned modules
(`01_background` through `09_synthesis`) are finished; the only remaining step per
`CONTINUATION_BRIEF.md` SS8 is a final whole-project consistency audit.
