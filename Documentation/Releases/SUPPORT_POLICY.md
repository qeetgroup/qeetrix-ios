# Support and maintenance

The initial model for keeping Qeetrix for iOS working for the Qeet Group apps that depend on it. It is
deliberately small: nothing here promises a response time, a support window or a named team that the
organisation hasn't agreed to.

## What is supported

| | Supported | Notes |
|:--|:--|:--|
| Platforms | iOS and iPadOS 17 and later | No macOS, watchOS, tvOS or visionOS. macOS 14 appears in the manifest only so tests can run on a Mac |
| Toolchain | The Xcode pinned in CI (`XCODE_VERSION`, now 27.1) | Others with Swift 6 may work, but only the pinned one is tested |
| Versions | The latest minor series | `RELEASE_POLICY.md` |
| Language | English built-in strings | Translations are not yet provided (`Documentation/Quality/LOCALIZATION_REPORT.md`) |

A new minimum iOS version is a breaking change: it ships in a minor release before 1.0, or a major
release after, with a decision record.

## Who does what

| Role | Responsibility | Today |
|:--|:--|:--|
| Owner | Approves and creates release tags; decides licensing, distribution and support changes | The repository owner (`.github/CODEOWNERS`) |
| Maintainers | Review pull requests; keep CI green; triage issues; run `Scripts/release-check.sh` | People with write access, as `.github/CODEOWNERS` lists them. When a maintainers team exists, it replaces individuals there |
| Consuming apps | Pin a version (`.upToNextMinor`); report defects; own their app's privacy disclosures, App Store review and translations of their own text | Each app team |

## Reporting

- **Defects:** a GitHub issue with the bug-report template: the Qeetrix version, iOS version, device,
  the steps to reproduce, and what was expected.
- **Accessibility defects** use the same template, with "Accessibility:" at the start of the title, and
  name the assistive technology. (The repository has no accessibility label yet; adding one is the
  owner's call.) They are triaged as P1 when they block a task (`RELEASE_POLICY.md`).
- **Design-system changes** — a new token, component or variant — start upstream in `@qeetrix/ui` or
  `qeetrix-icons`, then reach iOS through the sync (`CONTRIBUTING.md`). Use the design-system-change
  template.
- **Security issues:** never in a public issue. See `.github/SECURITY.md`.

## Changes and contributions

Every change follows `CONTRIBUTING.md` and the component contract
(`Documentation/Standards/COMPONENT_CONTRACT.md`). Every gate must pass, including the public API
baseline, source compatibility and the accessibility audit. A pull request that changes public API says
so, and a breaking one carries its decision record.

## Keeping current

- **Upstream:** a new `@qeetrix/ui` or `qeetrix-icons` release is adopted by bumping the pins, syncing,
  regenerating, and releasing in the next minor version. The weekly CI job checks that the pinned
  artifacts are unchanged.
- **Xcode:** a new Xcode is adopted by updating `XCODE_VERSION` in both workflows once the full suite
  passes on it locally.
- **Documentation:** DocC is part of every pull request that changes behaviour. The ui.qeet.in pages
  are updated from the handoffs in `Documentation/Website/` by the documentation team.
