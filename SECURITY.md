# Security

## Scope

Qeetrix for iOS is a UI library. It makes no network requests, stores no credentials and reads no user
data. The security-relevant parts are:

- **Supply chain.** The upstream artifacts it is built from (tokens, fonts, icon drawings, the
  component manifest) come from three npm packages — `@qeetrix/tokens`, `@qeetrix/icons`,
  `@qeetrix/react` — pinned in `Upstream/pins.json` and locked by sha256 in
  `Upstream/upstream.lock.json`. Each tarball is checked against the npm registry's integrity hash at
  sync time, and each font against the sha256 the tokens package publishes for it. `Scripts/verify.sh` (run
  in CI) fails if any locked file changes, and `Scripts/sync-upstream.sh --check` re-fetches the pinned
  artifacts and compares them.
- **Bundled resources.** Two font files and a provenance record, loaded only from the package bundle.
- **Dependencies.** None at run time.

## Supported versions

The package has no released versions yet. Only `main` is supported.

## Reporting a vulnerability

This repository is private. Report a vulnerability **privately to a repository administrator**. Do not
describe it in an issue or a pull request.

Include:

- what you found and its impact;
- how to reproduce it;
- the commit you tested.

A dedicated security contact for this repository has not been designated yet. Until one is, reports
go to the administrators directly.
