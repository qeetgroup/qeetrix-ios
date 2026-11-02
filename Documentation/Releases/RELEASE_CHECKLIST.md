# Release checklist

The steps from a commit on `main` to a tagged release. Steps 1–4 can be done by any maintainer and
change nothing remote. Steps 5–7 publish, and **only the owner does them, after approving the
evidence**. No automation performs them.

## 1. Prepare

- [ ] Every change for the release is merged to `main` through reviewed pull requests, and CI is green.
- [ ] `CHANGELOG.md` has a section for the version; `Documentation/Releases/RELEASE_NOTES.md` is
      written for it, with breaking changes and migrations first.
- [ ] Any source break has a decision record and its lines in
      `Documentation/API/breaking-changes-allowlist.txt` (`RELEASE_POLICY.md`).
- [ ] Snapshot baselines are recorded on the previous release's commit, so the comparison in step 2
      shows exactly this release's visual changes (ADR 0013).

## 2. Verify

On a clean checkout of the commit to be released, with the pinned Xcode:

```sh
Scripts/release-check.sh 0.1.0-rc.1
```

It runs every gate and writes the evidence to `.build/release-evidence/<version>/`:

- the host gates (`Scripts/check.sh`) and the upstream check;
- source compatibility against the last tag;
- the library, snapshot and showcase UI tests, including the accessibility audit, on the simulator;
- the consumer check, which installs the version into an independent app;
- DocC, the privacy check and the bill of materials.

The same run is available on GitHub as the **Release candidate verification** workflow, which keeps
the evidence as an artifact. That run cannot compare snapshots: there are no baselines on the runner.

- [ ] `SUMMARY.md` shows no FAIL.
- [ ] Every NOT RUN is accounted for in the candidate report: run elsewhere with evidence attached, or
      accepted by the owner as a known gap.

## 3. Verify what this machine can't

These are needed for **1.0** and for any release claiming the matching support; record the results in
`COMPATIBILITY_MATRIX.md`:

- [ ] Library and UI tests on an iOS 17 simulator runtime (the minimum supported version).
- [ ] UI tests and the accessibility audit on an iPad simulator.
- [ ] A device pass of the accessibility checklist (`Documentation/Standards/ACCESSIBILITY.md`):
      VoiceOver, Voice Control, Switch Control, Full Keyboard Access, the largest text size, Bold Text
      and Increase Contrast.

## 4. Decide

- [ ] Write `RELEASE_CANDIDATE_REPORT.md` for the version: the gates and their evidence, known issues,
      and a GO, CONDITIONAL GO or NO-GO.
- [ ] The owner approves, in writing (the pull request or the issue that tracks the release).

## 5. Tag — owner only

```sh
git checkout <commit>                       # the verified commit, unchanged
git tag -s 0.1.0-rc.1 -m "Qeetrix 0.1.0-rc.1"   # signed if a signing key is set up; otherwise -a
git push origin 0.1.0-rc.1
```

The tag never moves afterwards (`ROLLBACK_PROCEDURE.md`).

## 6. Announce — owner only

- [ ] Optionally, a GitHub release from the tag, with the release notes, the bill of materials
      (`.cdx.json`) and the evidence summary attached. The repository stays private.
- [ ] Tell the app teams the version and the install rule (`.upToNextMinor(from:)`; candidates pinned
      exactly).
- [ ] Hand the release to the documentation team (`Documentation/Website/`).

## 7. After a final release

- [ ] The final tag goes on the last candidate's commit, unchanged.
- [ ] Record the baselines on this commit for the next release's comparison.
