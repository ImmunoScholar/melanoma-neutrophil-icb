# Regulatory Coherence of the Recruitment Programme (H4)

**Status: primary analysis complete. This README covers the primary (patient-level
TF-activity) result only.** The ligand-receptor communication analysis (H4's second
component) and the pre-specified secondary compartment-level TF-activity follow-up are not
yet run — see `CONTINUATION_BRIEF.md` §8 and `CHANGELOG.md`'s pre-registration entry.

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
- **This module's two components are not both complete.** The ligand-receptor communication
  analysis (testing convergence on T-cell suppression, the second half of H4's hypothesis) has
  not yet been run — this README and evidence-ledger entry cover the TF-activity result only.

## Conclusion

**Evidence grade: Moderate.** Patient-level statistics and multiple-testing correction are
satisfied; the module-clustering characterization adds honest specificity (Meff≈31, not 56)
rather than inflating the finding; one hit cluster (IKZF3/BACH2/SATB2) is concordant with
independently published lymphocyte-differentiation biology, stated as plausibility, not
validation. Capped at Moderate rather than Strong for the same reason as H1/H2: no
cross-dataset replication of its own, and TF activity here is inferred rather than directly
measured. The recruitment programme is regulatorily coherent in the sense tested here — a
small number of correlated, plausible regulatory programs, not undirected noise — but this is
one component of H4, not the whole hypothesis; the communication-network component remains to
be run.
