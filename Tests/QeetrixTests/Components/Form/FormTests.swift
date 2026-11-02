import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Form composition")
struct FormTests {
    @Test("Compact width: actions stack full-width, primary (last) on top")
    func compactActions() throws {
        let view = QeetrixFormActionsLayout(isCompact: true) {
            Color.blue.frame(width: 60, height: 20)
            Color.red.frame(width: 60, height: 20)
        }
        .frame(width: 100)
        let rendered = try #require(Rendered(view))
        #expect(rendered.height == 48, "20 + 8 + 20")
        #expect(rendered.pixel(50, 5).r > 200, "The last button, red, is on top")
        #expect(rendered.pixel(50, 40).b > 200)
    }

    @Test("Regular width: a trailing row, primary last")
    func regularActions() throws {
        let view = QeetrixFormActionsLayout(isCompact: false) {
            Color.blue.frame(width: 30, height: 20)
            Color.red.frame(width: 30, height: 20)
        }
        .frame(width: 100)
        let rendered = try #require(Rendered(view))
        #expect(rendered.height == 20)
        #expect(rendered.pixel(10, 10).a == 0, "Space at the leading edge")
        #expect(rendered.pixel(95, 10).r > 200, "Red, the last, at the trailing edge")
        #expect(rendered.pixel(55, 10).b > 200)
    }

    @Test("An error summary draws nothing without items")
    func emptySummary() {
        #expect(ImageRenderer(content: QeetrixErrorSummary(items: [])).cgImage == nil)
        let summary = QeetrixErrorSummary(items: [.init(id: "email", message: "Enter a work email") {}])
        #expect(ImageRenderer(content: summary.frame(width: 300)).cgImage != nil)
    }

    @Test("The summary is the danger Alert: its tint, and the 3 pt danger edge on the start side")
    func summaryLook() throws {
        let summary = QeetrixErrorSummary(items: [.init(id: "email", message: "Enter a work email") {}])
            .frame(width: 300).environment(\.colorScheme, .light)
        let image = try #require(Rendered(summary))
        #expect(close(QeetrixTheme.light.resolve(.iconDanger).bytes, image.pixel(1, image.height / 2)))
        #expect(close(QeetrixTheme.light.resolve(.bgDangerSubtle).bytes, image.pixel(290, 4)))
        #expect(QeetrixAlertSurface<EmptyView>.titleType.tokens.weight == .semibold)
    }

    @Test("Alert tones: each its tint, its accent and its own icon")
    func alertTones() {
        let tones: [QeetrixAlertTone] = [.info, .success, .warning, .danger]
        #expect(tones.map(\.background) == [.bgInfoSubtle, .bgSuccessSubtle, .bgWarningSubtle, .bgDangerSubtle])
        #expect(tones.map(\.accent) == [.iconInfo, .iconSuccess, .iconWarning, .iconDanger])
        #expect(Set(tones.map(\.icon)).count == 4)
    }

    @Test("Following a link runs its action")
    func links() {
        var followed: [String] = []
        let items: [QeetrixErrorSummary.Item] = [
            .init(id: "email", message: "Enter a work email") { followed.append("email") },
            .init(id: "pan", message: "Enter the PAN as 10 characters") { followed.append("pan") },
        ]
        items[1].action()
        #expect(followed == ["pan"])
        #expect(items.map(\.id) == ["email", "pan"])
    }
}
