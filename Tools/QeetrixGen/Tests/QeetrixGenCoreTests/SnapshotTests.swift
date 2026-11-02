import Foundation
import Testing

@testable import QeetrixGenCore

/// Tests against the committed upstream snapshot: the real tokens, fonts, icons and component manifest.
@Suite("Upstream snapshot")
struct SnapshotTests {
    /// Tools/QeetrixGen/Tests/QeetrixGenCoreTests/SnapshotTests.swift → the repository root.
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // QeetrixGenCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // QeetrixGen
        .deletingLastPathComponent()  // Tools
        .deletingLastPathComponent()

    func model() throws -> TokenModel {
        try Generator(root: Self.root).tokenModel().0
    }

    @Test("The snapshot matches its lock, and names the three npm packages")
    func lock() throws {
        let provenance = try Lock.read(root: Self.root)
        #expect(Lock.check(provenance, root: Self.root).isEmpty)
        #expect(provenance.packages.map(\.name) == ["@qeetrix/tokens", "@qeetrix/icons", "@qeetrix/react"])
        #expect(provenance.packages.allSatisfy { $0.integrity.hasPrefix("sha512-") && $0.gitHead.count == 40 })
    }

    @Test("A changed snapshot file is caught")
    func tamper() throws {
        let provenance = try Lock.read(root: Self.root)
        let altered = Provenance(
            packages: provenance.packages, fonts: provenance.fonts,
            files: provenance.files.map {
                ($0.path, $0.path == "Upstream/qeetrix-tokens/dtcg/light.tokens.json" ? String(repeating: "0", count: 64) : $0.sha256)
            })
        #expect(Lock.check(altered, root: Self.root).count == 1)
    }

    @Test("The resolver gives every context; colour schemes are light then dark, densities default first")
    func contexts() throws {
        let source = try model().source
        #expect(source.colorSchemes == ["light", "dark"])
        #expect(source.densities.first == "default")
        #expect(Set(source.densities) == ["default", "comfortable", "compact"])
        #expect(source.contexts.count == 6)
    }

    @Test("Every token is generated or excluded with a reason; no primitive is generated except the weight scale")
    func scope() throws {
        let model = try model()
        #expect(model.included.count + model.excluded.count == model.source.paths.count)
        let primitives = model.included.filter { $0.path.first == "primitive" }
        #expect(primitives.allSatisfy { $0.group == .fontWeight })
        #expect(model.tokens(.color).count == model.source.paths.filter { $0.first == "color" }.count)
    }

    @Test("Only colours and shadows follow the colour scheme; only the density group follows the density")
    func variation() throws {
        let model = try model()
        for token in model.included {
            switch token.group {
            case .color, .shadow: #expect(token.variation != .density, "\(token.dotted)")
            case .density: #expect(token.variation != .colorScheme, "\(token.dotted)")
            default: #expect(token.variation == .none, "\(token.dotted)")
            }
        }
        #expect(model.token("color.bg.input")?.variation == .colorScheme)
        #expect(model.token("size.control.lg")?.variation == .density)
    }

    @Test("Brand values convert exactly: Ember #d04800 and the dark scheme's #f26d0e border")
    func brand() throws {
        let model = try model()
        let light = TokenContext(colorScheme: "light", density: "default")
        let dark = TokenContext(colorScheme: "dark", density: "default")
        guard case let .color(ember)? = model.token("color.bg.brand.bold")?.values[light],
            case let .color(border)? = model.token("color.border.brand")?.values[dark]
        else { Issue.record("missing brand colours"); return }
        #expect(ember.hex == "#D04800" && ember.space == .sRGB)
        #expect(border.hex == "#F26D0E")
    }

    @Test("Densities give the design rules' control heights: compact 24/28/32, default 28/32/40, comfortable 32/36/44")
    func densities() throws {
        let model = try model()
        func heights(_ density: String) -> [Double] {
            ["sm", "md", "lg"].compactMap {
                guard
                    case let .dimension(points)? = model.token("size.control.\($0)")?.values[
                        TokenContext(colorScheme: "light", density: density)]
                else { return nil }
                return points
            }
        }
        #expect(heights("compact") == [24, 28, 32])
        #expect(heights("default") == [28, 32, 40])
        #expect(heights("comfortable") == [32, 36, 44])
    }

    @Test("Bundled fonts are the TTFs the lock names, with the axes the roles use")
    func fonts() throws {
        let provenance = try Lock.read(root: Self.root)
        let sans = try #require(provenance.fonts.first { $0.family == "sans" })
        #expect(sans.source == "package/dist/fonts/QeetSans.ttf" && sans.madeWith.contains("fontTools"))
        let info = try FontInspector.inspect(try Data(contentsOf: Self.root.appendingPathComponent(sans.destination)), context: "sans")
        #expect(info.familyName == "Cal Sans")
        #expect(Set(info.axes.map(\.tag)).isSuperset(of: ["wght", "opsz", "GEOM", "ital"]))
        let geometry = try #require(info.axes.first { $0.tag == "GEOM" })
        #expect(geometry.minimum == 0 && geometry.maximum == 100)
        #expect(throws: GeneratorError.self) { try FontInspector.inspect(Data("wOF2xxxxxxxx".utf8), context: "woff2") }
    }

    @Test("Every typography role lands on the 4 pt grid and names its letter style, as design rules §5 give it")
    func typography() throws {
        let model = try model()
        let roles = model.tokens(.textRole)
        #expect(roles.count == 18)
        for role in roles {
            guard case let .typography(type) = role.value(model.source.defaultContext) else {
                Issue.record("\(role.dotted) is a typography value")
                continue
            }
            #expect(type.size * type.lineHeight == type.lineHeightLength, "\(role.dotted)")
            #expect(type.lineHeightLength.truncatingRemainder(dividingBy: 4) == 0, "\(role.dotted)")
            let expected = ["display": "display", "heading": "heading", "title": "heading"][role.path[1]] ?? "body"
            #expect(type.geometry == "font.geometry.\(expected)", "\(role.dotted)")
        }
    }

    @Test("Every pinned icon's SVG files read into its manifest's drawings")
    func icons() throws {
        let icons = try IconCatalog.load(
            manifest: try Data(contentsOf: Self.root.appendingPathComponent("Upstream/qeetrix-icons/icons.json")),
            svgDirectory: Self.root.appendingPathComponent("Upstream/qeetrix-icons/svg"))
        #expect(!icons.isEmpty)
        let check = try #require(icons.first { $0.name == "check" })
        #expect(check.drawings.map(\.key) == ["round-outline", "sharp-outline"])
        let sharp = try #require(check.drawings.first { $0.key == "sharp-outline" }?.drawing)
        #expect(sharp.elements.allSatisfy { $0.lineCap == "square" && $0.lineJoin == "miter" })
    }

    @Test("An icon's files must be exactly the drawings its manifest entry lists")
    func iconFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-icons-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let svg = #"<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M18 6 6 18"/></svg>"#
        func write(_ key: String) throws {
            let folder = directory.appendingPathComponent(key)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try Data(svg.utf8).write(to: folder.appendingPathComponent("x.svg"))
        }
        let manifest = Data(
            #"[{ "name": "x", "componentName": "XIcon", "shapes": ["round"], "variants": ["outline"], "directionality": "preserve" }]"#.utf8
        )
        #expect(throws: GeneratorError.self) { try IconCatalog.load(manifest: manifest, svgDirectory: directory) }
        try write("round-outline")
        #expect(try IconCatalog.load(manifest: manifest, svgDirectory: directory).first?.drawings.map(\.key) == ["round-outline"])
        try write("sharp-outline")
        #expect(throws: GeneratorError.self) { try IconCatalog.load(manifest: manifest, svgDirectory: directory) }
    }

    @Test("Generation is deterministic and the committed output is current")
    func deterministic() throws {
        let generator = Generator(root: Self.root)
        let first = try generator.outputs()
        let second = try generator.outputs()
        #expect(first == second)
        #expect(try generator.drift() == [])
    }
}
