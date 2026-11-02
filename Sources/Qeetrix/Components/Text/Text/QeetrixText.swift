import SwiftUI

/// A body size, as `@qeetrix/react`'s `TextSize`: the body typography roles.
public enum QeetrixTextSize: String, CaseIterable, Sendable {
    /// `body.sm`, 12/16.
    case sm
    /// `body.md`, 14/20, the default.
    case md
    /// `body.lg`, 16/24.
    case lg

    var role: QeetrixTextRole {
        switch self {
        case .sm: .bodySm
        case .md: .bodyMd
        case .lg: .bodyLg
        }
    }
}

/// A text weight, as `@qeetrix/react`'s `TextWeight`.
public enum QeetrixTextWeight: String, CaseIterable, Sendable {
    /// 400, the default.
    case regular
    /// 500.
    case medium
    /// 600.
    case semibold

    var fontWeight: QeetrixFontWeight {
        switch self {
        case .regular: QeetrixTextRole.bodyMd.tokens.weight
        case .medium: QeetrixTextRole.labelMd.tokens.weight
        case .semibold: QeetrixTextRole.titleMd.tokens.weight
        }
    }
}

/// Running text, labels and inline code, on the body typography roles — `@qeetrix/react`'s Text.
///
/// ```swift
/// QeetrixText("Invoices are sent on the 1st of each month.")
/// QeetrixText("Last synced 2 min ago", size: .sm, tone: .subtle)
/// QeetrixText("INV-2026-0042", mono: true)
/// ```
///
/// Qeet Sans in its A11y letter style (`font.geometry.body`), or Fira Code at the same size with
/// `mono`. It scales with Dynamic Type and wraps unless `truncate` limits its lines. A `tone` of `nil`
/// keeps the surrounding colour. For a section title, use ``QeetrixHeading``.
public struct QeetrixText: View {
    let text: Text
    let size: QeetrixTextSize
    let weight: QeetrixTextWeight
    let tone: QeetrixTextTone?
    let mono: Bool
    let truncate: Int?
    let align: QeetrixTextAlign?

    public init(
        _ key: LocalizedStringKey, size: QeetrixTextSize = .md, weight: QeetrixTextWeight = .regular, tone: QeetrixTextTone? = nil,
        mono: Bool = false, truncate: Int? = nil, align: QeetrixTextAlign? = nil, tableName: String? = nil, bundle: Bundle? = nil
    ) {
        self.init(
            Text(key, tableName: tableName, bundle: bundle), size: size, weight: weight, tone: tone, mono: mono, truncate: truncate,
            align: align)
    }

    public init<S: StringProtocol>(
        _ content: S, size: QeetrixTextSize = .md, weight: QeetrixTextWeight = .regular, tone: QeetrixTextTone? = nil,
        mono: Bool = false, truncate: Int? = nil, align: QeetrixTextAlign? = nil
    ) {
        self.init(Text(content), size: size, weight: weight, tone: tone, mono: mono, truncate: truncate, align: align)
    }

    public init(
        _ text: Text, size: QeetrixTextSize = .md, weight: QeetrixTextWeight = .regular, tone: QeetrixTextTone? = nil,
        mono: Bool = false, truncate: Int? = nil, align: QeetrixTextAlign? = nil
    ) {
        self.text = text
        self.size = size
        self.weight = weight
        self.tone = tone
        self.mono = mono
        self.truncate = truncate
        self.align = align
    }

    public var body: some View {
        let styled =
            text
            .qeetrixType(Self.spec(size: size, weight: weight, mono: mono))
            .qeetrixTruncate(truncate)
            .qeetrixAlign(align)
        if let tone {
            styled.foregroundStyle(tone.color)
        } else {
            styled
        }
    }

    /// The body role at the size, with the weight; Fira Code (`font.family.mono`) at the same size
    /// and line height when `mono`.
    static func spec(size: QeetrixTextSize, weight: QeetrixTextWeight, mono: Bool) -> QeetrixTypeSpec {
        let tokens = size.role.tokens
        let family: QeetrixFontFamily = mono ? .mono : tokens.family
        return QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: family, size: tokens.size, weight: weight.fontWeight, lineHeight: tokens.lineHeight,
                letterSpacing: tokens.letterSpacing, geometry: mono ? nil : tokens.geometry),
            scalesLike: size.role.textStyle)
    }
}
