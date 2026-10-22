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

All of these must pass; CI runs the same:

```sh
Scripts/check.sh              # generator tests, drift, format, warnings, dependencies, resources,
                              # host tests, public API — stops at the first failure
sim="platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"
xcodebuild test -scheme Qeetrix -destination "$sim"     # unit and snapshot tests on iOS
xcodebuild test -project Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj \
  -scheme QeetrixShowcase -destination "$sim"           # UI tests and the accessibility audit
Scripts/docs.sh               # DocC, warnings as errors
Scripts/api-compat.sh origin/main   # no source-breaking change against main (CI: pull requests)
```

`Scripts/lint.sh --fix` rewrites formatting; `Scripts/api-check.sh --update` accepts an intended API
change, which then needs a CHANGELOG entry. A change `api-compat.sh` reports as breaking needs a
decision record, its lines in `Documentation/API/breaking-changes-allowlist.txt`, and a migration note
in the CHANGELOG (`Documentation/Quality/API_COMPATIBILITY.md`).

A new issue from `AccessibilityAuditUITests` is fixed, not excluded. An exclusion is for an audit that
is wrong about the component; it names the issue narrowly and says why
(`Documentation/Quality/ACCESSIBILITY_REPORT.md`).

## Documentation

- **How to use the API:** the DocC catalogue, `Sources/Qeetrix/Qeetrix.docc`, plus doc comments on every
  public symbol. Concrete examples in the articles and component pages are compiled and rendered by the
  `*DocumentationExamplesTests.swift` files in `Tests/QeetrixTests/Integration`; change both together.
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
  let`s of `Sendable` values. Two caches change after launch, and both are bounded: rendered images,
  main-actor isolated (`QeetrixIconImageCache`, for `Image(qeetrix:)`), and resolved typefaces, behind
  an `OSAllocatedUnfairLock` (`QeetrixResolvedType`).
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

- **Snapshots** (`Tests/QeetrixSnapshotTests`, iOS only) compare component specimens with baselines in
  four configurations (ADR 0009). Baselines live only on your machine — screenshots are never committed
  (ADR 0013): record them with `TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all` on a commit you trust, run the
  snapshots on your change, look at every image that differs, and describe visual changes in the pull
  request.
- **UI tests** (`Examples/QeetrixShowcase/QeetrixShowcaseUITests`, XCTest) drive the showcase: taps,
  typing, toggles, touch-target size and what VoiceOver is given.

## Releases

Releases follow `Documentation/Releases/RELEASE_CHECKLIST.md`. `Scripts/release-check.sh <version>` runs
every gate and keeps the evidence; tagging and publishing are the owner's steps, never automation's.
A change that affects consumers belongs in the CHANGELOG, and a source-breaking one also in the release
notes with its migration (`Documentation/Releases/RELEASE_POLICY.md`). Keep `Examples/QeetrixConsumer`
on the public API only: it is the stand-in for a real app.

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

## Adding a component

Start with the scaffold, then follow
[`Documentation/Standards/COMPONENT_CONTRACT.md`](Documentation/Standards/COMPONENT_CONTRACT.md):

```sh
Scripts/new-component.sh Checkbox Checkbox --category "Forms & inputs" --dry-run   # see what it will do
Scripts/new-component.sh Checkbox Checkbox --category "Forms & inputs"
```

In short:

- **Location.** `Sources/Qeetrix/Components/<Family>/<Component>/`, where `<Family>` is the qeetrix-ui
  family identifier from its `component-map.json` (`Button`, `DropdownMenu`, …). The ui.qeet.in
  categories, such as Actions or Forms & inputs, are for documentation and the showcase, not folders.
- **Tokens.** Semantic tokens by default. Component tokens only where qeetrix-ui defines
  `component.<name>.*` (the scaffold adopts them). Web utility values through `QeetrixWebScale`. Never
  add iOS-only design values.
- **Accessibility.** Hit areas of at least 44 pt (`qeetrixHitArea()`), Dynamic Type up to the
  accessibility sizes, VoiceOver labels and traits, Reduce Motion, and right-to-left layout. Test
  each.
- **The rest of the file set.** Behaviour tests, visual regression tests (ADR 0009), a DocC page and a
  showcase page.
