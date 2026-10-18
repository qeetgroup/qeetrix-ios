import Foundation

/// Token path → Swift identifier, one rule for every generated name.
///
/// Segments are joined in lowerCamelCase (`text.on-brand` → `textOnBrand`). Swift identifiers cannot
/// start with a digit, so a leading numeric prefix moves to the end (`2xl` → `xl2`, `2xs` → `xs2`),
/// and a bare `0` becomes `zero`. Any other leading digit fails generation rather than inventing a
/// spelling. Words Swift reserves are escaped with backticks at the use site.
public enum SwiftNames {
    public static func identifier(_ segments: [String], context: String) throws -> String {
        let words = segments.flatMap { $0.split(whereSeparator: { $0 == "-" || $0 == "_" }).map(String.init) }
        guard var first = words.first, !first.isEmpty else {
            throw GeneratorError("\(context): empty identifier.")
        }
        if first.first!.isNumber {
            if first == "0" {
                first = "zero"
            } else if let letters = first.firstIndex(where: { !$0.isNumber }) {
                first = String(first[letters...]) + String(first[..<letters])
            } else {
                throw GeneratorError("\(context): \"\(first)\" cannot start a Swift identifier.")
            }
        }
        let rest = words.dropFirst().map { word in word.prefix(1).uppercased() + word.dropFirst() }
        let name = first.prefix(1).lowercased() + first.dropFirst() + rest.joined()
        guard name.allSatisfy({ $0.isLetter || $0.isNumber }) else {
            throw GeneratorError("\(context): \"\(name)\" is not a valid identifier.")
        }
        return name
    }

    static let reserved: Set<String> = [
        "default", "case", "class", "enum", "extension", "func", "import", "init", "internal", "let", "operator",
        "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "continue",
        "do", "else", "fallthrough", "for", "if", "in", "return", "switch", "where", "while", "as", "is", "nil",
        "self", "Self", "super", "throw", "throws", "true", "false", "try", "repeat", "defer", "guard", "inout",
    ]

    /// The identifier as it must be written in a declaration.
    public static func declaration(_ name: String) -> String {
        reserved.contains(name) ? "`\(name)`" : name
    }

    /// Checks a set of generated names for collisions (two tokens folding to one identifier).
    public static func requireUnique(_ names: [(name: String, source: String)], scope: String) throws {
        var seen: [String: String] = [:]
        for (name, source) in names {
            if let other = seen[name] {
                throw GeneratorError("\(scope): \(source) and \(other) both become \"\(name)\".")
            }
            seen[name] = source
        }
    }
}

/// Deterministic number formatting for generated source: at most six decimals, no trailing zeros,
/// no `-0`, never locale-dependent.
public func swiftNumber(_ value: Double) -> String {
    let rounded = (value * 1_000_000).rounded() / 1_000_000
    if rounded == 0 { return "0" }
    if rounded == rounded.rounded(), abs(rounded) < 1e15 { return String(Int(rounded)) }
    var text = String(format: "%.6f", rounded)
    while text.hasSuffix("0") { text.removeLast() }
    if text.hasSuffix(".") { text.removeLast() }
    return text
}

/// A Swift string literal.
public func swiftString(_ value: String) -> String {
    "\"" + value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
}
