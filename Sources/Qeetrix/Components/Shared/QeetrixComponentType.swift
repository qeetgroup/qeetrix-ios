import SwiftUI

/// The text styles components set with utility classes on the web (`font-ui text-sm font-medium`)
/// rather than with a typography role. Each is a ``QeetrixTypeSpec``, so it gets the same font, Dynamic
/// Type and Bold Text handling as the roles.
///
/// The family and letter style come from the role the web utility reads: `font-ui` is the label
/// role's geometry, `font-sans` the body role's and `font-heading` the heading role's (index.css
/// `--font-*--font-variation-settings`). Sizes come from ``QeetrixWebScale``.
enum QeetrixComponentType {
    /// `font-ui`.
    static func ui(
        _ step: QeetrixWebScale.TextStep, _ weight: QeetrixFontWeight, lineHeight: Double? = nil, scalesLike style: Font.TextStyle?
    )
        -> QeetrixTypeSpec
    {
        spec(QeetrixTextRole.label.tokens, step, weight, lineHeight, style)
    }

    /// `font-sans`.
    static func sans(
        _ step: QeetrixWebScale.TextStep, _ weight: QeetrixFontWeight, lineHeight: Double? = nil, scalesLike style: Font.TextStyle?
    )
        -> QeetrixTypeSpec
    {
        spec(QeetrixTextRole.body.tokens, step, weight, lineHeight, style)
    }

    /// `font-heading`.
    static func heading(
        _ step: QeetrixWebScale.TextStep, _ weight: QeetrixFontWeight, lineHeight: Double? = nil, scalesLike style: Font.TextStyle?
    )
        -> QeetrixTypeSpec
    {
        spec(QeetrixTextRole.heading.tokens, step, weight, lineHeight, style)
    }

    /// A typography role at another weight — `text-caption font-medium`.
    static func role(_ role: QeetrixTextRole, _ weight: QeetrixFontWeight) -> QeetrixTypeSpec {
        let tokens = role.tokens
        return QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: tokens.family, size: tokens.size, weight: weight, lineHeight: tokens.lineHeight,
                letterSpacing: tokens.letterSpacing, geometry: tokens.geometry),
            scalesLike: role.textStyle)
    }

    private static func spec(
        _ font: QeetrixTextRoleTokens, _ step: QeetrixWebScale.TextStep, _ weight: QeetrixFontWeight, _ lineHeight: Double?,
        _ style: Font.TextStyle?
    ) -> QeetrixTypeSpec {
        QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: font.family, size: step.size, weight: weight, lineHeight: lineHeight ?? step.lineHeight,
                letterSpacing: font.letterSpacing, geometry: font.geometry),
            scalesLike: style)
    }
}
