import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Check list")
struct CheckListTests {
    private func render(_ view: some View, width: CGFloat = 390) throws -> Rendered {
        try #require(Rendered(view.frame(width: width).environment(\.colorScheme, .light)))
    }

    @Test("Statuses are @qeetrix/react's, each with its icon and its words")
    func statuses() {
        #expect(QeetrixCheckStatus.allCases.map(\.rawValue) == ["passed", "failed", "pending", "running"])
        #expect(QeetrixCheckStatus.allCases.map(\.icon) == [.circleCheck, .circleX, .circleDashed, nil])
        #expect(QeetrixCheckStatus.allCases.map(\.label) == ["Passed", "Failed", "Not run", "Running"])
    }

    @Test("check-list.css: success and danger for passed and failed, subtle otherwise")
    func colours() {
        #expect(QeetrixCheckStatus.allCases.map(\.iconColor) == [.iconSuccess, .iconDanger, .iconSubtle, .iconSubtle])
        #expect(QeetrixCheckStatus.allCases.map(\.textColor) == [.textSuccess, .textDanger, .textSubtle, .textSubtle])
    }

    @Test("A status change is announced as the title and the new status, at low priority")
    func announcement() {
        let item = QeetrixCheckItem("At least 12 characters", status: .passed)
        #expect(String(item.announcement.characters) == "At least 12 characters, Passed")
        #expect(item.announcement.accessibilitySpeechAnnouncementPriority == .low)
        let relabelled = QeetrixCheckItem("At least 12 characters", status: .passed, statusLabel: "Done")
        #expect(relabelled.statusText == "Done")
        #expect(String(relabelled.announcement.characters) == "At least 12 characters, Done")
        let name = "The metadata URL answers"
        #expect(QeetrixCheckItem(name, status: .running).title == name)
    }

    @Test("Items are at least 3 rem, ruled in border.subtle between them, on a raised sheet with a border.default edge")
    func sheet() throws {
        let list = QeetrixCheckList {
            QeetrixCheckItem("At least 12 characters", status: .passed)
            QeetrixCheckItem("A number", status: .pending)
        }
        let image = try render(list)
        #expect(image.height == 48 + 1 + 48)
        #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(195, 48)))
        #expect(close(QeetrixTheme.light.resolve(.borderDefault).bytes, image.pixel(195, 0)))
        #expect(close(QeetrixTheme.light.resolve(.borderDefault).bytes, image.pixel(0, 24)))
        #expect(close(QeetrixTheme.light.resolve(.surfaceRaised).bytes, image.pixel(100, 3)))
        // The icon, inset.md in: circle-check in icon.success.
        let success = QeetrixTheme.light.resolve(.iconSuccess).bytes
        #expect((12..<28).contains { x in (16..<32).contains { y in close(success, image.pixel(x, y), tolerance: 12) } })
    }

    @Test("The footer is under its own rule, its parts at the two ends")
    func footer() throws {
        let list = QeetrixCheckList {
            QeetrixCheckItem("At least 12 characters", status: .passed)
        } footer: {
            Color.red.frame(width: 40, height: 16)
            Color.blue.frame(width: 40, height: 16)
        }
        let image = try render(list, width: 300)
        // 48 + the rule + inset.sm, 16, inset.sm.
        #expect(image.height == 48 + 1 + 8 + 16 + 8)
        #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(150, 48)))
        #expect(image.pixel(12 + 20, 65).r > 200 && image.pixel(12 + 20, 65).b < 100, "The first part at the start")
        #expect(image.pixel(300 - 12 - 20, 65).b > 200 && image.pixel(300 - 12 - 20, 65).r < 100, "The last at the end")
        #expect(close(QeetrixTheme.light.resolve(.surfaceRaised).bytes, image.pixel(150, 65)), "Space between")
    }

    @Test("The footer's parts wrap onto lines of their own, each at the start")
    func footerWraps() throws {
        let list = QeetrixCheckList {
            QeetrixCheckItem("A", status: .passed)
        } footer: {
            Color.red.frame(width: 150, height: 16)
            Color.blue.frame(width: 150, height: 16)
        }
        let image = try render(list, width: 300)
        #expect(image.height == 48 + 1 + 8 + 16 + 8 + 16 + 8)
        #expect(image.pixel(20, 89).b > 200, "The second line at the start")
    }

    @Test("At the accessibility sizes, the status moves under the text")
    func largeText() throws {
        let item = QeetrixCheckItem("A", status: .failed)
        func statusColumns(_ size: DynamicTypeSize) throws -> [Int] {
            let image = try render(QeetrixCheckList { item }.environment(\.dynamicTypeSize, size))
            let danger = QeetrixTheme.light.resolve(.textDanger).bytes
            // Below the icon, so the icon's own pixels don't count.
            return (60..<image.width).filter { x in (0..<image.height).contains { close(danger, image.pixel(x, $0), tolerance: 20) } }
        }
        #expect(try statusColumns(.large).last ?? 0 > 330, "The status at the end")
        #expect(try statusColumns(.accessibility2).last ?? 400 < 300, "Under the title, at its start")
    }

    #if os(macOS)
        @Test("VoiceOver reads each check as one element, with its status; the footer's parts on their own")
        func accessibility() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixCheckList {
                    QeetrixCheckItem("At least 12 characters", detail: Text("You have 8"), status: .pending)
                    QeetrixCheckItem("A number", status: .passed)
                    QeetrixCheckItem("Not reused", status: .failed)
                    QeetrixCheckItem("The URL answers", status: .running)
                } footer: {
                    Text("Ran just now")
                    QeetrixButton("Run again", variant: .ghost, size: .sm) {}
                })
            #expect(
                elements.map(\.text) == [
                    "At least 12 characters, You have 8, Not run", "A number, Passed", "Not reused, Failed", "The URL answers, Running",
                    "Ran just now", "Run again",
                ], "\(elements)")
        }
    #endif

    @Test("Lists render every status, with a footer, in both schemes, large and right to left")
    func renders() {
        let list = QeetrixCheckList {
            ForEach(QeetrixCheckStatus.allCases, id: \.self) { status in
                QeetrixCheckItem(status.rawValue, detail: Text("Detail"), status: status)
            }
        } footer: {
            Text("Ran just now")
            QeetrixButton("Run again", variant: .ghost, size: .sm) {}
        }
        for scheme in [ColorScheme.light, .dark] {
            #expect(ImageRenderer(content: list.frame(width: 390).environment(\.colorScheme, scheme)).cgImage != nil)
        }
        #expect(ImageRenderer(content: list.frame(width: 390).environment(\.dynamicTypeSize, .accessibility3)).cgImage != nil)
        #expect(ImageRenderer(content: list.frame(width: 390).environment(\.layoutDirection, .rightToLeft)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCheckItem("Alone", status: .passed).frame(width: 390)).cgImage != nil)
    }
}
