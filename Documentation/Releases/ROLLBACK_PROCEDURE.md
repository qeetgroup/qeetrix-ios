# When a release is bad

SwiftPM resolves releases from Git tags, and apps record the commit a tag pointed to in their
`Package.resolved`. So a release is never undone by changing history: a moved or deleted tag breaks
every app that resolved it, and a tag that silently points elsewhere is a supply-chain risk. Roll
forward instead.

## Never

- Move, delete or force-push a published tag.
- Rewrite history on `main` after a release.
- Reuse a version number.

## Instead

1. **Tell the app teams.** Name the bad version, the symptom, and which version to use meanwhile. If
   the defect is a vulnerability, follow `.github/SECURITY.md` and keep details private until a fix is
   out.
2. **Point apps at the last good version.** An app pins it in its manifest
   (`exact: "0.1.0"`, or `.upToNextMinor(from:)` with a lower bound below the bad patch), or reverts its
   `Package.resolved` to the previous pin. This needs nothing from Qeetrix.
3. **Release the fix as a new version.**
   - For a patch-level defect: revert or fix on a branch from the bad tag, add a regression test, and
     release the next patch (`0.1.1`) through the full checklist.
   - If the fix needs more time, release a patch that reverts the change, then fix it properly in a
     later version.
4. **Record it.** A CHANGELOG entry for the fix release names the bad version and what was wrong. The
   bad version's GitHub release (if one was created) is edited to point to the fix; it isn't deleted.

## Release candidates

An `-rc.N` that fails is not rolled back either: the fix becomes `-rc.N+1`. Apps should only ever pin a
candidate exactly, so nothing resolves to it by accident.
