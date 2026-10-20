# Consumer integration

Phase 7, 2026-10-20. Whether Qeetrix works as an app's dependency, not only inside its own showcase.

## Approach

**An independent app, `Examples/QeetrixConsumer`.** It is its own Xcode project, with:

- an app target and a UI-test target;
- bundle identifier `in.qeet.qeetrix.consumer`;
- iOS 17 deployment target, iPhone and iPad;
- Swift 6, with warnings as errors set in its own target settings.

It depends on the `Qeetrix` library product and imports `Qeetrix` only: no `@testable`, no internal
types, no showcase code. In the repository it refers to the package by path, as the showcase does.

**Installed by version, from Git.** `Scripts/consumer-check.sh <version>` reproduces how an app installs
a release, without touching this repository, its history or its remote:

1. It copies the working tree (tracked and untracked files, nothing ignored) into a throwaway Git
   repository in a temporary directory, commits it, and tags it there.
2. It points a copy of the consumer project at that repository by URL and exact version, replacing the
   path reference.
3. It resolves the package and checks that `Package.resolved` lists Qeetrix alone, at that version.
4. It runs the consumer's UI tests on the simulator.
5. It builds the app in Release for iOS devices, unsigned, and checks the app carries Qeetrix's
   resource bundle with its fonts, licences and metadata.

CI runs the same check on pushes and pull requests (the `consumer` job, as version `0.0.0-ci.1`).

**What this is not.** A tag in a throwaway repository proves that SwiftPM resolves a Qeetrix tag by
version and builds it. It is not a published release: no tag exists on `qeetgroup/qeetrix-ios`, and
installation from GitHub by version hasn't been tested, because there's nothing to install yet.

## Public API exercised

| Scenario | API |
|:--|:--|
| Theme from storage | `@AppStorage("theme")` with `QeetrixThemeMode`, `.qeetrixThemeMode(_:)`, a picker over `QeetrixThemeMode.allCases` |
| Resources | `QeetrixFontRegistry.register()` and its registrations; `QeetrixProvenance.bundled()` |
| Foundations | `QeetrixColor`, `QeetrixTextRole` and `.qeetrixTextStyle(_:)`, `QeetrixSpacing`, `QeetrixIcon` (labelled), `QeetrixCard`, `QeetrixBadge` |
| A form | `QeetrixTextField`, `QeetrixPasswordInput` (new password), `QeetrixSelect` with `QeetrixOption`, `QeetrixCheckbox`, `QeetrixFieldMessage`, `QeetrixFormErrorSummary` with focus, `QeetrixFormActions`, `QeetrixButton`, `QeetrixToast` |
| Presentation | `QeetrixAlertDialog` and `QeetrixDialogAction` (destructive), `.qeetrixSheet(isPresented:)` with `QeetrixSheetContent` |
| A searchable list | `List` and `searchable`, `QeetrixListItem`, `QeetrixSectionHeader`, `QeetrixEmptyState(.noResults)` |
| Navigation | `.qeetrixNavigationBar(background:)` |

## Results

Xcode 27.1, iOS 27.1 iPhone Duo simulator, macOS 26.6.

| Check | Result |
|:--|:--|
| Builds against the package by path, warnings as errors | Pass |
| `Scripts/consumer-check.sh 0.1.0-rc.1`: resolved `qeetrix-ios` exactly `0.1.0-rc.1` from a Git URL | Pass. `Package.resolved` lists `qeetrix-ios` alone: no test-only dependency was fetched |
| Consumer UI tests (8) | 8 passed: fonts and tokens load; form validates then submits; alert and sheet present and dismiss; search filters and shows no results; light and dark from storage; large text grows content; right to left mirrors layout; Apple's accessibility audit passes on all four screens |
| Release build for iOS devices (arm64, unsigned, whole-module optimisation) | Pass. The app carries `Qeetrix_Qeetrix.bundle`: both fonts, three licences, the token provenance (1.5 MB) |
| iPad simulator | **Not run**: the iOS 27.1 runtime here can't create an iPad (`COMPATIBILITY_MATRIX.md`) |
| iOS 17 | **Not run**: no iOS 17 runtime. The consumer and the library compile with an iOS 17 deployment target |

## Defects found and fixed

| Finding | Fix |
|:--|:--|
| The icon artwork's notice wasn't in the resource bundle, so an app shipping the icons didn't carry it (P2, licensing) | The sync now pins it into `Resources/Licenses/`; `IconTests` and the consumer check confirm it reaches the app |
| Forcing `SWIFT_TREAT_WARNINGS_AS_ERRORS` on the `xcodebuild` command line fails once Qeetrix is a remote package: Xcode builds remote packages with warnings suppressed, and the options conflict (consumer guidance) | Documented in DocC's Troubleshooting article; the consumer sets it in its target instead |

What the consumer showed about the API without needing a change:

- `QeetrixFieldMessage.error(_:)` and `QeetrixFormErrorSummary.Item` take localisable text, not a
  `String`: an app passing computed messages writes `.error("\(message)")`. That is deliberate — app text
  is localisable — and the DocC examples show it.

## Qeet ID Auth

The intended first consumer, `qeet-id-auth`, was inspected read-only. It is an **Expo (SDK 57) and React
Native 0.86** app, with no native iOS project in its repository. It can't use a SwiftUI package as it
stands: that would need a native module that hosts SwiftUI views, an architecture decision for that app
outside this phase. **Integration with Qeet ID Auth is therefore unverified, and not applicable to its
current architecture.** No Qeet Group app in the workspace is a native SwiftUI app today.

## Remaining consumer risks

- No real app has shipped with Qeetrix; the harness is representative, not a product.
- iPad and iOS 17 behaviour hasn't been run (`COMPATIBILITY_MATRIX.md`).
- Access to a private repository from app CI hasn't been exercised.
