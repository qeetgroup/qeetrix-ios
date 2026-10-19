import SwiftUI

/// The weights of ``QeetrixSeparator``, as on the web.
public enum QeetrixSeparatorVariant: String, CaseIterable, Sendable {
    /// The border colour. Divides sections, groups and toolbars.
    case `default`
    /// The subtle border colour, one step quieter. Divides items inside a section — rows of a list,
    /// metadata in a card — where a default rule would draw more lines than the content.
    case muted
}

/// A 1 pt rule between groups of content.
///
/// Horizontal separators fill the available width; vertical ones fill the height their container
/// proposes, so inside an `HStack` give the stack a height or let its content set one.
///
/// ```swift
/// VStack(spacing: QeetrixSpacing.m) {
///     QeetrixText("Profile", variant: .h3)
///     QeetrixSeparator()
///     QeetrixText("Your name and photo are visible to your team.")
/// }
/// ```
///
/// The web separator carries `role="separator"`. VoiceOver has no separator trait, so here it is hidden
/// from VoiceOver, like the system's own list separators; grouping is carried by spacing and headings,
/// never by the rule alone.
public struct QeetrixSeparator: View {
    let orientation: Axis
    let variant: QeetrixSeparatorVariant

    public init(_ orientation: Axis = .horizontal, variant: QeetrixSeparatorVariant = .default) {
        self.orientation = orientation
        self.variant = variant
    }

    public var body: some View {
        Rectangle()
            .fill(Self.color(variant))
            .frame(
                width: orientation == .vertical ? QeetrixStroke.hairline : nil,
                height: orientation == .horizontal ? QeetrixStroke.hairline : nil
            )
            .frame(
                maxWidth: orientation == .horizontal ? .infinity : nil,
                maxHeight: orientation == .vertical ? .infinity : nil
            )
            .accessibilityHidden(true)
    }

    static func color(_ variant: QeetrixSeparatorVariant) -> QeetrixColor {
        switch variant {
        case .default: .borderDefault  // bg-border
        case .muted: .borderSubtle  // bg-border-subtle
        }
    }
}
