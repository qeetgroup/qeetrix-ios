# Component template

`Scripts/new-component.sh <Family> <Component> --category <docs category> [--slug <web slug>]` renders
these files for a new component, at the paths in
[COMPONENT_CONTRACT.md](../../Documentation/Standards/COMPONENT_CONTRACT.md):

| Template | Becomes |
|:--|:--|
| `Component.swift.template` | `Sources/Qeetrix/Components/<Family>/<Component>/Qeetrix<Component>.swift` |
| `ComponentTests.swift.template` | `Tests/QeetrixTests/Components/<Family>/<Component>Tests.swift` |
| `ComponentSnapshotTests.swift.template` | `Tests/QeetrixSnapshotTests/<Family>/<Component>SnapshotTests.swift` |
| `Component.md.template` | `Sources/Qeetrix/Qeetrix.docc/Components/<Component>.md` |
| `ComponentPage.swift.template` | `Examples/QeetrixShowcase/QeetrixShowcase/Components/<Family>/<Component>Page.swift` |

It also lists the component in the DocC landing page under its category, adds its page to the
showcase catalogue. When `@qeetrix/tokens` has a `component.<family>` group, the source's header names
it: those groups aren't generated, so add a rule to `Scope.swift` before using one.

The scaffold does not build on purpose: the source and the showcase page carry an `#error`, and the
behaviour test records an issue, until the component is implemented.

Placeholders: `{{Family}}`, `{{Component}}`, `{{slug}}` (the web manifest slug), `{{title}}` (sentence
case), `{{name}}` and `{{description}}` (from the manifest), `{{category}}`, `{{pageID}}` (the showcase
`-page` argument) and `{{tokens}}`.
