# Snapshot baselines

The reference images for `QeetrixSnapshotTests` are recorded here, on your machine, and are **not
committed**: screenshots never go into the repository (`.gitignore`). See ADR 0009.

Record them before comparing, on the pinned simulator (iOS 27, iPhone Duo):

```sh
TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all xcodebuild test -scheme Qeetrix -only-testing:QeetrixSnapshotTests \
  -destination "platform=iOS Simulator,id=$(../../../Scripts/ci-simulator.sh)"
```

Record on a commit you trust (for example `main`), switch to your change, and run the tests again to
compare. Look at every image a change re-records.
