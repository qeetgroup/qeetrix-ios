import Foundation

/// The upstream token artifacts as published in `@qeetrix/ui`: `tokens.json` (Style Dictionary's
/// resolved values per theme), `tokens.css` (the runtime variables; its `--qx-*` names are the
/// consumable layer — primitives are deliberately absent) and `index.css` (only for the `--radius-*`
/// scale, which the semantic `corner.*` tokens reference).
public struct TokenSource: Sendable {
    /// Token paths in `tokens.json` order, e.g. `["color", "text", "primary"]`.
    public let paths: [[String]]
    /// Raw values per theme, keyed by dotted path.
    public let values: [String: [String: String]]
    /// The themes in registry order (base first).
    public let themes: [String]
    /// The `--qx-*` names declared on `:root` in tokens.css: semantic + component, never primitives.
    public let consumableNames: Set<String>
    /// Variable tables per theme, for `var()` resolution.
    public let resolvers: [String: CSSVariableResolver]

    /// The selector each upstream theme's variables are published under (scripts/config/themes.json).
    /// A theme missing from this table fails generation: it needs an iOS mapping first.
    public static let themeSelectors: [String: String] = ["light": ":root", "dark": ".dark"]
    static let ignoredSelectorPrefixes = ["[data-qx-density="]

    public init(tokensJSON: Data, tokensCSS: String, indexCSS: String) throws {
        let root = try OrderedJSON.parse(tokensJSON, context: "tokens.json")
        guard case let .object(top) = root else {
            throw GeneratorError("tokens.json: top level is not an object.")
        }
        let themes = top.map(\.0).filter { !$0.hasPrefix("$") }
        guard !themes.isEmpty else { throw GeneratorError("tokens.json: no themes.") }
        for theme in themes where Self.themeSelectors[theme] == nil {
            throw GeneratorError(
                "tokens.json: theme \"\(theme)\" has no iOS mapping. Add it to TokenSource.themeSelectors and to QeetrixTheme before regenerating."
            )
        }
        self.themes = themes

        var paths: [[String]] = []
        var values: [String: [String: String]] = [:]
        for theme in themes {
            guard let tree = root[theme] else {
                throw GeneratorError("tokens.json: theme \"\(theme)\" is missing.")
            }
            var leaves: [([String], String)] = []
            try Self.flatten(tree, path: [], into: &leaves)
            if theme == themes[0] {
                paths = leaves.map(\.0)
            } else {
                let base = Set(paths.map { $0.joined(separator: ".") })
                let this = Set(leaves.map { $0.0.joined(separator: ".") })
                if base != this {
                    let missing = base.subtracting(this).sorted().prefix(5)
                    let extra = this.subtracting(base).sorted().prefix(5)
                    throw GeneratorError(
                        "tokens.json: theme \"\(theme)\" breaks parity with \"\(themes[0])\" — missing \(Array(missing)), extra \(Array(extra))."
                    )
                }
            }
            for (path, value) in leaves {
                values[path.joined(separator: "."), default: [:]][theme] = value
            }
        }
        self.paths = paths
        self.values = values

        // tokens.css: the consumable names and the per-theme variable tables.
        let declarations = CSSDeclarations.parse(tokensCSS)
        var perSelector: [String: [String: String]] = [:]
        for declaration in declarations {
            if Self.ignoredSelectorPrefixes.contains(where: declaration.selector.hasPrefix) { continue }
            guard Self.themeSelectors.values.contains(declaration.selector) else {
                throw GeneratorError(
                    "tokens.css: unexpected selector \"\(declaration.selector)\" — a new theme or scope needs an iOS mapping.")
            }
            perSelector[declaration.selector, default: [:]][declaration.name] = declaration.value
        }
        consumableNames = Set((perSelector[":root"] ?? [:]).keys.filter { $0.hasPrefix("--qx-") })

        // index.css: the `--radius-*` scale only. Anything else there is web layout, not a token.
        var radius: [String: String] = [:]
        for declaration in CSSDeclarations.parse(indexCSS) where declaration.name.hasPrefix("--radius-") {
            if let existing = radius[declaration.name], existing != declaration.value {
                throw GeneratorError("index.css: \(declaration.name) is declared twice with different values.")
            }
            radius[declaration.name] = declaration.value
        }

        var resolvers: [String: CSSVariableResolver] = [:]
        let base = perSelector[":root"] ?? [:]
        for theme in themes {
            var table = radius
            table.merge(base) { $1 }
            if let selector = Self.themeSelectors[theme], selector != ":root" {
                table.merge(perSelector[selector] ?? [:]) { $1 }
            }
            resolvers[theme] = CSSVariableResolver(variables: table)
        }
        self.resolvers = resolvers

        // The two artifacts come from one Style Dictionary run; prove it for every consumable token.
        for path in paths {
            let name = Self.cssName(for: path)
            guard consumableNames.contains(name), path.first != "component" else { continue }
            for theme in themes {
                let selector = Self.themeSelectors[theme]!
                let css = perSelector[selector]?[name] ?? perSelector[":root"]?[name]
                if css != values[path.joined(separator: ".")]?[theme] {
                    throw GeneratorError(
                        "\(path.joined(separator: ".")) (\(theme)): tokens.json says \(values[path.joined(separator: ".")]?[theme] ?? "nil") but tokens.css says \(css ?? "nil")."
                    )
                }
            }
        }
    }

    public static func cssName(for path: [String]) -> String {
        "--qx-" + path.joined(separator: "-")
    }

    static func flatten(_ node: OrderedJSON, path: [String], into leaves: inout [([String], String)]) throws {
        switch node {
        case let .object(pairs):
            for (key, child) in pairs where !key.hasPrefix("$") {
                try flatten(child, path: path + [key], into: &leaves)
            }
        case let .string(value), let .number(value):
            leaves.append((path, value))
        default:
            throw GeneratorError("tokens.json: \(path.joined(separator: ".")) has an unsupported value.")
        }
    }
}
