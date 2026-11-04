## 📝 What and why

<!-- What changes, and why. One topic per pull request. -->

## 🔗 Related

- Jira: QTRX-
- Upstream change, if any: <!-- the @qeetrix/tokens, @qeetrix/react or @qeetrix/icons version or PR -->

## 🧩 Type of change

- [ ] 🐛 Fix
- [ ] ✨ New component or feature
- [ ] 💥 Breaking change to the public API
- [ ] 🎨 Upstream bump (tokens, components or icons)
- [ ] 🛠️ Build, CI or docs only

## 📸 Screenshots

<!-- For a visual change: before and after, in light and dark. Delete this section otherwise. -->

## ✅ Checklist

- [ ] `Scripts/check.sh` passes
- [ ] New behaviour has a test that fails without the change
- [ ] **Public API change:** DocC written, `Scripts/api-check.sh --update` run, and the CHANGELOG updated
- [ ] **Visual change:** snapshots compared with baselines recorded before the change
- [ ] **New component:** its tests, snapshot test, DocC page, showcase page and row in `docs/components.md`
- [ ] Nothing in `Upstream/` or a `Generated/` folder is edited by hand
- [ ] Docs match the change (CHANGELOG, DocC, a decision if structural)

## 🚀 Release (pull requests into `main` only)

- [ ] `VERSION` is the version to release. The Version workflow raises the patch when the library changes; raise the
      minor or major by hand.
- [ ] The CHANGELOG has an entry for that version, dated
