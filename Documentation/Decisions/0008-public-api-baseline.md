# 0008 — The public API has a reviewed baseline

**Status:** Accepted, 2026-10-18

## Context

Every Qeet Group app will compile against this package, so a renamed or removed public symbol breaks
them. Swift has no compiler-enforced API baseline for a package without a released version to compare
with.

## Decision

- **Baseline.** `Documentation/API/Qeetrix.public-api.txt` lists every public symbol by kind and
  qualified name with argument labels, generated from the compiler's symbol graph. Symbols a type only
  inherits from a protocol are left out.
- **Check.** `Scripts/api-check.sh` fails when the API differs from the baseline, in CI and before
  every pull request.
- **Recording a change.** An intended change is accepted with `Scripts/api-check.sh --update`, noted in
  `CHANGELOG.md`, and reviewed in the pull request.
- **Compile check.** `Tests/QeetrixTests/Integration` uses the public API without `@testable`, so a
  breaking change also stops it compiling.

## Consequences

- Additions are visible and removals are deliberate. Once versions are released, a removal needs a
  major version and a deprecation period first.
- The baseline records names, not types, so it stays stable across compiler versions. Type-level
  changes are caught by the integration test and by review.
