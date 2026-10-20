# Migrating

Changes that need code changes in your app, newest first.

## Overview

Each source-breaking change has a decision record and a migration here. Before 1.0 they come only in
minor versions; a patch never breaks source.

### Before 0.1.0: icon names are an open set

``QeetrixIconName`` was an enum and is now a struct with one static property per icon, so adding an
icon is no longer a breaking change (decision record 0016).

Everything that names an icon compiles unchanged:

- `QeetrixIcon(.bell)`;
- `QeetrixIconName(rawValue: "bell")`, `rawValue` and `allCases`;
- `case .bell:` inside a `switch` that has a `default` case.

A `switch` over icon names with no `default` case stops compiling. Add one:

```swift
switch icon {
case .bell: showNotifications()
case .settings: showSettings()
default: break
}
```
