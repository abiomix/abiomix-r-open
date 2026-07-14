# QUILT 2.0.4.9000

- Establish the Abiomix-maintained public fork and record upstream provenance.
- Preserve upstream behavior pending focused maternal/fetal ploidy and
  incomplete reference-panel changes.
- Resolve `bgzip` and `tabix` checks through the STITCH namespace so exported
  entry points do not depend on STITCH being attached to the search path.
- Resolve process parallelism through the `parallel` namespace instead of a
  transitive STITCH attachment.
- Declare the existing STITCH runtime-helper boundary in the QUILT namespace,
  allowing `QUILT::QUILT()` to run without attaching STITCH globally.
- Resolve msPBWT symbol-distance fallback through the STITCH namespace instead
  of relying on `mspbwt` attaching STITCH globally.
