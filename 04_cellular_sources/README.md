# Cellular Sources of the Recruitment Programme (H2)

## Hypothesis
Neutrophil-recruiting signalling is compartment-restricted rather than uniformly distributed
across the immune infiltrate — i.e., H1's recruitment programme originates from specific
immune-cell lineages, not equally from all of them.

## Analysis

**Compartments tested.** T cell, B cell, Myeloid, NK — the four with usable patient-level
representation (see `01_h2_sanity_check.R`). Mast, Malignant, and Unassigned were excluded:
Mast is unusable in every patient (0/19 with ≥10 cells), Malignant was already established as
negligible in H0's dataset audit, and Unassigned is not a biological compartment.

**Sample.** Same 19 pre-treatment, response-labeled patients as H1. Patient-level pseudobulk
per compartment (mean TPM per gene, per patient, restricted to that patient's cells in that
compartment); patients with fewer than 10 cells in a given compartment are excluded from that
compartment's pseudobulk only, not from the study. Usable patients per compartment: T cell 19,
NK 16, B cell 11, Myeloid 11.

**Primary test — compartment specificity.** All 35 genes H1 tested (not only its significant
hits — this asks about the recruitment programme generally, not only the response-associated
subset). Kruskal-Wallis per gene across the four compartments' patient-level pseudobulk
(non-parametric: chosen over one-way ANOVA because per-compartment group sizes are modest,
11-19, and normality of pseudobulk means at this scale cannot be assumed). Benjamini-Hochberg
FDR across the 35 genes tested. Dominant compartment reported as the one with the highest
mean pseudobulk expression.

**Secondary test — within-compartment response comparison (exploratory, pre-declared as
such).** Restricted to compartments with adequate per-patient power (T cell, NK, B cell —
Myeloid excluded: only 3 usable responder patients, see `01_h2_sanity_check.R`) and to H1's 9
FDR<0.10 hit genes specifically, since this test follows up on H1's findings rather than
screening broadly. Same `limma` `lmFit`/`eBayes` method as H1, same direction convention
(positive logFC = higher in non-responder). BH-FDR applied globally across all 27 tests
performed (3 compartments x 9 genes), not stratified by compartment.

## Evidence

**Primary test.** 34 of 35 genes show significant compartment restriction (FDR<0.05). The one
exception, RABEP1 (p=0.26), is an intracellular vesicle-trafficking protein rather than a
genuine secreted factor — its lack of restriction is consistent with not really belonging to
this biology, not a contradiction of the hypothesis. Dominant compartments for H1's hits:

| Gene | Dominant compartment | KW p-value |
|---|---|---|
| LTB | B cell | 2.2e-06 |
| CXCL13 | T cell | 6.3e-08 |
| CCL3 | Myeloid | 8.8e-07 |
| TYMP | Myeloid | 8.6e-06 |
| CCL4 | NK | 8.1e-07 |
| CCL4L2 | NK | 8.1e-07 |
| GPI | Myeloid | 2.9e-06 |
| CD320 | NK | 3.9e-04 |
| FAM3C | T cell | 1.7e-02 |

Full results: `results/h2_compartment_specificity.csv`.

**Secondary test.** 7 of 27 tests significant at FDR<0.05: B_cell.TYMP, T_cell.LTB,
T_cell.CCL4, T_cell.CXCL13, B_cell.FAM3C, T_cell.CCL3, T_cell.FAM3C. Notably, the compartment
carrying the significant response-difference is not always the dominant-expression
compartment (CCL4: NK-dominant in magnitude, but its response-difference is significant in T
cells, not NK; LTB: B-cell-dominant, but its response-difference is significant in T cells,
not B cells). One result, B_cell.CCL4L2, is degenerate rather than a genuine null — CCL4L2 is
essentially unexpressed in B cells (0.01 TPM), triggering limma's zero-variance warning;
logFC=0 and P=1.0 exactly reflect that no real comparison was possible, not evidence of no
difference. Full results: `results/h2_within_compartment_response.csv`.

## Interpretation

1. **Statistical change.** Near-universal compartment restriction in the primary test (34/35
   genes); a smaller, more selective set of within-compartment response differences in the
   secondary test (7/27).
2. **Biological process.** The recruitment programme is not one undifferentiated signal — it
   decomposes into at least three distinguishable sources: a myeloid-derived chemotactic axis
   (CCL3, TYMP, GPI), an NK-derived axis (CCL4, CCL4L2, CD320), and a lymphocyte-derived
   organisational axis (LTB from B cells, CXCL13 from T cells). The lymphocyte axis is
   internally divided by response direction (LTB up in responders, CXCL13 down), which
   compartment attribution clarifies but does not fully resolve — both are lymphocyte-derived,
   ruling out a simple myeloid-vs-lymphocyte story, but not explaining the opposite directions.
   The secondary test adds that regulation can be compartment-specific independent of where a
   gene is most abundant (CCL4, LTB): the compartment carrying the clinically-relevant signal
   is not always the compartment producing the most transcript.
3. **Tumour immunology implication.** The myeloid and NK axes (CCL3/TYMP/GPI and
   CCL4/CCL4L2/CD320, all higher in non-responders) are consistent with an
   innate/chemotactic recruitment programme associated with resistance, distinguishable from
   the lymphocyte-organisational axis associated with response. This is a more specific
   picture than H1 alone could support, though it remains a pattern across compartments and
   genes, not a mechanism -- H4 (communication network) is where sender-receiver structure is
   actually tested.
4. **Translational implication.** Not stated yet -- appropriately deferred to H4 and H5, which
   add network context and independent-cohort validation respectively.
5. **Validating experiment.** Deferred to `08_experimental_translation`. Compartment
   attribution of this kind is exactly what multiplex immunofluorescence or flow cytometry
   would be positioned to confirm directly (co-staining ligand with compartment marker),
   noted here rather than acted on prematurely.

## Limitations

Per the Negative Results Policy, both the RABEP1 exception and the degenerate result below are
reported as informative, not omitted.

- **Myeloid excluded from the secondary (response) test entirely** — only 3 usable responder
  patients (see `01_h2_sanity_check.R`). This means CCL3 and TYMP's response-association,
  established in H1's whole-sample analysis, could not be specifically confirmed as
  myeloid-driven at adequate power in this dataset. This is a real gap, not glossed over.
- **B cell sample is small** (n=11 patients) and imbalanced in the opposite direction to
  Myeloid (4 non-responder / 7 responder) -- secondary-test findings involving B cell
  (B_cell.TYMP, B_cell.FAM3C) should be read with that in mind.
- **B_cell.CCL4L2 is a degenerate result** (zero expression, zero variance), not a genuine
  null finding -- excluded from substantive interpretation.
- **No cross-dataset replication available**, same constraint as H1 -- GSE72056 was scoped to
  H0 replication only. External validation remains H5's role.
- **This module inherits H1's therapy-type confound and its uneven robustness across the 4
  hits, not a new or independent limitation.** A post-hoc check (`03_recruitment/README.md`
  addendum #2) found LTB (attributed here to B cell) robust to therapy-adjustment, while
  CCL3 (Myeloid) and CCL4 (NK) are not -- H2's compartment attribution for CCL3/CCL4 is
  therefore built on the less robust half of H1's discovery, stated here rather than assumed
  unaffected.
- **Compartment attribution relies on the original study's (Sade-Feldman et al.) own
  cell-type calls, not independently re-verified in this project.** This is standard practice
  for reusing public single-cell metadata, but it is an inherited assumption, not a tested
  one -- an error in the original T/B/Myeloid/NK annotation would propagate directly into
  this module's dominant-compartment calls.
- **The near-universal significance of the primary test (34/35 genes) is expected, not
  surprising, given that four genuinely distinct immune lineages were compared** -- this
  finding's value is in which compartment dominates for each gene, not in the fact of
  restriction itself, which was likely on priors.

## Conclusion

**Primary compartment-attribution finding: evidence grade Moderate.** Patient-level
statistics and multiple-testing correction are satisfied; dominant-compartment assignments
are concordant with established immunology (macrophage-derived CCL3, NK/T-derived CCL4,
lymphocyte-derived LTB and CXCL13) -- concordance, not independent validation, which remains
H5's objective. Capped at Moderate rather than Strong for the same reason as H1: no
cross-dataset replication of its own.

**Secondary within-compartment response finding: evidence grade Exploratory.** Pre-declared
as exploratory given reduced power (Myeloid excluded entirely; B cell n=11); genuinely
informative (regulation is not always co-located with abundance) but not yet substantial
enough to grade higher, and specifically **not** substantial enough to confirm CCL3/TYMP as
myeloid-driven response markers, which remains an open question this dataset cannot answer at
adequate power.

H2 sharpens H1's finding into distinguishable cellular sources without resolving every
tension it raises (LTB/CXCL13 direction) or confirming every expected source (myeloid's role
in CCL3/TYMP's response-association). Both are carried forward explicitly rather than settled
prematurely.
