import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Icons")
struct IconTests {
    @Test("Names are the pinned qeetrix-icons names")
    func names() throws {
        let pins = try JSONSerialization.jsonObject(with: try Repository.data("Upstream/pins.json")) as? [String: Any]
        let pinned = (pins?["qeetrixIcons"] as? [String: Any])?["icons"] as? [String] ?? []
        #expect(QeetrixIconName.allCases.map(\.rawValue).sorted() == pinned.sorted())
    }

    @Test("Drawings exist for every shape and variant the manifest lists")
    func drawings() throws {
        let manifest =
            try JSONSerialization.jsonObject(with: try Repository.data("Upstream/qeetrix-icons/icons.json")) as? [[String: Any]]
            ?? []
        for entry in manifest {
            let name = try #require(QeetrixIconName(rawValue: entry["name"] as? String ?? ""))
            let shapes = entry["shapes"] as? [String] ?? []
            let variants = entry["variants"] as? [String] ?? []
            for shape in QeetrixIconShape.allCases {
                for variant in QeetrixIconVariant.allCases {
                    let listed = shapes.contains(shape.rawValue) && variants.contains(variant.rawValue)
                    #expect((name.drawing(shape, variant) != nil) == listed, "\(name) \(shape)-\(variant)")
                }
            }
            #expect(name.mirrorsInRightToLeft == (entry["directionality"] as? String == "mirror"))
        }
    }

    @Test("Paths keep the 24-unit geometry of the SVG")
    func geometry() throws {
        // x: M18 6 6 18 and m6 6 12 12.
        let x = try #require(QeetrixIconName.x.drawing(.round, .outline))
        let bounds = x.elements.map(\.path.boundingRect).reduce(CGRect.null) { $0.union($1) }
        #expect(bounds == CGRect(x: 6, y: 6, width: 12, height: 12))
        // search: circle cx 11 cy 11 r 8.
        let search = try #require(QeetrixIconName.search.drawing(.round, .outline))
        #expect(search.elements.contains { $0.path.boundingRect == CGRect(x: 3, y: 3, width: 16, height: 16) })
        // Sharp drawings use square caps and mitres; round ones round.
        #expect(QeetrixIconName.x.drawing(.sharp, .outline)?.elements.first?.stroke?.cap == .square)
        #expect(x.elements.first?.stroke?.cap == .round)
        // Filled drawings fill, with the SVG's fill rule.
        let filled = try #require(QeetrixIconName.search.drawing(.round, .filled))
        #expect(filled.elements.allSatisfy { $0.fill != nil && $0.stroke == nil })
    }

    @Test("A missing variant falls back to the outline")
    func fallback() {
        let icon = QeetrixIcon(.x, variant: .filled)
        #expect(icon.drawing.elements.first?.stroke != nil)
    }

    @Test("Icons are decorative unless labelled")
    func accessibility() {
        guard case .hidden = QeetrixIcon(.search).accessibility else {
            Issue.record("an unlabelled icon must be hidden from VoiceOver")
            return
        }
        guard case .image = QeetrixIcon(.lock, label: Text("Locked")).accessibility else {
            Issue.record("a labelled icon must be an image")
            return
        }
    }

    @Test("Icons draw in the foreground colour, at the requested size")
    @MainActor
    func renders() throws {
        let icon = QeetrixIcon(.x, size: .lg, relativeTo: nil).foregroundStyle(Color.black).background(Color.white)
        let image = try #require(Rendered(icon))
        #expect(image.width == 24 && image.height == 24)
        #expect(image.pixel(12, 12).r < 60)  // the crossing of the two strokes
        #expect(image.pixel(1, 12).r > 240)  // outside the drawing
        let themed = try #require(
            Rendered(QeetrixIcon(.x, size: .lg, relativeTo: nil).foregroundStyle(QeetrixColor.textBrand).qeetrixTheme(.light)))
        #expect(close(QeetrixTheme.light.resolve(.textBrand).bytes, themed.pixel(12, 12), tolerance: 8))
    }

    @Test("Mirrored icons flip in right-to-left layouts")
    @MainActor
    func mirroring() throws {
        func inkColumns(_ direction: LayoutDirection) throws -> [Int] {
            let view = QeetrixIcon(.send, size: .lg, relativeTo: nil)
                .foregroundStyle(Color.black).background(Color.white)
                .environment(\.layoutDirection, direction)
            let image = try #require(Rendered(view))
            return (0..<image.width).map { x in (0..<image.height).filter { image.pixel(x, $0).r < 128 }.count }
        }
        let ltr = try inkColumns(.leftToRight)
        let rtl = try inkColumns(.rightToLeft)
        #expect(ltr != rtl)
        #expect(ltr == Array(rtl.reversed()))
    }
}
