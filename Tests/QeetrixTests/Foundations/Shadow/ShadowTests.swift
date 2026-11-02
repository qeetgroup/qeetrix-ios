import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Shadows")
struct ShadowTests {
    @Test("Five shadows, from shadow.*, matching the DTCG layers in both schemes", arguments: ["light", "dark"])
    func layers(scheme: String) throws {
        #expect(
            QeetrixShadow.allCases.map(\.rawValue) == [
                "shadow.raised", "shadow.raised-hover", "shadow.overlay", "shadow.modal", "shadow.inset",
            ])
        let tokens = try Repository.dtcg(scheme)
        let colorScheme: ColorScheme = scheme == "dark" ? .dark : .light
        for shadow in QeetrixShadow.allCases {
            let expected = try #require(
                tokens[shadow.rawValue]?.value as? [[String: Any]] ?? (tokens[shadow.rawValue]?.value as? [String: Any]).map { [$0] })
            let layers = shadow.layers(for: colorScheme)
            #expect(layers.count == expected.count, "\(shadow)")
            for (layer, source) in zip(layers, expected) {
                #expect(Double(layer.x) == Repository.points(source["offsetX"]) ?? 0)
                #expect(Double(layer.y) == Repository.points(source["offsetY"]) ?? 0)
                #expect(Double(layer.blur) == Repository.points(source["blur"]) ?? 0)
                #expect(Double(layer.spread) == Repository.points(source["spread"]) ?? 0)
                #expect(layer.isInset == (source["inset"] as? Bool ?? false))
            }
        }
    }

    @Test("Overlay and modal keep the web's negative spreads and the 1 pt ring; dark adds an inset highlight")
    func shape() {
        let light = QeetrixShadow.overlay.layers(for: .light)
        let dark = QeetrixShadow.overlay.layers(for: .dark)
        #expect(light != dark)
        #expect(light.contains { $0.spread < 0 })
        #expect(light.contains { $0.x == 0 && $0.y == 0 && $0.blur == 0 && $0.spread == 1 })
        #expect(dark.contains { $0.isInset && $0.y == 1 })
        #expect(QeetrixShadow.inset.layers(for: .light).allSatisfy { $0.isInset })
    }

    @Test("A surface draws its fill inside and its shadow outside, below the shape")
    @MainActor
    func renders() throws {
        let card = Color.clear
            .frame(width: 40, height: 40)
            .qeetrixShadow(.modal, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.modal))
            .padding(30)
            .background(Color.white)
        let image = try #require(Rendered(card))
        #expect(image.width == 100 && image.height == 100)
        #expect(close(QeetrixTheme.light.resolve(.surfaceOverlay).bytes, image.pixel(50, 50)))
        // Below the card, inside the 24 pt-offset shadow: darker than the white page.
        #expect(image.pixel(50, 75).r < 250)
        // Far above the card the page is untouched — the shadow falls downward.
        #expect(image.pixel(50, 2).r >= 250)
    }

    @Test("A theme override changes the shadow and fill drawn")
    @MainActor
    func followsTheme() throws {
        func render(_ theme: QeetrixTheme) throws -> (r: Int, g: Int, b: Int, a: Int) {
            let card = Color.clear
                .frame(width: 20, height: 20)
                .qeetrixShadow(.raised, fill: .surfaceRaised, in: Rectangle())
                .padding(10)
                .qeetrixTheme(theme)
            return try #require(Rendered(card)).pixel(20, 20)
        }
        #expect(close(QeetrixTheme.light.resolve(.surfaceRaised).bytes, try render(.light)))
        #expect(close(QeetrixTheme.dark.resolve(.surfaceRaised).bytes, try render(.dark)))
    }
}
