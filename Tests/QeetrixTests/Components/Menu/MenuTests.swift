import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Menu")
struct MenuTests {
    @Test("Titled and icon-only triggers render, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let titled = QeetrixMenu("Export", icon: .share2) {
                QeetrixMenuItem("Export as CSV", icon: .copy, description: Text("Opens in a spreadsheet")) {}
            }
            let iconOnly = QeetrixMenu(icon: .ellipsis, label: "Actions for Priya Sharma") {
                QeetrixMenuItem("Edit", icon: .pencil) {}
                QeetrixMenuItem("Remove", icon: .trash, tone: .danger) {}
            }
            #expect(ImageRenderer(content: titled.environment(\.colorScheme, scheme)).cgImage != nil)
            #expect(ImageRenderer(content: iconOnly.environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }

    @Test("Items keep their tone, icon and description; danger is the system's destructive role")
    func items() {
        #expect(QeetrixMenuItemTone.allCases.map(\.rawValue) == ["default", "danger"])
        let remove = QeetrixMenuItem("Remove", icon: .trash, tone: .danger) {}
        #expect(remove.tone == .danger && remove.icon == .trash)
        #expect(QeetrixMenuItem("Rename") {}.tone == .default)
        #expect(QeetrixMenuItem("Export", description: Text("CSV")) {}.description != nil)
    }

    @Test("Text triggers are soft buttons with a trailing chevron; icon-only ones neutral ghosts")
    func triggers() {
        let titled = QeetrixMenu("Sort") { QeetrixMenuItem("Newest") {} }
        #expect(titled.variant == .soft && titled.tone == .brand && titled.icon == .chevronDown && !titled.isIconOnly)
        let iconOnly = QeetrixMenu(icon: .ellipsis, label: "More") { QeetrixMenuItem("Newest") {} }
        #expect(iconOnly.variant == .ghost && iconOnly.tone == .neutral && iconOnly.isIconOnly)
    }

    @Test("The trigger takes the density's height")
    func density() throws {
        func height(_ density: QeetrixDensity) throws -> Int {
            let menu = QeetrixMenu("Sort") { QeetrixMenuItem("Newest") {} }.qeetrixDensity(density)
            return try #require(Rendered(menu)).height
        }
        #expect(try height(.compact) == 28)
        #expect(try height(.comfortable) == 36)
    }
}
