# Security

## Reporting a vulnerability

Report it privately to the repository owner listed in `.github/CODEOWNERS`, never in an issue or pull
request. Say which version is affected and how to reproduce the problem. (GitHub's private
vulnerability reporting isn't available on this private repository.)

Fixes ship as patch releases on the latest minor series (`Documentation/Releases/RELEASE_POLICY.md`).

## Scope

Qeetrix for iOS is a UI library. It makes no network requests, stores nothing, reads no user data,
uses no required-reason APIs and has no dependencies at run time. The security-relevant parts:

- **Supply chain.** Every upstream input — design tokens, fonts, icon drawings, their licences — is
  pinned in `Upstream/pins.json` and locked by SHA-256 in `Upstream/upstream.lock.json`. CI fails on
  any change. The fonts are accepted only if their WOFF2 is byte-identical to the one the web ships.
  CI actions are pinned by commit and run with read-only permissions. The release's bill of materials
  is generated from these files (`Scripts/sbom.sh`).
- **Dependencies.** None in the library. The test-only packages are allowlisted by version and
  licence (`Tools/dependency-allowlist.json`) and never reach an app.
- **Text input.** Inputs keep what is typed only in the binding the app owns; the library never logs,
  stores or describes it. The password field is the system's `SecureField`, marked privacy-sensitive,
  with autocorrection off; the one-time-code field is one system text field. VoiceOver never reads a
  hidden password.
- **Logging.** Two `os.Logger` channels carry font-registration and missing-icon messages: library
  names only, never user data.

Qeetrix provides no authentication, credential storage or encryption. A confirmation dialog records a
choice; the app's own code decides whether the action is allowed.

Details: `Documentation/Quality/SECURITY_PRIVACY_REVIEW.md`.
