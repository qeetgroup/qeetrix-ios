import SwiftUI
import Testing

@testable import Qeetrix

#if canImport(UIKit)
    import UIKit
#endif

@MainActor
@Suite("Permission primer")
struct PermissionPrimerTests {
    @Test("Five kinds, each with its pinned icon in the sharp outline components draw")
    func kinds() {
        #expect(QeetrixPermissionPrimerKind.allCases.map(\.rawValue) == ["camera", "location", "notifications", "photos", "contacts"])
        #expect(QeetrixPermissionPrimerKind.allCases.map(\.icon) == [.camera, .mapPin, .bell, .image, .contactRound])
        #expect(QeetrixPermissionPrimerKind.allCases.allSatisfy { $0.icon.hasDrawing(.sharp, .outline) })
    }

    @Test("Two statuses: before the system's prompt, and turned off")
    func statuses() {
        #expect(QeetrixPermissionPrimerStatus.allCases.map(\.rawValue) == ["notDetermined", "denied"])
    }

    @Test("The buttons say Continue (never Allow), Not now and Open Settings until the app's words replace them")
    func strings() {
        let english = Locale(identifier: "en")
        func string(_ resource: LocalizedStringResource) -> String {
            var resource = resource
            resource.locale = english
            return String(localized: resource)
        }
        #expect(string(QeetrixPermissionPrimerStrings.continueTitle) == "Continue")
        #expect(string(QeetrixPermissionPrimerStrings.notNow) == "Not now")
        #expect(string(QeetrixPermissionPrimerStrings.openSettings) == "Open Settings")
        let messages = QeetrixPermissionPrimerMessages(continueTitle: Text("Turn on"))
        #expect(messages.continueTitle == Text("Turn on") && messages.notNowTitle == nil && messages.openSettingsTitle == nil)
    }

    @Test("Open Settings opens the app's settings, and for notifications its notification settings")
    func settings() {
        #if canImport(UIKit)
            #expect(QeetrixPermissionPrimer.settingsURL(for: .camera)?.absoluteString == UIApplication.openSettingsURLString)
            #expect(QeetrixPermissionPrimer.settingsURL(for: .photos)?.absoluteString == UIApplication.openSettingsURLString)
            #expect(
                QeetrixPermissionPrimer.settingsURL(for: .notifications)?.absoluteString == UIApplication.openNotificationSettingsURLString)
        #else
            #expect(QeetrixPermissionPrimer.settingsURL(for: .camera) == nil, "No Settings app on the Mac host")
        #endif
    }

    @Test("EmptyState's column: at most 480 pt, its icon 24 pt")
    func layout() throws {
        #expect(QeetrixPermissionPrimerLayout<EmptyView>.maxWidth == 480)
        let wide = try #require(
            Rendered(
                QeetrixPermissionPrimer(.camera, title: "Scan the QR code", message: "The camera reads the code.", onContinue: {})
                    .frame(width: 800)))
        #expect(wide.width == 800)
        // Centred: the 480 pt column leaves 160 pt either side, where nothing is drawn.
        #expect((0..<wide.height).allSatisfy { wide.pixel(100, $0).a == 0 && wide.pixel(700, $0).a == 0 })
    }

    @Test("Continue carries arrow-right and Open Settings external-link; the footnote sits gap.sm under the actions")
    func iconsAndFootnote() throws {
        #expect(QeetrixPermissionPrimerMetrics.continueIcon == .arrowRight)
        #expect(QeetrixPermissionPrimerMetrics.openSettingsIcon == .externalLink)
        func height(_ primer: QeetrixPermissionPrimer) throws -> Int {
            try #require(Rendered(primer.frame(width: 390))).height
        }
        let primer = QeetrixPermissionPrimer(.notifications, title: "Approve sign-ins", message: "From this phone.", onContinue: {})
        #expect(primer.footnoteText == nil)
        let noted = primer.footnote(Text("Only sign-in requests."))
        #expect(noted.footnoteText != nil)
        // 8 pt under the actions, then body.sm's 16 pt line.
        #expect(abs(try height(noted) - (try height(primer)) - (8 + 16)) <= 1)
    }

    @Test("A button's icon mirrors right to left where its use asks: the primer's arrows")
    func arrowsMirror() throws {
        func render(_ mirrors: Bool?, _ direction: LayoutDirection) throws -> Rendered {
            let button = QeetrixButton(title: Text("Continue"), icon: .arrowRight, size: .lg, isFullWidth: true) {}
                .environment(\.qeetrixButtonIconMirrors, mirrors)
                .environment(\.layoutDirection, direction)
                .environment(\.colorScheme, .light)
                .frame(width: 300)
            return try #require(Rendered(button))
        }
        func same(_ a: Rendered, _ b: Rendered) -> Bool {
            a.width == b.width && a.height == b.height
                && (0..<a.height).allSatisfy { y in (0..<a.width).allSatisfy { x in a.pixel(x, y) == b.pixel(x, y) } }
        }
        #expect(same(try render(true, .leftToRight), try render(nil, .leftToRight)), "Left to right, as drawn")
        #expect(!same(try render(true, .rightToLeft), try render(nil, .rightToLeft)), "Right to left, the arrow turns")
        #expect(!QeetrixIconName.arrowRight.mirrorsInRightToLeft, "By its name alone it wouldn't")
    }

    @Test("Every kind renders in both statuses, with and without Not now, and the app's words")
    func renders() {
        for kind in QeetrixPermissionPrimerKind.allCases {
            for status in QeetrixPermissionPrimerStatus.allCases {
                let primer = QeetrixPermissionPrimer(
                    kind, status: status, title: Text("Why"), message: Text("Because."), onContinue: {}, onNotNow: {})
                #expect(ImageRenderer(content: primer.frame(width: 390)).cgImage != nil)
            }
        }
        let custom = QeetrixPermissionPrimer(
            .location, status: .denied, title: "Location is off", message: "Turn it on to find branches near you.",
            messages: QeetrixPermissionPrimerMessages(openSettingsTitle: Text("Go to Settings")), onContinue: {}, onOpenSettings: {})
        #expect(ImageRenderer(content: custom.frame(width: 390)).cgImage != nil)
    }
}
