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
| Hardware | 6 cores, 10 GB RAM available to WSL2 |

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
- **GSE120575's TPM matrix cannot be loaded with `data.table::fread()` or base `readLines`/
  `gzfile`.** Decompressed size is 4.5 GB, which exceeds R's ~2.1 GB (2^31-1 byte) limit on a
  single character string/vector element — both `fread` and base R's gzip-connection reading
  hit this ceiling and fail with `R character strings are limited to 2^31-1 bytes`. Ruled out
  CR-only line endings as a cause (verified directly: standard `\n` throughout; lines are just
  genuinely long because the matrix is 16,291 columns wide). Fix: `readr::read_tsv()`, which
  streams/memory-maps rather than materialising the file as one contiguous string. Any script
  in this repository reading this specific file must use `readr::read_tsv()`, not `fread()`.
- **`vroom`/`readr`'s default 128 KB (`VROOM_CONNECTION_SIZE`) line buffer is too small for
  GSE72056's TPM matrix.** `read_tsv()` fails with "The size of the connection buffer (131072)
  was not large enough to fit a complete line" — fixed by `Sys.setenv(VROOM_CONNECTION_SIZE =
  "10000000")` before the read call. This is a different limitation from GSE120575's 2GB-string
  issue (different file, different failure mode) — do not conflate the two fixes.
- **Absolute TPM thresholds are not comparable across independently-processed public
  datasets.** The same `TPM > 1` threshold, applied to the same three genes (CEACAM8, MPO,
  ELANE), gave individual positivity rates of 0.1–0.4% in GSE120575 (2018, TPM values) versus
  45.9% in GSE72056 (2016, `log2(TPM/10+1)` back-transformed to TPM-equivalent) — a roughly
  100x difference in baseline "signal," most likely reflecting differences in RSEM/quantification
  pipeline and normalization era rather than biology. Any comparison across independently
  processed public datasets in this project uses relative/rank-based or orthogonal-annotation
  checks, not shared absolute thresholds — see `02_dataset_audit/README.md` for how this was
  handled (cell-type cross-reference instead of a chance-level statistical test for GSE72056).

## Random seeds

(pending — every stochastic step, e.g. UMAP, permutation tests, will set and record an explicit
seed at the point it is introduced)

## Datasets

| Accession | Study | Role | Verified | Files retrieved |
|---|---|---|---|---|
| GSE120575 | Sade-Feldman et al. | Primary discovery (scRNA-seq, ICB responder/non-responder, paired pre/post) | 2026-08-01 | Downloaded and checksummed — see `data/raw/GSE120575/download_manifest.csv` (TPM matrix, 126,721,504 bytes, MD5 `8bb26ab1e694c1396de3751695fa90e8`; patient/cell metadata, 83,035 bytes, MD5 `1b2788e594d9ee3ebf24b419a7fec295`). Loaded and verified: 55,738 genes x 16,291 cells; metadata 16,291 rows; join key (TPM column names vs metadata `title` field) matches exactly, 0 mismatches either direction. |
| GSE72056 | Tirosh et al. | H0 replication check only — independent CD45+-sorted, Smart-seq2 melanoma cohort | 2026-08-01 | Downloaded and checksummed — see `data/raw/GSE72056/download_manifest.csv` (75,031,245 bytes, MD5 `9c05cb22103d01d3086a2a952e97e96b`). Loaded and verified: 23,686 genes x 4,645 cells (metadata rows `tumor`/`malignant`/`non-malignant cell type` separated from gene rows by pattern match, not fixed line indices). H0 replicated — see `02_dataset_audit/README.md`. |
| GSE78220 | Hugo et al. | Bulk validation (anti-PD-1, pre-treatment) | 2026-08-01 | Not yet downloaded |
| GSE91061 | Riaz et al. | Bulk validation (anti-CTLA4/anti-PD-1, paired) | 2026-08-01 | Not yet downloaded |

**Scope decision, 2026-08-01:** GSE115978 dropped from the dataset table. It appeared in an
earlier design pass but was never assigned a role in the locked Analysis order or any
hypothesis module, and offers no marginal value beyond GSE72056 for the one purpose it could
have served (H0 replication) — replicating a finding across a second AND third independent
dataset doesn't move the evidence grade past "Strong" (≥2 datasets), so it would cost download/
parse time against the one-week budget for zero additional rigor. Rule applied per project
owner's instruction: pursue additional datasets only where they demonstrably strengthen the
project, not for completeness.

GSE120575's metadata file (`GSE120575_patient_ID_single_cells.txt.gz`) is a GEO submission
template with two structural quirks, both handled in the parsing script rather than assumed
away: (1) lines 1–19 are boilerplate/instructions, the real column header ("Sample name...")
is on line 20 — located by content match, not a hardcoded line number; (2) after the real
16,291-row sample table, the same file continues with a shared-protocol section (partly
non-UTF-8 encoded) that is NOT per-cell data — the parser bounds the read to stop exactly
where lines stop matching the `^Sample [0-9]+\t` pattern. The `title` column (e.g.
`A10_P3_M11`) matches the TPM matrix's column names exactly — this is the join key between
expression and metadata.

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

| Step | Wall time | Hardware |
|---|---|---|
| GSE120575 TPM matrix decompression (gunzip, one-time, cached thereafter) | 20.1 sec | 6 cores, 10 GB RAM (WSL2) |
| GSE120575 TPM matrix load (`readr::read_tsv`, 55,738 x 16,291) | 2159.5 sec (~36 min) | 6 cores, 10 GB RAM (WSL2) |

The 36-minute load is a real, substantial cost. Every subsequent script that needs this matrix
caches the parsed object to `data/processed/GSE120575/` as `.rds` after first load, so this
cost is paid once, not once per module.

## Figure regeneration

(pending — one command per figure, to be added as each analysis script is written)

## Fresh-clone reproduction

(pending — full sequence: clone → `renv::restore()` → data download script → analysis order
above → figure outputs; to be finalised once package installation is complete)
