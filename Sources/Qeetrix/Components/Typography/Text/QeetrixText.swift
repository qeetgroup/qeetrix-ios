import SwiftUI

/// The styles of ``QeetrixText``: the web Typography component's variants, by the same names.
///
/// Headings follow the web's application scale: on a compact-width screen they take the web's mobile
/// sizes (h1 24 pt, h2 20, h3 18), and in a regular-width size class the sizes from its `sm`
/// breakpoint up (32, 24, 20). h4 is 16 pt at every width.
public enum QeetrixTextVariant: String, CaseIterable, Sendable {
    /// A page title. VoiceOver heading level 1.
    case h1
    /// A section heading. Level 2.
    case h2
    /// A group heading. Level 3.
    case h3
    /// A block heading. Level 4.
    case h4
    /// Body copy, in the body role.
    case p
    /// A quotation: body copy in the tertiary colour behind a 2 pt rule on the leading edge.
    case blockquote
    /// An introductory paragraph: 16 pt with relaxed leading, in the secondary colour.
    case lead
    /// Emphasised copy: 18 pt semibold.
    case large
    /// An interface label, in the label role.
    case small
    /// De-emphasised body copy, in the tertiary colour.
    case muted
    /// Code in Fira Code on a sunken chip.
    case inlineCode

    /// True for h1–h4, which VoiceOver reads as headings.
    public var isHeading: Bool {
        switch self {
        case .h1, .h2, .h3, .h4: true
        default: false
        }
    }
}

/// A piece of copy in a Qeetrix text style: the font, size, line height, colour and heading
/// semantics of a ``QeetrixTextVariant``, with Dynamic Type and Bold Text.
///
/// ```swift
/// QeetrixText("Billing", variant: .h2)
/// QeetrixText("Invoices are sent on the first of each month.", variant: .muted)
/// ```
///
/// It wraps rather than truncates. To clip it, use SwiftUI's `lineLimit(_:)`, as on any text.
public struct QeetrixText: View {
    let text: Text
    let variant: QeetrixTextVariant
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Localised copy, looked up like `Text`'s `init(_:tableName:bundle:comment:)`.
    public init(_ key: LocalizedStringKey, variant: QeetrixTextVariant = .p, tableName: String? = nil, bundle: Bundle? = nil) {
        self.init(Text(key, tableName: tableName, bundle: bundle), variant: variant)
    }

    /// Copy shown as given, without localisation.
    public init<S: StringProtocol>(_ content: S, variant: QeetrixTextVariant = .p) {
        self.init(Text(content), variant: variant)
    }

    /// A `Text` — for concatenated or already-formatted text.
    public init(_ text: Text, variant: QeetrixTextVariant = .p) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        let isRegularWidth = horizontalSizeClass != .compact
        switch variant {
        case .blockquote:
            styled(isRegularWidth: isRegularWidth)
                .padding(.leading, QeetrixWebScale.spacing(4))  // ps-4
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(QeetrixColor.borderStrong)
                        .frame(width: 2)  // border-s-2
                        .accessibilityHidden(true)
                }
        case .inlineCode:
            styled(isRegularWidth: isRegularWidth)
                .padding(.horizontal, QeetrixTypographyTokens.codePaddingInline)
                .padding(.vertical, QeetrixTypographyTokens.codePaddingBlock)
                .background(QeetrixTypographyTokens.codeBackground, in: RoundedRectangle(cornerRadius: QeetrixTypographyTokens.codeCorner))
        default:
            styled(isRegularWidth: isRegularWidth)
        }
    }

    private func styled(isRegularWidth: Bool) -> some View {
        text
            .qeetrixType(Self.spec(variant, isRegularWidth: isRegularWidth))
            .foregroundStyle(Self.color(variant))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(variant.isHeading ? .isHeader : [])
            .accessibilityHeading(Self.headingLevel(variant))
    }

    static func color(_ variant: QeetrixTextVariant) -> QeetrixColor {
        switch variant {
        case .lead: .textSecondary  // text-(--qx-color-text-secondary)
        case .muted, .blockquote: .textTertiary  // text-muted-foreground
        default: .textPrimary  // inherited text-foreground
        }
    }

    static func headingLevel(_ variant: QeetrixTextVariant) -> AccessibilityHeadingLevel {
        switch variant {
        case .h1: .h1
        case .h2: .h2
        case .h3: .h3
        case .h4: .h4
        default: .unspecified
        }
    }

    /// The web classes for each variant, at mobile width and from the `sm` breakpoint up.
    static func spec(_ variant: QeetrixTextVariant, isRegularWidth: Bool) -> QeetrixTypeSpec {
        let title = QeetrixTextRole.title.tokens
        let heading = QeetrixTextRole.heading.tokens
        let text2XL = QeetrixWebScale.text2XL
        let textXL = QeetrixWebScale.textXL
        switch variant {
        case .h1:
            // text-2xl/(title line height), sm:text-title
            return isRegularWidth
                ? QeetrixComponentType.heading(.init(size: title.size, lineHeight: title.lineHeight), .semibold, scalesLike: .title)
                : QeetrixComponentType.heading(text2XL, .semibold, lineHeight: title.lineHeight, scalesLike: .title)
        case .h2:
            // text-xl/(heading line height), sm:text-2xl/(heading line height)
            return QeetrixComponentType.heading(
                isRegularWidth ? text2XL : textXL, .semibold, lineHeight: heading.lineHeight, scalesLike: .title2)
        case .h3:
            // text-lg/(heading line height), sm:text-heading
            return isRegularWidth
                ? QeetrixComponentType.heading(.init(size: heading.size, lineHeight: heading.lineHeight), .semibold, scalesLike: .title3)
                : QeetrixComponentType.heading(QeetrixWebScale.textLG, .semibold, lineHeight: heading.lineHeight, scalesLike: .title3)
        case .h4:
            // text-base/snug
            return QeetrixComponentType.heading(
                QeetrixWebScale.textBase, .semibold, lineHeight: QeetrixWebScale.leadingSnug, scalesLike: .headline)
        case .p, .muted, .blockquote:
            return QeetrixTypeSpec(.body)  // text-body
        case .lead:
            // text-base/relaxed
            return QeetrixComponentType.sans(
                QeetrixWebScale.textBase, .regular, lineHeight: QeetrixWebScale.leadingRelaxed, scalesLike: .body)
        case .large:
            // text-lg/snug font-semibold
            return QeetrixComponentType.sans(
                QeetrixWebScale.textLG, .semibold, lineHeight: QeetrixWebScale.leadingSnug, scalesLike: .title3)
        case .small:
            return QeetrixComponentType.role(.label, .medium)  // text-label font-medium
        case .inlineCode:
            // font-mono at the code font size, an em of the body text it sits in
            let code = QeetrixTextRole.code.tokens
            let size = QeetrixTextRole.body.tokens.size * QeetrixTypographyTokens.codeFontSize
            return QeetrixTypeSpec(
                QeetrixTextRoleTokens(
                    family: code.family, size: size, weight: .regular, lineHeight: code.lineHeight, letterSpacing: code.letterSpacing,
                    geometry: code.geometry),
                scalesLike: .body)
        }
    }
}
