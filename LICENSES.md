# License And Rights Policy

This monorepo aggregates packages and bundled native projects that may use
different open-source licenses. The root [`LICENSE`](LICENSE) covers
repository-level documentation, templates, CI, and tools. It is not a blanket
license grant over package source.

Every package added under `packages/` must include its authoritative `LICENSE`
or `LICENSE.md`, all licenses/notices required by bundled dependencies, and an
`UPSTREAM.dcf` record. The license declared in that package's `DESCRIPTION` and
included license files governs that package.

No package may rely on the root license or this policy file as a substitute for
its own license.

## Dual-Licensing Model

The public option for Abiomix-owned package code is GPL-2.0-or-later or the
stronger GPL minimum declared by the package. Abiomix FZ LLC may separately
license its own code under commercial terms in a signed agreement. A commercial
license is not granted by this repository; see
[`COMMERCIAL-LICENSE.md`](COMMERCIAL-LICENSE.md).

The alternative commercial path only covers copyrights Abiomix FZ LLC owns or
is authorized to license. It cannot remove upstream obligations. In particular:

| Package | Public package license | Commercial-license boundary |
| --- | --- | --- |
| `RBCFTools` | GPL-3.0-or-later | Abiomix-owned wrapper contributions only; bundled `bcftools`/`htslib` and a combined distribution retain upstream terms. |
| `Rducks` | GPL-3.0-or-later | Abiomix-owned R/native bridge; vendored NNG and Mbed TLS retain their notices and terms. |
| `Rminibwa` | GPL-2.0-or-later | Abiomix-owned R bindings; `minibwa`, `libsais`, QSufSort, and BWT-SW components retain their terms. |
| `Ropendal` | GPL-3.0-or-later | Abiomix-owned R/Rust bridge; Apache OpenDAL and other crates retain their terms. |
| `htmxr` | GPL-2.0-or-later for the Abiomix fork | Upstream `htmxr` remains available under MIT; only Abiomix-owned fork changes can be offered under separate commercial terms. |
| `s7contract` | GPL-3.0-or-later | Abiomix-owned code, subject to confirmation of contribution ownership. |
| `httpuv` | GPL-2.0-or-later | Abiomix-owned range-serving patches only; the combined fork and bundled libraries retain all upstream terms. |
| `STITCH` | GPL-3.0-or-later | Abiomix-owned patches only; the combined STITCH derivative remains GPL-3.0-or-later. |
| `QUILT` | GPL-3.0-or-later | Abiomix-owned patches only; the combined QUILT derivative remains GPL-3.0-or-later. |

The same rule applies to future forks. Abiomix modifications to `QUILT`,
`STITCH`, `httpuv`, or other GPL projects may be licensed separately only to the
extent they are separable Abiomix-owned works; the upstream project and any
combined derivative remain governed by its GPL.
