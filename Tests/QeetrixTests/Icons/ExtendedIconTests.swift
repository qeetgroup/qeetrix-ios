import Foundation
import Testing

@testable import Qeetrix
@testable import QeetrixIconsExtended

@Suite("Extended icons")
struct ExtendedIconTests {
    /// Every icon `@qeetrix/icons` publishes, as the snapshot holds them.
    static func upstream() throws -> [String: [String: Any]] {
        let manifest = try Repository.json("Upstream/qeetrix-icons/icons.json") as? [[String: Any]] ?? []
        return Dictionary(uniqueKeysWithValues: manifest.map { ($0["name"] as? String ?? "", $0) })
    }

    @Test("The core and the extended catalogue are the whole package, once")
    func wholePackage() throws {
        let core = QeetrixIconName.allCases.map(\.rawValue)
        let extended = QeetrixIconName.extendedCases.map(\.rawValue)
        #expect(extended == extended.sorted())
        #expect(Set(core).isDisjoint(with: extended))
        let upstream = try Self.upstream().keys.sorted()
        #expect((core + extended).sorted() == upstream)
        // @qeetrix/icons 2.1.2: 1,863 icons in outline, 775 of them filled too.
        #expect(core.count + extended.count == 1863)
        #expect((QeetrixIconName.allCases + QeetrixIconName.extendedCases).filter { $0.hasDrawing(.round, .filled) }.count == 775)
    }

    @Test("Drawings and mirroring follow the manifest")
    func manifest() throws {
        let upstream = try Self.upstream()
        for icon in QeetrixIconName.extendedCases {
            let entry = try #require(upstream[icon.rawValue])
            let shapes = entry["shapes"] as? [String] ?? []
            let variants = entry["variants"] as? [String] ?? []
            for shape in QeetrixIconShape.allCases {
                for variant in QeetrixIconVariant.allCases {
                    let listed = shapes.contains(shape.rawValue) && variants.contains(variant.rawValue)
                    #expect(icon.hasDrawing(shape, variant) == listed, "\(icon.rawValue) \(shape)-\(variant)")
                }
            }
            #expect(icon.mirrorsInRightToLeft == (entry["directionality"] as? String == "mirror"), "\(icon.rawValue)")
        }
    }

    @Test("Names read as their upstream name, and compare by it")
    func names() {
        #expect(QeetrixIconName.alarmClock.rawValue == "alarm-clock")
        #expect(QeetrixIconName.extendedCases.contains(.alarmClock))
        #expect(QeetrixIconName.alarmClock != .send)
        // The core lookup by raw value covers the core catalogue only.
        #expect(QeetrixIconName(rawValue: "alarm-clock") == nil)
        // A directional icon outside the core set mirrors, as on the web.
        #expect(QeetrixIconName.logOut.mirrorsInRightToLeft)
        // Swift keywords are names too.
        #expect(QeetrixIconName.package.rawValue == "package")
        #expect(QeetrixIconName.repeat.rawValue == "repeat")
    }

    @Test("Every drawing decodes")
    func everyDrawingDecodes() {
        var count = 0
        for icon in QeetrixIconName.extendedCases {
            for shape in QeetrixIconShape.allCases {
                for variant in QeetrixIconVariant.allCases where icon.hasDrawing(shape, variant) {
                    let drawing = icon.drawing(shape, variant)
                    let drawn = drawing.map { !$0.elements.isEmpty && $0.elements.allSatisfy { !$0.commands.isEmpty } }
                    #expect(drawn == true, "\(icon.rawValue) \(shape)-\(variant)")
                    count += 1
                }
            }
        }
        // 1,763 icons in two outline shapes, and the filled ones in two filled shapes.
        #expect(count > 1763 * 2)
    }
}

@Suite("Icon drawing encoding")
struct IconDrawingDecodingTests {
    @Test("Every flag and command decodes")
    func decodes() throws {
        let drawing = QeetrixIconDrawing(
            encoded: "4|-srrM8 2L8 5Z|essmM-1.5 0.25Q1 2 3 4C1 2 3 4 5 6.125|n-bbE3 3 18 18R2 4 20 16 2 2", icon: "test")
        #expect(drawing.miterLimit == 4)
        #expect(drawing.elements.count == 3)
        let (stroked, evenOdd, nonZero) = (drawing.elements[0], drawing.elements[1], drawing.elements[2])
        #expect(stroked.fill == nil)
        #expect(stroked.stroke?.cap == .round && stroked.stroke?.join == .round)
        #expect(stroked.commands.count == 3)
        #expect(evenOdd.fill == .evenOdd && evenOdd.stroke?.cap == .square && evenOdd.stroke?.join == .miter)
        #expect(evenOdd.path.boundingRect.minX == -1.5)
        #expect(nonZero.fill == .nonZero && nonZero.stroke == nil)
        #expect(nonZero.path.boundingRect == CGRect(x: 2, y: 3, width: 20, height: 18))
    }

    @Test("A core drawing decodes to the generated geometry")
    func core() throws {
        // x: M18 6 6 18 and m6 6 12 12.
        let x = try #require(QeetrixIconName.x.drawing(.round, .outline))
        #expect(x.elements.map(\.path.boundingRect).reduce(CGRect.null) { $0.union($1) } == CGRect(x: 6, y: 6, width: 12, height: 12))
    }
}
