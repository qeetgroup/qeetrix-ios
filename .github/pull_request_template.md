## What and why

<!-- What changes, and the reason. Link the issue or the upstream qeetrix-ui / qeetrix-icons change. -->

## Checklist

Each box is a command that exists in this repository; CI runs the same ones.

- [ ] `Scripts/check.sh`: generator tests, drift, format, warnings, dependencies, resources, host tests
      and public API (an API change is updated with `Scripts/api-check.sh --update` and noted in
      `CHANGELOG.md`)
- [ ] `xcodebuild test -scheme Qeetrix -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"`: unit and snapshot tests pass on iOS
- [ ] Showcase UI tests pass: `xcodebuild test -project Examples/QeetrixShowcase/QeetrixShowcase.xcodeproj -scheme QeetrixShowcase -destination …`
- [ ] `Scripts/docs.sh`: DocC builds with no warnings
- [ ] Snapshots compared locally against baselines recorded before the change (they are never committed,
      ADR 0013); any visual change is described above
- [ ] No screenshots or other images are added to the repository
- [ ] A new overlay or navigation component follows ADR 0014: the system presentation, state in a
      binding the app owns, and a UI test that presents and dismisses it
- [ ] Documentation matches the change (`CHANGELOG.md`, DocC, `ARCHITECTURE.md` or a decision record)

## Upstream inputs

- [ ] This PR does not change `Upstream/`, **or** it bumps `Upstream/pins.json`, was produced by
      `Scripts/sync-upstream.sh` and `Scripts/generate.sh`, and nothing in `Upstream/` or a
      `Generated/` folder was edited by hand.
