# Third-party notices

Qeetrix for iOS bundles or derives from the following works. Each is used under its own licence; the
licence texts are in this repository as listed.

## Fonts (bundled in `Sources/Qeetrix/Resources/Fonts/`)

| Font | Version | Licence | Licence file |
|:--|:--|:--|:--|
| Cal Sans, variable (`CalSansVF.ttf`), used as "Qeet Sans" | v2.011, [calcom/sans](https://github.com/calcom/sans) | SIL Open Font License 1.1 | [`CalSans-OFL.txt`](../Sources/Qeetrix/Resources/Fonts/CalSans-OFL.txt) |
| Fira Code, variable (`FiraCode-VF.ttf`) | 6.2, [tonsky/FiraCode](https://github.com/tonsky/FiraCode) | SIL Open Font License 1.1 | [`FiraCode-OFL.txt`](../Sources/Qeetrix/Resources/Fonts/FiraCode-OFL.txt) |

The font files are bundled unmodified, each beside its licence. The licence files are copied verbatim
from the font projects at those tags. Neither declares a Reserved Font Name.

## Icon artwork (`Sources/Qeetrix/Icons/Generated/`)

The icon path data is converted from the SVG drawings of
[qeetrix-icons](https://github.com/qeetgroup/qeetrix-icons) 1.0.11 (commit `331cd85`):

- the MIT-licensed Qeet Group package;
- its round outlines are [Lucide](https://lucide.dev) 1.52.0, under the ISC License;
- some of those are derived from [Feather](https://github.com/feathericons/feather), under the MIT
  License.

The complete notice, including the Lucide and Feather licences, is reproduced verbatim in
[`Upstream/qeetrix-icons/LICENSE`](../Upstream/qeetrix-icons/LICENSE).

## Design tokens

Token values are generated from [`@qeetrix/ui`](https://www.npmjs.com/package/@qeetrix/ui) 2.1.6, Qeet
Group's own package.
