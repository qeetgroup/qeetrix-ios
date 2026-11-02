import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Theme")
struct ThemeTests {
    @Test("Theme modes use @qeetrix/react's ColorScheme values")
    func modes() {
        #expect(Set(QeetrixThemeMode.allCases.map(\.rawValue)) == ["light", "dark", "system"])
        #expect(QeetrixThemeMode.light.colorScheme == .light)
        #expect(QeetrixThemeMode.dark.colorScheme == .dark)
        #expect(QeetrixThemeMode.system.colorScheme == nil)
        #expect(QeetrixThemeMode(rawValue: "dark") == .dark)
    }

    @Test("The environment's theme follows its colour scheme and contrast")
    func environmentTheme() {
        var values = EnvironmentValues()
        values.colorScheme = .dark
        values._colorSchemeContrast = .increased
        #expect(values.qeetrixTheme == QeetrixTheme(colorScheme: .dark, contrast: .increased))
        #expect(values.qeetrixThemeMode == .system)
    }

    func swatch(_ color: QeetrixColor) -> some View {
        Rectangle().fill(color).frame(width: 4, height: 4)
    }

    @Test("A subtree override draws that scheme's values, and nests")
    @MainActor
    func overrides() throws {
        let dark = try #require(Rendered(swatch(.surfaceDefault).qeetrixTheme(.dark)))
        #expect(close(QeetrixTheme.dark.resolve(.surfaceDefault).bytes, dark.pixel(1, 1)))

        let nested = try #require(Rendered(swatch(.textDefault).qeetrixTheme(.light).qeetrixTheme(.dark)))
        #expect(close(QeetrixTheme.light.resolve(.textDefault).bytes, nested.pixel(1, 1)))

        let inherited = try #require(Rendered(VStack { swatch(.textDefault) }.environment(\.colorScheme, .dark)))
        #expect(close(QeetrixTheme.dark.resolve(.textDefault).bytes, inherited.pixel(1, 1)))
    }

    @Test("qeetrixThemeMode publishes the mode to its subtree")
    @MainActor
    func modePropagates() throws {
        struct Probe: View {
            @Environment(\.qeetrixThemeMode) private var mode
            var body: some View { Rectangle().fill(mode == .dark ? Color.black : Color.white).frame(width: 2, height: 2) }
        }
        let image = try #require(Rendered(Probe().qeetrixThemeMode(.dark)))
        #expect(image.pixel(0, 0).r == 0)
    }

    @Test("A theme gives Color and resolved access to every semantic colour and shadow")
    func themeAccess() {
        for color in QeetrixColor.allCases {
            #expect(QeetrixTheme.dark.resolve(color) == color.rgba(for: .dark).resolved)
        }
        #expect(QeetrixTheme.light.layers(.overlay) == QeetrixShadow.overlay.layers(for: .light))
    }

    @Test("Density: default unless set, and the setting reaches the subtree")
    @MainActor
    func density() throws {
        #expect(EnvironmentValues().qeetrixDensity == .default)
        struct Probe: View {
            @Environment(\.qeetrixDensity) private var density
            var body: some View { Color.black.frame(width: density.sizeControlLg, height: 2) }
        }
        #expect(try #require(Rendered(Probe().qeetrixDensity(.comfortable))).width == 44)
        #expect(try #require(Rendered(Probe().qeetrixDensity(.compact))).width == 32)
    }
}
