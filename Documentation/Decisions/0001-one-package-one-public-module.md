# 0001 — One Swift package, one public module

**Status:** Accepted, 2026-10-18

## Context

Qeetrix for iOS will grow from foundations to the full component catalogue: 137 components in 97
families on the web today. Public iOS design systems differ in how they package that:

- Wanted's Montage, HeadHunter's Levitan and SBB ship one or two modules.
- SAP Fiori, Microsoft Fluent and Skyscanner Backpack separate theme and foundations from components.
- Orange's OUDS ships 17 products, mostly because it has several brands.

Qeet Group has one brand and one consumer framework, SwiftUI.

## Decision

- One Swift Package Manager package with one library product and one module, both named `Qeetrix`.
- iOS 17 is the product platform. macOS 14 is declared only so `swift build` and `swift test` run on a
  Mac.
- Swift 6 language mode, and no third-party runtime dependencies.
- Foundations and, from Phase 2, components live in the one module, separated by folder
  (`Tokens/ Foundations/ Theme/ Icons/` versus `Components/`). Internal types stay `internal`.

## Consequences

- Apps write `import Qeetrix` and nothing else, and there is one public API to keep stable.
- Layering inside the module is a convention, not something the compiler enforces. It is checked in
  review, and `ARCHITECTURE.md` states the dependency direction.
- **Splitting later is not a folder move.** A new target means a new module name, so imports change.
  Cross-module use of internal types needs `package` access. Re-exporting through the umbrella module
  affects documentation and the public API baseline (ADR 0008). It would be planned as an API change.

A second target or product is justified only by one of these, and is recorded in a new decision:

1. A component needs a heavy or optional dependency that most apps should not link (SAP keeps its
   charts in a separate product for this reason).
2. An app needs foundations or tokens without components, and measures a real cost from linking them.
3. Measured build times make the single module a problem for contributors.
4. A platform needs code the iOS target cannot compile, such as a UIKit-only adaptation.
