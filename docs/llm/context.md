# Repository Context — qeetrix-ios

**Level:** L2 · **Status:** active · **Last verified:** 2026-11-04
**Verification scope:** versions, paths and release state read from `Package.swift`, `VERSION`, the workflows and
GitHub.

## Identity

`Qeetrix` — Qeet Group's design system for SwiftUI: the Qeetrix tokens, light and dark themes, fonts, 1,863 icons and 71
components, as native iOS. One Swift package with one module, iOS 17 or later, Swift 6.4 (Xcode 27.1), **no runtime
dependencies**. Released by Git tag through Swift Package Manager. Public, MIT-licensed.

**Status:** `0.1.0` is released (4 November 2026); `0.2.0` is the next version (`VERSION`).

## Context inheritance

```text
qeet-context (L0)  →  Qeetrix design system  →  @qeetrix/tokens · @qeetrix/react · @qeetrix/icons (the source)
                                              →  qeetrix-android (the Compose sibling)
                                              →  qeetrix-ios (L2 — this document)
```

## What makes this package different

> **Nothing visual is decided here.** Tokens, fonts and icons are generated from the pinned npm packages, and every
> component restates its `@qeetrix/react` counterpart's CSS. A look changes upstream first, then arrives by a pin bump.

- **Generated, never hand-written:** `Upstream/`, every `Generated/` folder, `docs/tokens.md` and
  `docs/token-values.json`. `Scripts/verify.sh` fails on drift.
- **Native first:** components wrap the system controls and presentations, so VoiceOver, Full Keyboard Access and
  AutoFill behave as iOS users expect.
- **The app owns state:** values, selections and presentations come in as bindings. No global state.
- **A stable API:** Swift's source-compatibility check in every CI run on develop. Only a new major version (a new minor
  while 0.x) may break it.

## Key numbers

71 components · 109 colour roles · 18 text roles · 1,863 icons (100 core, 1,763 in QeetrixIconsExtended) · about 650 library tests · 109 showcase UI tests.

## Where to read next

- [architecture-map.md](architecture-map.md): where everything lives
- [boundaries.md](boundaries.md): what this repo owns, and the rules
- [workflows.md](workflows.md): how to do common tasks
- [../quality.md](../quality.md): what is checked, and the known gaps
