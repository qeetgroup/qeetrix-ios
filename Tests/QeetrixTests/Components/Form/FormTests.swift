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

    @Test("An error summary draws nothing without errors")
    func emptySummary() {
        #expect(ImageRenderer(content: QeetrixFormErrorSummary(errors: [])).cgImage == nil)
        let summary = QeetrixFormErrorSummary(errors: [.init(id: "email", message: "Enter an email address.") {}])
        #expect(ImageRenderer(content: summary.frame(width: 300)).cgImage != nil)
    }
}
