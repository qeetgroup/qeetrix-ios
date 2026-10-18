import SwiftUI

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
