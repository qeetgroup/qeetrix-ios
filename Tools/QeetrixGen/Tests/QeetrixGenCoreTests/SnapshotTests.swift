import Foundation
import Testing

@testable import QeetrixGenCore

/// Tests against the committed upstream snapshot: the real tokens, fonts and icons.
@Suite("Upstream snapshot")
struct SnapshotTests {
    /// Tools/QeetrixGen/Tests/QeetrixGenCoreTests/SnapshotTests.swift → the repository root.
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // QeetrixGenCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // QeetrixGen
        .deletingLastPathComponent()  // Tools
        .deletingLastPathComponent()

    func source() throws -> TokenSource {
        func read(_ name: String) throws -> Data {
            try Data(contentsOf: Self.root.appendingPathComponent("Upstream/qeetrix-ui/\(name)"))
        }
        return try TokenSource(
            tokensJSON: try read("tokens.json"),
            tokensCSS: String(decoding: try read("tokens.css"), as: UTF8.self),
            indexCSS: String(decoding: try read("index.css"), as: UTF8.self))
    }

    @Test("The snapshot matches its lock")
    func lock() throws {
        let provenance = try Lock.read(root: Self.root)
        #expect(Lock.check(provenance, root: Self.root).isEmpty)
        #expect(provenance.qeetrixUIPackage == "@qeetrix/ui")
    }

    @Test("A changed snapshot file is caught")
    func tamper() throws {
        let provenance = try Lock.read(root: Self.root)
        let altered = Provenance(
            qeetrixUIPackage: provenance.qeetrixUIPackage, qeetrixUIVersion: provenance.qeetrixUIVersion,
            qeetrixUIGitHead: provenance.qeetrixUIGitHead, qeetrixUIIntegrity: provenance.qeetrixUIIntegrity,
            iconsRepository: provenance.iconsRepository, iconsPackage: provenance.iconsPackage,
            iconsVersion: provenance.iconsVersion, iconsCommit: provenance.iconsCommit, fonts: provenance.fonts,
            files: provenance.files.map { ($0.path, $0.path.hasSuffix("tokens.json") ? String(repeating: "0", count: 64) : $0.sha256) })
        #expect(Lock.check(altered, root: Self.root).count == 1)
    }

    @Test("Themes are light then dark, with identical token paths")
    func parity() throws {
        let source = try source()
        #expect(source.themes == ["light", "dark"])
        for path in source.paths {
            let values = source.values[path.joined(separator: ".")] ?? [:]
            #expect(values.keys.sorted() == ["dark", "light"])
        }
    }

    @Test("Every consumable token is generated or excluded with a reason; no primitive colour is generated")
    func scope() throws {
        let source = try source()
        let model = try TokenModel(source: source)
        #expect(model.included.count + model.excluded.count == source.paths.count)
        #expect(!model.included.contains { $0.path.first == "color" && !$0.consumable })
        #expect(model.tokens(under: ["color"]).count == source.consumableNames.filter { $0.hasPrefix("--qx-color-") }.count)
        #expect(!model.included.contains { $0.path.first == "component" })
    }

    @Test("Semantic corners resolve through the web's --radius-* scale")
    func corners() throws {
        let model = try TokenModel(source: try source())
        func value(_ name: String) -> Double? {
            guard case let .dimension(points)? = model.tokens(under: ["corner", name]).first?.values["light"] else { return nil }
            return points
        }
        // --radius is 0.45rem = 7.2 pt; --radius-lg is --radius, -md ×0.8, -xl ×1.4.
        #expect(abs((value("control") ?? 0) - 7.2) < 1e-9)
        #expect(abs((value("chip") ?? 0) - 5.76) < 1e-9)
        #expect(abs((value("surface") ?? 0) - 10.08) < 1e-9)
    }

    @Test("Bundled fonts are the TTFs the lock names, with the axes the roles use")
    func fonts() throws {
        let provenance = try Lock.read(root: Self.root)
        let sans = try #require(provenance.fonts.first { $0.family == "sans" })
        let info = try FontInspector.inspect(try Data(contentsOf: Self.root.appendingPathComponent(sans.destination)), context: "sans")
        #expect(info.familyName == "Cal Sans")
        #expect(Set(info.axes.map(\.tag)).isSuperset(of: ["wght", "opsz", "GEOM", "ital"]))
        let geometry = try #require(info.axes.first { $0.tag == "GEOM" })
        #expect(geometry.minimum == 0 && geometry.maximum == 100)
        #expect(throws: GeneratorError.self) { try FontInspector.inspect(Data("wOF2xxxxxxxx".utf8), context: "woff2") }
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
