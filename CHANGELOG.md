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

## 2026-08-01 — Tooling fix (not a scientific deviation)

- `.Rprofile` initially sourced `renv/activate.R` before `renv::init()` had created it, causing
  every `Rscript` invocation (including `renv::init()` itself) to fail. Fixed by letting
  `renv::init()` append its own activation line after `options()` is set.
- Root documentation (`README.md`, `CHANGELOG.md`, `REPRODUCIBILITY.md`) written via a
  Windows-side tool over `\\wsl.localhost\...` was not reliably visible to native WSL processes
  (git repeatedly reported no changes despite confirmed on-disk content). Resolved by writing
  through the Windows scratchpad and copying into the WSL filesystem with `cp`, run from inside
  the WSL session — the same pattern already used for R scripts.
- Core package install (Seurat/Bioconductor stack) surfaced five `error code 22` download
  failures against guessed Bioconductor repository URLs, before `BiocManager` (itself one of
  the packages being installed) existed to resolve the `BioC_mirror` option correctly.
  Investigated against `renv`'s documented Bioconductor resolution mechanism and confirmed via
  `renv.lock` (Bioconductor packages correctly tagged `Bioconductor 3.23` with real pinned
  versions) that this is a harmless, self-resolving bootstrap-ordering warning, not a
  configuration defect. Documented in `REPRODUCIBILITY.md` rather than "fixed" — no working
  configuration was broken.
