import Foundation

/// A Qeetrix icon drawing, reduced to absolute path commands in the 24-unit grid.
public struct IconDrawing: Equatable, Sendable {
    public struct Element: Equatable, Sendable {
        public var commands: [PathCommand]
        /// Filled with the foreground colour; `evenOdd` selects the fill rule.
        public var fill: Bool
        public var evenOdd: Bool
        /// Stroked with the foreground colour at the icon's stroke width.
        public var stroke: Bool
        public var lineCap: String
        public var lineJoin: String
    }

    public var miterLimit: Double
    public var elements: [Element]
}

public enum PathCommand: Equatable, Sendable {
    case move(Double, Double)
    case line(Double, Double)
    case quad(Double, Double, Double, Double)
    case cubic(Double, Double, Double, Double, Double, Double)
    case close
    case ellipse(Double, Double, Double, Double)
    case roundedRect(Double, Double, Double, Double, Double, Double)
}

/// Parses the SVG subset qeetrix-icons uses. Anything outside it — transforms, groups, gradients,
/// masks, hard-coded colours, per-element stroke widths — fails with the file and element named, so
/// a drawing never renders differently from the web without someone deciding it should.
public enum SVGParser {
    static let geometry: [String: Set<String>] = [
        "path": ["d"],
        "line": ["x1", "y1", "x2", "y2"],
        "circle": ["cx", "cy", "r"],
        "ellipse": ["cx", "cy", "rx", "ry"],
        "rect": ["x", "y", "width", "height", "rx", "ry"],
        "polyline": ["points"],
        "polygon": ["points"],
    ]
    static let paint: Set<String> = ["fill", "fill-rule", "stroke", "stroke-linecap", "stroke-linejoin"]
    static let root: Set<String> = [
        "xmlns", "viewBox", "fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit",
    ]

    public static func parse(_ data: Data, context: String) throws -> IconDrawing {
        let collector = Collector()
        let parser = XMLParser(data: data)
        parser.delegate = collector
        guard parser.parse() else {
            throw GeneratorError("\(context): invalid SVG — \(parser.parserError?.localizedDescription ?? "unknown error").")
        }
        if let error = collector.error { throw GeneratorError("\(context): \(error)") }
        guard let svg = collector.root else { throw GeneratorError("\(context): no <svg> element.") }

        for key in svg.keys where !root.contains(key) {
            throw GeneratorError("\(context): unsupported <svg> attribute \(key).")
        }
        guard svg["viewBox"] == "0 0 24 24" else {
            throw GeneratorError("\(context): viewBox must be \"0 0 24 24\".")
        }
        if let width = svg["stroke-width"], width != "2" {
            throw GeneratorError("\(context): stroke-width \(width); Qeetrix icons are drawn at 2 and scaled by the stroke token.")
        }

        var elements: [IconDrawing.Element] = []
        for (name, attributes) in collector.elements {
            let label = "\(context) <\(name)>"
            guard let allowed = geometry[name] else { throw GeneratorError("\(label): unsupported element.") }
            for key in attributes.keys where !allowed.contains(key) && !paint.contains(key) {
                throw GeneratorError("\(label): unsupported attribute \(key).")
            }
            func inherited(_ key: String) -> String? { attributes[key] ?? svg[key] }
            let fill = inherited("fill") ?? "black"
            let stroke = inherited("stroke") ?? "none"
            for (key, value) in [("fill", fill), ("stroke", stroke)] where value != "none" && value != "currentColor" {
                throw GeneratorError("\(label): \(key)=\"\(value)\" — icons are drawn in currentColor only.")
            }
            let fillRule = attributes["fill-rule"] ?? "nonzero"
            guard fillRule == "nonzero" || fillRule == "evenodd" else {
                throw GeneratorError("\(label): unsupported fill-rule \(fillRule).")
            }
            let cap = inherited("stroke-linecap") ?? "butt"
            let join = inherited("stroke-linejoin") ?? "miter"
            guard ["butt", "round", "square"].contains(cap), ["miter", "round", "bevel"].contains(join) else {
                throw GeneratorError("\(label): unsupported stroke-linecap/linejoin.")
            }
            elements.append(
                IconDrawing.Element(
                    commands: try commands(name, attributes, context: label),
                    fill: fill != "none", evenOdd: fillRule == "evenodd",
                    stroke: stroke != "none", lineCap: cap, lineJoin: join))
        }
        guard !elements.isEmpty else { throw GeneratorError("\(context): the drawing is empty.") }
        let miterLimit = try svg["stroke-miterlimit"].map { try number($0, context: context) } ?? 4
        return IconDrawing(miterLimit: miterLimit, elements: elements)
    }

    static func number(_ text: String, context: String) throws -> Double {
        guard let value = Double(text.trimmingCharacters(in: .whitespaces)) else {
            throw GeneratorError("\(context): \"\(text)\" is not a number.")
        }
        return value
    }

    static func commands(_ name: String, _ attributes: [String: String], context: String) throws -> [PathCommand] {
        func value(_ key: String, default fallback: Double? = nil) throws -> Double {
            if let text = attributes[key] { return try number(text, context: context) }
            if let fallback { return fallback }
            throw GeneratorError("\(context): missing \(key).")
        }
        switch name {
        case "path":
            return try PathData.parse(attributes["d"] ?? "", context: context)
        case "line":
            return [
                .move(try value("x1", default: 0), try value("y1", default: 0)),
                .line(try value("x2", default: 0), try value("y2", default: 0)),
            ]
        case "circle":
            let r = try value("r")
            return [.ellipse(try value("cx", default: 0) - r, try value("cy", default: 0) - r, 2 * r, 2 * r)]
        case "ellipse":
            let rx = try value("rx")
            let ry = try value("ry")
            return [.ellipse(try value("cx", default: 0) - rx, try value("cy", default: 0) - ry, 2 * rx, 2 * ry)]
        case "rect":
            let width = try value("width")
            let height = try value("height")
            // SVG: a missing rx/ry takes the other's value; both clamp to half the side.
            var rx = attributes["rx"].flatMap { Double($0) }
            var ry = attributes["ry"].flatMap { Double($0) }
            rx = rx ?? ry
            ry = ry ?? rx
            let x = try value("x", default: 0)
            let y = try value("y", default: 0)
            return [.roundedRect(x, y, width, height, min(rx ?? 0, width / 2), min(ry ?? 0, height / 2))]
        case "polyline", "polygon":
            let numbers = try PathData.numbers(attributes["points"] ?? "", context: context)
            guard numbers.count >= 4, numbers.count % 2 == 0 else {
                throw GeneratorError("\(context): points needs an even number of coordinates.")
            }
            var result: [PathCommand] = [.move(numbers[0], numbers[1])]
            for index in stride(from: 2, to: numbers.count, by: 2) { result.append(.line(numbers[index], numbers[index + 1])) }
            if name == "polygon" { result.append(.close) }
            return result
        default:
            throw GeneratorError("\(context): unsupported element.")
        }
    }

    private final class Collector: NSObject, XMLParserDelegate {
        var root: [String: String]?
        var elements: [(String, [String: String])] = []
        var error: String?
        var depth = 0

        func parser(
            _ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?,
            attributes: [String: String] = [:]
        ) {
            depth += 1
            if depth == 1 {
                if elementName != "svg" { error = "the root element is <\(elementName)>, not <svg>." }
                root = attributes
            } else if depth == 2 {
                elements.append((elementName, attributes))
            } else {
                error = "nested element <\(elementName)> — groups are not supported."
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
            depth -= 1
        }
    }
}

/// SVG path data → absolute commands. Smooth curves are expanded and arcs are converted to cubic
/// Béziers (SVG 1.1 implementation notes F.6), so the library only needs move/line/quad/cubic/close.
public enum PathData {
    public static func parse(_ text: String, context: String) throws -> [PathCommand] {
        var scanner = Scanner(Array(text), context: context)
        var result: [PathCommand] = []
        var current = (x: 0.0, y: 0.0)
        var start = (x: 0.0, y: 0.0)
        var lastCubicControl: (x: Double, y: Double)?
        var lastQuadControl: (x: Double, y: Double)?
        var command: Character?

        while true {
            scanner.skipSeparators()
            guard let next = scanner.current else { break }
            if next.isLetter {
                command = next
                scanner.position += 1
            } else if command == nil {
                throw GeneratorError("\(context): path data must start with a command.")
            }
            guard let op = command else { break }
            let relative = op.isLowercase
            func point(_ x: Double, _ y: Double) -> (x: Double, y: Double) {
                relative ? (current.x + x, current.y + y) : (x, y)
            }
            var cubicControl: (x: Double, y: Double)?
            var quadControl: (x: Double, y: Double)?

            switch op.uppercased() {
            case "M":
                let p = point(try scanner.number(), try scanner.number())
                result.append(.move(p.x, p.y))
                current = p
                start = p
                command = relative ? "l" : "L"  // further pairs are implicit line-tos
            case "L":
                let p = point(try scanner.number(), try scanner.number())
                result.append(.line(p.x, p.y))
                current = p
            case "H":
                let x = try scanner.number()
                current = (relative ? current.x + x : x, current.y)
                result.append(.line(current.x, current.y))
            case "V":
                let y = try scanner.number()
                current = (current.x, relative ? current.y + y : y)
                result.append(.line(current.x, current.y))
            case "C":
                let c1 = point(try scanner.number(), try scanner.number())
                let c2 = point(try scanner.number(), try scanner.number())
                let p = point(try scanner.number(), try scanner.number())
                result.append(.cubic(c1.x, c1.y, c2.x, c2.y, p.x, p.y))
                cubicControl = c2
                current = p
            case "S":
                let c1 = lastCubicControl.map { (x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                let c2 = point(try scanner.number(), try scanner.number())
                let p = point(try scanner.number(), try scanner.number())
                result.append(.cubic(c1.x, c1.y, c2.x, c2.y, p.x, p.y))
                cubicControl = c2
                current = p
            case "Q":
                let c = point(try scanner.number(), try scanner.number())
                let p = point(try scanner.number(), try scanner.number())
                result.append(.quad(c.x, c.y, p.x, p.y))
                quadControl = c
                current = p
            case "T":
                let c = lastQuadControl.map { (x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                let p = point(try scanner.number(), try scanner.number())
                result.append(.quad(c.x, c.y, p.x, p.y))
                quadControl = c
                current = p
            case "A":
                let rx = try scanner.number()
                let ry = try scanner.number()
                let rotation = try scanner.number()
                let largeArc = try scanner.flag()
                let sweep = try scanner.flag()
                let p = point(try scanner.number(), try scanner.number())
                result += arc(from: current, rx: rx, ry: ry, rotation: rotation, largeArc: largeArc, sweep: sweep, to: p)
                current = p
            case "Z":
                result.append(.close)
                current = start
            default:
                throw GeneratorError("\(context): unsupported path command \(op).")
            }
            lastCubicControl = cubicControl
            lastQuadControl = quadControl
        }
        return result
    }

    /// The numbers in a `points` list.
    public static func numbers(_ text: String, context: String) throws -> [Double] {
        var scanner = Scanner(Array(text), context: context)
        var values: [Double] = []
        while true {
            scanner.skipSeparators()
            if scanner.current == nil { return values }
            values.append(try scanner.number())
        }
    }

    /// SVG F.6.5 (endpoint → centre parameterisation) and F.6.6 (radius correction), then one cubic
    /// per quarter turn or less.
    static func arc(
        from p0: (x: Double, y: Double), rx: Double, ry: Double, rotation: Double, largeArc: Bool, sweep: Bool,
        to p1: (x: Double, y: Double)
    ) -> [PathCommand] {
        if p0.x == p1.x && p0.y == p1.y { return [] }
        var rx = abs(rx)
        var ry = abs(ry)
        if rx == 0 || ry == 0 { return [.line(p1.x, p1.y)] }
        let phi = rotation * .pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)
        let dx = (p0.x - p1.x) / 2
        let dy = (p0.y - p1.y) / 2
        let x1 = cosPhi * dx + sinPhi * dy
        let y1 = -sinPhi * dx + cosPhi * dy
        let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 {
            rx *= sqrt(lambda)
            ry *= sqrt(lambda)
        }
        let numerator = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1
        let denominator = rx * rx * y1 * y1 + ry * ry * x1 * x1
        let coefficient = (largeArc == sweep ? -1.0 : 1.0) * sqrt(max(0, numerator / denominator))
        let cxPrime = coefficient * rx * y1 / ry
        let cyPrime = coefficient * -ry * x1 / rx
        let cx = cosPhi * cxPrime - sinPhi * cyPrime + (p0.x + p1.x) / 2
        let cy = sinPhi * cxPrime + cosPhi * cyPrime + (p0.y + p1.y) / 2

        func angle(_ ux: Double, _ uy: Double, _ vx: Double, _ vy: Double) -> Double {
            atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        }
        let theta1 = angle(1, 0, (x1 - cxPrime) / rx, (y1 - cyPrime) / ry)
        var delta = angle((x1 - cxPrime) / rx, (y1 - cyPrime) / ry, (-x1 - cxPrime) / rx, (-y1 - cyPrime) / ry)
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let segments = max(1, Int((abs(delta) / (.pi / 2)).rounded(.up)))
        let step = delta / Double(segments)
        let k = 4.0 / 3.0 * tan(step / 4)
        func point(_ t: Double) -> (Double, Double) {
            (cx + rx * cos(t) * cosPhi - ry * sin(t) * sinPhi, cy + rx * cos(t) * sinPhi + ry * sin(t) * cosPhi)
        }
        func derivative(_ t: Double) -> (Double, Double) {
            (-rx * sin(t) * cosPhi - ry * cos(t) * sinPhi, -rx * sin(t) * sinPhi + ry * cos(t) * cosPhi)
        }
        var result: [PathCommand] = []
        for index in 0..<segments {
            let a1 = theta1 + Double(index) * step
            let a2 = a1 + step
            let start = point(a1)
            var end = point(a2)
            if index == segments - 1 { end = (p1.x, p1.y) }  // land exactly on the endpoint
            let d1 = derivative(a1)
            let d2 = derivative(a2)
            result.append(
                .cubic(start.0 + k * d1.0, start.1 + k * d1.1, end.0 - k * d2.0, end.1 - k * d2.1, end.0, end.1))
        }
        return result
    }

    struct Scanner {
        let characters: [Character]
        let context: String
        var position = 0

        init(_ characters: [Character], context: String) {
            self.characters = characters
            self.context = context
        }

        var current: Character? { position < characters.count ? characters[position] : nil }

        mutating func skipSeparators() {
            while let c = current, c.isWhitespace || c == "," { position += 1 }
        }

        /// An SVG number: `-1.5`, `.5`, `1e-3`. "1.5.5" is 1.5 then .5; "1-2" is 1 then -2.
        mutating func number() throws -> Double {
            skipSeparators()
            var text = ""
            if let c = current, c == "-" || c == "+" {
                text.append(c)
                position += 1
            }
            var seenDot = false
            while let c = current, c.isNumber || (c == "." && !seenDot) {
                if c == "." { seenDot = true }
                text.append(c)
                position += 1
            }
            if let e = current, e == "e" || e == "E" {
                text.append(e)
                position += 1
                if let sign = current, sign == "-" || sign == "+" {
                    text.append(sign)
                    position += 1
                }
                while let c = current, c.isNumber {
                    text.append(c)
                    position += 1
                }
            }
            guard let value = Double(text) else {
                throw GeneratorError("\(context): expected a number at offset \(position) in path data.")
            }
            return value
        }

        /// An arc flag: a single 0 or 1, which may be written without a separator ("a1 1 0 011 1").
        mutating func flag() throws -> Bool {
            skipSeparators()
            guard let c = current, c == "0" || c == "1" else {
                throw GeneratorError("\(context): expected an arc flag at offset \(position).")
            }
            position += 1
            return c == "1"
        }
    }
}
