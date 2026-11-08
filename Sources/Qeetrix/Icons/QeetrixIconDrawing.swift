import SwiftUI
import os

// The data the generated icon catalogue is written in. Internal: the public API is `QeetrixIcon`.

/// One icon drawing in the 24-unit grid.
struct QeetrixIconDrawing: Sendable {
    let miterLimit: CGFloat
    let elements: [QeetrixIconElement]
}

/// One SVG element of a drawing, with its paint.
struct QeetrixIconElement: Sendable {
    let fill: QeetrixIconFill?
    let stroke: QeetrixIconStrokeStyle?
    let commands: [QeetrixPathCommand]

    var path: Path {
        var path = Path()
        for command in commands {
            switch command {
            case let .move(x, y):
                path.move(to: CGPoint(x: x, y: y))
            case let .line(x, y):
                path.addLine(to: CGPoint(x: x, y: y))
            case let .quad(cx, cy, x, y):
                path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: cx, y: cy))
            case let .cubic(c1x, c1y, c2x, c2y, x, y):
                path.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: c1x, y: c1y), control2: CGPoint(x: c2x, y: c2y))
            case .close:
                path.closeSubpath()
            case let .ellipse(x, y, width, height):
                path.addEllipse(in: CGRect(x: x, y: y, width: width, height: height))
            case let .roundedRect(x, y, width, height, rx, ry):
                let rect = CGRect(x: x, y: y, width: width, height: height)
                if rx == 0 && ry == 0 {
                    path.addRect(rect)
                } else {
                    path.addRoundedRect(in: rect, cornerSize: CGSize(width: rx, height: ry))
                }
            }
        }
        return path
    }
}

enum QeetrixIconFill: Sendable {
    case nonZero
    case evenOdd
}

struct QeetrixIconStrokeStyle: Sendable {
    let cap: CGLineCap
    let join: CGLineJoin
}

/// Absolute path commands; arcs and smooth curves were expanded by the generator.
enum QeetrixPathCommand: Sendable {
    case move(CGFloat, CGFloat)
    case line(CGFloat, CGFloat)
    case quad(CGFloat, CGFloat, CGFloat, CGFloat)
    case cubic(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    case close
    case ellipse(CGFloat, CGFloat, CGFloat, CGFloat)
    case roundedRect(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
}

// MARK: - Decoding

extension QeetrixIconName {
    /// The encoded drawing for a shape and variant, or `nil` when `@qeetrix/icons` does not draw that combination.
    func encodedDrawing(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> String? {
        switch (shape, variant) {
        case (.round, .outline): roundOutline
        case (.round, .filled): roundFilled
        case (.sharp, .outline): sharpOutline
        case (.sharp, .filled): sharpFilled
        }
    }

    /// The drawing for a shape and variant, or `nil` when `@qeetrix/icons` does not draw that combination. Decoded the
    /// first time it is asked for, then kept.
    func drawing(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> QeetrixIconDrawing? {
        guard let encoded = encodedDrawing(shape, variant) else { return nil }
        return QeetrixIconDrawingCache.drawing(QeetrixIconDrawingCache.Key(name: rawValue, shape: shape, variant: variant)) {
            QeetrixIconDrawing(encoded: encoded, icon: rawValue)
        }
    }
}

/// Decoded drawings, shared by every view that draws an icon.
enum QeetrixIconDrawingCache {
    struct Key: Hashable, Sendable {
        let name: String
        let shape: QeetrixIconShape
        let variant: QeetrixIconVariant
    }

    private static let drawings = OSAllocatedUnfairLock(initialState: [Key: QeetrixIconDrawing]())

    static func drawing(_ key: Key, decode: () -> QeetrixIconDrawing) -> QeetrixIconDrawing {
        if let drawing = drawings.withLock({ $0[key] }) { return drawing }
        // Decoded outside the lock; a race decodes twice and keeps either, as both are the same drawing.
        let drawing = decode()
        drawings.withLock { $0[key] = drawing }
        return drawing
    }
}

extension QeetrixIconDrawing {
    /// Decodes the generator's one-string form of a drawing (Tools/QeetrixGen, `IconEmitter.encode`): the miter limit,
    /// then each element after a `|` — four flags (fill `-`/`n`/`e`, stroke `-`/`s`, cap `b`/`r`/`s`, join `m`/`r`/`b`)
    /// and its commands `M x y`, `L x y`, `Q cx cy x y`, `C c1x c1y c2x c2y x y`, `Z`, `E x y w h` and
    /// `R x y w h rx ry`, numbers separated by spaces. The data is generated and checked in CI, so a malformed drawing
    /// is a programming error that names its icon.
    init(encoded: String, icon: String) {
        func malformed(_ what: String) -> Never {
            preconditionFailure("The \(icon) icon's drawing has a malformed \(what); regenerate it with Scripts/generate.sh.")
        }
        let parts = encoded.split(separator: "|", omittingEmptySubsequences: false)
        guard let miterLimit = Double(parts[0]) else { malformed("miter limit") }
        var elements: [QeetrixIconElement] = []
        for part in parts.dropFirst() {
            let bytes = Array(part.utf8)
            guard bytes.count >= 4 else { malformed("element") }
            let fill: QeetrixIconFill? =
                switch bytes[0] {
                case UInt8(ascii: "-"): nil
                case UInt8(ascii: "n"): .nonZero
                case UInt8(ascii: "e"): .evenOdd
                default: malformed("fill")
                }
            let cap: CGLineCap =
                switch bytes[2] {
                case UInt8(ascii: "b"): .butt
                case UInt8(ascii: "r"): .round
                case UInt8(ascii: "s"): .square
                default: malformed("line cap")
                }
            let join: CGLineJoin =
                switch bytes[3] {
                case UInt8(ascii: "m"): .miter
                case UInt8(ascii: "r"): .round
                case UInt8(ascii: "b"): .bevel
                default: malformed("line join")
                }
            let stroke: QeetrixIconStrokeStyle? =
                switch bytes[1] {
                case UInt8(ascii: "-"): nil
                case UInt8(ascii: "s"): QeetrixIconStrokeStyle(cap: cap, join: join)
                default: malformed("stroke")
                }
            var commands: [QeetrixPathCommand] = []
            var index = 4
            var numbers = [CGFloat](repeating: 0, count: 6)
            while index < bytes.count {
                let command = bytes[index]
                index += 1
                let count: Int =
                    switch command {
                    case UInt8(ascii: "M"), UInt8(ascii: "L"): 2
                    case UInt8(ascii: "Q"), UInt8(ascii: "E"): 4
                    case UInt8(ascii: "C"), UInt8(ascii: "R"): 6
                    case UInt8(ascii: "Z"): 0
                    default: malformed("path command")
                    }
                for n in 0..<count {
                    if n > 0 {
                        guard index < bytes.count, bytes[index] == UInt8(ascii: " ") else { malformed("path") }
                        index += 1
                    }
                    var end = index
                    while end < bytes.count, bytes[end] != UInt8(ascii: " "), !(65...90).contains(bytes[end]) { end += 1 }
                    guard let value = Double(String(decoding: bytes[index..<end], as: UTF8.self)) else { malformed("number") }
                    numbers[n] = CGFloat(value)
                    index = end
                }
                let v = numbers
                let next: QeetrixPathCommand =
                    switch command {
                    case UInt8(ascii: "M"): .move(v[0], v[1])
                    case UInt8(ascii: "L"): .line(v[0], v[1])
                    case UInt8(ascii: "Q"): .quad(v[0], v[1], v[2], v[3])
                    case UInt8(ascii: "C"): .cubic(v[0], v[1], v[2], v[3], v[4], v[5])
                    case UInt8(ascii: "E"): .ellipse(v[0], v[1], v[2], v[3])
                    case UInt8(ascii: "R"): .roundedRect(v[0], v[1], v[2], v[3], v[4], v[5])
                    default: .close
                    }
                commands.append(next)
            }
            elements.append(QeetrixIconElement(fill: fill, stroke: stroke, commands: commands))
        }
        self.init(miterLimit: CGFloat(miterLimit), elements: elements)
    }
}
