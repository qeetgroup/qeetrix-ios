import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Empty state")
struct EmptyStateTests {
    @Test("Sizes and tones are @qeetrix/react's: page and section; neutral and danger")
    func names() {
        #expect(QeetrixEmptyStateSize.allCases.map(\.rawValue) == ["page", "section"])
        #expect(QeetrixEmptyStateSize.allCases.map(\.titleRole) == [.titleMd, .titleSm])
        #expect(QeetrixEmptyStateSize.allCases.map(\.paddingBlock) == [48, 24])
        #expect(QeetrixEmptyStateTone.allCases.map(\.rawValue) == ["neutral", "danger"])
        #expect(QeetrixEmptyStateTone.allCases.map(\.iconColor) == [.iconSubtle, .iconDanger])
        #expect(QeetrixEmptyStateMetrics.maximumWidth == 480)
    }

    @Test("A page has 48 pt above and below, a section 24; the title's line is 24 pt in both")
    func sizes() throws {
        let page = try #require(Rendered(QeetrixEmptyState("No accounts yet").frame(width: 390)))
        let section = try #require(Rendered(QeetrixEmptyState("No accounts yet", size: .section).frame(width: 390)))
        // iOS rounds each text block up to the screen's pixel grid (20.33 pt on a 3× screen) and the 1× image to
        // whole points: allow a point per text block. The lines themselves are exact.
        #expect(abs(page.height - (48 + 24 + 48)) <= 1)
        #expect(abs(section.height - (24 + 24 + 24)) <= 1)
    }

    @Test("The parts are 8 pt apart, the icon 4 pt more, the actions 8 pt more")
    func spacing() throws {
        func height(_ view: some View) throws -> Int {
            try #require(Rendered(view.frame(width: 390))).height
        }
        let title = try height(QeetrixEmptyState("No accounts yet", size: .section))
        // The 24 pt icon, 4 pt under it, and the 8 pt gap.
        #expect(try height(QeetrixEmptyState("No accounts yet", icon: .userPlus, size: .section)) == title + 24 + 4 + 8)
        // body.md's 20 pt line, 8 pt under the title.
        #expect(abs(try height(QeetrixEmptyState("No accounts yet", description: "Add one.", size: .section)) - (title + 8 + 20)) <= 1)
        let actions = QeetrixEmptyState("No accounts yet", size: .section) { Color.blue.frame(width: 80, height: 32) }
        #expect(try height(actions) == title + 8 + 8 + 32)
    }

    @Test("The icon is drawn sharp at 24 pt in the tone's colour")
    func icon() throws {
        let danger = QeetrixEmptyState("Couldn't load", icon: .circleAlert, size: .section, tone: .danger)
            .frame(width: 100).environment(\.colorScheme, .light)
        let image = try #require(Rendered(danger))
        // The circle's stroke crosses the icon's top centre, 24 pt down from the section's edge.
        let ink = (0..<6).map { image.pixel(50, 24 + $0) }
        #expect(ink.contains { close(QeetrixTheme.light.resolve(.iconDanger).bytes, $0, tolerance: 40) })
    }

    @Test("A level makes the title a heading, clamped to 1–6")
    func levels() {
        #expect(QeetrixEmptyState("No accounts yet").level == nil)
        #expect(QeetrixEmptyState("No accounts yet", level: 2).level == 2)
        #expect(QeetrixEmptyState("No accounts yet", level: 9).level == 6)
        #expect(QeetrixEmptyState("No accounts yet", level: 0).level == 1)
        #expect(ImageRenderer(content: QeetrixEmptyState("No accounts yet", level: 2).frame(width: 390)).cgImage != nil)
    }

    @Test("Actions are centred in rows that wrap, 8 pt apart")
    func actionsLayout() throws {
        let row = QeetrixFeedbackActionsLayout(spacing: 8, alignment: .center) {
            Color.blue.frame(width: 30, height: 20)
            Color.red.frame(width: 30, height: 20)
        }
        let one = try #require(Rendered(row.frame(width: 100)))
        #expect(one.height == 20)
        #expect(one.pixel(10, 10).a == 0, "Space at the start")
        #expect(one.pixel(90, 10).a == 0, "and at the end")
        #expect(one.pixel(25, 10).b > 200)
        #expect(one.pixel(70, 10).r > 200)
        let wrapped = try #require(Rendered(row.frame(width: 50)))
        #expect(wrapped.height == 20 + 8 + 20)
    }

    @Test("Footer and actions together, and all three title forms, render")
    func renders() {
        let footer = QeetrixEmptyState("No accounts yet", description: "Add one to sign in.", icon: .userPlus) {
            QeetrixButton("Add account") {}
        } footer: {
            Text(verbatim: "Or scan a code")
        }
        #expect(ImageRenderer(content: footer.frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixEmptyState(title: Text("No accounts yet")).frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixEmptyState(String("No accounts yet")).frame(width: 390)).cgImage != nil)
    }
}
