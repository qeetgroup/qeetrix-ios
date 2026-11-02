import Foundation

// A deliberately small CSS reader. It understands exactly the value grammar Qeetrix's generated
// stylesheets use for the tokens iOS consumes, and rejects everything else by name, so an upstream
// change that introduces new syntax fails the build instead of producing a quietly wrong value.

/// One custom-property declaration and the selector block it sits in.
public struct CSSDeclaration: Equatable, Sendable {
    public let selector: String
    public let name: String
    public let value: String
    /// Every enclosing block, outermost first: `["@media (prefers-reduced-motion: reduce)", ":root"]`.
    public var blocks: [String] = []
}

public enum CSSDeclarations {
    /// Every `--name: value` declaration in `css`, with the innermost enclosing selector.
    /// Comments are ignored; nested at-rule blocks (`@theme inline { … }`) are walked.
    public static func parse(_ css: String) -> [CSSDeclaration] {
        let text = stripComments(css)
        var stack: [String] = []
        var buffer = ""
        var result: [CSSDeclaration] = []

        func flushDeclaration() {
            let statement = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
            buffer = ""
            guard statement.hasPrefix("--"), let colon = statement.firstIndex(of: ":") else { return }
            let name = statement[..<colon].trimmingCharacters(in: .whitespaces)
            let value = statement[statement.index(after: colon)...]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            result.append(CSSDeclaration(selector: stack.last ?? "", name: name, value: value, blocks: stack))
        }

        var depth = 0  // parentheses, so `;` or `{` inside a function never splits a value
        for character in text {
            switch character {
            case "(":
                depth += 1
                buffer.append(character)
            case ")":
                depth -= 1
                buffer.append(character)
            case "{" where depth == 0:
                stack.append(buffer.trimmingCharacters(in: .whitespacesAndNewlines))
                buffer = ""
            case "}" where depth == 0:
                flushDeclaration()
                _ = stack.popLast()
            case ";" where depth == 0:
                flushDeclaration()
            default:
                buffer.append(character)
            }
        }
        return result
    }

    static func stripComments(_ css: String) -> String {
        var out = ""
        var index = css.startIndex
        while index < css.endIndex {
            if css[index...].hasPrefix("/*") {
                guard let end = css.range(of: "*/", range: index..<css.endIndex) else { break }
                index = end.upperBound
            } else {
                out.append(css[index])
                index = css.index(after: index)
            }
        }
        return out
    }
}

/// Resolves `var(--name, fallback)` references against a variable table.
public struct CSSVariableResolver: Sendable {
    public let variables: [String: String]

    public init(variables: [String: String]) {
        self.variables = variables
    }

    /// `value` with every `var()` replaced by its declared value, recursively.
    public func substitute(_ value: String, context: String) throws -> String {
        try substitute(value, context: context, visiting: [])
    }

    private func substitute(_ value: String, context: String, visiting: [String]) throws -> String {
        var output = ""
        var index = value.startIndex
        while let start = value.range(of: "var(", range: index..<value.endIndex) {
            output += value[index..<start.lowerBound]
            let (arguments, end) = try Self.balancedArguments(in: value, openingAt: start.upperBound, context: context)
            let parts = Self.splitTopLevel(arguments, separator: ",", maxSplits: 1)
            let name = parts[0].trimmingCharacters(in: .whitespaces)
            guard name.hasPrefix("--") else {
                throw GeneratorError("\(context): var() names \"\(name)\", which is not a custom property.")
            }
            if visiting.contains(name) {
                throw GeneratorError("\(context): reference cycle \((visiting + [name]).joined(separator: " → ")).")
            }
            if let declared = variables[name] {
                output += try substitute(declared, context: context, visiting: visiting + [name])
            } else if parts.count == 2 {
                output += try substitute(
                    parts[1].trimmingCharacters(in: .whitespaces), context: context, visiting: visiting)
            } else {
                throw GeneratorError("\(context): unresolved reference \(name) — no declaration and no fallback.")
            }
            index = end
        }
        output += value[index...]
        return output
    }

    /// The text between `(` (already consumed) and its matching `)`, and the index after the `)`.
    static func balancedArguments(
        in value: String, openingAt start: String.Index, context: String
    ) throws
        -> (String, String.Index)
    {
        var depth = 1
        var index = start
        while index < value.endIndex {
            switch value[index] {
            case "(": depth += 1
            case ")":
                depth -= 1
                if depth == 0 { return (String(value[start..<index]), value.index(after: index)) }
            default: break
            }
            index = value.index(after: index)
        }
        throw GeneratorError("\(context): unbalanced parentheses in \"\(value)\".")
    }

    static func splitTopLevel(_ text: String, separator: Character, maxSplits: Int = .max) -> [String] {
        var parts: [String] = []
        var current = ""
        var depth = 0
        for character in text {
            if character == "(" { depth += 1 }
            if character == ")" { depth -= 1 }
            if character == separator, depth == 0, parts.count < maxSplits {
                parts.append(current)
                current = ""
            } else {
                current.append(character)
            }
        }
        parts.append(current)
        return parts
    }
}

/// A parsed CSS component value.
public indirect enum CSSComponent: Equatable, Sendable {
    case number(Double, unit: String)
    case ident(String)
    case string(String)
    case function(String, [CSSComponent])
    case delimiter(Character)
}

public enum CSSParser {
    /// Parses a resolved (var-free) value into components. Whitespace separates components and is
    /// otherwise dropped; commas, slashes and calc() operators are kept as delimiters.
    public static func parse(_ value: String, context: String) throws -> [CSSComponent] {
        var scanner = Scanner(Array(value), context: context)
        let components = try scanner.components(untilClosingParenthesis: false)
        return components
    }

    private struct Scanner {
        let characters: [Character]
        let context: String
        var position = 0

        init(_ characters: [Character], context: String) {
            self.characters = characters
            self.context = context
        }

        var current: Character? { position < characters.count ? characters[position] : nil }

        func peek(_ offset: Int) -> Character? {
            position + offset < characters.count ? characters[position + offset] : nil
        }

        mutating func components(untilClosingParenthesis: Bool) throws -> [CSSComponent] {
            var result: [CSSComponent] = []
            while let character = current {
                if character.isWhitespace {
                    position += 1
                } else if character == ")" {
                    guard untilClosingParenthesis else {
                        throw GeneratorError("\(context): unexpected \")\".")
                    }
                    position += 1
                    return result
                } else if character == "," || character == "/" || character == "*" {
                    result.append(.delimiter(character))
                    position += 1
                } else if character == "+" || character == "-", startsNumber(at: position) {
                    result.append(try number())
                } else if character == "+" || character == "-" {
                    result.append(.delimiter(character))
                    position += 1
                } else if character.isNumber || character == "." {
                    result.append(try number())
                } else if character == "\"" || character == "'" {
                    result.append(.string(try string(quote: character)))
                } else if character.isLetter || character == "_" {
                    let name = identifier()
                    if current == "(" {
                        position += 1
                        result.append(.function(name.lowercased(), try components(untilClosingParenthesis: true)))
                    } else {
                        result.append(.ident(name))
                    }
                } else {
                    throw GeneratorError("\(context): unsupported character \"\(character)\".")
                }
            }
            if untilClosingParenthesis {
                throw GeneratorError("\(context): missing \")\".")
            }
            return result
        }

        func startsNumber(at index: Int) -> Bool {
            // "-1px" is a number; "a - b" in calc() is an operator (CSS requires the spaces).
            guard index + 1 < characters.count else { return false }
            let next = characters[index + 1]
            let previousIsSpaceOrStart =
                index == 0 || characters[index - 1].isWhitespace
                || characters[index - 1] == "(" || characters[index - 1] == ","
            return previousIsSpaceOrStart && (next.isNumber || next == ".")
        }

        mutating func number() throws -> CSSComponent {
            var text = ""
            if let sign = current, sign == "+" || sign == "-" {
                text.append(sign)
                position += 1
            }
            while let character = current, character.isNumber || character == "." {
                text.append(character)
                position += 1
            }
            if let e = current, e == "e" || e == "E", let next = peek(1), next.isNumber || next == "-" || next == "+" {
                text.append(e)
                position += 1
                if let sign = current, sign == "-" || sign == "+" {
                    text.append(sign)
                    position += 1
                }
                while let character = current, character.isNumber {
                    text.append(character)
                    position += 1
                }
            }
            guard let value = Double(text) else {
                throw GeneratorError("\(context): \"\(text)\" is not a number.")
            }
            var unit = ""
            if current == "%" {
                unit = "%"
                position += 1
            } else {
                while let character = current, character.isLetter {
                    unit.append(character)
                    position += 1
                }
            }
            return .number(value, unit: unit.lowercased())
        }

        mutating func identifier() -> String {
            var text = ""
            while let character = current, character.isLetter || character.isNumber || character == "-" || character == "_" {
                text.append(character)
                position += 1
            }
            return text
        }

        mutating func string(quote: Character) throws -> String {
            position += 1
            var text = ""
            while let character = current {
                position += 1
                if character == quote { return text }
                text.append(character)
            }
            throw GeneratorError("\(context): unterminated string.")
        }
    }
}

/// Splits a component list on top-level comma delimiters.
func splitOnCommas(_ components: [CSSComponent]) -> [[CSSComponent]] {
    var groups: [[CSSComponent]] = [[]]
    for component in components {
        if component == .delimiter(",") {
            groups.append([])
        } else {
            groups[groups.count - 1].append(component)
        }
    }
    return groups
}
