# STITCH 1.8.5.9000

- Establish the Abiomix-maintained public fork and record upstream provenance.
- Make `rrbgen` an optional enhancement used only when BGEN output is selected;
  normal BGVCF/VCF inference no longer installs an unrelated BGEN dependency,
  while BGEN output enforces the declared `rrbgen >= 0.0.4` minimum.
- Correct bundled SeqLib interval-tree constructor syntax for C++20 compilers
  used by current R releases.
- Resolve fork-based runtime calls through `parallel::mclapply()` so exported
  STITCH helpers also work when the package is namespace-loaded by QUILT.
- Preserve upstream behavior pending focused defined-ploidy and incomplete
  reference-panel changes.
