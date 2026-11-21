# ``Qeetrix/QeetrixLink``

## Overview

A text link — `@qeetrix/react`'s Link — for an action in place, such as "Change number" under a field
(the web's `<Link render={<button />}>`), or a page to open.

```swift
QeetrixLink("Change number") { goBack() }
    .qeetrixTextStyle(.bodySm)
QeetrixLink("Read in another language", icon: .globe) { showLanguages() }
QeetrixLink("Privacy Policy", destination: privacyURL, tone: .subtle)
```

- **Look** (link.css): `color.text.link`, underlined 1 point with the underline's top 3 points under the
  baseline. Pressed, or under a pointer, `color.text.link-hover` with a 2-point underline, over
  `motion.duration.fast`. Disabled, `color.text.disabled`.
- **Font**: the text round it sets the font, as the web's Link takes its paragraph's. Give it a role
  with `.qeetrixTextStyle(_:)`, on the link or on a stack of them.
- **Tone**, a ``QeetrixLinkTone``: `default`; `subtle` — `color.text.subtle`, `color.text.default` when
  pressed — for footnotes and metadata; or `inherit`, the surrounding colour, underlined.
- **Icon**: an optional leading icon, 16 points and 6 points before the words, in the link's colour and
  not underlined.
- **Destination**: a link with a URL opens it through the environment's `openURL`, so an app can handle
  it in place.

An action that changes data is a ``QeetrixButton``; a link moves the person on, or acts in place.

### Inside a sentence

"By tapping Agree and continue, you accept the Terms of Service and Privacy Policy": write the links
in the localised string, in Markdown, and draw them as Qeetrix links with
`AttributedString.qeetrixLinks()`, which underlines them, and `.qeetrixLinkTone(_:)`, which gives them
the tone's colour:

```swift
let consent = AttributedString(
    localized: "By tapping Agree and continue, you accept the [Terms of Service](https://qeet.in/terms).")

Text(consent.qeetrixLinks())
    .qeetrixTextStyle(.bodySm)
    .foregroundStyle(QeetrixColor.textSubtle)
    .qeetrixLinkTone()
```

The links wrap with the sentence and keep its font. A tap opens the link through `openURL`; for an
action in place, give the link a URL the app's `OpenURLAction` recognises and handles.

### Accessibility

- VoiceOver reads an action link as a button and a link with a destination as a link, by its words:
  write words that say where it goes. Links inside a sentence are in VoiceOver's Links rotor.
- A link on its own is a 44-point target, however short its line, without changing the line's layout.
- Keyboard focus is the Ember frame round it.

### Platform differences

- **The underline's position.** iOS 18 and later draw the underline 3 points under the baseline, as the
  web does. iOS 17 can't move an underline, so there it is the font's own, a little higher, and stays
  1 point while pressed.
- **Inside a sentence** the system draws the links: the underline sits at the font's own position, a
  pressed link is marked the system's way rather than with the hover colour, and the target is the
  words themselves rather than 44 points.
- **External links.** The web's `external` arrow and "(opens in a new tab)" aren't carried: on iOS a
  link opens in place or in Safari, which the system shows.

On the web: [Link on ui.qeet.in](https://ui.qeet.in/components/link/).

## Topics

### Tone

- ``QeetrixLinkTone``
