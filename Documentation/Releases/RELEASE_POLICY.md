# Release policy

How Qeetrix for iOS is versioned, and what each kind of version promises. How it is installed is in
`DISTRIBUTION.md`; how a release is made is in `RELEASE_CHECKLIST.md`.

## Versions

Releases are Git tags in [Semantic Versioning 2.0.0](https://semver.org) form, `MAJOR.MINOR.PATCH`,
without a `v` prefix — SwiftPM reads them as they are. Pre-releases add `-rc.N` (or `-beta.N`).

There is no release yet. The first candidate is **0.1.0-rc.1**, prepared but not tagged
(`RELEASE_CANDIDATE_REPORT.md`).

## Why 0.x first

The API is reviewed, baselined and checked for compatibility (`Documentation/Quality/API_COMPATIBILITY.md`).
But no app has shipped with it yet, and the first real integration is the test of whether names, defaults
and compositions hold up. Version 0.x leaves room to correct them in the open, with notice, instead of
freezing them before they've been used.

**What 0.x promises:**

| Change | Allowed in | With |
|:--|:--|:--|
| A fix that changes no public API | `0.MINOR.PATCH` | A CHANGELOG entry |
| An addition (new type, initialiser, member, defaulted parameter) | `0.MINOR.0` | A CHANGELOG entry |
| A source-breaking change | `0.MINOR.0` only, never a patch | A decision record; its lines in `Documentation/API/breaking-changes-allowlist.txt`; a migration note in the CHANGELOG and the release notes; one minor release of deprecation first wherever the old form can be kept |

So within a `0.MINOR` series, updates never break source: apps depend with `.upToNextMinor(from:)`.

**1.0.0** is tagged once at least one Qeet Group app has shipped with Qeetrix through a full release
cycle, and the gates `RELEASE_CHECKLIST.md` marks as owner-run — iOS 17, iPad, device accessibility —
have passed. From then on standard SemVer applies.

## From 1.0

- **Major:** source-breaking changes, each with a decision record and migration notes, after a
  deprecation period of at least one minor release wherever a deprecated form can be kept.
- **Minor:** additions and deprecations.
- **Patch:** fixes, including security and accessibility fixes, with no API change.

## Release candidates

- A minor or major release is preceded by at least one `-rc.N` tag, cut from the commit to be released,
  after `Scripts/release-check.sh` has run and its evidence has been reviewed.
- An RC with a defect is never moved or retagged: the fix becomes `-rc.N+1`.
- The final tag goes on the same commit as the last RC, unchanged.

## Deprecation

A symbol to be removed is marked first:

```swift
@available(*, deprecated, renamed: "newName(_:)", message: "Removed in 0.3.0. See CHANGELOG.")
```

It stays for at least one minor release. Its removal is a source break (above).

## What counts as public API

Everything in `Documentation/API/Qeetrix.public-api.txt`: names, signatures, default values, enum
cases and documented behaviour. Not covered: internal types, the generated token and icon tables, the
exact pixels a component draws (they follow upstream design changes), and the snapshot and showcase
apps. Design changes from upstream `@qeetrix/ui` arrive in minor releases and are listed in the release
notes.

Only source compatibility is promised, not binary compatibility: the package is built from source.

## Fixes

- **Security:** report privately (`.github/SECURITY.md`). The fix ships as a patch on the latest minor
  series; an older series gets one only when an app on it needs it and the owner agrees.
- **Accessibility:** a defect that stops someone completing a task with VoiceOver, Switch Control,
  Voice Control, Full Keyboard Access or the largest text size is treated as P1: fixed in a patch
  release, with a regression test.
- **Everything else:** in the next minor release, or a patch if an app is blocked.

## Approval

Every tag is created by a person with write access to the repository, after the checklist is complete.
Today that is the repository owner (`.github/CODEOWNERS`). Automation verifies; it never tags, pushes
or publishes.
