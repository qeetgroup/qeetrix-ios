import SwiftUI
import XCTest

@testable import Qeetrix

/// Timings for the work every Qeetrix view repeats. They describe the machine they run on — the Mac host
/// or the simulator, in a debug build — and are recorded in Documentation/Quality/PERFORMANCE_REPORT.md;
/// they are not thresholds, so no baseline is set and a slower machine doesn't fail them.
final class RenderingPerformanceTests: XCTestCase {
    /// What a Qeetrix text costs on each update without the cache: a variable font built and measured.
    func testResolvingTypeUncached() {
        let roles = QeetrixTextRole.allCases
        measure {
            for index in 0..<2_000 {
                let role = roles[index % roles.count]
                _ = QeetrixResolvedType(tokens: role.tokens, size: nil, legibilityWeight: nil)
            }
        }
    }

    /// The same, through the cache that `qeetrixTextStyle(_:)` and component text now use.
    func testResolvingTypeCached() {
        let roles = QeetrixTextRole.allCases
        measure {
            for index in 0..<2_000 {
                let role = roles[index % roles.count]
                _ = QeetrixResolvedType.resolved(tokens: role.tokens, size: nil, legibilityWeight: nil)
            }
        }
    }

    /// Laying out and drawing fifty list rows, off screen.
    @MainActor
    func testRenderingFiftyListRows() {
        let rows = VStack(spacing: 0) {
            ForEach(0..<50, id: \.self) { index in
                QeetrixListItem("Document \(index)", description: Text(verbatim: "Asha Rao"), metadata: Text(verbatim: "2 MB")) {
                    QeetrixListItemIcon(.fileText)
                } trailing: {
                    QeetrixBadge("Active", tone: .success)
                }
            }
        }
        .frame(width: 390)
        measure {
            _ = ImageRenderer(content: rows).cgImage
        }
    }

    /// Drawing every icon in the catalogue at the default size.
    @MainActor
    func testDrawingTheIconCatalogue() {
        let icons = VStack {
            ForEach(QeetrixIconName.allCases, id: \.self) { QeetrixIcon($0) }
        }
        measure {
            _ = ImageRenderer(content: icons).cgImage
        }
    }
}
