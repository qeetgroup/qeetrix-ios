import SwiftUI

/// The two drawing shapes `@qeetrix/icons` provides.
public enum QeetrixIconShape: String, CaseIterable, Sendable {
    /// Round caps and joins — the default, Lucide's own drawing.
    case round
    /// Square caps and mitred joins.
    case sharp
}

/// Outline (stroked) or filled.
public enum QeetrixIconVariant: String, CaseIterable, Sendable {
    case outline
    case filled
}

/// A Qeetrix icon, drawn from vector paths in the icon's colour (the inherited foreground style).
///
/// Defaults match `@qeetrix/icons`' components: size `md`, stroke `regular`, round outline. Qeetrix
/// components draw the sharp shape inside controls (design rules §16). Like an SF Symbol,
/// the icon scales with Dynamic Type relative to `.body`; pass `relativeTo: nil` for a fixed size.
///
/// Icons are decorative unless given a label — hidden from VoiceOver, because the text beside them
/// says what they mean. A labelled icon is read as an image with that label. Icons whose meaning has
/// a direction (send, reply, undo, …) mirror in right-to-left layouts.
///
/// ```swift
/// QeetrixIcon(.search)                                  // decorative
/// QeetrixIcon(.lock, size: .lg, label: Text("Locked"))  // meaningful
/// ```
public struct QeetrixIcon: View {
    let name: QeetrixIconName
    let stroke: QeetrixIconStroke
    let shape: QeetrixIconShape
    let variant: QeetrixIconVariant
    let label: Text?
    let scales: Bool
    @ScaledMetric private var scaledSide: CGFloat
    private let fixedSide: CGFloat

    public init(
        _ name: QeetrixIconName,
        size: QeetrixIconSize = .md,
        stroke: QeetrixIconStroke = .regular,
        shape: QeetrixIconShape = .round,
        variant: QeetrixIconVariant = .outline,
        relativeTo textStyle: Font.TextStyle? = .body,
        label: Text? = nil
    ) {
        self.name = name
        self.stroke = stroke
        self.shape = shape
        self.variant = variant
        self.label = label
        scales = textStyle != nil
        fixedSide = size.points
        _scaledSide = ScaledMetric(wrappedValue: size.points, relativeTo: textStyle ?? .body)
    }

    /// The drawing rendered: the requested one, else the same shape's outline, else the round outline
    /// (which every icon has). A fallback is logged.
    var drawing: QeetrixIconDrawing {
        if let exact = name.drawing(shape, variant) { return exact }
        QeetrixLog.icons.notice(
            "\(name.rawValue, privacy: .public) has no \(self.shape.rawValue, privacy: .public)-\(self.variant.rawValue, privacy: .public) drawing; using the outline."
        )
        return name.drawing(shape, .outline) ?? name.drawing(.round, .outline)!
    }

    /// How VoiceOver sees the icon.
    var accessibility: QeetrixIconAccessibility {
        label.map(QeetrixIconAccessibility.image) ?? .hidden
    }

    public var body: some View {
        let drawing = self.drawing
        let width = stroke.width
        let side = scales ? scaledSide : fixedSide
        let canvas = Canvas { context, size in
            let unit = min(size.width, size.height) / 24
            context.scaleBy(x: unit, y: unit)
            for element in drawing.elements {
                let path = element.path
                if let fill = element.fill {
                    context.fill(path, with: .foreground, style: FillStyle(eoFill: fill == .evenOdd))
                }
                if let style = element.stroke {
                    context.stroke(
                        path, with: .foreground,
                        style: StrokeStyle(lineWidth: width, lineCap: style.cap, lineJoin: style.join, miterLimit: drawing.miterLimit))
                }
            }
        }
        .frame(width: side, height: side)
        .flipsForRightToLeftLayoutDirection(name.mirrorsInRightToLeft)

        switch accessibility {
        case .hidden:
            canvas.accessibilityHidden(true)
        case let .image(label):
            canvas
                .accessibilityElement()
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isImage)
        }
    }
}

enum QeetrixIconAccessibility {
    case hidden
    case image(Text)
}

extension QeetrixIconName {
    /// Whether `@qeetrix/icons` draws this icon in a shape and variant. Without that drawing,
    /// `QeetrixIcon` shows the outline instead.
    public func hasDrawing(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> Bool {
        drawing(shape, variant) != nil
    }
}
