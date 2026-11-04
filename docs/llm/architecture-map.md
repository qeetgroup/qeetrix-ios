# Architecture Map — qeetrix-ios

**Level:** L2 · **Last verified:** 2026-11-04
**Verification scope:** every path below was confirmed to exist.

| Need | Path |
|---|---|
| **The package manifest** | `Package.swift` |
| **The library** | `Sources/Qeetrix/` |
| **The version to release** | `VERSION` |
| **Public API baseline** | `api/Qeetrix.public-api.txt` · accepted breaks: `api/breaking-changes-allowlist.txt` |
| The DocC catalogue | `Sources/Qeetrix/Qeetrix.docc/` |
| Resources: fonts, licence texts, strings, provenance | `Sources/Qeetrix/Resources/` |
| Test-only dependencies, pinned | `Package.resolved` · reviewed in `Tools/dependency-allowlist.json` |

## Inside the library

| Folder | Holds |
|---|---|
| `Tokens/` | Token values; the generated part in `Tokens/Generated/` |
| `Foundations/` | Accessibility, colours, haptics, motion, shadows, sizing, typography |
| `Theme/` | `QeetrixThemeMode`, `QeetrixTheme` and their modifiers |
| `Icons/` | `QeetrixIcon`, `QeetrixIconName`; the drawings in `Icons/Generated/` |
| `Components/<Family>/` | One folder per `@qeetrix/react` family, its components' files directly inside |
| `Internal/` | Shared helpers |

## Tokens, fonts and icons

| Concern | Path |
|---|---|
| **Pinned packages** | `Upstream/pins.json` (versions) · `Upstream/upstream.lock.json` (hashes) |
| Synced inputs | `Upstream/qeetrix-tokens/`, `Upstream/qeetrix-react/`, `Upstream/qeetrix-icons/` |
| The generator | `Tools/QeetrixGen/` (its own Swift package) |
| Generated reports | `docs/tokens.md`, `docs/token-values.json` |

## Tests

| Kind | Path |
|---|---|
| Library tests (Swift Testing; Mac host and Simulator) | `Tests/QeetrixTests/` |
| Snapshot tests (local baselines, never committed) | `Tests/QeetrixSnapshotTests/` |
| The showcase app, its UI tests and the accessibility audit | `Showcase/` |

## Scripts and workflows

| Need | Path |
|---|---|
| Every Mac-host gate | `Scripts/check.sh` |
| Sync, generate, verify tokens | `Scripts/sync-upstream.sh`, `Scripts/generate.sh`, `Scripts/verify.sh` |
| Format, warnings, dependencies, resources | `Scripts/lint.sh`, `Scripts/warnings.sh`, `Scripts/dependencies.sh`, `Scripts/resources.sh` |
| Public API and source compatibility | `Scripts/api-check.sh`, `Scripts/api-compat.sh` |
| DocC | `Scripts/docs.sh` |
| Every release gate, the bill of materials | `Scripts/release-check.sh`, `Scripts/sbom.sh` |
| A simulator for CI | `Scripts/ci-simulator.sh` |
| CI | `.github/workflows/ci.yml` (Build and test; iOS and showcase tests toward `main`) |
| Release | `.github/workflows/version.yml`, `release.yml`, `rollback.yml` |
| Code scanning, updates | `.github/workflows/codeql.yml`, `.github/dependabot.yml` |
| Hosted documentation (Swift Package Index) | `.spi.yml` |
