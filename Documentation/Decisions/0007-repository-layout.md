# 0007 — Repository layout

**Status:** Accepted, 2026-10-18. Amended by ADR 0018: component folders follow `@qeetrix/react`'s families.

## Context

Public iOS design systems converge on a few conventions:

- a standard Swift package layout;
- the demo app kept outside the library;
- generated code committed, with its generator in the repository;
- documentation as DocC inside the module;
- tooling kept apart from the scripts people run.

The examples reviewed were Microsoft Fluent, SAP Fiori, Orange OUDS, Skyscanner Backpack, Adevinta
Spark, Point-Free TCA, SBB, pixiv, HeadHunter and Wanted.

Phase 1 first placed the generator, its pinned inputs and the shell entry points together in
`Scripts/`. That mixed three different things.

## Decision

- **Library and tests.** `Sources/Qeetrix/` and `Tests/QeetrixTests/`, with tests mirroring the
  sources.
- **Tooling and inputs.** Three separate places:
  - `Tools/QeetrixGen/` — the generator, as its own Swift package that apps never resolve;
  - `Upstream/` — the pinned inputs and their lock;
  - `Scripts/` — the commands people and CI run.
- **Showcase.** `Examples/QeetrixShowcase/` is an iOS app that depends on the package through a local
  reference.
- **Documentation.** Two places, with no duplication between them:
  - `Sources/Qeetrix/Qeetrix.docc/` — how to use the API;
  - `Documentation/` — architecture, decisions, standards, and generated reports.
- **Components** (Phase 2) go in `Sources/Qeetrix/Components/<Family>/<Component>/`, where `<Family>`
  is qeetrix-ui's family identifier from its `component-map.json`. The ui.qeet.in categories are a
  navigation layer, and two families appear in two of them. Folders follow families; categories are
  used only in documentation and the showcase. A folder is created with its first component, never as
  a placeholder.

## Consequences

- Each top-level folder has one job, and generated output lives only in the `Generated/` folders and
  `Documentation/{Foundations,API}`, which the generator owns.
- The iOS component tree mirrors `qeetrix-ui/src/components/<Family>/`, so the same name finds a
  component on both platforms.
