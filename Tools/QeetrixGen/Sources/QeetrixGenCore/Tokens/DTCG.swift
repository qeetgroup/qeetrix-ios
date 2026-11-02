import Foundation

/// One combination of the resolver's modifiers: a colour scheme and a density.
public struct TokenContext: Hashable, Sendable, CustomStringConvertible {
    public let colorScheme: String
    public let density: String

    public init(colorScheme: String, density: String) {
        self.colorScheme = colorScheme
        self.density = density
    }

    public var description: String { "\(colorScheme)/\(density)" }
}

/// A token after the resolver has run and every alias is followed.
public struct DTCGToken: Equatable, Sendable {
    public let path: [String]
    /// The DTCG `$type`, its own or inherited from its group.
    public let type: String
    /// The value with every `{alias}` replaced by its target's value, recursively.
    public let value: OrderedJSON
    /// The alias the token was written as, when it was one: `{primitive.color.qeet.600}`.
    public let alias: String?
    /// The resolver source that defined the winning value, e.g. `tokens/modes/color-scheme/dark.tokens.json`.
    public let file: String
    /// `$extensions["in.qeet.qeetrix"]` as written, aliases kept: what the package records beside a
    /// value, such as a typography role's exact line height and its letter style.
    public let qeetrix: OrderedJSON?

    public var dotted: String { path.joined(separator: ".") }

    /// The `$extensions` namespace `@qeetrix/tokens` writes its own metadata under.
    public static let extensionNamespace = "in.qeet.qeetrix"
}

/// The `@qeetrix/tokens` DTCG build, resolved the way its `qeetrix.resolver.json` says: the
/// foundation set, then the colour-scheme modifier, then the density modifier, later sources
/// replacing earlier tokens at the same path. Every combination of the two modifiers is resolved.
///
/// The package also publishes each colour scheme pre-resolved at the default density
/// (`light.tokens.json`, `dark.tokens.json`). The resolution here must reproduce both exactly, token
/// for token, or generation fails: two readings of one build that disagree mean one of them is wrong.
public struct DTCGSource: Sendable {
    /// The colour schemes in resolver order (default first).
    public let colorSchemes: [String]
    /// The densities in resolver order (default first).
    public let densities: [String]
    /// Every combination, colour scheme major.
    public let contexts: [TokenContext]
    /// Token paths in document order: the foundation set's, then any a modifier adds.
    public let paths: [[String]]
    /// The resolved tokens of each context, keyed by dotted path.
    public let tokens: [TokenContext: [String: DTCGToken]]

    /// The modifiers iOS maps. A resolver with any other fails: it needs a native mapping first.
    public static let modifiers = ["colorScheme", "density"]
    /// The colour schemes iOS maps to `ColorScheme`.
    public static let knownColorSchemes = ["light", "dark"]

    public var defaultContext: TokenContext { TokenContext(colorScheme: colorSchemes[0], density: densities[0]) }

    /// - Parameters:
    ///   - resolver: the path of `qeetrix.resolver.json`, relative to `read`'s root.
    ///   - read: returns a file's bytes by path.
    public init(resolver resolverPath: String, read: (String) throws -> Data) throws {
        let directory = resolverPath.split(separator: "/").dropLast().joined(separator: "/")
        func resolve(_ reference: String) -> String {
            var parts = directory.split(separator: "/").map(String.init)
            for part in reference.split(separator: "/") {
                if part == "." { continue }
                if part == ".." { parts.removeLast() } else { parts.append(String(part)) }
            }
            return parts.joined(separator: "/")
        }
        let resolver = try OrderedJSON.parse(try read(resolverPath), context: resolverPath)
        func references(_ list: OrderedJSON?, _ what: String) throws -> [String] {
            guard let items = list?.arrayValue else { throw GeneratorError("\(resolverPath): \(what) has no sources.") }
            return try items.map { item in
                guard let reference = item["$ref"]?.stringValue else {
                    throw GeneratorError("\(resolverPath): \(what) has a source without $ref.")
                }
                return reference
            }
        }

        guard case let .object(modifierPairs)? = resolver["modifiers"] else { throw GeneratorError("\(resolverPath): no modifiers.") }
        guard modifierPairs.map(\.0).sorted() == Self.modifiers.sorted() else {
            throw GeneratorError(
                "\(resolverPath): modifiers are \(modifierPairs.map(\.0)); iOS maps \(Self.modifiers). A new modifier needs a native mapping first."
            )
        }
        var contextsByModifier: [String: [(String, [String])]] = [:]
        for (name, modifier) in modifierPairs {
            guard case let .object(contexts)? = modifier["contexts"], let fallback = modifier["default"]?.stringValue else {
                throw GeneratorError("\(resolverPath): modifier \(name) needs contexts and a default.")
            }
            var ordered = try contexts.map { ($0.0, try references($0.1, "\(name).\($0.0)")) }
            // The default first: it is what `:root` publishes and what the pre-resolved files hold.
            ordered.sort { ($0.0 == fallback ? 0 : 1) < ($1.0 == fallback ? 0 : 1) }
            contextsByModifier[name] = ordered
        }
        colorSchemes = contextsByModifier["colorScheme"]!.map(\.0)
        densities = contextsByModifier["density"]!.map(\.0)
        guard Set(colorSchemes) == Set(Self.knownColorSchemes), colorSchemes.first == "light" else {
            throw GeneratorError(
                "\(resolverPath): colour schemes are \(colorSchemes); iOS maps light (default) and dark. A new scheme needs a QeetrixTheme mapping first."
            )
        }

        guard let order = resolver["resolutionOrder"]?.arrayValue else { throw GeneratorError("\(resolverPath): no resolutionOrder.") }
        var contexts: [TokenContext] = []
        var tokens: [TokenContext: [String: DTCGToken]] = [:]
        var paths: [[String]] = []
        var cache: [String: OrderedJSON] = [:]
        func file(_ path: String) throws -> OrderedJSON {
            if let parsed = cache[path] { return parsed }
            let parsed = try OrderedJSON.parse(try read(path), context: path)
            cache[path] = parsed
            return parsed
        }

        for scheme in colorSchemes {
            for density in densities {
                let context = TokenContext(colorScheme: scheme, density: density)
                var sources: [String] = []
                for step in order {
                    guard let reference = step["$ref"]?.stringValue, reference.hasPrefix("#/") else {
                        throw GeneratorError("\(resolverPath): resolutionOrder entries must be #/ references.")
                    }
                    let parts = reference.dropFirst(2).split(separator: "/").map(String.init)
                    switch (parts.first, parts.count) {
                    case ("sets", 2):
                        sources += try references(resolver["sets"]?[parts[1]]?["sources"], "set \(parts[1])")
                    case ("modifiers", 2):
                        let chosen = parts[1] == "colorScheme" ? scheme : density
                        guard let selected = contextsByModifier[parts[1]]?.first(where: { $0.0 == chosen }) else {
                            throw GeneratorError("\(resolverPath): no context \(chosen) in \(parts[1]).")
                        }
                        sources += selected.1
                    default:
                        throw GeneratorError("\(resolverPath): unsupported resolutionOrder entry \(reference).")
                    }
                }
                var merged: [String: (token: OrderedJSON, type: String?, file: String)] = [:]
                var order: [[String]] = []
                for source in sources {
                    let path = resolve(source)
                    try Self.flatten(try file(path), path: [], type: nil) { tokenPath, token, type in
                        let key = tokenPath.joined(separator: ".")
                        if merged[key] == nil { order.append(tokenPath) }
                        merged[key] = (token, type, source)
                    }
                }
                let raw = merged.mapValues { (value: $0.token["$value"] ?? .null, type: $0.type, file: $0.file) }
                var resolved: [String: DTCGToken] = [:]
                for tokenPath in order {
                    let key = tokenPath.joined(separator: ".")
                    resolved[key] = try Self.resolvedToken(
                        key, raw, qeetrix: Self.qeetrixExtension(merged[key]!.token), context: "\(key) (\(context))")
                }
                if paths.isEmpty {
                    paths = order
                } else if Set(order.map { $0.joined(separator: ".") }) != Set(paths.map { $0.joined(separator: ".") }) {
                    let base = Set(paths.map { $0.joined(separator: ".") })
                    let this = Set(order.map { $0.joined(separator: ".") })
                    throw GeneratorError(
                        "\(context) breaks parity with \(contexts[0]): missing \(base.subtracting(this).sorted().prefix(5)), extra \(this.subtracting(base).sorted().prefix(5))."
                    )
                }
                contexts.append(context)
                tokens[context] = resolved
            }
        }
        self.contexts = contexts
        self.tokens = tokens
        self.paths = paths
    }

    /// Checks the resolution against a pre-resolved file the package publishes for one context
    /// (`light.tokens.json` is light at the default density). Returns one message per disagreement.
    public func disagreements(with resolvedFile: OrderedJSON, context: TokenContext, name: String) throws -> [String] {
        var raw: [String: (value: OrderedJSON, type: String?, file: String)] = [:]
        var extensions: [String: OrderedJSON] = [:]
        var order: [String] = []
        try Self.flatten(resolvedFile, path: [], type: nil) { path, token, type in
            let key = path.joined(separator: ".")
            raw[key] = (token["$value"] ?? .null, type, name)
            extensions[key] = Self.qeetrixExtension(token)
            order.append(key)
        }
        guard let mine = tokens[context] else { return ["\(context) was not resolved."] }
        var problems: [String] = []
        let theirs = Set(order)
        for key in Set(mine.keys).symmetricDifference(theirs).sorted().prefix(10) {
            problems.append("\(key): \(theirs.contains(key) ? "only in \(name)" : "missing from \(name)")")
        }
        for key in order {
            guard let token = mine[key] else { continue }
            let published = try Self.resolvedToken(key, raw, qeetrix: extensions[key], context: "\(name) \(key)")
            if published.type != token.type || Self.canonical(published.value) != Self.canonical(token.value) {
                problems.append(
                    "\(key): the resolver gives \(token.value.compact.prefix(160)) but \(name) has \(published.value.compact.prefix(160))")
            }
            if published.qeetrix.map(Self.canonical) != token.qeetrix.map(Self.canonical) {
                problems.append(
                    "\(key): the resolver gives $extensions[\(DTCGToken.extensionNamespace)] \(token.qeetrix?.compact.prefix(160) ?? "none") but \(name) has \(published.qeetrix?.compact.prefix(160) ?? "none")"
                )
            }
        }
        return problems
    }

    // MARK: Reading

    /// Calls `visit` for every token (an object with `$value`) under `node`, with its path and its
    /// `$type`, inherited from the nearest group that sets one.
    static func flatten(
        _ node: OrderedJSON, path: [String], type: String?, visit: ([String], OrderedJSON, String?) throws -> Void
    ) throws {
        guard case let .object(pairs) = node else { throw GeneratorError("\(path.joined(separator: ".")): expected a group or token.") }
        let type = node["$type"]?.stringValue ?? type
        if node["$value"] != nil {
            try visit(path, node, type)
            return
        }
        for (key, child) in pairs where !key.hasPrefix("$") {
            try flatten(child, path: path + [key], type: type, visit: visit)
        }
    }

    /// A token's `$extensions["in.qeet.qeetrix"]`, if it has one.
    static func qeetrixExtension(_ token: OrderedJSON) -> OrderedJSON? {
        token["$extensions"]?[DTCGToken.extensionNamespace]
    }

    static func resolvedToken(
        _ key: String, _ raw: [String: (value: OrderedJSON, type: String?, file: String)], qeetrix: OrderedJSON?, context: String
    ) throws -> DTCGToken {
        guard let entry = raw[key] else { throw GeneratorError("\(context): no token \(key).") }
        var alias: String?
        var type = entry.type
        if let reference = Self.reference(entry.value) {
            alias = "{\(reference)}"
            if type == nil { type = try Self.targetType(reference, raw, context: context, visiting: [key]) }
        }
        guard let type else { throw GeneratorError("\(context): no $type.") }
        let value = try Self.substitute(entry.value, raw, context: context, visiting: [key])
        return DTCGToken(
            path: key.split(separator: ".").map(String.init), type: type, value: value, alias: alias, file: entry.file, qeetrix: qeetrix)
    }

    /// `"{a.b.c}"` → `a.b.c`.
    static func reference(_ value: OrderedJSON) -> String? {
        guard case let .string(text) = value, text.hasPrefix("{"), text.hasSuffix("}"), text.count > 2 else { return nil }
        return String(text.dropFirst().dropLast())
    }

    static func targetType(
        _ reference: String, _ raw: [String: (value: OrderedJSON, type: String?, file: String)], context: String, visiting: [String]
    ) throws -> String? {
        guard let target = raw[reference] else { throw GeneratorError("\(context): {\(reference)} does not exist.") }
        if let type = target.type { return type }
        guard let next = Self.reference(target.value), !visiting.contains(reference) else { return nil }
        return try targetType(next, raw, context: context, visiting: visiting + [reference])
    }

    static func substitute(
        _ value: OrderedJSON, _ raw: [String: (value: OrderedJSON, type: String?, file: String)], context: String, visiting: [String]
    ) throws -> OrderedJSON {
        if let reference = Self.reference(value) {
            guard !visiting.contains(reference) else {
                throw GeneratorError("\(context): alias cycle \((visiting + [reference]).joined(separator: " → ")).")
            }
            guard let target = raw[reference] else { throw GeneratorError("\(context): {\(reference)} does not exist.") }
            return try substitute(target.value, raw, context: context, visiting: visiting + [reference])
        }
        switch value {
        case let .object(pairs):
            return .object(try pairs.map { ($0.0, try substitute($0.1, raw, context: context, visiting: visiting)) })
        case let .array(items):
            return .array(try items.map { try substitute($0, raw, context: context, visiting: visiting) })
        case let .string(text) where text.contains("{"):
            throw GeneratorError("\(context): \"\(text)\" embeds an alias inside a string, which iOS does not resolve.")
        default:
            return value
        }
    }

    /// A form for comparing values that ignores key order, number spelling (`1` and `1.0`) and
    /// properties left at their DTCG default: a colour's `alpha` of 1, a shadow layer's `inset` of false.
    static func canonical(_ value: OrderedJSON) -> String {
        switch value {
        case var .object(pairs):
            if pairs.contains(where: { $0.0 == "colorSpace" }), !pairs.contains(where: { $0.0 == "alpha" }) {
                pairs.append(("alpha", .number("1")))
            }
            if pairs.contains(where: { $0.0 == "offsetX" }), !pairs.contains(where: { $0.0 == "inset" }) {
                pairs.append(("inset", .bool(false)))
            }
            return "{" + pairs.sorted { $0.0 < $1.0 }.map { "\($0.0):\(canonical($0.1))" }.joined(separator: ",") + "}"
        case let .array(items): return "[" + items.map(canonical).joined(separator: ",") + "]"
        case let .number(text): return Double(text).map { swiftNumber($0) } ?? text
        case let .string(text): return "\"\(text)\""
        case let .bool(flag): return flag ? "true" : "false"
        case .null: return "null"
        }
    }
}

extension OrderedJSON {
    /// One-line JSON, for messages.
    var compact: String {
        serialized().split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: " ")
    }

    var doubleValue: Double? {
        if case let .number(text) = self { return Double(text) }
        return nil
    }
}
