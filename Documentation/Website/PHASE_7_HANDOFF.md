# ui.qeet.in handoff: iOS release candidate

For the documentation team maintaining ui.qeet.in (`qeetrix-docs`). Phase 7 prepared the first release
candidate of Qeetrix for iOS. **Nothing is released yet**, so nothing on the site should say the iOS
package can be installed by version until the owner tags one. Earlier handoffs (Phases 4–6) still
apply; this one adds release status, installation and policy.

The sources of truth: DocC in `Sources/Qeetrix/Qeetrix.docc` (in particular *Installing and updating*,
*Migrating* and *Troubleshooting*), and `Documentation/Releases/`.

## Status to show

> **iOS: 0.1.0-rc.1, release candidate, not yet released.** Beta: tested on the iOS simulator,
> including Apple's accessibility audit; not yet verified on iOS 17, iPad or devices.

Update it when a tag exists: the version, and the date from the GitHub tag.

## An iOS installation page

Once a version is tagged, from *Installing and updating*:

- Swift Package Manager, from `https://github.com/qeetgroup/qeetrix-ios.git` (a private repository: the
  reader needs access);
- `.upToNextMinor(from: "0.1.0")`, with the reason (before 1.0 a minor version may break source);
- iOS and iPadOS 17 or later; Xcode with Swift 6; no other dependencies.

Before a tag exists, say only that the package is in preparation.

## Supported components

The table in `Documentation/Releases/RELEASE_NOTES.md` under "What's in it" is the list. Mark every
other web component as not available on iOS. Don't list deferred or conditional components (data
table, image presentation, snackbar, inline alert, separate dialog).

## Policies to link or summarise

- **Versioning** (`RELEASE_POLICY.md`): SemVer tags; before 1.0, minor versions may break source with a
  migration note, patches never do.
- **Support** (`SUPPORT_POLICY.md`): the latest minor series; no response-time commitments.
- **Migration** (DocC *Migrating*): icon names are an open set; add `default:` to a `switch` over them.
- **Accessibility:** as the Phase 6 handoff says. No claim of formal conformance.
- **Known limitations:** English-only built-in strings; no increased-contrast colours yet; untested on
  iOS 17, iPad and devices.

## Not to publish

- Version numbers as released before the tag exists.
- The bill of materials or the evidence logs (internal).
- Screenshots from the repository; capture showcase or consumer pages locally.
- Anything about Qeet ID Auth using Qeetrix iOS: it is a React Native app and doesn't.
