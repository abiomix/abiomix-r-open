# License Policy

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
