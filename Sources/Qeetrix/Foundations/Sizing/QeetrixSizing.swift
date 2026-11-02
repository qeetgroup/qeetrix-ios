import SwiftUI

/// A control's size, as `@qeetrix/react`'s `ControlSize`: its height comes from the density in effect
/// (`size.control.sm` / `md` / `lg`).
public enum QeetrixControlSize: String, CaseIterable, Sendable {
    case sm
    case md
    case lg
}

extension QeetrixDensity {
    /// The height of a control of `size` at this density: 24 / 28 / 32 pt compact, 28 / 32 / 40 pt
    /// default, 32 / 36 / 44 pt comfortable.
    public func controlHeight(_ size: QeetrixControlSize) -> CGFloat {
        switch size {
        case .sm: sizeControlSm
        case .md: sizeControlMd
        case .lg: sizeControlLg
        }
    }
}

private struct QeetrixDensityKey: EnvironmentKey {
    static let defaultValue: QeetrixDensity = .default
}

extension EnvironmentValues {
    /// The density in effect — the counterpart of the web's `data-qx-density`. Components read their
    /// control and row heights, and forms their field gap, from it.
    public var qeetrixDensity: QeetrixDensity {
        get { self[QeetrixDensityKey.self] }
        set { self[QeetrixDensityKey.self] = newValue }
    }
}

extension View {
    /// Sets the density for this view hierarchy. Set it once per region, never per component (design
    /// rules §6): `compact` for data-heavy consoles, `default` for most screens, `comfortable` for
    /// welcoming pages such as sign-in and checkout.
    public func qeetrixDensity(_ density: QeetrixDensity) -> some View {
        environment(\.qeetrixDensity, density)
    }
}

/// A single-line control's box at every text size. At the default size, and smaller, it is the web's:
/// `height` tall, the content centred, nothing added. With larger Dynamic Type the box scales with the
/// text — `height` × the text's scale — so it keeps the web's proportions instead of closing round the
/// text. Content taller than that (a wrapped label) gets room above and below it that grows from
/// nothing at the default size by the web's `(height − line height) / 2` per step of scale.
struct QeetrixControlBlockSize: ViewModifier {
    let height: CGFloat
    let lineHeight: CGFloat
    let scales: Bool
    @ScaledMetric private var scale: CGFloat

    /// `style` is the curve the control's text scales along; `nil` for text at a fixed size.
    init(height: CGFloat, lineHeight: CGFloat, relativeTo style: Font.TextStyle?) {
        self.height = height
        self.lineHeight = lineHeight
        scales = style != nil
        _scale = ScaledMetric(wrappedValue: 100, relativeTo: style ?? .body)
    }

    /// The room above and below the line, scaled with the text.
    static func inset(height: CGFloat, lineHeight: CGFloat, scale: CGFloat) -> CGFloat {
        max(0, (height - lineHeight) / 2) * scale
    }

    func body(content: Content) -> some View {
        content.qeetrixControlBlockSize(height, lineHeight: lineHeight, scale: scales ? scale / 100 : 1)
    }
}

extension View {
    /// ``QeetrixControlBlockSize`` at a text scale the caller has read (1 at the default size). For a
    /// system menu's label, which SwiftUI draws in a graph of its own: a modifier that reads Dynamic Type
    /// itself there stops `ImageRenderer` with "accessing attribute in a different namespace".
    func qeetrixControlBlockSize(_ height: CGFloat, lineHeight: CGFloat, scale: CGFloat) -> some View {
        // Never below the token height: at the smaller text sizes the control stays the web's.
        let growth = max(1, scale)
        return
            self
            .padding(.vertical, QeetrixControlBlockSize.inset(height: height, lineHeight: lineHeight, scale: growth - 1))
            .frame(minHeight: height * growth)
    }

    /// Sizes a single-line control: `height` at the default text size, growing with Dynamic Type.
    func qeetrixControlBlockSize(_ height: CGFloat, type: QeetrixTypeSpec) -> some View {
        modifier(
            QeetrixControlBlockSize(
                height: height, lineHeight: type.tokens.size * CGFloat(type.tokens.lineHeight), relativeTo: type.textStyle))
    }
}
