# Contributing

## Prerequisites

- Xcode with a Swift 6 toolchain. Phase 1 was verified with Xcode 27.1 (Swift 6.4); CI pins the same
  version in `.github/workflows/ci.yml`.
- An iOS Simulator runtime (`xcodebuild -downloadPlatform iOS`) for the iOS tests and the showcase.
- Nothing else: no Node, no Ruby, no Python, no third-party Swift packages.

## Local setup

```sh
git clone https://github.com/qeetgroup/qeetrix-ios.git
cd qeetrix-ios
swift test                                   # library tests on the Mac
swift test --package-path Tools/QeetrixGen   # generator tests
Scripts/verify.sh                            # snapshot and generated files are consistent
```

Open `Package.swift` in Xcode to work on the library, or
`Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj` to see it in an app.

## Before you push

All seven must pass; CI runs the same:

```sh
swift test --package-path Tools/QeetrixGen
Scripts/verify.sh
Scripts/lint.sh               # Scripts/lint.sh --fix rewrites
swift test
Scripts/api-check.sh          # --update when an API change is intended
xcodebuild test -scheme Qeetrix -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"
Scripts/docs.sh               # DocC, warnings as errors
```

## Documentation

- **How to use the API:** the DocC catalogue, `Sources/Qeetrix/Qeetrix.docc`, plus doc comments on every
  public symbol. Concrete examples in the articles are compiled and rendered by
  `Tests/QeetrixTests/Integration/DocumentationExamplesTests.swift`; change both together.
- **How the package is built and why:** `ARCHITECTURE.md` and `Documentation/`.

Each fact lives in one place. Link to it rather than copying it.

## Conventions

- **Formatting.** swift-format with `.swift-format` (4-space indent, 140 columns), strict. Generated
  files are excluded from lint because `Scripts/verify.sh` holds them to the generator's exact output.
- **Names.** Public types start `Qeetrix`. A token's Swift name is its upstream path in lowerCamelCase,
  generated, never chosen by hand. Modifiers start `qeetrix` (`.qeetrixTextStyle(_:)`).
- **Access control.** Everything is internal unless an app needs it. Storage, per-theme tables, icon
  drawings and logging stay internal. A public API change shows up in `Scripts/api-check.sh`; note it in
  `CHANGELOG.md`.
- **Concurrency.** Swift 6 language mode, strict. No global mutable state. Shared caches are `static
  let`s of `Sendable` values.
- **Comments.** Say why: the token, the platform rule or the upstream fact behind a decision.

## Tests

[Swift Testing](https://developer.apple.com/documentation/testing). Tests check behaviour against
something independent of the code under test:

- the upstream snapshot (token parity);
- the agreed brand values (colour conversion);
- upstream's WCAG pairs (contrast);
- rendered pixels (theme overrides, elevation, icons).

A test that only restates a constant is not a test. Test files mirror `Sources`; anything that must use
only the public API goes in `Tests/QeetrixTests/Integration`, without `@testable`.

## Upstream sync

Tokens, fonts and icons come from upstream and are never edited here.

1. Make the change upstream (qeetrix-ui or qeetrix-icons) and release it.
2. Update `Upstream/pins.json`: the `@qeetrix/ui` version, the qeetrix-icons commit and icon
   list, or a font tag.
3. Run `Scripts/sync-upstream.sh`. It fetches, verifies (npm integrity, and that each TTF's WOFF2
   sibling is byte-identical to the web's), copies, and rewrites `upstream.lock.json`.
4. Run `Scripts/generate.sh`, then read the diff of `Documentation/Foundations/TOKEN_COVERAGE.md` and
   the generated Swift.
5. Run every check above. If public names changed, `Scripts/api-check.sh --update` and note the change
   in `CHANGELOG.md`.

Generation fails, by design, when upstream adds something iOS has no decision for:

- a consumable token group with no rule in
  [`Scope.swift`](Tools/QeetrixGen/Sources/QeetrixGenCore/Tokens/Scope.swift);
- a new theme;
- CSS syntax the evaluator does not know;
- a typography role on a font that is not bundled;
- SVG features outside the supported subset.

Make the decision in the generator, not by editing generated files.

## Recording a decision

A choice that shapes the package for the long term gets a numbered record in
[`Documentation/Decisions/`](Documentation/Decisions/README.md): a new dependency, a new target, a
change to how tokens, fonts or icons arrive, or a testing approach.

## Adding a component (Phase 2 onwards)

Follow [`Documentation/Standards/COMPONENT_CONTRACT.md`](Documentation/Standards/COMPONENT_CONTRACT.md).
In short:

- **Location.** `Sources/Qeetrix/Components/<Family>/<Component>/`, where `<Family>` is the qeetrix-ui
  family identifier from its `component-map.json` (`Button`, `DropdownMenu`, …). The ui.qeet.in
  categories, such as Actions or Forms & inputs, are for documentation and the showcase, not folders.
- **Tokens.** Semantic tokens by default. Generate component tokens with a scope rule only where
  qeetrix-ui defines `component.<name>.*`. Never add iOS-only design values.
- **Accessibility.** Hit areas of at least 44 pt (`qeetrixMinimumTouchTarget()`), Dynamic Type up to
  the accessibility sizes, VoiceOver labels and traits, Reduce Motion, and right-to-left layout. Test
  each.
- **The rest of the file set.** Behaviour tests, visual regression tests (ADR 0009), a DocC page and a
  showcase page.
