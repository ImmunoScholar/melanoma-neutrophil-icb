# Reproducibility

This document records everything needed to reproduce every figure and table in this repository
from a fresh clone. It is populated incrementally as the project proceeds; sections marked
`(pending)` will be filled during the corresponding implementation phase. Runtimes are measured
on the machine that produced them, never estimated.

## System

| Component | Value |
|---|---|
| OS | Ubuntu 24.04.4 LTS (via WSL2, host Windows 11) |
| R | 4.6.1 "Happy Hop" |
| Python | (pending — only introduced if Phase 1 determines it is necessary) |
| git | 2.43.0 |
| Hardware | (pending — CPU/RAM to be recorded at first compute-heavy step) |

## Package management

- R packages managed via `renv`, snapshot type `all` (every package pinned, not just direct
  dependencies).
- CRAN/Bioconductor binaries served from Posit Public Package Manager (P3M), noble binaries,
  configured in the project `.Rprofile`.
- Full package versions: see `renv.lock` (created in Phase 1, Step 2).
- Figure rendering uses `ragg::agg_png` and `svglite` exclusively — base `png()`/cairo is not
  pinned by `renv` and is not byte-reproducible across machines.

## Random seeds

(pending — every stochastic step, e.g. UMAP, permutation tests, will set and record an explicit
seed at the point it is introduced)

## Datasets

| Accession | Study | Role | Verified |
|---|---|---|---|
| GSE120575 | Sade-Feldman et al. | Primary discovery (scRNA-seq, ICB responder/non-responder, paired pre/post) | 2026-08-01 |
| GSE115978 | Jerby-Arnon et al. | Secondary scRNA-seq | 2026-08-01 |
| GSE72056 | Tirosh et al. | Secondary scRNA-seq | 2026-08-01 |
| GSE78220 | Hugo et al. | Bulk validation (anti-PD-1, pre-treatment) | 2026-08-01 |
| GSE91061 | Riaz et al. | Bulk validation (anti-CTLA4/anti-PD-1, paired) | 2026-08-01 |

Dataset versions (GEO series matrix release dates, checksums where available) to be recorded in
`02_dataset_audit` at download time.

## Analysis order

1. `02_dataset_audit`
2. `03_recruitment`
3. `04_cellular_sources`
4. `05_neutrophil_states` (conditional)
5. `06_regulation_communication`
6. `07_validation_concordance`
7. `08_experimental_translation` (no computation — synthesis of findings above)
8. `09_synthesis`

## Runtime

(pending — recorded per module as it is run, with hardware spec)

## Figure regeneration

(pending — one command per figure, to be added as each analysis script is written)

## Fresh-clone reproduction

(pending — full sequence: clone → `renv::restore()` → data download script → analysis order
above → figure outputs; to be finalised once Phase 1 environment setup is complete)
