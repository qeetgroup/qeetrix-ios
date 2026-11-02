# Third-party notices

Qeetrix for iOS bundles or derives from the following works. Each is used under its own licence; the
licence texts are in this repository as listed.

## Fonts (bundled in `Sources/Qeetrix/Resources/Fonts/`)

| Font | Version | Licence | Licence file |
|:--|:--|:--|:--|
| Cal Sans, variable (`QeetSans.ttf`), used as "Qeet Sans" | v2.011, [calcom/sans](https://github.com/calcom/sans) | SIL Open Font License 1.1 | [`QeetSans-OFL.txt`](../Sources/Qeetrix/Resources/Fonts/QeetSans-OFL.txt) |
| Fira Code, variable (`FiraCode-VF.ttf`) | 6.2, [tonsky/FiraCode](https://github.com/tonsky/FiraCode) | SIL Open Font License 1.1 | [`FiraCode-OFL.txt`](../Sources/Qeetrix/Resources/Fonts/FiraCode-OFL.txt) |

Both files are the TrueType fonts [`@qeetrix/tokens`](https://www.npmjs.com/package/@qeetrix/tokens)
0.0.13 ships for native platforms (`dist/fonts/`, made losslessly from the package's WOFF2 files with
fontTools 4.68.0), bundled unmodified, each beside the licence file the package ships with it. Neither
licence declares a Reserved Font Name.

## Icon artwork (`Sources/Qeetrix/Icons/Generated/`)

The icon path data is converted from the SVG files of
[`@qeetrix/icons`](https://www.npmjs.com/package/@qeetrix/icons) 2.1.0 (gitHead `e2a8f9f`):

- the MIT-licensed Qeet Group package;
- its round outlines are [Lucide](https://lucide.dev) 1.52.0, under the ISC License;
- some of those are derived from [Feather](https://github.com/feathericons/feather), under the MIT
  License.

The complete notice, including the Lucide and Feather licences, is reproduced verbatim in
[`Upstream/qeetrix-icons/LICENSE`](../Upstream/qeetrix-icons/LICENSE).

## Test-only dependencies (not distributed)

Used only by the `QeetrixSnapshotTests` target. They are never linked into the `Qeetrix` library, and an
app that depends on Qeetrix does not resolve them (ADR 0009). Reviewed versions and licences are in
[`Tools/dependency-allowlist.json`](../Tools/dependency-allowlist.json), checked by
`Scripts/dependencies.sh`.

| Package | Version | Licence |
|:--|:--|:--|
| [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) | 1.19.6 | MIT |
| [swift-custom-dump](https://github.com/pointfreeco/swift-custom-dump) | 1.7.3 | MIT |
| [swift-issue-reporting](https://github.com/pointfreeco/swift-issue-reporting) | 2.1.2 | MIT |
| [swift-syntax](https://github.com/swiftlang/swift-syntax) | 604.0.0 | Apache 2.0 with Runtime Library Exception |

## Design tokens

Token values are generated from [`@qeetrix/tokens`](https://www.npmjs.com/package/@qeetrix/tokens)
0.0.13, and component metrics and colours restated from the CSS of
[`@qeetrix/react`](https://www.npmjs.com/package/@qeetrix/react) 0.4.0 — Qeet Group's own packages,
under the MIT License ([`Upstream/qeetrix-tokens/LICENSE`](../Upstream/qeetrix-tokens/LICENSE)).
