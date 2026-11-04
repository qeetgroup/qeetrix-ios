# 🧭 Decisions

The architecture decisions behind Qeetrix for iOS, as they stand today. The full records, with the alternatives
weighed, are in the git history (`git log -- Documentation/Decisions`).

| # | Decision | In short |
|:--|:--|:--|
| 0001 | **One Swift package, one public module** | `Qeetrix` is the only library product. Splitting it later would change module names and imports, so it needs a real reason. |
| 0002 | ~~Tokens from `@qeetrix/ui`~~ | Replaced by 0018. |
| 0003 | **Colours per CSS Color 4** | OKLCH converted with the CSS Color 4 matrices, as qeetrix-android does: sRGB when it fits, Display P3 otherwise. |
| 0004 | **The web's fonts, in native format** | Qeet Sans and Fira Code: the TrueType files `@qeetrix/tokens` publishes, unmodified, registered from the package bundle. |
| 0005 | **Icons are generated vector paths** | The pinned SVGs become SwiftUI paths at generation time, tinted with the foreground style and mirrored in right to left by meaning. |
| 0006 | **Theming through the SwiftUI environment** | `.qeetrixThemeMode(_:)` sets light, dark or system; colours resolve from the environment's colour scheme. No global state. |
| 0007 | **Repository layout** | The library in `Sources/Qeetrix/`, with one folder per `@qeetrix/react` family in `Components/`; tests in `Tests/`, the generator in `Tools/`, pinned inputs in `Upstream/`, the showcase in `Showcase/`, docs in `docs/`. |
| 0008 | **The public API has a reviewed baseline** | `api/Qeetrix.public-api.txt`, checked on every build; `swift package diagnose-api-breaking-changes` blocks source-breaking changes unless `api/breaking-changes-allowlist.txt` accepts them. |
| 0009 | **Visual regression testing** | swift-snapshot-testing, a test-only dependency apps never resolve: every component in light, dark, the largest text size and right to left. |
| 0010 | **Component API conventions** | `Qeetrix<Component>` with the web's variant, tone and size names; SwiftUI styles where a style protocol exists; the app owns state through bindings. |
| 0011 | **Component tokens and web metrics** | Component tokens are adopted per group; every other size comes from the family's CSS, restated with the CSS beside it. |
| 0012 | **Form components** | One shared field (label, control, description, error) around the system input; the app owns values and validation. |
| 0013 | **Snapshot baselines stay local** | Recorded and compared on a maintainer's machine, never committed (the owner's choice). |
| 0014 | **Navigation, overlays and feedback** | The system's presentations (`.alert`, `.confirmationDialog`, `.sheet`, `.popover`, `Menu`), driven by a binding the app owns. No router or presentation manager. |
| 0015 | **Data display and content states** | Qeetrix presents, the app owns the data; rows and states go inside SwiftUI's own `List` and `Section`. |
| 0016 | **Icon names are an open set** | `QeetrixIconName` is a struct, not an enum, so a new icon is not a breaking change; apps switch over it with a `default` case. |
| 0017 | **Releases: a source package, SemVer from 0.1** | Released by Git tag (`X.Y.Z`, Swift's convention), on merge to `main` after approval ([releases.md](releases.md)). Before 1.0, a minor may break source. |
| 0018 | **Built from `@qeetrix/react`, `@qeetrix/tokens` and `@qeetrix/icons`** | The three npm packages, pinned and integrity-checked; tokens generated from the DTCG build; every component re-specified to its `@qeetrix/react` counterpart. |
