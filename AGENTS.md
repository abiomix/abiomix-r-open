# Abiomix R Open Agent Guide

## Scope

This is a public monorepo for generally applicable R packages, native-tool
wrappers, and upstreamable patches. Product logic, proprietary curation,
customer configuration, credentials, patient identifiers, and internal
reference data never belong here.

## Package Rules

- Every `packages/<Package>` directory is a complete CRAN-shaped package.
- Preserve upstream copyright, authorship, licenses, notices, and source
  history in `UPSTREAM.dcf` and `UPSTREAM.md`.
- Do not add partial source subsets merely to make a build smaller.
- Keep patches focused, covered by failing fixtures, and suitable for upstream
  review.
- Prefer upstream changes. Keep a public patch only while an acceptable
  upstream release is unavailable.
- Native-tool packages expose version, capability, installed-path, and typed
  invocation APIs. They do not silently download or compile at runtime.
- Do not create analytical facade packages that duplicate an upstream engine.
- Never edit generated Rcpp or Rd files manually; regenerate from source.
- Package-specific license files are mandatory before package source is added.
- Every Abiomix-maintained package `Authors@R` must include Sounkou Mahamane
  Toure as `aut` (and `cre` when he is the maintainer) and Abiomix FZ LLC as
  `cph` and `fnd`.
- Retain every upstream author/copyright/funder entry. Abiomix FZ LLC's `cph`
  attribution covers Abiomix contributions, not upstream source ownership.

## Validation

- Run `bash tools/check-repository.sh` after repository-structure changes.
- Run `R CMD build` and `R CMD check --as-cran` for each changed package.
- Run native unit, sanitizer, thread-determinism, and scientific fixtures where
  the package contains C/C++ or algorithmic changes.
- Test the Ubuntu binary installed from the Abiomix R-universe before release.

## R-universe

The registry is maintained in the separate public
`abiomix/abiomix.r-universe.dev` repository. Add a package to that manifest only
after its source directory is complete and its default branch builds.
