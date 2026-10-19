import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Menu")
struct MenuTests {
    @Test("Titled and icon-only triggers render, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let titled = QeetrixMenu("Sort", icon: .navigation) {
                QeetrixMenuItem("Newest") {}
            }
            let iconOnly = QeetrixMenu(icon: .ellipsis, label: "More actions") {
                QeetrixMenuItem("Rename", icon: .pencil) {}
                QeetrixMenuItem("Delete", icon: .trash, role: .destructive) {}
            }
            #expect(ImageRenderer(content: titled.environment(\.colorScheme, scheme)).cgImage != nil)
            #expect(ImageRenderer(content: iconOnly.environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }

    @Test("Items keep their role and icon")
    func items() {
        let delete = QeetrixMenuItem("Delete", icon: .trash, role: .destructive) {}
        #expect(delete.role == .destructive)
        #expect(delete.icon == .trash)
        #expect(QeetrixMenuItem("Rename") {}.role == nil)
    }

    @Test("The trigger takes the density's height")
    func density() throws {
        func height(_ density: QeetrixDensity) throws -> Int {
            let menu = QeetrixMenu("Sort") { QeetrixMenuItem("Newest") {} }.qeetrixDensity(density)
            return try #require(Rendered(menu)).height
        }
        #expect(try height(.compact) < height(.comfortable))
    }
}
