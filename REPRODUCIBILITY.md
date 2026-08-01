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
| Python | (pending — only introduced if a later phase determines it is necessary) |
| git | 2.43.0 |
| Hardware | (pending — CPU/RAM to be recorded at first compute-heavy step) |

## Package management

- R packages managed via `renv`, snapshot type `all` (every package pinned, not just direct
  dependencies).
- CRAN/Bioconductor binaries served from Posit Public Package Manager (P3M), noble binaries,
  configured in the project `.Rprofile`.
- Full package versions: see `renv.lock`.
- Figure rendering uses `ragg::agg_png` and `svglite` exclusively — base `png()`/cairo is not
  pinned by `renv` and is not byte-reproducible across machines.
- **Known harmless warning on first install / fresh clone:** `renv::install()` prints five
  `error downloading ... PACKAGES [error code 22]` lines for Bioconductor repository paths
  before any packages are fetched. Cause: `renv` resolves Bioconductor URLs by calling
  `BiocManager::repositories()`, which reads the `BioC_mirror` option set in `.Rprofile` — but
  `BiocManager` itself is one of the packages this same call installs, so the very first
  repository probe runs before it exists and falls back to a guessed URL that P3M does not
  serve. Once `BiocManager` installs (seconds later, same run), subsequent Bioconductor
  resolution succeeds via the correct mechanism — confirmed by `renv.lock`, which tags every
  Bioconductor package under a distinct `Bioconductor 3.23` source with real pinned versions,
  not a generic CRAN fallback. Expect this warning again on a genuinely fresh clone; it is not
  a sign of a broken `.Rprofile` and requires no action.
- `options(timeout = 600)` set in `.Rprofile` (default is 60s) — needed for the ~120 MB GEO
  supplementary matrices this project downloads; the default caused a genuine mid-transfer
  failure on GSE120575's TPM matrix during Phase 2.
- `getGEOSuppFiles()` (GEOquery 2.80.0) returned `NULL` for GSE120575 for reasons unrelated to
  network access or User-Agent (both verified working independently). Dataset-download scripts
  in this repository fetch files by explicit, GEO-confirmed URL rather than relying on
  GEOquery's remote directory-listing step.

## Random seeds

(pending — every stochastic step, e.g. UMAP, permutation tests, will set and record an explicit
seed at the point it is introduced)

## Datasets

| Accession | Study | Role | Verified | Files retrieved |
|---|---|---|---|---|
| GSE120575 | Sade-Feldman et al. | Primary discovery (scRNA-seq, ICB responder/non-responder, paired pre/post) | 2026-08-01 | Downloaded and checksummed — see `data/raw/GSE120575/download_manifest.csv` (TPM matrix, 126,721,504 bytes, MD5 `8bb26ab1e694c1396de3751695fa90e8`; patient/cell metadata, 83,035 bytes, MD5 `1b2788e594d9ee3ebf24b419a7fec295`) |
| GSE115978 | Jerby-Arnon et al. | Secondary scRNA-seq | 2026-08-01 | Not yet downloaded |
| GSE72056 | Tirosh et al. | Secondary scRNA-seq | 2026-08-01 | Not yet downloaded |
| GSE78220 | Hugo et al. | Bulk validation (anti-PD-1, pre-treatment) | 2026-08-01 | Not yet downloaded |
| GSE91061 | Riaz et al. | Bulk validation (anti-CTLA4/anti-PD-1, paired) | 2026-08-01 | Not yet downloaded |

GSE120575's metadata file (`GSE120575_patient_ID_single_cells.txt.gz`) is a GEO submission
template: lines 1–19 are boilerplate/instructions, the real column header ("Sample name...")
is on line 20, and per-cell rows follow. The `title` column (e.g. `A10_P3_M11`) matches the
TPM matrix's column names exactly — this is the join key between expression and metadata.
Parsing scripts locate the header row by content match, not a hardcoded line number.

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
above → figure outputs; to be finalised once package installation is complete)
