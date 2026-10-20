# Compatibility matrix

Where the release candidate has actually been built and tested. A configuration is ✓ only if a suite ran
on it and passed; supported but untested is "not run", never ✓.

Last full run: 2026-10-20, the 0.1.0-rc.1 dry run (`RELEASE_CANDIDATE_REPORT.md`).

## Toolchain

| | Tested | Supported |
|:--|:--|:--|
| Xcode | 27.1 ✓ | The version pinned in CI (`XCODE_VERSION`) |
| Swift | 6.4 ✓ (Swift 6 language mode) | Swift 6; the manifest is `swift-tools-version: 6.0` |
| Mac | macOS 26.6, Apple silicon ✓ | For development only |

## Runtimes and devices

| Configuration | Supported | Library tests | Snapshots | Showcase UI and audit | Consumer |
|:--|:--|:--|:--|:--|:--|
| iOS 27.1 simulator, iPhone Duo | ✓ | ✓ | ✓ | ✓ | ✓ |
| iOS 27.1 simulator, other iPhones | ✓ | not run | not run | not run | not run |
| iPadOS simulator, any | ✓ | **not run** | **not run** | **not run** | **not run** |
| iOS 17.x simulator (the minimum) | ✓ | **not run** | **not run** | **not run** | **not run** |
| A physical iPhone or iPad | ✓ | not run | — | not run | not run |
| Build for iOS devices (arm64, Release) | ✓ | — | — | — | ✓ (consumer, unsigned) |
| Mac host (development) | — | ✓ | — | — | — |

Why the gaps:

- The only runtime installed is iOS 27.1, and on it `simctl create` refuses every device type but the
  iPhone Duo: re-checked on 2026-10-20 with iPad Air 11-inch (M3), iPhone 16e, iPhone 17 and iPhone 18
  Pro Max, each "Incompatible device". So no small or large iPhone, and no iPad, could be tested.
- An iOS 17 runtime is a multi-gigabyte download (`xcodebuild -downloadPlatform iOS -buildVersion 17.x`),
  and whether Xcode 27.1 runs iOS 17 simulators hasn't been checked. Both are the owner's to decide.
- No physical device is attached.

Everything compiles with an iOS 17 deployment target, so availability is checked at compile time.
Behaviour on iOS 17 itself is unverified.

## Settings covered on the tested simulator

| Setting | How it was tested |
|:--|:--|
| Light, dark | Snapshots in both; the audit gate's contrast check in both; the consumer's stored theme |
| Default and accessibility text sizes up to the largest | Snapshots at an accessibility size; the audit gate at the largest; UI tests of reflow; the consumer at Accessibility Large |
| Right to left | Snapshots right to left; RTL launches of twelve showcase pages; the consumer's mirrored layout |
| Portrait, landscape (iPhone) | UI tests of popovers and sheets in landscape (Phase 4) |
| Reduce Motion | Unit tests and snapshots of the still states |
| Bold Text, Increase Contrast, Smart Invert, Differentiate Without Colour | Unit tests of the type and colour resolution only; not seen on a device |
| VoiceOver, Voice Control, Switch Control, Full Keyboard Access | Labels, traits, values and focus in UI tests; not used by a person |
| External keyboard | Focus movement in form UI tests; not on hardware |

## Consumers

| Consumer | Status |
|:--|:--|
| `Examples/QeetrixConsumer` (independent app) | ✓ by path and by version (`CONSUMER_INTEGRATION.md`) |
| Qeet ID Auth | Not applicable today: an Expo and React Native app, which can't host a SwiftUI package without a native module |
| QeetrixShowcase | ✓ (development app) |
