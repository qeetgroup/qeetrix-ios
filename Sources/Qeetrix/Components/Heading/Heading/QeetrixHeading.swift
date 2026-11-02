import SwiftUI

/// A heading's look, as `@qeetrix/react`'s `HeadingSize`: the display, heading and title roles.
public enum QeetrixHeadingSize: String, CaseIterable, Sendable {
    case displayLg = "display-lg"
    case displayMd = "display-md"
    case displaySm = "display-sm"
    case headingLg = "heading-lg"
    case headingMd = "heading-md"
    case headingSm = "heading-sm"
    case titleLg = "title-lg"
    case titleMd = "title-md"
    case titleSm = "title-sm"

    var role: QeetrixTextRole {
        switch self {
        case .displayLg: .displayLg
        case .displayMd: .displayMd
        case .displaySm: .displaySm
        case .headingLg: .headingLg
        case .headingMd: .headingMd
        case .headingSm: .headingSm
        case .titleLg: .titleLg
        case .titleMd: .titleMd
        case .titleSm: .titleSm
        }
    }

    /// The default look for a level, as on the web: 1 heading-lg, 2 heading-md, 3 heading-sm,
    /// 4 title-lg, 5 title-md, 6 title-sm.
    public static func `default`(for level: Int) -> QeetrixHeadingSize {
        switch level {
        case ...1: .headingLg
        case 2: .headingMd
        case 3: .headingSm
        case 4: .titleLg
        case 5: .titleMd
        default: .titleSm
        }
    }
}

/// A heading's colour, as `@qeetrix/react`'s `HeadingTone`.
public enum QeetrixHeadingTone: String, CaseIterable, Sendable {
    case `default`
    case subtle
    case inverse

    var color: QeetrixColor {
        switch self {
        case .default: .textDefault
        case .subtle: .textSubtle
        case .inverse: .textInverse
        }
    }
}

/// A section heading — `@qeetrix/react`'s Heading: the `level` sets the outline, the `size` the look.
///
/// ```swift
/// QeetrixHeading("Billing", level: 1)
/// QeetrixHeading("Sign in to Qeet", level: 1, size: .displaySm)
/// ```
///
/// Weight 600 in Qeet Sans's Base letter style, or Geo for the display sizes, which headline welcoming
/// pages only (design rules §5, §17). VoiceOver reads it as a heading of its level, so the rotor's
/// heading navigation follows the page's outline.
public struct QeetrixHeading: View {
    let text: Text
    let level: Int
    let size: QeetrixHeadingSize
    let tone: QeetrixHeadingTone
    let truncate: Int?
    let align: QeetrixTextAlign?

    public init(
        _ key: LocalizedStringKey, level: Int, size: QeetrixHeadingSize? = nil, tone: QeetrixHeadingTone = .default,
        truncate: Int? = nil, align: QeetrixTextAlign? = nil, tableName: String? = nil, bundle: Bundle? = nil
    ) {
        self.init(Text(key, tableName: tableName, bundle: bundle), level: level, size: size, tone: tone, truncate: truncate, align: align)
    }

    public init<S: StringProtocol>(
        _ content: S, level: Int, size: QeetrixHeadingSize? = nil, tone: QeetrixHeadingTone = .default, truncate: Int? = nil,
        align: QeetrixTextAlign? = nil
    ) {
        self.init(Text(content), level: level, size: size, tone: tone, truncate: truncate, align: align)
    }

    public init(
        _ text: Text, level: Int, size: QeetrixHeadingSize? = nil, tone: QeetrixHeadingTone = .default, truncate: Int? = nil,
        align: QeetrixTextAlign? = nil
    ) {
        self.text = text
        self.level = min(max(level, 1), 6)
        self.size = size ?? .default(for: level)
        self.tone = tone
        self.truncate = truncate
        self.align = align
    }

    public var body: some View {
        text
            .qeetrixTextStyle(size.role)
            .foregroundStyle(tone.color)
            .qeetrixTruncate(truncate)
            .qeetrixAlign(align)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(Self.accessibilityLevel(level))
    }

    static func accessibilityLevel(_ level: Int) -> AccessibilityHeadingLevel {
        switch level {
        case 1: .h1
        case 2: .h2
        case 3: .h3
        case 4: .h4
        case 5: .h5
        default: .h6
        }
    }
}
