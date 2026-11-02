# 0010 — Component API conventions

**Status:** Accepted (Phase 2, 2026-10-18). Amended by ADR 0018: names follow `@qeetrix/react`.

## Context

Phase 2 adds the first eleven components. Their public API is the hardest thing to change later, so
the shape every component takes is decided once, here, and checked by the API baseline (ADR 0008).

## Decision

1. **Names.** `Qeetrix<Component>` for the view; `Qeetrix<Component><Axis>` for its options
   (`QeetrixButtonVariant`, `QeetrixButtonSize`). Options are top-level enums, not nested types: a type
   nested in a generic view (`QeetrixCard<Content, Footer>`) cannot be named without its generic
   arguments.
2. **Variant and size names are the web's.** `.default`, `.outline`, `.sm`, `.lg` — the names in
   qeetrix-ui's `cva` definitions, as Phase 1 did for icon sizes (`.sm`, `.md`). One vocabulary across
   platforms outweighs Swift's preference for unabbreviated names. Each enum is `String`-backed with the
   web name as its raw value, and `CaseIterable`.
3. **Styles where SwiftUI has a style protocol.** `QeetrixButtonStyle`, `QeetrixCardButtonStyle`,
   `QeetrixSwitchToggleStyle` and `QeetrixProgressViewStyle` give native controls (`Button`,
   `NavigationLink`, `ShareLink`, `Toggle`, `ProgressView`) the Qeetrix look, with static accessors
   (`.qeetrix()`, `.qeetrixSwitch()`). The named view is a convenience built on the style; it adds only
   what a style cannot, such as a button's loading state.
4. **Text parameters.** A component's main text has three initializers: `LocalizedStringKey` for
   literals, a generic `StringProtocol` for runtime strings shown as given, and `Text` (`label:` or
   `title:`) for anything else. Secondary text — a prompt, a description, a label with a built-in
   default — is an optional `Text`. Messages that must also be announced (`QeetrixFieldMessage`) store a
   `String`, localised on creation from a `LocalizedStringResource`, because an announcement cannot
   take a `Text`.
5. **State comes from SwiftUI.** Disabled from `disabled(_:)` (`isEnabled`), density from
   `qeetrixDensity(_:)`, theme from the colour scheme, focus from `@FocusState`. A component never takes
   a parameter for something the environment already carries. Its own states (`isLoading`,
   `isSelected`, `isReadOnly`, a message) are parameters.
6. **No colour or font parameters.** Customisation is variant, size and density. Qeetrix has one brand.
7. **Accessibility is not optional.** Icon-only controls require a label in their initializer. Every
   control has a 44 × 44 pt touch target — extended without moving layout where the web control is
   drawn smaller (`QeetrixHitArea`). Native semantics come from native controls or
   `accessibilityRepresentation`, not from imitating traits.
8. **Built-in strings are localised resources.** `Resources/Localization/<language>.lproj` holds the
   web message catalogue's strings ("Loading") under `qeetrix.*` keys; every component that shows one
   also takes a parameter that replaces it.
9. **Additive evolution.** New variants, sizes and parameters with defaults are additive. Removing or
   renaming one, or changing a default's look, is a breaking change: it needs a CHANGELOG entry under
   *Changed* or *Removed* and an API baseline update in the same pull request.

## Consequences

- Swift API guidelines' "avoid abbreviations" yields to the shared vocabulary for variant and size
  names only; everything else is spelled out.
- Adding a case to a public enum can break a consumer's exhaustive `switch`. Consumers rarely switch on
  these enums, so new cases are treated as additive, and the CHANGELOG says so.
- Each component has two entry points (view and style) to document and test; the style is the more
  general one.
