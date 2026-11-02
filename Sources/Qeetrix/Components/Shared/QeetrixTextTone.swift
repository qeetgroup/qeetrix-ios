import SwiftUI

/// A text colour from the tokens, as `@qeetrix/react`'s `TextTone`.
public enum QeetrixTextTone: String, CaseIterable, Sendable {
    case `default`
    case subtle
    case subtlest
    /// Only for text inside an inactive control, which WCAG 1.4.3 exempts from contrast; anywhere
    /// else it is unreadable (2.48:1 in light). Quieter text that must still be read is `subtle`.
    case disabled
    case inverse
    case brand
    case danger
    case success
    case warning
    case info

    var color: QeetrixColor {
        switch self {
        case .default: .textDefault
        case .subtle: .textSubtle
        case .subtlest: .textSubtlest
        case .disabled: .textDisabled
        case .inverse: .textInverse
        case .brand: .textBrand
        case .danger: .textDanger
        case .success: .textSuccess
        case .warning: .textWarning
        case .info: .textInfo
        }
    }
}

/// Logical text alignment, as `@qeetrix/react`'s `TextAlign`: `start` and `end` follow the layout
/// direction.
public enum QeetrixTextAlign: String, CaseIterable, Sendable {
    case start
    case center
    case end

    var textAlignment: TextAlignment {
        switch self {
        case .start: .leading
        case .center: .center
        case .end: .trailing
        }
    }

    var frameAlignment: Alignment {
        switch self {
        case .start: .leading
        case .center: .center
        case .end: .trailing
        }
    }
}

extension View {
    /// `truncate` as on the web: `1` line with an ellipsis, or a number of lines; `nil` wraps freely.
    @ViewBuilder
    func qeetrixTruncate(_ lines: Int?) -> some View {
        if let lines {
            lineLimit(max(1, lines)).truncationMode(.tail)
        } else {
            fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    func qeetrixAlign(_ align: QeetrixTextAlign?) -> some View {
        if let align {
            multilineTextAlignment(align.textAlignment).frame(maxWidth: .infinity, alignment: align.frameAlignment)
        } else {
            self
        }
    }
}
