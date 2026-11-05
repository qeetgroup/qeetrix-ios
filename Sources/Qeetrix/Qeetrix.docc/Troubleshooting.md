# Troubleshooting

Problems an app can meet when it adds Qeetrix, and what to do about them.

## Overview

### Xcode can't fetch the package

The repository is private. Sign in to GitHub in Xcode (**Settings › Accounts**) with an account that has
read access. A CI system needs a read-only credential for the repository.

### Text isn't in Qeet Sans

The fonts are registered from the package's bundle the first time Qeetrix draws text. Call
``QeetrixFontRegistry/register()`` at launch and check its result: each registration reports whether
its family is available and, if not, why. Failures are also logged to the `in.qeet.qeetrix` subsystem,
category `fonts`. Text falls back to the system font, never to nothing.

### The theme doesn't change

Apply `.qeetrixThemeMode(_:)` at the root of each scene, not deeper, and pass it the stored value. It sets
the window's preferred colour scheme, so sheets, alerts and menus follow it; another scene needs its own.

If the theme is right at launch but doesn't change when the person picks another, the value is read in the
`App` and passed into `WindowGroup { … }`. That content isn't rebuilt when the `App`'s state changes: read
the stored value with `@AppStorage` in the scene's root view instead (<doc:GettingStarted>).

### A switch over icon names stops compiling after an update

Add a `default` case. Icon names are an open set; see <doc:Migrating>.

### Warnings as errors fail the build in the package

Set `SWIFT_TREAT_WARNINGS_AS_ERRORS` in your app target's build settings, not as a command-line override.
An override also reaches the package, which Xcode builds with its warnings suppressed, and the two
options conflict.

### Built-in strings are English in a localised app

The library's own strings — "Loading", "Required", "Close" — have no translations yet. Your app's own
text is localised as usual.

### Which versions are inside my build

``QeetrixProvenance/bundled()`` reports the `@qeetrix/ui`, icon and font versions the package was
generated from.
