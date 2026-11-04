import SwiftUI

/// A separator's strength, as `@qeetrix/react`'s Separator `tone`.
public enum QeetrixSeparatorTone: String, CaseIterable, Sendable {
    /// `color.border.subtle`, the default.
    case subtle
    /// `color.border.default`.
    case `default`
    /// `color.border.strong`.
    case strong

    var color: QeetrixColor {
        switch self {
        case .subtle: .borderSubtle
        case .default: .borderDefault
        case .strong: .borderStrong
        }
    }
}

/// A 1 pt line (`border.width.default`) between groups of content — `@qeetrix/react`'s Separator.
///
/// ```swift
/// QeetrixSeparator()
/// QeetrixSeparator(.vertical, tone: .default)
/// ```
///
/// A vertical separator stretches to its row. It is decorative by default — hidden from VoiceOver,
/// the web's `decorative` — since spacing and headings already group the content; pass
/// `isDecorative: false` where the boundary itself carries meaning, and VoiceOver reads it as a
/// separator.
public struct QeetrixSeparator: View {
    let orientation: Axis
    let tone: QeetrixSeparatorTone
    let isDecorative: Bool

    public init(_ orientation: Axis = .horizontal, tone: QeetrixSeparatorTone = .subtle, isDecorative: Bool = true) {
        self.orientation = orientation
        self.tone = tone
        self.isDecorative = isDecorative
    }

    public var body: some View {
        let line = Rectangle()
            .fill(tone.color)
            .frame(
                width: orientation == .vertical ? QeetrixBorderWidth.default : nil,
                height: orientation == .horizontal ? QeetrixBorderWidth.default : nil
            )
            .frame(
                maxWidth: orientation == .horizontal ? .infinity : nil,
                maxHeight: orientation == .vertical ? .infinity : nil
            )
        if isDecorative {
            line.accessibilityHidden(true)
        } else {
            line.accessibilityElement().accessibilityLabel(Text(verbatim: "")).accessibilityAddTraits(.isStaticText)
        }
    }
}
