# Migrating Qeetrix for iOS to `@qeetrix/react`

Qeetrix for iOS moved from `@qeetrix/ui` 2.1.6 to the `@qeetrix/react` design system on 2026-10-30.
This file maps every old name to its new one and records every decision the move needed. The
decision record is [ADR 0015](Decisions/0015-qeetrix-react-tokens-and-icons-from-npm.md); the Android
library keeps a file of the same name, so the two can be compared.

## Inputs

| | Before | After |
|:--|:--|:--|
| Tokens | `@qeetrix/ui` 2.1.6: `tokens.json`, `tokens.css`, `index.css` (Style Dictionary output) | `@qeetrix/tokens` **0.0.13**: `dist/dtcg/` (resolver, both pre-resolved schemes, every source file) and `tokens.css` |
| Fonts | calcom/sans v2.011 and tonsky/FiraCode 6.2 release TTFs, each proven by its WOFF2 sibling | `@qeetrix/tokens` 0.0.13 (unchanged since 0.0.12) `fonts/QeetSans.ttf` and `fonts/FiraCode-VF.ttf`, checked against `fonts/native.json` (sha256, size, and the source WOFF2) |
| Icons | qeetrix-icons git commit `331cd85` (1.0.11): SVGs and manifest entries | `@qeetrix/icons` **2.1.0** from npm: `dist/svg/<shape>-<variant>/<id>.svg` and the entries of `dist/manifest.json` |
| Components | `@qeetrix/ui` 2.1.6 `component-manifest.json`; component sources read at the pinned commit | `@qeetrix/react` **0.4.0**: `dist/manifest.json` and each implemented family's `dist/css/<family>.css` |
| Fetched from | npm, GitHub releases, raw.githubusercontent.com | npm only, each tarball checked against the registry's integrity hash |

The lock (`Upstream/upstream.lock.json`) now lists three packages (name, version, gitHead,
integrity), the two fonts (package, source file, the WOFF2's sha256, the TTF's sha256, how the package
made it) and the sha256 of every file taken. `Upstream/qeetrix-ui/` and `Upstream/qeetrix-icons/svg/`
are gone; `Upstream/qeetrix-tokens/`, `Upstream/qeetrix-icons/svg/` (now `@qeetrix/icons`' files,
in the layout 1.0.11 had) and `Upstream/qeetrix-react/` replace them.

The migration was done on tokens 0.0.12, icons 2.0.0 and react 0.3.0, then brought to 0.0.13, 2.1.0
and 0.4.0 the same day, before release. What the second step changed is under each heading below and
in [the bump to 0.4.0](#the-bump-to-tokens-0013-icons-210-and-react-040).

| Font | SHA-256 |
|:--|:--|
| `QeetSans.ttf` (from `QeetSans.woff2` `8362505b…db55f1`) | `668e52b011f9273a4c18881b69e5d31086a64c31584412cce7fadba5d28af12b` |
| `FiraCode-VF.ttf` (from `FiraCode-VF.woff2` `408e876a…dd49f`) | `6017720c9794b1c8187af200a1cc2df3a32ddbd097767930ec19f9c7db0c718d` |

The two WOFF2s are byte-identical to the ones `@qeetrix/ui` shipped, so the faces didn't change. The
first pass of this migration (on tokens 0.0.11, which shipped WOFF2 only) converted them with
fontTools 4.68.0 and brotli 1.2.1 in a pinned virtual environment; its output had exactly the hashes
above, the same as the TTFs 0.0.12 now ships, and the conversion was removed (QTRX-91).

## Tokens

Generated from the DTCG build, resolved as `qeetrix.resolver.json` says: the foundation set, then the
colour-scheme context, then the density context, for light/dark × default/comfortable/compact. The
generator must reproduce the package's `light.tokens.json` and `dark.tokens.json` exactly and agree with
`tokens.css`. **194** tokens are generated, **145** excluded with a reason
([TOKEN_COVERAGE.md](Foundations/TOKEN_COVERAGE.md)). Every value is in
[`token-values.json`](Foundations/token-values.json): path, `$type`, Swift name, CSS variable, source
file, alias, what it varies with, and its value in each context (lengths in points, durations in ms,
colours as the package's OKLCH and hex plus the RGB iOS draws).

**Naming rule.** The Swift name is the token path after the group it belongs to, in lowerCamelCase;
a leading digit moves to the end (`size.icon.2xs` → `xs2`); Swift keywords are escaped
(`border.width.default` → `` QeetrixBorderWidth.`default` ``, used as `.default`). Raw values are the
token paths. Density tokens keep their whole path, since they come from three groups.

### Types

| Before | After | Tokens |
|:--|:--|:--|
| `QeetrixColor` (84) | `QeetrixColor` (109) | `color.**` |
| `QeetrixElevation` (14) | `QeetrixShadow` (5) | `shadow.*` |
| `QeetrixTextRole` (9) | `QeetrixTextRole` (18) | `typography.*.*` |
| `QeetrixSpacing` | `QeetrixSpace` | `space.inset.*`, `space.gap.*`, `space.layout.*` |
| `QeetrixCorner` | `QeetrixRadius` | `radius.*` |
| `QeetrixStroke` | `QeetrixBorderWidth` | `border.width.*` |
| `QeetrixFocus` | `QeetrixFocus` | `focus.ring.*` |
| `QeetrixOpacity` | `QeetrixOpacity` | `opacity.*` |
| `QeetrixIconSize`, `QeetrixIconStroke` | the same | `size.icon.*`, `icon.stroke.*` |
| `QeetrixDensity` (`controlHeight`, `rowHeight`, `cellPaddingY`, `fieldGap`) | `QeetrixDensity` (`sizeControlSm`, `sizeControlMd`, `sizeControlLg`, `sizeRow`, `spaceFormGap`) | `size.control.*`, `size.row`, `space.form.gap` |
| `QeetrixDuration`, `QeetrixEasing` | the same | `motion.duration.*`, `motion.easing.*` |
| — | `QeetrixSpring` (new) | `motion.spring.*.*` |
| `QeetrixMotion.reducedDuration`, `.reducedEasing` | `QeetrixMotion.reducedDuration` only | tokens.css `@media (prefers-reduced-motion)` |
| `QeetrixFontWeight` (regular … bold) | `QeetrixFontWeight` (regular, medium, semibold) | `primitive.font.weight.*` |
| `QeetrixFontGeometry` (a11y, ui, base, geo) | `QeetrixFontGeometry` (body, heading, display) | `font.geometry.*` |
| `QeetrixSize` | new: `targetMin` | `size.target.*` |
| — | `QeetrixControlSize` (hand-written: sm, md, lg) | the control-height scale |
| `.qeetrixElevation(_:fill:in:)` | `.qeetrixShadow(_:fill:in:)` | |

### Colours

| Before | After |
|:--|:--|
| `textPrimary` | `textDefault` |
| `textSecondary` | `textSubtle` |
| `textTertiary` | `textSubtlest` (descriptions now use `textSubtle`) |
| `textPlaceholder` | `textSubtlest` |
| `textDisabled`, `textInverse`, `textBrand`, `textLink`, `textLinkHover`, `textSuccess`, `textWarning`, `textDanger`, `textInfo`, `textOnBrand` | the same names |
| `textBrandDisplay` | `textBrand` |
| `textOnSubtle` | `textDefault` |
| `textOnFeedback`, `textOnFeedbackStrong` | `textOnBold` |
| `textOnWarningStrong` | `textOnWarning` |
| `surfaceCanvas`, `surfaceDefault`, `surfaceOverlay`, `surfaceSunken`, `surfaceInverse` | the same names |
| `surfaceElevated` | `surfaceRaised` |
| `surfaceSubtle`, `surfaceInteractive` | `bgNeutralSubtle` |
| `surfaceInteractiveHover`, `surfaceInteractiveActive` | `bgNeutralSubtleHover`, `bgNeutralSubtlePressed` |
| `surfaceBrandSubtle`, `-Hover`, `-Active` | `bgBrandSubtle`, `bgBrandSubtleHover`, `bgBrandSubtlePressed` |
| `surfaceRail` | — (`surfaceSunken`) |
| `borderDefault`, `borderSubtle`, `borderStrong`, `borderBrand`, `borderDanger`, `borderSuccess`, `borderWarning`, `borderInfo` | the same names |
| `borderControl`, `borderControlHover`, `borderHover` | `borderStrong`, `borderStrongHover`, `borderStrongHover` |
| `borderFocused`, `focusRing` | `borderFocus` |
| `actionPrimary`, `-Hover`, `-Active` | `bgBrandBold`, `bgBrandBoldHover`, `bgBrandBoldPressed` |
| `feedbackSuccess`, `feedbackWarning`, `feedbackError`, `feedbackInfo` | `bgSuccessBold`, `bgWarningBold`, `bgDangerBold`, `bgInfoBold` (edges and icons: `iconSuccess`, `iconWarning`, `iconDanger`, `iconInfo`) |
| `feedbackSuccessSubtle`, `…Warning…`, `…Error…`, `…Info…` | `bgSuccessSubtle`, `bgWarningSubtle`, `bgDangerSubtle`, `bgInfoSubtle` |
| `feedbackSuccessStrong`, `…Warning…`, `…Error…`, `…Info…` | `bgSuccessBold`, `bgWarningBold`, `bgDangerBoldHover`, `bgInfoBold` |
| `overlayScrim` | `overlayScrim` |
| `selectionBackground` | `selection` |
| `ratingFilled` | `iconHighlight` |
| `syntaxKey`, `syntaxString`, `syntaxNumber`, `syntaxLiteral`, `syntaxPunctuation`, `syntaxComment` | `codeKeyword`, `codeString`, `codeNumber`, `codeLiteral`, `codePunctuation`, `codeComment` |
| `dataCategorical1` … `8`, `dataGrid`, `dataAxis`, `dataReference`, `dataPositive`, `dataNegative`, `dataWarning` | `datavizCategorical1` … `8`, `datavizGrid`, `datavizAxis`, `datavizReference`, `datavizPositive`, `datavizNegative`, `datavizWarning` |
| — | new: `bgDisabled`, `bgInput`, `bgSelected`, `bgSelectedHover`, `bgNeutralBold` (+ hover, pressed), `bgDangerBold*`, `borderDisabled`, `borderSelected`, `icon*` (12), `overlayHover`, `overlayPressed`, `textOnBold`, `textSubtlest`, `datavizSequential1–7`, `datavizDiverging1–7` |

One colour falls outside sRGB: `color.dataviz.categorical.2` in light, drawn in Display P3.

### Shadows

| Before | After |
|:--|:--|
| `flat` | — (no shadow: page content is ruled, not raised) |
| `raised`, `subtle`, `low`, `ramp2xs`, `rampXs`, `rampSm` | `raised` |
| `hover`, `rampMd` | `raisedHover` |
| `overlay`, `rampLg` | `overlay` (menus, popovers, toasts) |
| `modal`, `rampXl` | `modal` (dialogs, drawers) |
| `inset` | `inset` |

### Dimensions

| Before | After |
|:--|:--|
| `QeetrixSpacing.zero` / `.xxs` (2) | — |
| `.xs` 4 · `.s` 8 · `.m` 12 · `.l` 16 · `.xl` 24 | `QeetrixSpace.insetXs` / `gapXs` 4 · `insetSm` / `gapSm` 8 · `insetMd` / `gapMd` 12 · `insetLg` / `gapLg` 16 · `insetXl` / `gapXl` / `layoutSm` 24 |
| `.xl2` 32 · `.xl3` 48 · `.xl4` 64 | `layoutMd` 32 · `layoutLg` 48 · `layoutXl` 64 |
| `.xl5` 96 | — |
| `QeetrixCorner.control` / `.field` / `.base` (7.2) | `QeetrixRadius.control` (4) |
| `.surface` / `.overlay` (10.08) | `QeetrixRadius.surface` / `.overlay` / `.modal` (4) |
| `.chip` (5.76) | `QeetrixRadius.chip` (now a pill, status tags) or `.sm` (2, small marks) |
| `.xs` 2 · `.sm` 4 · `.pill` 9999 · `.none` 0 | `.sm` 2 · `.control` 4 · `.full` 9999 · `.none` 0 (and `.tooltip` 2) |
| `QeetrixStroke.hairline` 1 · `.thin` 2 · `.thick` 3 | `QeetrixBorderWidth.default` 1 · `.strong` 2 · `.accent` 3 |
| `QeetrixFocus.ringWidth` 3 · `.outlineWidth` 2 · `.offset` 2 | `QeetrixFocus.ringWidth` 2 · `.ringOffset` 2 |
| `QeetrixOpacity.disabled` 0.5 | 0.4 (no component fades any more: disabled states have their own colours) |
| `QeetrixIconSize` xs 14 · sm 16 · md 20 · lg 24 | adds `xs2` 12 |
| `QeetrixDensity.controlHeight` (28 / 32 / 36) | `sizeControlSm` / `Md` / `Lg`: compact 24 / 28 / 32, default 28 / 32 / 40, comfortable 32 / 36 / 44; `controlHeight(_:)` reads one |
| `rowHeight` (40 / 40 / 52) · `fieldGap` (8 / 16 / 16) · `cellPaddingY` | `sizeRow` (32 / 40 / 48) · `spaceFormGap` (12 / 16 / 20) · — |

### Motion

| Before | After |
|:--|:--|
| `QeetrixDuration.instant` 0 · `.fast` 150 · `.normal` 200 · `.slow` 300 · `.deliberate` 400 ms | `.instant` 0 · `.fast` 100 · `.normal` 200 · `.slow` 300 · `.slower` 400 ms |
| `QeetrixEasing.standard` (0.4, 0, 0.2, 1) | `.standard` (0.65, 0, 0.35, 1) |
| `.emphasized` (0.4, 0, 0.6, 1) · `.enter` (0, 0, 0.2, 1) · `.exit` (0.4, 0, 1, 1) · `.linear` | `.emphasized` (0.16, 1, 0.3, 1) · `.enter` (0.25, 1, 0.5, 1) · `.exit` (0.32, 0, 0.67, 0) · `.linear` |
| `QeetrixMotion.reducedEasing` | — (every duration is 0 under Reduce Motion) |
| — | `QeetrixSpring.snappy` (400, 0.9), `.gentle` (200, 1); `QeetrixSpring.animation`, `QeetrixMotion.animation(_:reduceMotion:)` |

### Typography

| Before | After | Size / line / weight | Letter style |
|:--|:--|:--|:--|
| `display` (48) | `displayLg` · `displayMd` · `displaySm` | 56/64 · 48/56 · 40/48, 600 | `display` (Geo, 100) |
| `title` (32) | `headingLg` · `headingMd` · `headingSm` | 32/40 · 28/36 · 24/32, 600 | `heading` (Base, 50) |
| `heading` (20) | `titleLg` · `titleMd` · `titleSm` | 20/28 · 18/24 · 16/24, 600 | `heading` (Base, 50) |
| `body` (14) | `bodyLg` · `bodyMd` · `bodySm` | 16/24 · 14/20 · 12/16, 400 | `body` (A11y, 0) |
| `label` (13) · `labelCompact` (12.8) | `labelLg` · `labelMd` · `labelSm` | 16/24 · 14/20 · 12/16, 500 | `body` (A11y, 0) |
| `micro` (11) | `labelCaps` | 11/16, 600, +0.66 pt | `body` (A11y, 0) |
| `caption` (12) | `bodySm` | 12/16, 400 | `body` |
| `code` (13) | `codeMd` · `codeSm` | 14/20 · 12/16, 400 (Fira Code) | — |

`opsz` follows the point size (CSS `font-optical-sizing: auto`). Dynamic Type curves:
`displayLg`/`Md`/`Sm`, `headingLg` → `.largeTitle`; `headingMd` → `.title`; `headingSm` → `.title2`;
`titleLg` → `.title3`; `titleMd`, `titleSm` → `.headline`; `bodyLg`, `bodyMd`, `codeMd` → `.body`;
`bodySm`, `labelSm`, `codeSm` → `.footnote`; `labelLg` → `.callout`; `labelMd` → `.subheadline`;
`labelCaps` → `.caption2`.

## Icons

No icon of the subset was renamed in 2.0.0 or 2.1.0: all 29 names are the same, and `chevron-right`
was added (the menu's submenu chevron in react, and the showcase's lists), for **30**. The components
of QTRX-95 to QTRX-155 pinned 38 more (68 in all); see the CHANGELOG. The sync fails with the
new name if a pinned name ever becomes an alias. Components draw the **sharp** shape (design rules
§16); `QeetrixIcon` and `Image(qeetrix:)` keep `@qeetrix/icons`' default, round outline. Mirroring
follows each manifest entry's `directionality`.

| Name | 1.0.11 | 2.0.0 |
|:--|:--|:--|
| all 29 previous icons | same name | same name (drawings from 2.1.0's SVG files; identical to 2.0.0's modules) |
| `chevron-right` | — | added |

## Components

Every component is done to the extent the platform allows; *partial* means a `@qeetrix/react`
feature has no iOS counterpart yet, listed beside it. Folders now follow `@qeetrix/react`'s families
(ADR 0007, 0015): `DropdownMenu/Menu` → `Menu/Menu`, `Input/Field` → `Field/Field`,
`Input/FieldSet` → `Fieldset/Fieldset`, `Input/TextField` → `TextField/TextField`,
`RadioGroup/RadioGroup` → `Radio/RadioGroup`, `Typography/Text` → `Text/Text` and `Heading/Heading`.
`OTPInput` keeps its folder name, the case-insensitive spelling of the `otp-input` family.

| iOS | `@qeetrix/react` | Before | After | Status |
|:--|:--|:--|:--|:--|
| `QeetrixButton` | Button | `(_:leadingIcon:trailingIcon:variant:size:isLoading:loadingLabel:action:)`; `variant` default · outline · secondary · ghost · destructive · link; `QeetrixButtonSize` xs · sm · default · lg | `(_:icon:variant:tone:size:isLoading:isFullWidth:action:)`; `variant` solid · soft · ghost; `tone` brand · danger · neutral; `size: QeetrixControlSize` sm · md · lg (density heights). Old → new: default → solid; secondary, outline → soft; ghost → ghost; destructive → solid + danger; link → ghost; xs, sm → sm; default → md; lg → lg. One trailing `icon` in its zone; no leading icon, no `loadingLabel` | Done |
| `QeetrixButtonStyle` | Button | `(_:size:)`, `.qeetrix(_:size:)`, `iconSize(for:)` | `(_:tone:size:)`, `.qeetrix(_:tone:size:)`, `iconSize(for: QeetrixControlSize)` | Done |
| `QeetrixIconButton` | IconButton | `(_:label:variant:size:isLoading:action:)` | `(_:label:variant:tone:size:isLoading:tooltip:action:)`; default ghost · brand · md; the label also shows as the pointer tooltip (`.help`) | Done (no `tooltipSide`) |
| `QeetrixBadge` | Badge | `(_:variant:icon:)`; variant default · secondary · outline · brand · info · success · warning · destructive · muted | `(_:tone:variant:size:icon:)`; `tone` neutral · brand · info · success · warning · danger; `variant` subtle · solid; `size` sm · md. Old → new: default → brand solid; secondary, outline, muted → neutral subtle; brand, info, success, warning → same tone, subtle; destructive → danger subtle | Done |
| `QeetrixCard` | Card | `(variant:size:isSelected:content:footer:)` + `QeetrixCardHeader`; variant default · outline · elevated; size default · sm | `(title:description:headingLevel:variant:tone:content:actions:footer:)` (+ shorter forms); `variant` default · subdued; `tone` neutral · danger. `QeetrixCardHeader` and `size` removed; `elevated` removed (no shadows in the page); a header-only card has no body | Done |
| `QeetrixCardButtonStyle` | — (react has no selectable card) | `(_:size:isSelected:)` | `(_:isSelected:)`, restyled: ruled, neutral tint on press, `bgSelected` inside a 2 pt Ember edge when selected (the choice tile's look) | Kept, iOS only |
| `QeetrixAvatar` | Avatar | `(name: String?, image:size:shape:badge:)`; size xs · sm · default · lg · xl | `(name: String, image:size:shape:isDecorative:)`; size sm 24 · md 32 · lg 40 · xl 48 (xs 20 removed); square = 4 pt corners; initials skip legal forms; `badge` removed | Done |
| `QeetrixSeparator` | Separator | `(_:variant:)` default · muted | `(_:tone:isDecorative:)` subtle (default) · default · strong. Old default → `.default`, muted → `.subtle` | Done |
| `QeetrixSpinner` | Spinner | `(size:label:)`; sm 16 · default 20 · lg 24 · xl 32; the `loader-circle` icon | `(size:tone:label:isDecorative:)`; sm 14 · md 16 · lg 20 · xl 24; tone neutral · brand; a 2 pt ring with a quarter gap, 800 ms a turn; fades under Reduce Motion | Done |
| `QeetrixProgress`, `QeetrixProgressViewStyle` | Progress | `(_:value:total:size:showsValue:)`, `showsValue` default true; size sm · md · lg | `(_:value:total:tone:showsValue:)`, `showsValue` default false; tone brand · success · danger; one 4 pt square track, `surface.sunken` in dark | Done (no Meter) |
| `QeetrixText` | Text | `(_:variant:)`; variant h1 · h2 · h3 · h4 · p · blockquote · lead · large · small · muted · inlineCode | `(_:size:weight:tone:mono:truncate:align:)`; size sm · md · lg; weight regular · medium · semibold; tone (10). Old → new: h1–h4 → `QeetrixHeading` level 1–4; p → `QeetrixText()`; lead → `size: .lg, tone: .subtle`; large → `size: .lg, weight: .semibold`; small → `size: .sm, weight: .medium`; muted → `tone: .subtle`; inlineCode → `mono: true`; blockquote → none (no counterpart) | Done |
| `QeetrixHeading` (new) | Heading | — | `(_:level:size:tone:truncate:align:)`; size display-lg … title-sm, default by level | Done |
| `QeetrixField` | Field | `(_:description:message:isRequired:isOptional:content:)`; `QeetrixFieldMessage` error · warning · success | `(_:description:error:isRequired:isOptional:isInvalid:isLabelHidden:content:)`; `error: String?` replaces the description; no warning or success; no asterisk; label `labelSm` in `textSubtle` | Done (no help ⓘ) |
| `QeetrixFieldset` | Fieldset | `QeetrixFieldSet(_:description:message:isRequired:isOptional:content:)` | `QeetrixFieldset(_:description:content:)`; legend `titleSm`; the density's form gap | Partial (no group `error`; no CheckboxGroup to pair it with) |
| `QeetrixTextField` | TextField, Input | `(_:text:prompt:description:message:isRequired:isOptional:isReadOnly:)` | `(_:text:prompt:description:error:icon:startAdornment:endAdornment:isRequired:isOptional:isReadOnly:isLabelHidden:)`; the filled field with a bottom line | Done |
| `QeetrixTextarea` | Textarea | `(_:text:prompt:description:message:isRequired:isOptional:isReadOnly:)` | `(_:text:prompt:description:error:rows:maxRows:isRequired:isOptional:isReadOnly:)` | Done |
| `QeetrixPasswordInput` | PasswordInput | `(_:text:purpose:prompt:description:message:isRequired:isOptional:showsToggle:)`; purpose current · new | `(_:text:autoComplete:prompt:description:error:isVisible:isRequired:isOptional:)`; autoComplete currentPassword · newPassword · off; the toggle is a neutral `sm` icon button, always there | Partial (no Caps Lock warning) |
| `QeetrixOTPInput` | OTPInput | `(_:code:length:characters:groupSize:description:message:isRequired:isOptional:onComplete:)`; characters digits · alphanumeric | `(_:code:length:groups:size:validationType:description:error:isRequired:isOptional:onValueComplete:)`; validationType numeric · alphanumeric; size md · lg; slots share the width | Done (no read-only) |
| `QeetrixNumberField` | NumberField | `(_:value:in:step:(fractionDigits:)prompt:description:message:isRequired:isOptional:)` | adds `startAdornment`, `endAdornment`, `showsSteppers`; `message` → `error`; both steppers at the end behind a hairline | Done (no `largeStep`, no `format`) |
| `QeetrixSelect` | Select | `(_:selection:options:placeholder:description:message:isRequired:isOptional:)` | `(_:selection:options:placeholder:description:error:size:isRequired:isOptional:isReadOnly:)`; the field look with a trailing sharp chevron; the list is the system menu | Partial (no `multiple`, no groups) |
| `QeetrixCheckbox`, `QeetrixCheckboxToggleStyle` | Checkbox | unchanged | unchanged signatures; 16 pt square, 2 pt corners, Ember when on | Done (no CheckboxGroup) |
| `QeetrixRadioGroup` | RadioGroup, Radio | `(_:selection:options:description:message:isRequired:isOptional:)` | `(_:selection:options:description:error:orientation:isRequired:isOptional:)`; `QeetrixChoiceOrientation` vertical · horizontal | Done (no tiles) |
| `QeetrixSwitch`, `QeetrixSwitchToggleStyle` | Switch | `(_:isOn:size:)`, `QeetrixSwitchSize` sm · default, `.qeetrixSwitch(size:)` | `(_:isOn:description:)`, `.qeetrixSwitch`; 32 × 18 square track, a white thumb when on; the control first, then the label | Done |
| `QeetrixErrorSummary` | ErrorSummary | `QeetrixFormErrorSummary(title:errors:)`, "There is a problem" | `QeetrixErrorSummary(title:headingLevel:items:)`, "Fix these to continue"; the danger Alert's look | Done |
| `QeetrixFormActions` | — (react footers) | unchanged | unchanged; 8 pt gaps | Kept, iOS layout |
| `QeetrixTabs`, `QeetrixTab` | Tabs | `variant` default · line; `QeetrixTab(_:value:icon:isDisabled:)` | `variant` line (default) · contained; `QeetrixTab(_:value:icon:filledWhenSelected:badge:isDisabled:)`, `filledWhenSelected` on by default; the 3 pt Ember bar slides | Partial (horizontal only) |
| `qeetrixTabBar()`, `qeetrixTabItem(_:icon:badge:)` | — (navigation) | brand tint | `color.icon.brand` tint | Kept, iOS only |
| `qeetrixNavigationBar(background:)` | — | unchanged | unchanged | Kept, iOS only |
| `QeetrixAlertDialog`, `QeetrixDialogAction` | Dialog (`intent` danger/warning) | unchanged | unchanged (the system alert) | Done (system-drawn) |
| `QeetrixConfirmationDialog` | — | unchanged | unchanged (the system action sheet) | Kept, iOS only |
| `qeetrixSheet`, `QeetrixSheetContent` | Drawer, Dialog | `QeetrixSheetContent(_:description:onClose:content:actions:)` | `(_:description:intent:isDismissible:onClose:content:actions:)`; ruled header and footer; `QeetrixDialogIntent` standard · danger · warning draws the 3 pt intent line | Partial (no dialog widths) |
| `qeetrixPopover` | Popover | `(isPresented:arrowEdge:compactAdaptation:content:)` | `(isPresented:title:description:arrowEdge:compactAdaptation:content:)`; at most 360 pt | Partial (system arrow) |
| `QeetrixMenu`, `QeetrixMenuItem` | Menu | `QeetrixMenu(_:icon:variant:size:content:)` (outline default), `(icon:label:variant:size:content:)`; `QeetrixMenuItem(_:icon:role:action:)` | `QeetrixMenu(_:icon:variant:tone:size:content:)` (soft, trailing chevron), `(icon:label:variant:tone:size:content:)` (ghost, neutral); `QeetrixMenuItem(_:icon:description:tone:action:)`, tone default · danger | Partial (system menu: no shortcuts, Ember edge or submenu chevron) |
| `QeetrixToast`, `qeetrixToast(_:)` | Toast | `QeetrixToastType` info · success · warning · error; `QeetrixToast(_ type:…)`, `.error(_:)`; 5 s, 10 s for warnings, errors and actions | `QeetrixToastTone` info · success · warning · danger; `QeetrixToast(_ tone:…)`, `.danger(_:)`; 5 s, a danger toast stays until dismissed; the action a ghost `sm` button, close "Dismiss" | Partial (one at a time, no `promise`) |
| `QeetrixIcon`, `Image(qeetrix:)` | `@qeetrix/icons` | unchanged | unchanged | Done |
| `QeetrixProvenance` | — | `tokens` (`@qeetrix/ui`), `icons` (repository, commit), `fonts` (repository, tag) | `tokens` (+ `colorSchemes`, `densities`), `icons` and `components` (package, version, gitHead, integrity), `fonts` (package, source, `woff2SHA256`, `sha256`) | Done |

## Decisions

The shared decisions (pins, DTCG tokens, fonts, icons, components, platform conventions, this file)
are in ADR 0015. These are the ones the migration needed beyond them:

1. **Fonts, then and now.** On 0.0.11 the WOFF2s were converted with fontTools 4.68.0 (pure wheel)
   and brotli 1.2.1, hash-pinned, in `.build/font-conversion`, losslessly (`recalcTimestamp=False`, no
   subsetting or instancing) and checked by reading the TTF back. The output was table-for-table equal
   to the calcom and FiraCode release TTFs except `head.flags` bit 11 and the checksum, and Fira's
   empty `DSIG`. 0.0.12's TTFs are byte-identical to it; the conversion and its venv were removed.
2. **Icons come from the published SVG files** (2.1.0, QTRX-188), validated by the existing SVG
   parser and kept verbatim so the lock hashes the package's own files. On 2.0.0, which published
   only React modules, a JavaScript reader turned them back into SVG; it was removed, and the
   generated drawings didn't change.
3. **Reduce Motion.** The DTCG build states the rule (`motion.duration`: under reduced motion every
   duration is 0 ms) but has no context for it; the generator reads `tokens.css`'s
   `prefers-reduced-motion` block and fails unless it sets every duration to one value (0 ms).
   `reducedEasing` is gone.
4. **Letter style and line height per role** come from the role's token (tokens 0.0.13, QTRX-186
   and QTRX-184): `$extensions["in.qeet.qeetrix"].fontGeometry` names the `font.geometry.*` token
   (display → display; heading, title → heading; body, label, code → body, which Fira Code, with no
   `GEOM` axis, ignores), and `.lineHeight` is the exact length. The generator's hand-written table
   (`TypographyRules`) is gone; the ratio is emitted as length over size (`lineHeight: 20 / 14`), so
   `body.md` is exactly 20 pt, not 14 × 1.4286. `token-values.json` lists both as `fontGeometry` and
   `lineHeightPoints`.
5. **Bold Text** steps up the token weight scale and, past semibold, 100 more on the font's `wght`
   axis (700).
6. **`label.caps` tracking** (0.66 px at 11 px) scales with the text size.
7. **Text takes CSS half-leading**, negative where a role's line is shorter than the font's natural
   line (ADR 0015 §9). Containers set their type without it.
8. **Dynamic Type curves** for the 18 roles (table above), by purpose and nearest size.
9. **Folder names follow `@qeetrix/react`'s families**; `OTPInput` keeps its spelling because a
   case-only rename isn't reliable on macOS's case-insensitive volumes.
10. **Two react cascade bugs weren't copied** on 0.3.0: a solid or soft neutral button is the soft
    button in every state, and a pressed danger ghost keeps the danger tint. React 0.4.0 fixed both
    (QTRX-157, QTRX-158), so iOS now simply follows `button.css`.
11. **Components draw sharp icons**; `QeetrixIcon` and `Image(qeetrix:)` keep the package's round
    default, as the web's `<Icon>` does.
12. **Focus frames** follow design rules §10 where SwiftUI reports focus (`isFocused`, with Full
    Keyboard Access): inside buttons (with the 1 pt surface gap) and fields, 2 pt outside checkboxes,
    radios, switches and selectable cards, inside tabs (tabs.css). The system's own focus effect is
    left on.
13. **Switch layout** follows the design rules (control first, label 8 pt after), replacing the
    earlier iOS-style trailing switch.
14. **Choice rows** stay 44 pt and flush (ADR 0012) where the web uses 24 px rows 4 px apart.
15. **Field errors** are `String?` — already-localised text that is also announced — and the field
    keeps announcing a new error; warnings and successes are gone with react's Field.
16. **The sheet stands in for Dialog and Drawer** (ADR 0014): it takes the drawer's ruled sections, and
    `intent` adds the dialog's 3 pt intent line.
17. **The selectable card** (`QeetrixCardButtonStyle`) takes the choice tile's selected look
    (`bgSelected`, a 2 pt `borderBrand` edge) — the nearest react pattern.
18. **Toast timing**: 5 s; danger stays; with VoiceOver running a toast with an action stays (kept from
    ADR 0014); one toast at a time (kept).
19. **Menu triggers** follow ui.qeet.in's examples: a soft button with a trailing icon (a chevron by
    default), or a neutral ghost icon button.
20. **The tab bar tint** is `color.icon.brand`; the navigation bar tint stays `color.text.brand`.
21. **Select toolbar sizes**: `size` `md` and `sm` as react's trigger has them; `lg` is the field.
22. **The Consumer app.** On `main` `Examples/QeetrixConsumer` held only an empty project shell; its
    sources exist on branch `phases-5-to-7`. The migration brought them to this branch, migrated.
23. **Snapshot baselines** were cleared and re-recorded: the previous local set mixed `main` with
    `phases-5-to-7` images, and seven didn't match `main` (see the before/after folders in the report).
24. **Single-line controls grow with Dynamic Type.** At the default size (and smaller) a button,
    text field, password, number field and select is exactly the web's height. Past it, the box is
    the token height × the text's scale, so it keeps its proportions instead of closing round the text
    (`qeetrixControlBlockSize`); a wrapped button label also gets room above and below that grows from
    nothing at the default size. The textarea's padding-block, `(control.lg − 1lh) / 2`, scales with
    the text. A button's label wraps rather than truncating.
25. **Icon boxes grow with their icons.** Icons scale with Dynamic Type, so the boxes drawn round them
    do too: icon buttons (and the password toggle), number-field steppers, a button's icon zone and
    its rule. Spinners standing in for an icon scale with it.
26. **Popovers in landscape.** In compact height a popover stays a popover; `compactAdaptation`
    applies to compact width (a portrait iPhone) only. `.automatic` covered the screen of an iPhone
    that is compact in both directions, with no way to dismiss it.
27. **The snapshot harness measures what it draws.** swift-snapshot-testing's `.sizeThatFits` measured
    the specimen in a hosting controller that had never been laid out, so at ax3 rows, switches,
    buttons and fields came out at their default height with the larger text overflowing them; and the
    ax3 traits asked for AX5 while the environment said AX3. Specimens are now measured after a layout
    pass in a window with the configuration's traits, drawn top-aligned at that height, and ax3 is AX3
    in both. The same artefact was in `main`'s baselines.

## The bump to tokens 0.0.13, icons 2.1.0 and react 0.4.0

The three releases of 30 October fixed what this migration (and qeetrix-android's) reported. What
changed on iOS:

| Release | Change | iOS |
|:--|:--|:--|
| tokens 0.0.13 | Dark `border.subtle` → graphite.800, `border.default` → graphite.750 (QTRX-183) | `borderSubtle` #2E2E2D, `borderDefault` #383837 in dark |
| | Dark `bg.brand.bold-hover` → the new `qeet.650` (QTRX-187) | `bgBrandBoldHover` #C5430A in dark; the brand fill's 3:1 on every surface is tested, as upstream |
| | Exact line heights: the length in `$extensions["in.qeet.qeetrix"].lineHeight` (QTRX-184) | every role's line is the token's length (`lineHeight: 20 / 14`) |
| | Each role names its letter style in `.fontGeometry` (QTRX-186) | read from the token; `TypographyRules` removed |
| | `component.timeline.marker-size` 28px (QTRX-185) | `QeetrixTimeline`'s 28 pt marker (QTRX-100) |
| icons 2.1.0 | SVG files and a JSON manifest (QTRX-188) | read directly; the JavaScript reader removed; drawings identical. iOS draws no Qeet logo, so the mask-free logo isn't needed |
| react 0.4.0 | A solid neutral Button hovers grey (QTRX-157); a ghost danger press keeps `bg.danger.subtle` (QTRX-158) | iOS already drew both; the comments now cite the CSS |
| | Invalid Checkbox, Radio and Switch keep the danger edge hovered and checked (QTRX-161) | the same, a chosen radio's ring included |
| | The Switch's on thumb is `color.icon.on-brand` (QTRX-162) | white in both schemes |
| | OTPInput's focused invalid slot shows focus (QTRX-163) | already so (the shared input surface) |
| | A read-only OTPInput looks read-only (QTRX-165) | iOS's OTP has no read-only state yet |
| | Progress slides from the reading start (QTRX-166) | already so (the track mirrors in right to left) |
| | A disabled Accordion chevron is `icon.disabled` (QTRX-167) | no Accordion yet (QTRX-118) |
| | Filled icons by default on the selected tab (QTRX-168) | `filledWhenSelected` defaults to `true` |
| | A header-only Card has no body (QTRX-174) | no body, and no header rule, when the content is empty |
| | Read-only fields draw their line in `border.strong` (QTRX-175) | every field, through the shared surface |
| | Progress's dark track is `surface.sunken`; Meter's light warning fill `border.warning` (QTRX-176) | the dark track; iOS has no Meter |
| | Select options, Menu items and AvatarItem wrap (QTRX-177, QTRX-178) | system menus, which wrap themselves; no AvatarItem |
| | Chip and ChipGroup (QTRX-180), Avatar `status` (QTRX-181) | separate iOS tickets (QTRX-117 for Chip) |

## Upstream gaps and bugs found

Found during the migration and reported as QTRX tickets. All are fixed upstream — in tokens 0.0.13,
icons 2.1.0, react 0.4.0 or the specs in qeetrix-files — so none needs a workaround here any more.

| Package | Where | What happened | Now | Ticket |
|:--|:--|:--|:--|:--|
| `@qeetrix/icons` 2.0.0 | `dist/` | Drawings shipped only as React modules and the manifest only as JavaScript | 2.1.0 ships `dist/svg/<shape>-<variant>/<id>.svg` and `dist/manifest.json`; iOS reads them | QTRX-188, Done |
| `@qeetrix/tokens` 0.0.12 | typography tokens | A role's letter style (`font.geometry.*`) wasn't in its token, so every platform restated it | 0.0.13 names it in `$extensions["in.qeet.qeetrix"].fontGeometry`; iOS reads it | QTRX-186, Done |
| `@qeetrix/react` 0.3.0 | `button.css`, solid + neutral | The solid variant's Ember hover and press won over the neutral tone | 0.4.0 gives the neutral tone its own hover and press | QTRX-157, Done |
| `@qeetrix/react` 0.3.0 | `button.css`, ghost + danger | No press rule: a pressed danger ghost showed the brand's tint | 0.4.0 keeps `bg.danger.subtle` on press | QTRX-158, Done |
| `06-component-specs.md` §1 vs `button.css` | ghost + neutral hover | Spec `bg.neutral.subtle-hover`, CSS `bg.neutral.subtle` | the spec says `bg.neutral.subtle` | QTRX-159, Done |
| `06-component-specs.md` (Toast) vs `toast.tsx` | status icon | Spec 18 px, code 16 px | the spec says 16 px | QTRX-171, Done |
| `05-design-rules.md` §9, spec §3 vs `switch.css` | the switch's on thumb (and the radio centre) | Rules "white"; CSS `surface.default`, near-black in dark | 0.4.0's thumb is `icon.on-brand`; the rules make only white-on-Ember white, so a radio's centre is `bg.input` | QTRX-162, Done |
| `05-design-rules.md` §8, §10 vs `tabs.css` | tab focus | Rules: outside the tab; CSS: inside | the rules draw it inside the tab | QTRX-169, Done |

## Verification

See the migration report for each command and its result: generator tests, sync `--check`, drift,
host and simulator tests, snapshot recording on iOS 27.1, the public-API check, lint, DocC, and the
example apps and their UI tests.

### Devices, 30 October 2026

One phone and one tablet were the target this round; more devices follow one at a time. On each
device run: the Showcase's 72 UI tests, screenshots of eight screens (index, foundations, button, form
patterns, select, tabs, card, app navigation) in light, dark, the largest accessibility text size
(AX5) and right to left, and a Consumer build. The snapshot baselines stay on the iOS 27.1 iPhone Duo
(a clone of it), unchanged by this pass.

| Device | iOS | Status |
|:--|:--|:--|
| iPhone 17 | 26.5 | **Run — the phone of this round** |
| iPad (A16) | 26.5 | **Run — the tablet of this round** |
| iPhone SE (3rd generation) | 26.5 | Run (before the narrowing) |
| iPhone 16e | 26.5 | Run (before the narrowing) |
| iPhone Air | 26.5 | Skipped on purpose: stopped part-way, no results kept |
| iPhone 17 Pro Max | 26.5 | Skipped on purpose |
| iPad mini (A17 Pro) | 26.5 | Skipped on purpose |
| iPhone Duo (device pass) | 27.1 | Skipped on purpose; its clone ran the snapshot, unit and UI tests |
