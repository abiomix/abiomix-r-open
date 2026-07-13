# Abiomix R Open

`abiomix-r-open` is the public package monorepo for generally applicable R and
native genomics infrastructure maintained by Abiomix.

It is intentionally separate from the internal `abiomix-r` scientific/product
monorepo. Code belongs here only when it is useful outside Abiomix products and
can be developed, tested, licensed, and reviewed in public.

## Initial Package Scope

- QUILT2: explicit ploidy, incomplete-reference, allele-state, indel, and
  multiallelic work.
- STITCH: generally applicable defined-ploidy and reference-reader work.
- httpuv: standards-compliant byte-range file serving.
- RBCFTools: the `freeseek/score` liftover plugin and typed liftover entrypoint,
  if those changes are not accepted directly upstream.
- Native-tool packages for GLnexus, SHAPEIT5, GLIMPSE2, and T1K where an R
  package can build and distribute the executable reliably.

No placeholder R packages are published. A package directory is added only
with complete source, upstream/license metadata, tests, and a working build.

## Package Contract

Every directory under `packages/` is an independently installable R package
with a normal `DESCRIPTION`, `NAMESPACE`, `R/`, `tests/`, and `inst/` layout.
Packages that bundle native tools follow the RBCFTools pattern:

1. pin and attribute the complete upstream source;
2. build the executable and/or library during `R CMD INSTALL`;
3. install tools below the package directory;
4. expose version, capability, include/library, and executable-path functions;
5. expose typed R runners with explicit argument vectors and structured results;
6. run without downloading source or solving an environment at runtime;
7. build as Ubuntu binaries through the Abiomix R-universe.

The package boundary distributes a native tool. It must not invent a second
scientific algorithm, hide upstream behavior, or combine unrelated executables
into one oversized package.

### Authorship and funding

Every Abiomix-maintained package includes these entries in `Authors@R`:

```r
person(
  given = "Sounkou Mahamane",
  family = "Toure",
  email = "sounkoutoure@gmail.com",
  role = c("aut", "cre")
)
person(
  given = "Abiomix FZ LLC",
  role = c("cph", "fnd")
)
```

Use `cre` only where Sounkou Mahamane Toure is the package maintainer. Preserve
all upstream authors, contributors, copyright holders, and funders. Abiomix FZ
LLC's `cph` role covers Abiomix-owned contributions; it does not replace or
claim ownership of bundled upstream code.

## Upstream and Licensing

Each imported or patched package must contain:

```text
UPSTREAM.dcf     upstream URL, tag/commit, source hash, import date
UPSTREAM.md      patch purpose, synchronization and upstreaming policy
LICENSE*         exact package and bundled-source licenses/notices
NEWS.md          user-visible Abiomix changes
tests/upstream/  retained upstream tests where applicable
tests/abiomix/   added behavior, conformance, and regression fixtures
```

The repository has no blanket license over package sources. Each package and
bundled upstream component keeps its own declared license. See
[`LICENSES.md`](LICENSES.md).

## Repositories

- Public packages and patches: this repository.
- Public binary registry:
  [`abiomix/abiomix.r-universe.dev`](https://github.com/abiomix/abiomix.r-universe.dev).
- Package installation endpoint: `https://abiomix.r-universe.dev`.
- Internal scientific/product packages: private `abiomix-r` monorepo.

## Repository Check

```bash
bash tools/check-repository.sh
```

Package-specific CI is added with each real package import. Repository checks
do not substitute for `R CMD check`, native sanitizers, or scientific fixtures.
