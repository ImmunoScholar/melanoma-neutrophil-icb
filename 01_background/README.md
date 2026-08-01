# Scientific Background

This module states the current understanding motivating the study and identifies the specific
unresolved question the analysis addresses. It is deliberately narrow: it covers only what is
needed to justify the central question, not the field in general.

*(Structural note: this module does not use the Hypothesis→Analysis→Evidence→Interpretation→
Limitations→Conclusion template that modules `02`–`07` follow. Those headings describe a
hypothesis test; this module states background. See `CHANGELOG.md`.)*

## 1. Immune checkpoint blockade in melanoma: durable benefit for a minority

Anti-CTLA-4 and anti-PD-1 therapy transformed outcomes in advanced melanoma, but a substantial
fraction of patients derive no durable benefit, and resistance mechanisms remain incompletely
defined. Most mechanistic attention has gone to the T-cell compartment — exhaustion programmes,
antigen presentation, interferon signalling — and to the myeloid compartment principally via
macrophages. Neutrophils have received comparatively little single-cell attention in melanoma
despite being the most abundant circulating leukocyte.

## 2. Neutrophils are plastic, and the two-state model is obsolete

Tumour-associated neutrophils (TANs) were long described in a binary anti-tumour ("N1") versus
pro-tumour ("N2") framework. Recent single-cell work has replaced this with multi-state
taxonomies. Wu et al. integrated neutrophil transcriptomes across 17 cancer types and resolved
**ten** distinct states spanning inflammation, angiogenesis and antigen presentation, with the
antigen-presenting programme associating with favourable survival and enhanced anti-PD-1
efficacy in murine models. Subsequent pan-cancer atlases have converged on immunosuppressive
TAN phenotypes linked to immunotherapy resistance — including a CXCR2⁺VNN2⁺ population whose
phenotypic transition tracks with resistance across 21 cancer types, and a CD83⁺ senescent
population associated with poor prognosis across 12.

**What this establishes:** TAN heterogeneity is real, reproducible across cancer types, and
linked to checkpoint therapy outcome.

**What it leaves open:** all three of these resources are pan-cancer. None is melanoma-focused,
and melanoma-specific TAN single-cell literature is close to absent.

## 3. The clinical signal is strong but mechanistically opaque

The neutrophil-to-lymphocyte ratio (NLR) is among the more reproducible clinical predictors of
checkpoint therapy failure. Elevated NLR predicts poorer response and survival in melanoma
specifically, and the association holds pan-cancer in a cohort of 1,714 patients across 16
tumour types, where combining NLR with tumour mutational burden improved prediction beyond
either alone.

**The gap this creates:** NLR is a peripheral blood cell count. It is a robust *marker* with no
established *mechanism* — it is not known which tumour-level programme a high NLR reflects, nor
whether the relevant biology is neutrophil-intrinsic, tumour-intrinsic, or a property of the
recruitment relationship between them. A blood ratio cannot distinguish these.

## 4. Why this study measures the tumour side, not the neutrophils

The obvious approach — profile TAN states directly in melanoma and relate them to checkpoint
response — was tested and found not to be supportable by available public data. Module
`02_dataset_audit` (H0) established, across two independent cohorts, that the CD45⁺-sorted,
Smart-seq2 protocols used by the major public melanoma single-cell datasets deplete neutrophils
to single-digit recoverable cells. This is consistent with independent published
characterisation of neutrophil loss in single-cell workflows, attributable to their ex vivo
fragility, high endogenous RNase content and short half-life. It is a protocol property, not
evidence about the tumours.

This constraint is the reason melanoma-specific TAN single-cell literature is sparse, and it
redirects the question rather than defeating it. **Neutrophil recruitment is initiated by the
tumour microenvironment**, and the cells that issue those signals — malignant, stromal and
other myeloid compartments — are captured well by exactly the protocols that lose neutrophils.
The recruitment programme is therefore measurable in these datasets even though its target
population is not.

This is also where clinical intervention already operates: agents targeting neutrophil-
recruitment signalling are in phase 1/2 trials in combination with anti-PD-1 in melanoma. The
specific axes involved are deliberately **not named here**, so that the discovery screen in
`03_recruitment` remains unbiased; whether the data converge on a clinically targeted axis is
asked post hoc in `09_synthesis`, after the discovery ranking is fixed and committed.

## 5. The unresolved question

Melanomas that fail checkpoint blockade are associated with an elevated systemic neutrophil
signal, but the tumour-level programme underlying that association has not been defined at
cell-state resolution — and cannot be approached from the neutrophil side using available
public melanoma single-cell data.

> **Which tumour-derived neutrophil recruitment and functional signalling programmes distinguish
> immune checkpoint responders from non-responders in human melanoma?**

The study addresses this from the signalling-source side: which programmes are elevated in
resistance (H1), which cellular compartments produce them (H2), whether they form a coherent
regulatory and communication architecture converging on T-cell suppression (H4), and whether
the result generalises to independent cohorts and agrees quantitatively with published TAN
biology (H5).

## References

Pan-cancer TAN state taxonomies:
- Wu et al., *Cell* 2024. [10.1016/j.cell.2024.02.005](https://doi.org/10.1016/j.cell.2024.02.005)
- Guo et al., *Functional & Integrative Genomics* 2025. [10.1007/s10142-025-01706-x](https://doi.org/10.1007/s10142-025-01706-x)
- Wang et al., *Computational and Structural Biotechnology Journal* 2025. [10.1016/j.csbj.2025.10.056](https://doi.org/10.1016/j.csbj.2025.10.056)

Melanoma single-cell context:
- Sade-Feldman et al. 2018, GSE120575 (primary discovery dataset for this study)
- Tirosh et al. 2016, GSE72056 (H0 replication cohort)
- Acral/mucosal melanoma single-cell landscape: [10.1158/1078-0432.CCR-24-3164](https://doi.org/10.1158/1078-0432.CCR-24-3164)

NLR as a clinical predictor: Valero et al., *Nature Communications* 2021 (n=1,714, 16 cancer
types); Guida et al., *Journal of Translational Medicine* 2022 (n=272, melanoma); Foerster et
al., *Cancer Medicine* 2025 (n=141, stage IV melanoma).

Neutrophil loss in single-cell workflows: Brown et al., *Data in Brief* 2024; Denisenko et al.,
*Genome Biology* 2020; Subramanian et al., *Genome Biology* 2021 (ddqc).

Clinical trials targeting neutrophil-recruitment signalling with anti-PD-1 in melanoma:
NCT03161431, NCT03400332, NCT04572451. *(Specific agents and axes are named in
`09_synthesis`, not here — see §4.)*
