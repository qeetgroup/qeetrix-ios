# Security and privacy review

Phase 6, 2026-10-19, on the working tree that follows `10b365f`. The review covers the `Qeetrix`
library target: what it stores, sends, logs and depends on, and how it handles what people type. The
showcase app and the generator are development tools and ship to no one.

**Result: one finding, fixed (SEC-1, P3).** Nothing in the library needs a privacy manifest, a
permission or a required-reason declaration.

## What the library does not do

Each search runs over the library's Swift files, doc comments excluded, and found nothing:
`find Sources/Qeetrix -name '*.swift' -exec grep -nE '<pattern>' {} + | grep -vE ':[0-9]+:[[:space:]]*///'`.

| Concern | Evidence | Result |
|:--|:--|:--|
| Network | `URLSession\|NWConnection\|URLRequest` | None. Fonts and icons are bundled; nothing is fetched. |
| Storage | `UserDefaults\|AppStorage\|FileManager\|Keychain\|SecItem` | None in code. `@AppStorage` appears only in documentation, as an example the app may use for its theme. |
| Pasteboard | `UIPasteboard` | None. Copy and paste are the system text fields' own. |
| Required-reason APIs (Apple's list: file timestamps, system boot time, disk space, active keyboards, user defaults) | `creationDate\|modificationDate\|systemUptime\|volumeAvailableCapacity\|activeInputModes` | None, so no `PrivacyInfo.xcprivacy` is needed. Add one if a future component uses any of them. |
| Tracking, identifiers, location | `identifierForVendor\|ATTrackingManager\|CLLocation` | None. |

## What it logs

Two `os.Logger` channels, subsystem `in.qeet.qeetrix` (`Sources/Qeetrix/Internal/QeetrixLog.swift`):

- `fonts`: a bundled font that failed to register — the family name and the system's reason.
- `icons`: an icon drawing that is missing — the icon, shape and variant names.

Both log the library's own names and, for fonts, the system's error text, marked `privacy: .public`. No call logs text a person typed, a binding's
value or a label the app passed. There is no `print`, `NSLog` or `debugPrint` in the library.

## Sensitive input

| Component | Protection | Verified by |
|:--|:--|:--|
| `QeetrixPasswordInput` | Native `SecureField`: masked text, no copy, hidden from screen recordings. Content type `.password` or `.newPassword` for AutoFill; autocapitalisation and autocorrection off, so nothing reaches a spelling service; `.privacySensitive()`, so the field is redacted wherever the app applies privacy redaction (widgets, `redacted(reason: .privacy)`). Revealing swaps in a plain `TextField` with the same traits. | UI tests: a secure field never reports its text as its value; revealing keeps the keyboard and the text. The content type and autocorrection settings are read in code review: a UI test can't observe them. |
| `QeetrixOTPInput` | One native field with the `.oneTimeCode` content type, autocorrection off, `.privacySensitive()`. The cells draw the code; the field itself is transparent. | UI tests: one native code field, not one per cell. |
| All inputs | The component holds text only in the app's binding: it doesn't log, store, describe or announce it. Announcements carry messages the app wrote, never the field's value. | Code review of the five `AccessibilityNotification.Announcement` calls: field and field-set messages, the form error summary, the toast and the data state's failure. Each posts text the app wrote. |

Not verified, because it needs a device: Password AutoFill and one-time-code AutoFill from Messages.

## Dependencies

The library has **no dependencies**. Its test targets use these, pinned in `Package.resolved`:

| Package | Version | Licence | Used by |
|:--|:--|:--|:--|
| swift-snapshot-testing | 1.19.6 (exact) | MIT | `QeetrixSnapshotTests` |
| swift-custom-dump | 1.7.3 | MIT | swift-snapshot-testing |
| swift-issue-reporting | 2.1.2 | MIT | swift-snapshot-testing |
| swift-syntax | 604.0.0 | Apache-2.0 | swift-snapshot-testing |

An app that depends on `Qeetrix` resolves none of them. Checked with a scratch consumer package that
depends on the `Qeetrix` product by path: `swift package resolve` fetched no remote package and wrote
no `Package.resolved`. `Scripts/dependencies.sh` (in `Scripts/check.sh` and CI) fails on any
dependency or licence not on its allowlist.

Bundled resources are the web's fonts (SIL OFL 1.1, unmodified, with their licence texts) and icons
generated from `qeetrix-icons` (MIT, with Lucide's ISC and Feather's MIT notices). Every upstream file
is pinned by SHA-256 in `Upstream/upstream.lock.json`; CI fails on any byte change.

## Supply chain

- `Scripts/sync-upstream.sh` is the only networked step. It fetches pinned versions and checks their
  hashes; generation never fetches.
- **SEC-1 (P3, fixed).** The CI workflow used `actions/checkout@v4`, a tag its owner can move to other
  code. It now pins `11d5960a326750d5838078e36cf38b85af677262`, the commit `v4` and `v4.4.0` pointed
  to on 2026-10-19. `Scripts/dependencies.sh` fails on any `uses:` not pinned to a full commit; it was
  run against the old line and failed (exit 1), then passed on the pinned one.
- The workflow grants `contents: read` only.
- Nothing is published: no package registry, no release, no tag.
