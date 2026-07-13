# Abiomix R Open

Public R packages and native genomics tools maintained by
[Abiomix](https://github.com/abiomix).

## Packages

Packages live in `packages/<package>` and use standard R package layouts. The
repository currently includes native-tool interfaces, SIMD and alignment
infrastructure, storage and data-system integrations, and maintained patches to
upstream scientific R packages.

Browse published packages and build status at
[abiomix.r-universe.dev](https://abiomix.r-universe.dev).

## Installation

```r
options(repos = c(
  abiomix = "https://abiomix.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

install.packages("Rminibwa")
```

R-universe also provides platform-specific binaries when available. See the
installation instructions on each package page.

## Development

Build and check an individual package from the repository root:

```sh
R CMD build packages/<package>
R CMD check <package>_<version>.tar.gz
```

Validate the monorepo structure with:

```sh
bash tools/check-repository.sh
```

## Licensing

Each package carries its own license and upstream notices. See
[`LICENSES.md`](LICENSES.md) for the repository-wide inventory.
