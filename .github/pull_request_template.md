## What and why

<!-- What changes, and the reason. Link the issue or the upstream qeetrix-ui / qeetrix-icons change. -->

## Checklist

Each box is a command that exists in this repository; CI runs the same ones.

- [ ] `swift test --package-path Tools/QeetrixGen`: generator tests pass
- [ ] `Scripts/verify.sh`: the snapshot matches its lock and generated files are current
- [ ] `Scripts/lint.sh`: swift-format, strict
- [ ] `swift test`: library tests pass on the Mac
- [ ] `xcodebuild test -scheme Qeetrix -destination "platform=iOS Simulator,id=$(Scripts/ci-simulator.sh)"`: library tests pass on iOS
- [ ] `Scripts/api-check.sh`: public API unchanged, or updated with `--update` and noted in `CHANGELOG.md`
- [ ] `Scripts/docs.sh`: DocC builds with no warnings
- [ ] Documentation matches the change (`CHANGELOG.md`, DocC, `ARCHITECTURE.md` or a decision record)

## Upstream inputs

- [ ] This PR does not change `Upstream/`, **or** it bumps `Upstream/pins.json`, was produced by
      `Scripts/sync-upstream.sh` and `Scripts/generate.sh`, and nothing in `Upstream/` or a
      `Generated/` folder was edited by hand.
