import SwiftUI

/// An input box's state, which its look follows (input.css): every Qeetrix field — text field,
/// textarea, password, select, number field, each one-time-code slot — is the same box.
struct QeetrixInputState: Hashable {
    let isEnabled: Bool
    let isReadOnly: Bool
    let isFocused: Bool
    let isHovered: Bool
    let isInvalid: Bool

    /// The fill: `bg.neutral.subtle`, `-hover` under a pointer, none when read-only, `bg.disabled`.
    var background: QeetrixColor? {
        if !isEnabled { return .bgDisabled }
        if isReadOnly { return nil }
        return isHovered && !isFocused ? .bgNeutralSubtleHover : .bgNeutralSubtle
    }

    /// The 1 pt bottom line, which the focus or invalid frame replaces. Read-only keeps the editable
    /// line, `border.strong`, so it holds 3:1; the missing fill is what tells it apart
    /// (`.qx-input:has(> .qx-input-control[readonly])`).
    var bottomLine: QeetrixColor? {
        if !isEnabled { return .borderDisabled }
        if isReadOnly { return .borderStrong }
        return frame == nil ? .borderStrong : nil
    }

    /// The 2 pt frame drawn inside the box: Ember on focus, danger when invalid. Focus wins, as on the
    /// web, where the focus rule comes after the invalid one.
    var frame: QeetrixColor? {
        guard isEnabled else { return nil }
        if isFocused { return .borderFocus }
        if isInvalid && !isReadOnly { return .borderDanger }
        return nil
    }

    /// The value's colour.
    var foreground: QeetrixColor { isEnabled ? .textDefault : .textDisabled }
}

/// The filled field box (design rules §8): 4 pt top corners and a square bottom, the fill, the bottom
/// line, and the 2 pt frame inside the box for focus and errors. Changes animate over
/// `motion.duration.fast` with `motion.easing.standard`.
struct QeetrixInputSurface: ViewModifier {
    let state: QeetrixInputState

    static var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: QeetrixRadius.control, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
            topTrailingRadius: QeetrixRadius.control)
    }

    func body(content: Content) -> some View {
        let shape = Self.shape
        content
            .foregroundStyle(state.foreground)
            .background { if let fill = state.background { shape.fill(fill) } }
            .overlay(alignment: .bottom) {
                if let line = state.bottomLine {
                    Rectangle().fill(line).frame(height: QeetrixBorderWidth.default)
                }
            }
            .overlay {
                if let frame = state.frame {
                    shape.strokeBorder(frame, lineWidth: QeetrixFocus.ringWidth)
                }
            }
            .qeetrixAnimation(.standard, .fast, value: state)
    }
}

extension View {
    func qeetrixInputSurface(_ state: QeetrixInputState) -> some View {
        modifier(QeetrixInputSurface(state: state))
    }
}

/// The input's own metrics (input.css): `size.control.lg` tall, 12 pt inline padding, 8 pt between an
/// adornment and the text, the value in `body.md` and the placeholder in `color.text.subtlest`.
enum QeetrixInputMetrics {
    static let padding = QeetrixSpace.insetMd
    static let gap = QeetrixSpace.gapSm
    static let textType = QeetrixTypeSpec(.bodyMd)
    static let placeholder = QeetrixColor.textSubtlest

    static func height(_ density: QeetrixDensity) -> CGFloat {
        density.sizeControlLg
    }
}
