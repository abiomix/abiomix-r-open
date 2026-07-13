# Upstream Record

This package was imported from `RGenomicsETL/RBCFTools` at the commit recorded
in `UPSTREAM.dcf`. The Abiomix fork is the public integration point for packaged
`bcftools`/`htslib` executables and retained plugins, including the
`freeseek/score` liftover work needed by the scientific stack.

The package deliberately has no variant-table or database API. DuckDB readers,
Arrow/Parquet conversion, VEP handling, and analytical extensions belong in
[`Rduckhts`](https://github.com/RGenomicsETL/duckhts/tree/main/r/Rduckhts).

Updates should be imported as reviewed subtree changes. Preserve the upstream
history, GPL-3.0-or-later terms, bundled notices, and tests. Generally useful
fixes should be proposed upstream where practical.
