import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Alert")
struct AlertTests {
    @Test("Tones are @qeetrix/react's, each its tint, its accent, its own icon and its word")
    func tones() {
        #expect(QeetrixAlertTone.allCases.map(\.rawValue) == ["info", "success", "warning", "danger"])
        #expect(QeetrixAlertTone.allCases.map(\.background) == [.bgInfoSubtle, .bgSuccessSubtle, .bgWarningSubtle, .bgDangerSubtle])
        #expect(QeetrixAlertTone.allCases.map(\.accent) == [.iconInfo, .iconSuccess, .iconWarning, .iconDanger])
        #expect(QeetrixAlertTone.allCases.map(\.icon) == [.info, .circleCheck, .triangleAlert, .circleAlert])
        // alert.info … alert.danger in @qeetrix/react's message catalogue.
        #expect(QeetrixAlertTone.allCases.map(\.spokenName) == ["Information", "Success", "Warning", "Error"])
        #expect(QeetrixAlertAnnouncement.allCases.map(\.rawValue) == ["polite", "urgent"])
    }

    @Test("The tone's tint, and its 3 pt edge on the start side, mirrored in right to left")
    func look() throws {
        func image(_ direction: LayoutDirection) throws -> Rendered {
            try #require(
                Rendered(
                    QeetrixAlert("Push notifications are off", tone: .warning)
                        .frame(width: 300).environment(\.colorScheme, .light).environment(\.layoutDirection, direction)))
        }
        let edge = QeetrixTheme.light.resolve(.iconWarning).bytes
        let tint = QeetrixTheme.light.resolve(.bgWarningSubtle).bytes
        let ltr = try image(.leftToRight)
        #expect(close(edge, ltr.pixel(1, ltr.height / 2)))
        #expect(close(tint, ltr.pixel(5, 2)), "The tint starts after the 3 pt edge")
        #expect(close(tint, ltr.pixel(298, ltr.height / 2)))
        let rtl = try image(.rightToLeft)
        #expect(close(edge, rtl.pixel(298, rtl.height / 2)))
        #expect(close(tint, rtl.pixel(1, rtl.height / 2)))
    }

    @Test("12 pt above and below one line of title: 44 pt; the description adds its 2 pt gap and line")
    func height() throws {
        let title = try #require(Rendered(QeetrixAlert("Phone linked", tone: .success).frame(width: 300)))
        // iOS rounds each text block up to the screen's pixel grid (20.33 pt on a 3× screen) and the 1× image to
        // whole points: allow a point per text block. The lines themselves are exact.
        #expect(abs(title.height - (12 + 20 + 12)) <= 1)
        let described = try #require(Rendered(QeetrixAlert("Phone linked", description: "You can approve sign-ins.").frame(width: 300)))
        #expect(abs(described.height - (12 + 20 + 2 + 20 + 12)) <= 2)
    }

    @Test("Actions sit 8 pt under the text, after the body's 2 pt gap")
    func actions() throws {
        let alert = QeetrixAlert("Push notifications are off") {
            Color.blue.frame(width: 40, height: 28)
        }
        let image = try #require(Rendered(alert.frame(width: 300)))
        #expect(abs(image.height - (12 + 20 + 2 + 8 + 28 + 12)) <= 2, "A point per text block on iOS")
    }

    @Test("Actions start at the start of the row, and wrap")
    func actionsLayout() throws {
        let row = QeetrixFeedbackActionsLayout(spacing: 8, alignment: .leading) {
            Color.blue.frame(width: 30, height: 20)
            Color.red.frame(width: 30, height: 20)
        }
        let one = try #require(Rendered(row.frame(width: 100)))
        #expect(one.pixel(10, 10).b > 200)
        #expect(one.pixel(50, 10).r > 200)
        #expect(one.pixel(90, 10).a == 0)
        #expect(try #require(Rendered(row.frame(width: 50))).height == 20 + 8 + 20)
        let wide = QeetrixFeedbackActionsLayout(spacing: 8, alignment: .leading) {
            Text(verbatim: "A label longer than its row")
        }
        // Offered the row's width, the label wraps onto several lines rather than running past the row.
        #expect(try #require(Rendered(wide.frame(width: 60))).height > 2 * 20)
    }

    @Test("Dismiss is a neutral sm icon button at the end, drawn 2 pt into the padding above and below")
    func dismiss() throws {
        var dismissed = 0
        let surface = QeetrixAlertSurface(tone: .info, dismiss: { dismissed += 1 }) { Text(verbatim: "Offline") }
        surface.dismiss?()
        #expect(dismissed == 1)
        #expect(QeetrixAlertSurface(tone: .info) { EmptyView() }.dismiss == nil)
        let image = try #require(Rendered(QeetrixAlert("You're offline", onDismiss: {}).frame(width: 300)))
        // The 28 pt button reaches 2 pt into the padding above and below, so the row is 24 pt.
        #expect(image.height == 12 + (28 - 2 * 2) + 12)
    }

    @Test("VoiceOver reads the tone's word before the title, then the description")
    func spoken() {
        let alert = QeetrixAlert("Push notifications are off", description: "Turn them on in Settings.", tone: .warning)
        #expect(alert.spokenText == "Warning: Push notifications are off, Turn them on in Settings.")
        #expect(QeetrixAlert("Phone linked", tone: .success).spokenText == "Success: Phone linked")
    }

    @Test("Only an alert with announce is announced: polite waits, urgent interrupts")
    func announcements() throws {
        #expect(QeetrixAlert("Phone linked").announcement == nil)
        let urgent = try #require(QeetrixAlert("Couldn't link this phone", tone: .danger, announce: .urgent).announcement)
        #expect(String(urgent.characters) == "Error: Couldn't link this phone")
        #expect(urgent.accessibilitySpeechAnnouncementPriority == .high)
        let polite = try #require(QeetrixAlert("Phone linked", tone: .success, announce: .polite).announcement)
        #expect(polite.accessibilitySpeechAnnouncementPriority == .low)
    }

    @Test("Titles from a literal, a runtime string or a substring; the icon can replace the tone's")
    func initializers() {
        let name = "Priya's iPhone"
        #expect(QeetrixAlert(name, description: "Linked").title == "Priya's iPhone")
        #expect(QeetrixAlert(name.prefix(5)).title == "Priya")
        #expect(QeetrixAlert("Viewing as Priya", icon: .eye).icon == .eye)
        #expect(QeetrixAlert("Literal title").title == "Literal title")
        #expect(ImageRenderer(content: QeetrixAlert("Viewing as Priya", icon: .eye).frame(width: 300)).cgImage != nil)
    }
}
