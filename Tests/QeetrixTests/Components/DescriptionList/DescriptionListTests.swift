import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Description list")
struct DescriptionListTests {
    @Test("Rules go between distinct item edges, never above the first")
    func ruleEdges() {
        #expect(QeetrixRuleEdges.between([]).isEmpty)
        #expect(QeetrixRuleEdges.between([10]).isEmpty)
        #expect(QeetrixRuleEdges.between([0, 30, 60]) == [30, 60])
        #expect(QeetrixRuleEdges.between([0, 0, 40, 40]) == [40], "A grid row shares one rule")
        #expect(QeetrixRuleEdges.between([60, 0, 30]) == [30, 60], "In order of position")
    }

    @Test("Every layout renders, divided and not")
    func renders() {
        for layout in QeetrixDescriptionListLayout.allCases {
            for divided in [false, true] {
                let list = QeetrixDescriptionList(layout: layout, isDivided: divided) {
                    QeetrixDescriptionItem("Plan", value: Text("Team"))
                    QeetrixDescriptionItem("Region", value: Text(verbatim: "Mumbai (ap-south-1)"))
                    QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
                }
                #expect(ImageRenderer(content: list.frame(width: 360)).cgImage != nil)
            }
        }
    }

    @Test("Divided: a border-subtle rule between pairs, none above the first")
    func dividedRule() throws {
        let rule = QeetrixColor.borderSubtle.color(for: .light).resolve(in: EnvironmentValues()).bytes
        let list = QeetrixDescriptionList(layout: .vertical, isDivided: true) {
            Color.clear.frame(height: 20).qeetrixRuledItem()
            Color.clear.frame(height: 20).qeetrixRuledItem()
        }
        .frame(width: 100)
        .environment(\.colorScheme, .light)
        let rendered = try #require(Rendered(list))
        let rows = (0..<rendered.height).filter { close(rule, rendered.pixel(50, $0), tolerance: 6) && rendered.pixel(50, $0).a > 0 }
        #expect(rows.count == 1, "One rule, between the two items")
        #expect(rendered.pixel(50, 0).a == 0, "None above the first")
    }

    @Test("Beside its value in regular width, above it in compact width")
    func horizontal() throws {
        let item = QeetrixDescriptionItem("Plan", value: Text("Team"))
        let regular = try #require(Rendered(item.frame(width: 400).environment(\.horizontalSizeClass, .regular)))
        let compact = try #require(Rendered(item.frame(width: 400).environment(\.horizontalSizeClass, .compact)))
        #expect(regular.height < compact.height, "One line beside, two stacked")
        let vertical = try #require(
            Rendered(
                QeetrixDescriptionList(layout: .vertical) { item }.frame(width: 400).environment(\.horizontalSizeClass, .regular)))
        #expect(vertical.height == compact.height, "Vertical stacks at every width")
        #expect(QeetrixDescriptionListMetrics.termColumnWidth == 192)
    }
}
