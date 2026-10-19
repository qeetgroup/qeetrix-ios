# ``Qeetrix/QeetrixSelect``

## Overview

One choice from a list, in the system's menu. Use it for more options than fit as a
``QeetrixRadioGroup``. Search, multiple selection and options loaded from a server are not part of it.

```swift
QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
```

- The field shows the selected option's title, or the placeholder while the selection matches no option.
- Tapping it opens the native menu: the current choice has a checkmark, long lists scroll, disabled
  options are listed but cannot be chosen, and descriptions appear as subtitles.
- A message colours its boundary; `disabled(_:)` dims it.

### Accessibility

VoiceOver reads a button named by the label, with the selected title — or the placeholder — as its
value. The menu and its items are the system's.

### Platform differences

The web `Select` draws its own popup list. iOS uses the system menu, which keeps scrolling, Dynamic
Type, VoiceOver and keyboard behaviour native — the same choice the web makes with `NativeSelect` on
mobile.

On the web: [Select on ui.qeet.in](https://ui.qeet.in/docs/components/select).

## Topics

### Options

- ``QeetrixOption``
