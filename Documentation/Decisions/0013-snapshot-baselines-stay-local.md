# 0013 — Snapshot baselines stay local

**Status:** Accepted (Phase 3, 2026-10-18). Amends ADR 0009.

## Context

ADR 0009 committed the snapshot baselines so CI could compare against them. On 2026-10-18 the project
owner decided that screenshots are never pushed to the repository.

## Decision

- Baseline images are ignored by git (`.gitignore`: `Tests/QeetrixSnapshotTests/__Snapshots__/**`, and
  `*.png`, `*.jpg`, `*.jpeg`, `*.heic` everywhere). Only the folder's README is committed.
- Each contributor records baselines on the pinned simulator before comparing — on a commit they trust,
  then again on their change — and looks at every image a change re-records.
- CI builds the snapshot target, so it keeps compiling, but does not run it: it has no baselines to
  compare with.
- `Scripts/resources.sh` accepts a checkout with no baselines; where they have been recorded, it still
  requires every test's four images and no orphans.

Everything else in ADR 0009 stands: the library, the matrix, the recording conditions and the tolerances.

## Consequences

- Visual regression is a local gate, not a CI gate. A change that alters the look is caught only when its
  author, or a reviewer, runs the snapshots against baselines recorded before the change.
- Reviewers cannot see image diffs in pull requests; a pull request that changes the look should say so,
  and reviewers run the snapshots themselves.
