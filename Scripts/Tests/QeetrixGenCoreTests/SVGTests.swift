import Foundation
import Testing

@testable import QeetrixGenCore

@Suite("SVG reading")
struct SVGTests {
    @Test("Compact path data: implicit line-tos, signs as separators, chained decimals")
    func compactNumbers() throws {
        #expect(try PathData.parse("M18 6 6 18", context: "t") == [.move(18, 6), .line(6, 18)])
        #expect(try PathData.parse("m6 6 12 12", context: "t") == [.move(6, 6), .line(18, 18)])
        #expect(try PathData.parse("M1.5.5h2v-1z", context: "t") == [.move(1.5, 0.5), .line(3.5, 0.5), .line(3.5, -0.5), .close])
        #expect(try PathData.parse("M0 0L1-2", context: "t") == [.move(0, 0), .line(1, -2)])
    }

    @Test("Smooth curves reflect the previous control point")
    func smoothCurves() throws {
        let commands = try PathData.parse("M0 0C1 1 2 1 3 0S5-1 6 0", context: "t")
        #expect(commands[2] == .cubic(4, -1, 5, -1, 6, 0))
    }

    @Test("Arcs become cubics that land exactly on the endpoint, with compact flags")
    func arcs() throws {
        let commands = try PathData.parse("M10 12a2 2 0 014 0", context: "t")
        guard case let .cubic(_, _, _, _, x, y) = commands.last else {
            Issue.record("expected a cubic")
            return
        }
        #expect(x == 14 && y == 12)
        // A half circle of radius 2 is two quarter-circle cubics; its midpoint lies on the circle.
        #expect(commands.count == 3)
        if case let .cubic(_, _, _, _, mx, my) = commands[1] {
            #expect(abs(hypot(mx - 12, my - 12) - 2) < 1e-9)
        }
    }

    @Test("Elements, inheritance and per-element paint")
    func elements() throws {
        let svg = """
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="square" stroke-linejoin="miter" stroke-miterlimit="4">
              <rect x="3" y="11" width="18" height="11" rx="2"/>
              <circle cx="12" cy="7" r=".5" fill="currentColor"/>
              <path d="M7 4h.01" stroke-linecap="round"/>
              <polygon points="3 11 22 2 13 21"/>
            </svg>
            """
        let drawing = try SVGParser.parse(Data(svg.utf8), context: "t")
        #expect(drawing.miterLimit == 4)
        #expect(drawing.elements[0].commands == [.roundedRect(3, 11, 18, 11, 2, 2)])
        #expect(drawing.elements[0].stroke && !drawing.elements[0].fill && drawing.elements[0].lineCap == "square")
        #expect(drawing.elements[1].fill && drawing.elements[1].stroke)
        #expect(drawing.elements[1].commands == [.ellipse(11.5, 6.5, 1, 1)])
        #expect(drawing.elements[2].lineCap == "round")
        #expect(drawing.elements[3].commands.last == .close)
    }

    @Test(
        "Anything outside the supported subset fails",
        arguments: [
            ##"<svg viewBox="0 0 24 24"><g><path d="M0 0"/></g></svg>"##,
            ##"<svg viewBox="0 0 24 24"><path d="M0 0" transform="rotate(45)"/></svg>"##,
            ##"<svg viewBox="0 0 24 24" fill="#F26D0E"><path d="M0 0L1 1"/></svg>"##,
            ##"<svg viewBox="0 0 32 32"><path d="M0 0L1 1"/></svg>"##,
            ##"<svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path d="M0 0L1 1"/></svg>"##,
        ])
    func rejects(svg: String) {
        #expect(throws: GeneratorError.self) { try SVGParser.parse(Data(svg.utf8), context: "t") }
    }
}

@Suite("Swift names")
struct SwiftNamesTests {
    @Test(
        "Token paths become lowerCamelCase identifiers",
        arguments: [
            (["text", "on-brand"], "textOnBrand"),
            (["data", "categorical", "1"], "dataCategorical1"),
            (["2xl"], "xl2"),
            (["0"], "zero"),
            (["label-compact"], "labelCompact"),
            (["ramp", "2xs"], "ramp2xs"),
        ])
    func identifiers(path: [String], expected: String) throws {
        #expect(try SwiftNames.identifier(path, context: "t") == expected)
    }

    @Test("Collisions and impossible names fail; keywords are escaped")
    func failures() {
        #expect(throws: GeneratorError.self) { try SwiftNames.requireUnique([("a", "x.a"), ("a", "x.A")], scope: "t") }
        #expect(throws: GeneratorError.self) { try SwiftNames.identifier(["12"], context: "t") }
        #expect(SwiftNames.declaration("default") == "`default`")
    }

    @Test("Generated numbers are stable and locale-free")
    func numbers() {
        #expect(swiftNumber(10.08) == "10.08")
        #expect(swiftNumber(48) == "48")
        #expect(swiftNumber(-0.0000001) == "0")
        #expect(swiftNumber(0.1234567) == "0.123457")
    }
}
