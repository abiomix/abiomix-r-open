# RBCFTools

`RBCFTools` packages pinned `bcftools` and `htslib` command-line tools for R.
It provides executable paths, plugin discovery, deterministic runtime
environment variables, version inspection, and a structured process runner.

It does not expose an in-process VCF/BCF, Arrow, Parquet, DuckDB, DuckLake, or
VEP API. Those capabilities are maintained in
[`Rduckhts`](https://github.com/RGenomicsETL/duckhts/tree/main/r/Rduckhts).

## Install

```r
options(repos = c(
  abiomix = "https://abiomix.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))
install.packages("RBCFTools")
```

## Run

```r
library(RBCFTools)

bcftools_path()
bcftools_version()
bcftools_plugins()

result <- bcftools_run(c("view", "--header-only", "sample.bcf"))
result$status
result$stdout
```

Arguments are passed directly to the executable without shell interpolation.
`rbcftools_run()` sets `HTS_PATH` and `BCFTOOLS_PLUGINS` for the child process.

```r
result <- rbcftools_run("tabix", c("--list-chroms", "sample.vcf.gz"))
```

The packaged plugin set includes the retained `liftover`, `score`, `munge`, and
PGS-related bcftools plugins when supported by the build platform.
