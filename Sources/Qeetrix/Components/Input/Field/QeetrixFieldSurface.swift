import SwiftUI

/// The field recipe's states, resolved to colours (qeetrix-ui `src/internal/field-styles.ts`).
struct QeetrixFieldState: Hashable {
    let isEnabled: Bool
    let isReadOnly: Bool
    let isFocused: Bool
    let isHovered: Bool
    let tone: QeetrixFieldMessage.Tone?

    var background: QeetrixComponentColor {
        if !isEnabled { return QeetrixInputTokens.backgroundDisabled }
        if isReadOnly { return QeetrixInputTokens.backgroundReadonly }
        return QeetrixInputTokens.background
    }

    /// The boundary: a status wins over hover, focus turns it to the ring, except an error, which
    /// keeps the error colour.
    var border: QeetrixComponentColor {
        if isFocused && isEnabled && !isReadOnly {
            return tone == .error ? QeetrixInputTokens.borderInvalid : QeetrixInputTokens.borderFocus
        }
        if let tone { return tone.borderColor }
        if isHovered && isEnabled && !isReadOnly { return QeetrixInputTokens.borderHover }
        return QeetrixInputTokens.border
    }

    /// The 1 pt focus outline, in the error colour on an invalid field.
    var outline: QeetrixComponentColor? {
        guard isFocused && isEnabled && !isReadOnly else { return nil }
        return tone == .error ? QeetrixInputTokens.borderInvalid : QeetrixInputTokens.borderFocus
    }
}

/// The field recipe drawn around a control: the writing surface, the boundary for its state, the focus
/// outline and the disabled fade (qeetrix-ui `src/internal/field-styles.ts`). Every bordered Qeetrix input
/// uses it, so they all read the same.
struct QeetrixFieldSurface: ViewModifier {
    let state: QeetrixFieldState
    var cornerRadius: CGFloat = QeetrixInputTokens.corner

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        content
            .background(state.background, in: shape)
            .overlay {
                shape.strokeBorder(
                    state.border, style: StrokeStyle(lineWidth: QeetrixStroke.hairline, dash: state.isReadOnly ? [3, 3] : []))
                if let outline = state.outline {
                    // focus-ring-field: a 1 pt outline outside the boundary thickens it to 2 pt.
                    shape.inset(by: -QeetrixStroke.hairline).strokeBorder(outline, lineWidth: QeetrixStroke.hairline)
                }
            }
            .opacity(state.isEnabled ? 1 : QeetrixOpacity.disabled)
            .qeetrixAnimation(.standard, .fast, value: state)  // duration-fast ease-standard
    }
}

extension View {
    func qeetrixFieldSurface(_ state: QeetrixFieldState, cornerRadius: CGFloat = QeetrixInputTokens.corner) -> some View {
        modifier(QeetrixFieldSurface(state: state, cornerRadius: cornerRadius))
    }
}
