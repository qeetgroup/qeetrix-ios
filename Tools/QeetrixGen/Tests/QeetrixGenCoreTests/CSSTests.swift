import Foundation
import Testing

@testable import QeetrixGenCore

@Suite("CSS reading")
struct CSSTests {
    @Test("Declarations keep their innermost selector and ignore comments")
    func declarations() {
        let css = """
            /* --ignored: 1px; */
            :root { --a: 1px; --b: var(--a); }
            .dark { --a: 2px }
            @theme inline { --radius-lg: var(--radius); }
            """
        let found = CSSDeclarations.parse(css)
        #expect(found.map(\.name) == ["--a", "--b", "--a", "--radius-lg"])
        #expect(found.map(\.selector) == [":root", ":root", ".dark", "@theme inline"])
        #expect(found[1].value == "var(--a)")
    }

    @Test("var() resolves recursively, uses fallbacks, and rejects cycles and unknown names")
    func variables() throws {
        let resolver = CSSVariableResolver(variables: [
            "--radius": "0.45rem", "--radius-xl": "calc(var(--radius) * 1.4)", "--loop": "var(--loop)",
        ])
        #expect(try resolver.substitute("var(--radius-xl)", context: "t") == "calc(0.45rem * 1.4)")
        #expect(try resolver.substitute("var(--missing, var(--radius))", context: "t") == "0.45rem")
        #expect(throws: GeneratorError.self) { try resolver.substitute("var(--loop)", context: "t") }
        #expect(throws: GeneratorError.self) { try resolver.substitute("var(--missing)", context: "t") }
    }

    @Test("Lengths: px, rem against a 16 pt root, calc() and min()")
    func lengths() throws {
        func points(_ value: String) throws -> Double {
            try CSSValues.dimension(try CSSParser.parse(value, context: "t"), context: "t")
        }
        #expect(try points("14px") == 14)
        #expect(try points("0.8rem") == 12.8)
        #expect(try points("0") == 0)
        #expect(abs(try points("calc(0.45rem * 1.4)") - 10.08) < 1e-9)
        #expect(try points("calc(2px + 0.25rem - 1px)") == 5)
        #expect(abs(try points("min(calc(0.45rem * 0.8), 6px)") - 5.76) < 1e-9)
        #expect(throws: GeneratorError.self) { try points("50vw") }
        #expect(throws: GeneratorError.self) { try points("calc(2px * 3px)") }
    }

    @Test("Durations, easings and font stacks")
    func scalars() throws {
        #expect(try CSSValues.duration(try CSSParser.parse("150ms", context: "t"), context: "t") == 0.15)
        #expect(try CSSValues.easing(try CSSParser.parse("cubic-bezier(0.4, 0, 0.2, 1)", context: "t"), context: "t") == [0.4, 0, 0.2, 1])
        #expect(try CSSValues.easing(try CSSParser.parse("linear", context: "t"), context: "t") == [0, 0, 1, 1])
        let stack = try CSSParser.parse("\"Qeet Sans\", ui-sans-serif, system-ui, sans-serif", context: "t")
        #expect(try CSSValues.primaryFontFamily(stack, context: "t") == "Qeet Sans")
        #expect(throws: GeneratorError.self) { try CSSValues.easing(try CSSParser.parse("steps(4)", context: "t"), context: "t") }
    }

    @Test("box-shadow lists keep offsets, blur, spread, inset and colour")
    func shadows() throws {
        let value = "0 1px 2px -1px rgb(12 12 12 / 0.08), inset 0 1px 0 rgb(255 255 255 / 0.04)"
        let layers = try CSSValues.shadows(try CSSParser.parse(value, context: "t"), context: "t")
        #expect(layers.count == 2)
        #expect(layers[0].inset == false && layers[0].y == 1 && layers[0].blur == 2 && layers[0].spread == -1)
        #expect(abs(layers[0].color.red - 12.0 / 255) < 1e-6 && layers[0].color.alpha == 0.08)
        #expect(layers[1].inset && layers[1].blur == 0 && layers[1].color.alpha == 0.04)
        #expect(try CSSValues.shadows(try CSSParser.parse("none", context: "t"), context: "t").isEmpty)
    }
}
