# Workflows — qeetrix-ios

**Level:** L2 · **Last verified:** 2026-11-04
**Verification scope:** every command checked against `Scripts/` and `.github/workflows/`.

## Set up

```bash
Scripts/check.sh                       # every Mac-host gate
xcodebuild test -scheme Qeetrix \
  -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"   # the library on iOS
```

Xcode 27.1 (Swift 6.4) with an iOS Simulator runtime. Nothing else.

## Add a component

```text
1  in Sources/Qeetrix/Components/<Family>/, copy a similar component of the same kind
2  implement it from the @qeetrix/react CSS (Upstream/qeetrix-react/css/), the CSS beside each literal
3  tests in Tests/QeetrixTests/Components/<Family>/, and a snapshot test
4  a DocC page in Sources/Qeetrix/Qeetrix.docc/Components/, linked from Qeetrix.md
5  a showcase page, added to Showcase/…/ShowcaseCatalog.swift
6  its row in docs/components.md, and an entry in the CHANGELOG
```

## Change a look, a token, a font or an icon

```text
1  change it upstream (qeetrix-tokens, qeetrix-icons or qeetrix-react) and publish to npm
2  bump the pin in Upstream/pins.json, and tell the qeetrix-android maintainers
3  Scripts/sync-upstream.sh, then Scripts/generate.sh
4  if the build fails, a token was added or removed: change the public type on purpose
5  review the diff of Upstream/ and the generated files; a CSS change means that component's values change too
```

## Release

```text
1  pull request develop → main; version.yml raises the patch in VERSION if the library changed (docs-only: no new version)
2  date the CHANGELOG entry: ## [X.Y.Z] — YYYY-MM-DD
3  merge; release.yml runs every Mac-host gate and builds the bill of materials
4  approve: Actions › Release › Review deployments › Approve
5  it tags X.Y.Z (no v) and opens the GitHub Release
```

A bad release: **Actions › Rollback**, then a new patch. Details: [../releases.md](../releases.md).

## When CI fails

| Symptom | Usually | Do |
|---|---|---|
| `xcode-select: invalid developer directory` | The runner image no longer carries `XCODE_VERSION` | Pick a version the `xcode-27` image lists, re-verify locally, update the pin |
| `Scripts/verify.sh` fails | A generated or upstream file was edited by hand | Run `Scripts/generate.sh` |
| The source-compatibility step fails | A source-breaking change | Make it additive (deprecate the old API), or raise the major version in `VERSION` (the minor while 0.x) |
| A simulator test can't start | A stuck simulator | Re-run the failed job |
