import Foundation

/// A JSON value that keeps object keys in document order. Token order carries meaning — a spacing
/// scale runs small to large, typography roles run display to code — and `JSONSerialization`
/// discards it.
public indirect enum OrderedJSON: Equatable, Sendable {
    case object([(String, OrderedJSON)])
    case array([OrderedJSON])
    case string(String)
    case number(String)
    case bool(Bool)
    case null

    public static func == (lhs: OrderedJSON, rhs: OrderedJSON) -> Bool {
        switch (lhs, rhs) {
        case let (.object(a), .object(b)): a.count == b.count && zip(a, b).allSatisfy { $0.0 == $1.0 && $0.1 == $1.1 }
        case let (.array(a), .array(b)): a == b
        case let (.string(a), .string(b)): a == b
        case let (.number(a), .number(b)): a == b
        case let (.bool(a), .bool(b)): a == b
        case (.null, .null): true
        default: false
        }
    }

    public subscript(key: String) -> OrderedJSON? {
        guard case let .object(pairs) = self else { return nil }
        return pairs.first { $0.0 == key }?.1
    }

    public var stringValue: String? {
        if case let .string(value) = self { return value }
        return nil
    }

    public var arrayValue: [OrderedJSON]? {
        if case let .array(value) = self { return value }
        return nil
    }

    /// Pretty-printed with two-space indentation, keys in insertion order, a trailing newline — the
    /// same bytes for the same value, so generated JSON never shows spurious diffs.
    public func serialized() -> String {
        render(indent: "") + "\n"
    }

    private func render(indent: String) -> String {
        let inner = indent + "  "
        switch self {
        case let .object(pairs):
            if pairs.isEmpty { return "{}" }
            let body = pairs.map { "\(inner)\(Self.quote($0.0)): \($0.1.render(indent: inner))" }.joined(separator: ",\n")
            return "{\n\(body)\n\(indent)}"
        case let .array(items):
            if items.isEmpty { return "[]" }
            let body = items.map { "\(inner)\($0.render(indent: inner))" }.joined(separator: ",\n")
            return "[\n\(body)\n\(indent)]"
        case let .string(value): return Self.quote(value)
        case let .number(value): return value
        case let .bool(value): return value ? "true" : "false"
        case .null: return "null"
        }
    }

    static func quote(_ value: String) -> String {
        var out = "\""
        for scalar in value.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            default:
                if scalar.value < 0x20 {
                    out += String(format: "\\u%04x", scalar.value)
                } else {
                    out.unicodeScalars.append(scalar)
                }
            }
        }
        return out + "\""
    }

    public static func parse(_ data: Data, context: String) throws -> OrderedJSON {
        guard let text = String(data: data, encoding: .utf8) else {
            throw GeneratorError("\(context): not UTF-8.")
        }
        var parser = Parser(scalars: Array(text.unicodeScalars), context: context)
        let value = try parser.value()
        parser.skipWhitespace()
        guard parser.position == parser.scalars.count else {
            throw GeneratorError("\(context): trailing content after the JSON value.")
        }
        return value
    }

    private struct Parser {
        let scalars: [Unicode.Scalar]
        let context: String
        var position = 0

        init(scalars: [Unicode.Scalar], context: String) {
            self.scalars = scalars
            self.context = context
        }

        mutating func skipWhitespace() {
            while position < scalars.count, [" ", "\n", "\r", "\t"].contains(scalars[position]) { position += 1 }
        }

        mutating func expect(_ scalar: Unicode.Scalar) throws {
            skipWhitespace()
            guard position < scalars.count, scalars[position] == scalar else {
                throw GeneratorError("\(context): expected \"\(scalar)\" at offset \(position).")
            }
            position += 1
        }

        mutating func value() throws -> OrderedJSON {
            skipWhitespace()
            guard position < scalars.count else { throw GeneratorError("\(context): unexpected end of JSON.") }
            switch scalars[position] {
            case "{":
                position += 1
                var pairs: [(String, OrderedJSON)] = []
                skipWhitespace()
                if scalars[position] == "}" {
                    position += 1
                    return .object(pairs)
                }
                while true {
                    skipWhitespace()
                    let key = try string()
                    if pairs.contains(where: { $0.0 == key }) {
                        throw GeneratorError("\(context): duplicate key \"\(key)\".")
                    }
                    try expect(":")
                    pairs.append((key, try value()))
                    skipWhitespace()
                    if scalars[position] == "," {
                        position += 1
                        continue
                    }
                    try expect("}")
                    return .object(pairs)
                }
            case "[":
                position += 1
                var items: [OrderedJSON] = []
                skipWhitespace()
                if scalars[position] == "]" {
                    position += 1
                    return .array(items)
                }
                while true {
                    items.append(try value())
                    skipWhitespace()
                    if scalars[position] == "," {
                        position += 1
                        continue
                    }
                    try expect("]")
                    return .array(items)
                }
            case "\"":
                return .string(try string())
            case "t":
                try literal("true")
                return .bool(true)
            case "f":
                try literal("false")
                return .bool(false)
            case "n":
                try literal("null")
                return .null
            default:
                var text = ""
                while position < scalars.count, "-+.eE0123456789".unicodeScalars.contains(scalars[position]) {
                    text.unicodeScalars.append(scalars[position])
                    position += 1
                }
                guard !text.isEmpty, Double(text) != nil else {
                    throw GeneratorError("\(context): invalid JSON at offset \(position).")
                }
                return .number(text)
            }
        }

        mutating func literal(_ word: String) throws {
            for scalar in word.unicodeScalars {
                guard position < scalars.count, scalars[position] == scalar else {
                    throw GeneratorError("\(context): invalid literal at offset \(position).")
                }
                position += 1
            }
        }

        mutating func string() throws -> String {
            guard position < scalars.count, scalars[position] == "\"" else {
                throw GeneratorError("\(context): expected a string at offset \(position).")
            }
            position += 1
            var result = String.UnicodeScalarView()
            while position < scalars.count {
                let scalar = scalars[position]
                position += 1
                switch scalar {
                case "\"":
                    return String(result)
                case "\\":
                    guard position < scalars.count else { break }
                    let escape = scalars[position]
                    position += 1
                    switch escape {
                    case "n": result.append("\n")
                    case "t": result.append("\t")
                    case "r": result.append("\r")
                    case "b": result.append("\u{08}")
                    case "f": result.append("\u{0C}")
                    case "u":
                        guard position + 4 <= scalars.count,
                            let code = UInt32(String(String.UnicodeScalarView(scalars[position..<position + 4])), radix: 16),
                            let decoded = Unicode.Scalar(code)
                        else { throw GeneratorError("\(context): bad \\u escape.") }
                        result.append(decoded)
                        position += 4
                    default: result.append(escape)
                    }
                default:
                    result.append(scalar)
                }
            }
            throw GeneratorError("\(context): unterminated string.")
        }
    }
}
