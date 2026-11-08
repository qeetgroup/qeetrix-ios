import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Icons")
struct IconTests {
    @Test("Names are the pinned @qeetrix/icons 2.1.0 names")
    func names() throws {
        let pins = try Repository.json("Upstream/pins.json") as? [String: Any]
        let pinned = (pins?["icons"] as? [String: Any])?["icons"] as? [String] ?? []
        #expect(QeetrixIconName.allCases.map(\.rawValue).sorted() == pinned.sorted())
        #expect(QeetrixIconName.allCases.count == 88)
        #expect(QeetrixIconName(rawValue: "chevron-right") == .chevronRight)
        #expect(QeetrixIconName(rawValue: "file-spreadsheet") == .fileSpreadsheet)
    }

    @Test("Drawings exist for every shape and variant the manifest lists")
    func drawings() throws {
        let manifest = try Repository.json("Upstream/qeetrix-icons/icons.json") as? [[String: Any]] ?? []
        #expect(manifest.count == QeetrixIconName.allCases.count)
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

    @Test("The native Qeet ID apps' icons are there, sharp, as on Android")
    func authenticator() throws {
        let names = [
            "arrow-right", "shield-check", "shield-x", "hourglass", "timer", "link", "external-link", "scan-face",
            "scan-qr-code", "rectangle-ellipsis", "key", "scan-line", "lock-open", "bell-off", "wifi-off",
            "fingerprint-pattern",
        ]
        for raw in names {
            let name = try #require(QeetrixIconName(rawValue: raw), "\(raw) is not in the catalogue")
            #expect(name.drawing(.sharp, .outline) != nil, "\(raw) has no sharp outline")
        }
    }

    @Test("A physical arrow mirrors only when its use says so; a directional icon always does")
    @MainActor
    func mirroringByUse() {
        #expect(QeetrixIcon(.arrowRight).mirrors == false)
        #expect(QeetrixIcon(.arrowRight, mirrorsInRightToLeft: true).mirrors == true)
        #expect(QeetrixIcon(.externalLink, mirrorsInRightToLeft: true).mirrors == true)
        #expect(QeetrixIcon(.send).mirrors == true)
        #expect(QeetrixIcon(.send, mirrorsInRightToLeft: false).mirrors == false)
    }

    @Test("Paths keep the 24-unit geometry of the drawing")
    func geometry() throws {
        // x: M18 6 6 18 and m6 6 12 12.
        let x = try #require(QeetrixIconName.x.drawing(.round, .outline))
        let bounds = x.elements.map(\.path.boundingRect).reduce(CGRect.null) { $0.union($1) }
        #expect(bounds == CGRect(x: 6, y: 6, width: 12, height: 12))
        // search: circle cx 11 cy 11 r 8.
        let search = try #require(QeetrixIconName.search.drawing(.round, .outline))
        #expect(search.elements.contains { $0.path.boundingRect == CGRect(x: 3, y: 3, width: 16, height: 16) })
        // Sharp drawings use square caps and mitres; round ones round — the shape Qeetrix's controls use.
        for name in QeetrixIconName.allCases {
            let sharp = try #require(name.drawing(.sharp, .outline), "\(name)")
            for element in sharp.elements where element.stroke != nil {
                #expect(element.stroke?.cap == .square && element.stroke?.join == .miter, "\(name)")
            }
        }
        #expect(x.elements.first?.stroke?.cap == .round)
        #expect(x.elements.first?.stroke?.join == .round)
        // Filled drawings fill, with the SVG's fill rule.
        let filled = try #require(QeetrixIconName.search.drawing(.round, .filled))
        #expect(filled.elements.allSatisfy { $0.fill != nil && $0.stroke == nil })
    }

    @Test("A missing variant falls back to the outline")
    @MainActor
    func fallback() {
        let icon = QeetrixIcon(.x, variant: .filled)
        #expect(icon.drawing.elements.first?.stroke != nil)
    }

    @Test("Icons are decorative unless labelled")
    @MainActor
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
            Rendered(QeetrixIcon(.x, size: .lg, relativeTo: nil).foregroundStyle(QeetrixColor.iconBrand).qeetrixTheme(.light)))
        #expect(close(QeetrixTheme.light.resolve(.iconBrand).bytes, themed.pixel(12, 12), tolerance: 8))
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

    @Test("A \"next\" arrow flips in right to left when its use says so, and only then")
    @MainActor
    func arrowMirroredByUse() throws {
        func inkColumns(_ direction: LayoutDirection, mirrors: Bool?) throws -> [Int] {
            let icon =
                mirrors.map { QeetrixIcon(.arrowRight, size: .lg, relativeTo: nil, mirrorsInRightToLeft: $0) }
                ?? QeetrixIcon(.arrowRight, size: .lg, relativeTo: nil)
            let view =
                icon
                .foregroundStyle(Color.black).background(Color.white)
                .environment(\.layoutDirection, direction)
            let image = try #require(Rendered(view))
            return (0..<image.width).map { x in (0..<image.height).filter { image.pixel(x, $0).r < 128 }.count }
        }
        let ltr = try inkColumns(.leftToRight, mirrors: nil)
        #expect(try inkColumns(.rightToLeft, mirrors: nil) == ltr)
        #expect(try inkColumns(.rightToLeft, mirrors: true) == Array(ltr.reversed()))
    }

    /// Phase 7: the icon artwork's notice travels in the library's bundle, as the fonts' licences do, so an
    /// app that ships the icons ships the MIT, Lucide (ISC) and Feather (MIT) notices with them.
    @Test("The icons' licence is in the library's bundle, byte for byte the pinned upstream licence")
    func licence() throws {
        let url = try #require(Bundle.module.url(forResource: "qeetrix-icons-LICENSE", withExtension: "txt", subdirectory: "Licenses"))
        let bundled = try Data(contentsOf: url)
        #expect(bundled == (try Repository.data("Upstream/qeetrix-icons/LICENSE")))
        let text = String(decoding: bundled, as: UTF8.self)
        for notice in ["MIT License", "Lucide", "ISC License", "Feather"] {
            #expect(text.contains(notice), "The notice names \(notice)")
        }
    }
}
