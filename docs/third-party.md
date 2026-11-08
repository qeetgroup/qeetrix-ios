# Third party

What Qeetrix for iOS bundles, and under which licence. The licence texts ship in the package's resources, in
`Sources/Qeetrix/Resources/`, so an app can show them in its open-source notices.

| Bundled | From | Licence |
|:--|:--|:--|
| Qeet Sans font (the file is Cal Sans 2.011) | `@qeetrix/tokens` 0.0.15, unmodified | SIL Open Font License 1.1 |
| Fira Code font | `@qeetrix/tokens` 0.0.15, unmodified | SIL Open Font License 1.1 |
| 88 icons, as path data | `@qeetrix/icons` 2.1.2, based on [Lucide](https://lucide.dev) | MIT, with Lucide's and Feather's notices |
| The package's own code | This repository | [MIT](../LICENSE) (© 2026 Qeet Group) |

The package has no runtime dependencies. Its test-only dependencies (swift-snapshot-testing and what it brings, MIT and
Apache 2.0) are never linked into the library, and apps don't resolve them; they're reviewed in
`Tools/dependency-allowlist.json`.
