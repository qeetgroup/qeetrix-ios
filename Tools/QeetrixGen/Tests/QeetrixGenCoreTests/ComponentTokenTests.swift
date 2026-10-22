import Foundation
import Testing

@testable import QeetrixGenCore

/// Component tokens (ADR 0002, ADR 0011): generated only for the groups pins.json adopts.
@Suite("Component tokens")
struct ComponentTokenTests {
    func source() throws -> TokenSource {
        func read(_ name: String) throws -> Data {
            try Data(contentsOf: SnapshotTests.root.appendingPathComponent("Upstream/qeetrix-ui/\(name)"))
        }
        return try TokenSource(
            tokensJSON: try read("tokens.json"), tokensCSS: String(decoding: try read("tokens.css"), as: UTF8.self),
            indexCSS: String(decoding: try read("index.css"), as: UTF8.self))
    }

    @Test("An adopted group is generated in full; every other group is excluded with the reason")
    func adoption() throws {
        let source = try source()
        let model = try TokenModel(source: source, adoptedComponents: ["button"])
        let button = model.included.filter { $0.path.starts(with: ["component", "button"]) }
        #expect(!button.isEmpty)
        #expect(button.allSatisfy { $0.kind == .component })
        #expect(button.count == source.paths.filter { $0.starts(with: ["component", "button"]) }.count)
        #expect(!model.included.contains { $0.path.starts(with: ["component", "card"]) })
        #expect(model.excluded.contains { $0.path.starts(with: ["component", "card"]) && $0.reason == Scope.unadoptedComponentReason })
    }

    @Test("A component colour that names a semantic colour stays a reference, so it follows the theme")
    func references() throws {
        let model = try TokenModel(source: try source(), adoptedComponents: ["button"])
        let primary = try #require(model.included.first { $0.path == ["component", "button", "primary", "background"] })
        guard case .colorReference(let light)? = primary.values["light"], case .colorReference(let dark)? = primary.values["dark"] else {
            Issue.record("component.button.primary.background should reference a semantic colour in both themes")
            return
        }
        #expect(light == ["color", "action", "primary"])
        #expect(dark == light)
    }

    @Test("A density-resolved size stays a function of the density")
    func density() throws {
        let model = try TokenModel(source: try source(), adoptedComponents: ["input"])
        let height = try #require(model.included.first { $0.path == ["component", "input", "height"] })
        guard case .densityReference(let metric)? = height.values["light"] else {
            Issue.record("component.input.height should follow the density")
            return
        }
        #expect(metric == "control-height")
    }

    @Test("A component duration becomes a QeetrixDuration")
    func duration() throws {
        let model = try TokenModel(source: try source(), adoptedComponents: ["accordion"])
        let token = try #require(model.included.first { $0.path == ["component", "accordion", "duration"] })
        #expect(token.values["light"] == .duration(0.2))
        #expect(token.values["dark"] == .duration(0.2))
    }

    @Test("Pins naming a group upstream does not define stop the generator")
    func unknownGroup() throws {
        let fixture = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-pins-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: fixture) }
        // Every locked path: the snapshot, and the fonts and notices it pins into the library's bundle.
        for path in ["Upstream", "Sources/Qeetrix/Resources/Fonts", "Sources/Qeetrix/Resources/Licenses"] {
            let target = fixture.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: SnapshotTests.root.appendingPathComponent(path), to: target)
        }
        let pinsURL = fixture.appendingPathComponent(Lock.pinsPath)
        let pins = try String(contentsOf: pinsURL, encoding: .utf8).replacingOccurrences(
            of: "\"switch\",", with: "\"switch\",\n      \"no-such-group\",")
        try Data(pins.utf8).write(to: pinsURL)
        // pins.json is not in the lock, so the snapshot still verifies and the adoption check is what stops it.
        #expect(Lock.check(try Lock.read(root: fixture), root: fixture).isEmpty)
        let error = #expect(throws: GeneratorError.self) { try Generator(root: fixture).outputs() }
        #expect(error?.message.contains("component.no-such-group") == true)
    }
}
