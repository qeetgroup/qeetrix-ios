# 0017 — Releases: a source package, SemVer from 0.1

**Status:** Accepted for the first candidate (Phase 7, 2026-10-20). Builds on ADRs 0001 and 0008; tagging
any release remains the owner's decision.

## Context

Qeetrix for iOS had no release: apps could only depend on a branch. Phase 7 prepares the first one.
Choices to make:

- **How the package is distributed:** source or binary; which repository and channel.
- **How it is versioned:** what the first version says about stability.
- **What a release promises:** what versions mean, and how releases are verified and approved.

Facts that shape them:

- The package is one source library with resources (ADR 0001).
- Its API is baselined and checked for source compatibility (ADR 0008, `Scripts/api-compat.sh`).
- No app has shipped with it, and its intended first consumer, Qeet ID Auth, is a React Native app that
  can't use it as it stands.

## Decision

1. **Source-based Swift package from the private repository**, tagged with SemVer versions without a
   prefix. No binary framework, CocoaPods, Carthage or registry. A binary is reconsidered only if a
   consumer outside Qeet Group needs the library without its sources.
2. **The first version is 0.1.0, after release candidates `0.1.0-rc.N`.**
   - Before 1.0, a minor version may break source: always with a decision record, an allowlist entry and
     a migration note. A patch never breaks it.
   - Apps depend with `.upToNextMinor(from:)`.
   - 1.0 follows the first app release built on Qeetrix, and the iOS 17, iPad and device checks.
3. **Verification is automated; publication is not.**
   - `Scripts/release-check.sh` runs every gate and keeps the evidence, locally or in the hand-run
     "Release candidate verification" workflow. That workflow has read-only permissions, no
     credentials and no publishing step.
   - A tag is created by the owner after reviewing that evidence (`RELEASE_CHECKLIST.md`).
   - Tags are never moved: a bad release is rolled forward (`ROLLBACK_PROCEDURE.md`).
4. **Consumption is tested as a consumer.**
   - An independent app, `Examples/QeetrixConsumer`, uses the public API only.
   - `Scripts/consumer-check.sh` installs the package into it by URL and version, from a throwaway
     repository tagged in a temporary directory.
5. **Each release has a bill of materials**: CycloneDX, generated from the pins, the lock and
   `Package.resolved` by `Scripts/sbom.sh`. Each pinned upstream records its reviewed licence in
   `Upstream/pins.json`.

## Consequences

- Apps install with Xcode or SwiftPM alone, with read access to the repository.
- 0.x gives room to correct the API after first real use. The cost is that apps must use
  `.upToNextMinor`; the documentation and the release notes say so.
- A release can't happen by accident: no workflow can tag or push.
- The consumer check tests resolution by version, but not GitHub access to a private repository. That
  is tested the first time an app's CI installs a real tag.
- Policies: `Documentation/Releases/RELEASE_POLICY.md`, `DISTRIBUTION.md`, `SUPPORT_POLICY.md`.
