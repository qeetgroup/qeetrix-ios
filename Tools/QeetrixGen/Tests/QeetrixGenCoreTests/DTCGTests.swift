import Foundation
import Testing

@testable import QeetrixGenCore

/// The DTCG resolver reading, on small fixtures: merge order, aliases, inherited types and the failures.
@Suite("DTCG resolution")
struct DTCGTests {
    static let resolver = """
        {
          "sets": { "foundation": { "sources": [{ "$ref": "./a.tokens.json" }] } },
          "modifiers": {
            "colorScheme": { "contexts": { "light": [{ "$ref": "./light.tokens.json" }], "dark": [{ "$ref": "./dark.tokens.json" }] }, "default": "light" },
            "density": { "contexts": { "default": [{ "$ref": "./d.tokens.json" }], "compact": [{ "$ref": "./c.tokens.json" }] }, "default": "default" }
          },
          "resolutionOrder": [{ "$ref": "#/sets/foundation" }, { "$ref": "#/modifiers/colorScheme" }, { "$ref": "#/modifiers/density" }]
        }
        """

    static let files: [String: String] = [
        "t/qeetrix.resolver.json": resolver,
        "t/a.tokens.json": """
        { "primitive": { "space": { "$type": "dimension", "100": { "$value": { "value": 0.25, "unit": "rem" } } } },
          "space": { "gap": { "sm": { "$type": "dimension", "$value": "{primitive.space.100}" } } },
          "color": { "$type": "color", "text": { "$value": { "colorSpace": "oklch", "components": [0, 0, 0], "hex": "#000000" } } } }
        """,
        "t/light.tokens.json": "{}",
        "t/dark.tokens.json": """
        { "color": { "text": { "$type": "color", "$value": { "colorSpace": "oklch", "components": [1, 0, 0], "hex": "#ffffff" } } } }
        """,
        "t/d.tokens.json": #"{ "size": { "row": { "$type": "dimension", "$value": { "value": 40, "unit": "px" } } } }"#,
        "t/c.tokens.json": #"{ "size": { "row": { "$type": "dimension", "$value": { "value": 32, "unit": "px" } } } }"#,
    ]

    func source(_ files: [String: String] = files) throws -> DTCGSource {
        try DTCGSource(resolver: "t/qeetrix.resolver.json") { path in
            guard let text = files[path] else { throw GeneratorError("no \(path)") }
            return Data(text.utf8)
        }
    }

    @Test("Later sources win, aliases resolve, and a group's $type is inherited")
    func resolution() throws {
        let source = try source()
        #expect(source.contexts.map(\.description) == ["light/default", "light/compact", "dark/default", "dark/compact"])
        let lightCompact = try #require(source.tokens[TokenContext(colorScheme: "light", density: "compact")])
        #expect(lightCompact["size.row"]?.value["value"]?.doubleValue == 32)
        #expect(lightCompact["space.gap.sm"]?.alias == "{primitive.space.100}")
        #expect(lightCompact["space.gap.sm"]?.value["value"]?.doubleValue == 0.25)
        #expect(lightCompact["primitive.space.100"]?.type == "dimension")
        let dark = try #require(source.tokens[TokenContext(colorScheme: "dark", density: "default")])
        #expect(dark["color.text"]?.value["hex"]?.stringValue == "#ffffff")
        #expect(dark["color.text"]?.file == "./dark.tokens.json")
    }

    @Test("The resolution is compared with a pre-resolved file, token for token")
    func preResolved() throws {
        let source = try source()
        let same = try OrderedJSON.parse(Data(Self.files["t/a.tokens.json"]!.utf8), context: "a")
        var merged = try source.disagreements(with: same, context: TokenContext(colorScheme: "light", density: "default"), name: "a")
        #expect(merged.contains { $0.contains("size.row") && $0.contains("missing from a") })
        let wrong = try OrderedJSON.parse(
            Data(
                ##"{ "color": { "text": { "$type": "color", "$value": { "colorSpace": "oklch", "components": [0.5, 0, 0], "hex": "#636363" } } } }"##
                    .utf8),
            context: "w")
        merged = try source.disagreements(with: wrong, context: TokenContext(colorScheme: "light", density: "default"), name: "w")
        #expect(merged.contains { $0.hasPrefix("color.text:") })
    }

    @Test("A cycle, a dangling alias and an unknown modifier fail")
    func failures() throws {
        var files = Self.files
        files["t/a.tokens.json"] = #"{ "x": { "$type": "number", "a": { "$value": "{x.b}" }, "b": { "$value": "{x.a}" } } }"#
        #expect(throws: GeneratorError.self) { try source(files) }
        files["t/a.tokens.json"] = #"{ "x": { "$type": "number", "a": { "$value": "{x.missing}" } } }"#
        #expect(throws: GeneratorError.self) { try source(files) }
        files = Self.files
        files["t/qeetrix.resolver.json"] = Self.resolver.replacingOccurrences(of: "\"density\"", with: "\"contrast\"")
        #expect(throws: GeneratorError.self) { try source(files) }
    }

    /// One typography role, as 0.0.13 writes it: the ratio in `$value`, the length and the letter
    /// style in the Qeetrix extension.
    static func typography(ratio: String = "1.4285714285714286", extensions: String? = nil) -> String {
        let qeetrix =
            extensions ?? #"{ "fontGeometry": "{font.geometry.body}", "lineHeight": { "value": 1.25, "unit": "rem" } }"#
        return """
            { "color": { "$type": "color", "text": { "$value": { "colorSpace": "oklch", "components": [0, 0, 0], "hex": "#000000" } } },
              "font": { "geometry": { "$type": "number", "body": { "$value": 0 } } },
              "typography": { "body": { "md": { "$type": "typography",
                "$value": { "fontFamily": ["Qeet Sans"], "fontSize": { "value": 0.875, "unit": "rem" }, "fontWeight": 400,
                            "letterSpacing": { "value": 0, "unit": "px" }, "lineHeight": \(ratio) },
                "$extensions": { "in.qeet.qeetrix": \(qeetrix) } } } } }
            """
    }

    @Test("A typography role takes its exact line height and its letter style from its extension")
    func typographyExtension() throws {
        var files = Self.files
        files["t/a.tokens.json"] = Self.typography()
        let model = try TokenModel(source: try source(files))
        guard case let .typography(type)? = model.token("typography.body.md")?.value(model.source.defaultContext) else {
            Issue.record("typography.body.md is a typography value")
            return
        }
        #expect(type.lineHeightLength == 20 && type.size * type.lineHeight == 20)
        #expect(type.geometry == "font.geometry.body" && type.geometryPosition == 0)

        // A pre-resolved file whose extension differs disagrees.
        let other = try OrderedJSON.parse(
            Data(
                Self.typography(extensions: #"{ "fontGeometry": "{font.geometry.body}", "lineHeight": { "value": 1.5, "unit": "rem" } }"#)
                    .utf8),
            context: "o")
        let problems = try model.source.disagreements(with: other, context: model.source.defaultContext, name: "o")
        #expect(problems.contains { $0.hasPrefix("typography.body.md:") && $0.contains("$extensions") })

        // The ratio must be the length over the size, and both entries must be there.
        files["t/a.tokens.json"] = Self.typography(ratio: "1.4286")
        #expect(throws: GeneratorError.self) { try TokenModel(source: try source(files)) }
        files["t/a.tokens.json"] = Self.typography(extensions: #"{ "lineHeight": { "value": 1.25, "unit": "rem" } }"#)
        #expect(throws: GeneratorError.self) { try TokenModel(source: try source(files)) }
        files["t/a.tokens.json"] = Self.typography(extensions: #"{ "fontGeometry": "{font.geometry.body}" }"#)
        #expect(throws: GeneratorError.self) { try TokenModel(source: try source(files)) }
    }

    @Test("Every scope rule maps; an unknown group fails")
    func scope() throws {
        #expect(try Scope.decide(path: ["color", "bg", "brand", "bold"]) == .include(.color, drop: 1))
        #expect(try Scope.decide(path: ["size", "control", "lg"]) == .include(.density, drop: 0))
        #expect(try Scope.decide(path: ["primitive", "font", "weight", "regular"]) == .include(.fontWeight, drop: 3))
        guard case .exclude = try Scope.decide(path: ["primitive", "color", "qeet", "600"]) else {
            Issue.record("primitives are excluded")
            return
        }
        #expect(throws: GeneratorError.self) { try Scope.decide(path: ["gradient", "brand"]) }
    }
}
