# Architecture decision records

One file per decision that shapes the package for the long term. A record states the context, the
decision and its consequences. It is not rewritten when things change: a later record supersedes it,
and the old one's status says so.

| # | Decision | Status |
|:--|:--|:--|
| [0001](0001-one-package-one-public-module.md) | One Swift package, one public module | Accepted |
| [0002](0002-tokens-from-the-published-qeetrix-ui-build.md) | Tokens come from the published `@qeetrix/ui` build | Accepted |
| [0003](0003-colour-conversion-per-css-color-4.md) | Colours are converted per CSS Color 4 | Accepted |
| [0004](0004-fonts-are-the-webs-fonts-in-native-format.md) | Fonts are the web's fonts, in native format | Accepted |
| [0005](0005-icons-are-generated-vector-paths.md) | Icons are generated vector paths | Accepted |
| [0006](0006-theming-through-the-swiftui-environment.md) | Theming goes through the SwiftUI environment | Accepted |
| [0007](0007-repository-layout.md) | Repository layout | Accepted |
| [0008](0008-public-api-baseline.md) | The public API has a reviewed baseline | Accepted |
| [0009](0009-visual-regression-testing.md) | Visual regression testing for components | Proposed (Phase 2) |

To add one, copy the shape of an existing record, take the next number, and link it here.
