import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Elevation")
struct ElevationTests {
    @Test("Layers differ per theme and keep the web's spread and inset layers")
    func layers() {
        let light = QeetrixElevation.overlay.layers(for: .light)
        let dark = QeetrixElevation.overlay.layers(for: .dark)
        #expect(light != dark)
        #expect(light.contains { $0.spread < 0 })
        // The 1 pt ring: no offset, no blur, spread 1.
        #expect(light.contains { $0.x == 0 && $0.y == 0 && $0.blur == 0 && $0.spread == 1 })
        // Dark overlays add a top highlight inside the surface.
        #expect(dark.contains { $0.isInset && $0.y == 1 })
        #expect(QeetrixElevation.flat.layers(for: .light).isEmpty)
    }

    @Test("A surface draws its fill inside and its shadow outside, below the shape")
    @MainActor
    func renders() throws {
        let card = Color.clear
            .frame(width: 40, height: 40)
            .qeetrixElevation(.modal, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
            .padding(30)
            .background(Color.white)
        let image = try #require(Rendered(card))
        #expect(image.width == 100 && image.height == 100)
        let fill = QeetrixTheme.light.resolve(.surfaceElevated).bytes
        #expect(close(fill, image.pixel(50, 50)))
        // Below the card, inside the 24 pt-offset shadow: darker than the white page.
        let below = image.pixel(50, 75)
        #expect(below.r < 250)
        // Far above the card the page is untouched — the shadow falls downward.
        #expect(image.pixel(50, 2).r >= 250)
    }

    @Test("A theme override changes the elevation drawn")
    @MainActor
    func followsTheme() throws {
        func render(_ theme: QeetrixTheme) throws -> (r: Int, g: Int, b: Int, a: Int) {
            let card = Color.clear
                .frame(width: 20, height: 20)
                .qeetrixElevation(.raised, fill: .surfaceElevated, in: Rectangle())
                .padding(10)
                .qeetrixTheme(theme)
            return try #require(Rendered(card)).pixel(20, 20)
        }
        #expect(close(QeetrixTheme.light.resolve(.surfaceElevated).bytes, try render(.light)))
        #expect(close(QeetrixTheme.dark.resolve(.surfaceElevated).bytes, try render(.dark)))
    }
}
