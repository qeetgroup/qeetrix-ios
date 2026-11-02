# Performance report

Phase 6, 2026-10-19 and 2026-10-20. Measured, not estimated. Every figure here comes from a debug
build on the Mac host or the iOS 27.1 simulator. Neither is a phone's CPU, GPU or memory, so these figures
catch regressions; they don't predict a device's frame rate. A device run is release gap GAP-5.

## What was measured

| Test | What it does | Where |
|:--|:--|:--|
| `RenderingPerformanceTests.testResolvingTypeUncached` | Builds 2,000 typefaces from the variable font across the nine roles: what every Qeetrix text cost before PERF-1 | `Tests/QeetrixTests/Performance` |
| `RenderingPerformanceTests.testResolvingTypeCached` | The same 2,000 through the cache `qeetrixTextStyle(_:)` and component text now use | same |
| `RenderingPerformanceTests.testRenderingFiftyListRows` | Lays out and draws 50 `QeetrixListItem` rows (icon, title, description, metadata, badge) off screen | same |
| `RenderingPerformanceTests.testDrawingTheIconCatalogue` | Draws all 37 icons at the default size | same |
| `LargeListPerformanceUITests.testScrollingFiveThousandRows` | Flicks a native `List` of 5,000 `QeetrixListItem` rows; scroll-deceleration hitches and the app's memory | the showcase's UI tests |

The unit timings set no baseline, so they never fail on a slower machine. XCTest runs each block ten
times.

## Results

### iOS 27.1 simulator (iPhone Duo), debug build

| Test | Average of 10 | Steady state | Note |
|:--|:--|:--|:--|
| Typefaces, uncached (2,000) | 0.094 s | 0.086–0.095 s | |
| Typefaces, cached (2,000) | 0.001 s | 0.00095–0.0010 s | **About 95 times faster** |
| 50 list rows | 0.081 s | 0.035 s | The first run, 0.477 s, includes loading the fonts and first-use setup |
| 37 icons | 0.054 s | 0.002 s | The first run, 0.519 s, is the same cold start |

### Mac host (Apple silicon), debug build

| Test | Average of 10 | Steady state | Note |
|:--|:--|:--|:--|
| Typefaces, uncached (2,000) | 0.091 s | 0.090–0.092 s | |
| Typefaces, cached (2,000) | 0.001 s | 0.0012–0.0013 s | **About 70 times faster** |
| 50 list rows | 0.081 s | 0.064–0.071 s | The first run, 0.203 s, is the cold start |
| 37 icons | 0.012 s | 0.003 s | The first run, 0.096 s, is the cold start |

## PERF-1: typefaces rebuilt on every update

Each Qeetrix text builds its font from a CoreText variation descriptor: weight, optical size and the
geometry axis, scaled to the Dynamic Type size and adjusted for Bold Text. SwiftUI evaluates a view's
body on every update, so a screen of text rebuilt dozens of fonts per frame while scrolling.

`QeetrixResolvedType.resolved(tokens:size:legibilityWeight:)` now caches the result by role tokens,
point size and Bold Text, behind an `OSAllocatedUnfairLock`. It holds up to 512 entries, and is emptied
when full, so custom sizes can't grow it without bound. Nine roles at a handful of sizes and two
weights stay far below that.

`TypeCacheTests` checks that:

- a cached result equals a fresh one, for every role, at several sizes, with and without Bold Text;
- Bold Text is part of the key;
- the cache stays within its bound.

## Scrolling 5,000 rows

| Measurement (5 iterations, iOS 27.1 simulator, debug) | Phase 5 (before PERF-1) | Phase 6 |
|:--|:--|:--|
| Scroll deceleration | 2.43 s | 2.43 s (2.430–2.433) |
| Peak memory | about 83 MB | 82.4 MB (82.1–82.6) |

No measurable change in this scenario. The deceleration duration is set by the system's scrolling
physics, and the simulator doesn't report hitches, so this test guards against large regressions —
memory growing with the list, a failure to scroll — rather than measuring frame time. PERF-1's effect
shows in the type timings above; on a device it would show as frame time, which is GAP-5.

Rows are `QeetrixListItem`s in a native `List`, which reuses cells: memory stays flat however far the
list scrolls, and `testFarRowsAreReachableAndSelectable` checks that rows far down are reached and keep
their selection.

## What was reviewed without a change

- **Icon images for system chrome** (`Image(qeetrix:)`) are rendered once per name, size and style,
  cached on the main actor and bounded at 256.
- **Animations** run only while their view is on screen: the spinner, the progress sweep and the
  skeleton belong to their view's state, and stop under Reduce Motion.
- **Layout.** The library's custom layouts (the wrapping row, the timeline) measure each child when
  sizing and again when placing it, without a layout cache. They hold a handful of children — chips,
  actions, events — so this was left as it is; it wasn't measured separately.

## Not measured

- A device: frame times, hitches and memory on the oldest supported iPhone (GAP-5).
- Instruments traces (Time Profiler, SwiftUI): not run in this phase.
- Launch time: the library adds two font registrations at first use, which this phase didn't time.
