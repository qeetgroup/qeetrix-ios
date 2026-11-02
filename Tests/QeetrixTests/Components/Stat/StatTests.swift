import SwiftUI
import Testing

@testable import Qeetrix

private let enIN = Locale(identifier: "en-IN")

@MainActor
@Suite("Stat")
struct StatTests {
    @Test("Values are written by QeetrixFormat: Indian grouping, money without a fraction when whole (StatNumber)")
    func values() {
        let count: QeetrixStatValue = 1_240_512
        #expect(count.string(locale: enIN) == "12,40,512")
        let ratio: QeetrixStatValue = 2.5
        #expect(ratio.string(locale: enIN) == "2.5")
        #expect(QeetrixStatValue.currency(1_842_600, code: "INR").string(locale: enIN) == "₹18,42,600")
        #expect(QeetrixStatValue.currency(Decimal(string: "1842600.5")!, code: "INR").string(locale: enIN) == "₹18,42,600.50")
        #expect(QeetrixStatValue.percent(0.999, fractionDigits: 1...1).string(locale: enIN) == "99.9%")
        #expect(QeetrixStatValue.number(Decimal(string: "12.25")!, fractionDigits: 1...1).string(locale: enIN) == "12.3")
        #expect(QeetrixStatValue.text(Text("42 ms")).string(locale: enIN) == nil)
    }

    @Test("A change's direction and tone: up is positive and down negative, the other way round when fewer is better")
    func changes() {
        #expect(QeetrixStatChange.percent(0.032).direction == .up)
        #expect(QeetrixStatChange.percent(0.032).tone == .positive)
        #expect(QeetrixStatChange.number(-6).tone == .negative)
        #expect(QeetrixStatChange.number(-6, isIncreaseGood: false).tone == .positive)
        #expect(QeetrixStatChange.number(6, isIncreaseGood: false).tone == .negative)
        #expect(QeetrixStatChange.number(0).direction == nil && QeetrixStatChange.number(0).tone == .neutral)
        #expect(QeetrixStatChange.currency(-12_500, code: "INR").direction == .down)
    }

    @Test("A change shows its amount without the sign beside the arrow, and says the direction in words")
    func words() {
        #expect(QeetrixStatChange.percent(0.032).magnitude(locale: enIN) == "3.2%")
        #expect(QeetrixStatChange.percent(0.032).spoken(locale: enIN) == "Up 3.2%")
        #expect(QeetrixStatChange.number(-6).spoken(locale: enIN) == "Down 6")
        #expect(QeetrixStatChange.currency(-12_500, code: "INR").spoken(locale: enIN) == "Down ₹12,500")
        #expect(QeetrixStatChange.number(0).spoken(locale: enIN) == "0")
    }

    @Test("The note's tone: as given, else the change's, else neutral; each tone's stat.css colour")
    func tones() {
        #expect(QeetrixStat("Users", value: 1).resolvedTone == .neutral)
        #expect(QeetrixStat("Users", value: 1, change: .number(3)).resolvedTone == .positive)
        #expect(QeetrixStat("Users", value: 1, change: .number(3), tone: .warning).resolvedTone == .warning)
        #expect(QeetrixStatTone.allCases.map(\.rawValue) == ["neutral", "positive", "negative", "warning"])
        #expect(QeetrixStatTone.allCases.map(\.color) == [.textSubtlest, .textSuccess, .textDanger, .textWarning])
    }

    @Test("The trend is trendGeometry's: 88 × 28, 3 pt in from top and bottom, the last point marked; flat when constant")
    func trend() throws {
        let geometry = try #require(QeetrixStatTrendGeometry([10, 20, 15]))
        #expect(geometry.points == [CGPoint(x: 0, y: 25), CGPoint(x: 44, y: 3), CGPoint(x: 88, y: 14)])
        #expect(geometry.end == CGPoint(x: 88, y: 14))
        let ordered = try #require(QeetrixStatTrendGeometry([10, 15, 20]))
        #expect(ordered.points.map(\.y) == [25, 14, 3])
        #expect(ordered.end == CGPoint(x: 88, y: 3))
        let flat = try #require(QeetrixStatTrendGeometry([7, 7, 7]))
        #expect(flat.points.allSatisfy { $0.y == 14 })
        #expect(QeetrixStatTrendGeometry([4]) == nil && QeetrixStatTrendGeometry([]) == nil)
        #expect(QeetrixStatTrendGeometry.endRadius == 2.5 && QeetrixStatTrendGeometry.areaOpacity == 0.1)
    }

    @Test("A strip has as many 200 pt columns as fit, at least one, never more than its stats")
    func columns() {
        #expect(QeetrixStatGroupLayout.columns(width: 390, count: 4) == 1)
        #expect(QeetrixStatGroupLayout.columns(width: 400, count: 4) == 2)
        #expect(QeetrixStatGroupLayout.columns(width: 820, count: 4) == 4)
        #expect(QeetrixStatGroupLayout.columns(width: 1_200, count: 3) == 3)
        #expect(QeetrixStatGroupLayout.columns(width: 150, count: 3) == 1)
        #expect(QeetrixStatGroupLayout.columns(width: 600, count: 0) == 1)
    }

    @Test("Grouped stats share their row's height and draw their rules; a short last row's rule runs on")
    func group() throws {
        let view = QeetrixStatGroup {
            QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"))
            QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"))
            QeetrixStat("Disputes", value: 3)
        }
        .frame(width: 420)
        .environment(\.colorScheme, .light)
        .environment(\.locale, enIN)
        let image = try #require(Rendered(view))
        let rule = QeetrixTheme.light.resolve(.borderDefault).bytes
        #expect(image.width == 420)
        // Two columns of 210: the rule between them in the first row, and the second row's rule above it,
        // across the whole strip.
        let firstRowMiddle = image.height / 4
        #expect(close(rule, image.pixel(209, firstRowMiddle)))
        let ruled = (1..<image.height).filter { y in close(rule, image.pixel(400, y)) }
        #expect(!ruled.isEmpty, "a rule runs past the short last row's one stat")
        #expect(!close(rule, image.pixel(0, firstRowMiddle)), "no rule at the start of a row")
    }

    @Test("The colours a stat draws meet AA in both schemes: the tones' notes and the trend's marks on every surface")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for surface in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceRaised] {
                for tone in QeetrixStatTone.allCases {
                    let pair = ContrastTests.Pair(foreground: tone.color, background: [surface], minimum: 4.5)
                    #expect(ContrastTests.ratio(pair, theme) >= 4.5, "\(theme.colorScheme): \(pair)")
                }
                for mark in [QeetrixColor.iconSubtle, .borderBrand] {
                    let pair = ContrastTests.Pair(foreground: mark, background: [surface], minimum: 3)
                    #expect(ContrastTests.ratio(pair, theme) >= 3, "\(theme.colorScheme): \(pair)")
                }
            }
        }
    }

    #if os(macOS)
        @Test("VoiceOver finds one element per stat, named by its label; the trend and rules are hidden")
        func accessibilityTree() {
            let view = QeetrixStatGroup {
                QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"), trend: [1, 2])
                QeetrixStat("Revenue", value: 0, isLoading: true)
            }
            #expect(ListsAccessibilityTree.elements(of: view).map(\.text) == ["Active users", "Revenue"])
        }
    #endif

    @Test("It renders alone, with a change, a trend, text, loading, in a group and right to left")
    func renders() {
        let views: [AnyView] = [
            AnyView(QeetrixStat("Active users", value: 1_240_512)),
            AnyView(QeetrixStat("Active users", value: 1_240_512, change: .percent(-0.012), note: Text("this week"), trend: [4, 6, 5, 9])),
            AnyView(QeetrixStat("Latency", value: .text(Text(verbatim: "42 ms")), note: Text("p95"), tone: .warning)),
            AnyView(QeetrixStat("Active users", value: 0, isLoading: true)),
            AnyView(
                QeetrixStatGroup {
                    QeetrixStat("A", value: 1)
                    QeetrixStat("B", value: 2)
                }
            ),
            AnyView(QeetrixStat("Active users", value: 1, trend: [1, 2]).environment(\.layoutDirection, .rightToLeft)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }
}
