# Accessibility

Qeetrix targets WCAG 2.2 AA and Apple's platform accessibility expectations. Web patterns are
translated into native semantics, not copied: there is no ARIA on iOS. What a component announces,
how it scales and how it moves is decided with VoiceOver, Dynamic Type and the system's motion
settings in mind.

## What the foundations provide

| Need | Provided by | Automated check |
|:--|:--|:--|
| Text contrast (4.5:1) and non-text contrast (3:1) | Semantic colours; upstream's AA pairs re-measured on iOS values | `ContrastTests`, both themes |
| Light, dark, system appearance | `QeetrixColor`, `QeetrixThemeMode`, `.qeetrixTheme(_:)` | `ThemeTests` (rendered pixels), `ColorTests` |
| Dynamic Type | `.qeetrixTextStyle(_:)` scales with the role's text style; icons scale relative to `.body` | `TypographyTests`; showcase at accessibility sizes |
| Bold Text | `legibilityWeight == .bold` → one weight step up | `TypographyTests` |
| Reduce Motion | `.qeetrixAnimation(_:_:value:)`, `QeetrixMotion.animation(_:_:reduceMotion:)` → `motion.reduced.*` (no animation) | `MotionTests` |
| VoiceOver | `QeetrixIcon` is hidden when decorative, an image with a label when meaningful; elevation backgrounds are hidden | `IconTests` (semantics chosen) |
| Right-to-left | Directional icons mirror (`directionality: mirror` upstream); layout uses leading/trailing | `IconTests` (rendered mirror) |
| Touch targets | `QeetrixAccessibility.minimumTouchTarget` (44 pt), `.qeetrixMinimumTouchTarget()` | `TouchTargetTests` |
| Increased contrast | Read from the environment; no separate values exist upstream yet | `ColorTests` (falls back to standard) |

## Rules for components (Phase 2 onwards)

- Every interactive element has a hit area of at least 44 × 44 pt, an accessibility label, and the
  traits of what it is: button, header, selected, …
- Text uses a typography role, never a fixed `Font`, so Dynamic Type and Bold Text apply. Layouts are
  tested at the accessibility sizes and reflow (stack, wrap) rather than truncate or overflow. The
  showcase uses `ViewThatFits` for this.
- Colour never carries meaning alone. Status pairs a colour with an icon or text.
- Motion goes through `qeetrixAnimation`. Nothing moves when Reduce Motion is on unless the movement
  carries meaning, and then it has a reduced alternative.
- Decorative images and icons are hidden from VoiceOver. Meaningful ones are labelled by what they
  mean ("Locked"), not what they show ("padlock").
- Use leading/trailing, never left/right. Icons with a direction come from the mirrored set.

## Verified on a device — still to do

The automated checks cover what can be measured in tests. These need a person with a device before a
component is called accessible:

- VoiceOver reading order, rotor headings and labels in context.
- Full Keyboard Access and Switch Control focus order.
- Dynamic Type at AX5 across real screens.
- Bold Text, Increased Contrast, Smart Invert and Differentiate Without Colour.
- The iOS 17 runtime itself. Phase 1 compiled against iOS 17 but was run on the iOS 27.1 Simulator.
