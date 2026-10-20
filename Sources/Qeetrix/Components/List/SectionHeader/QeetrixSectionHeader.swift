import SwiftUI

/// The heading of a group of rows: a title, an optional description and an optional action — for the
/// header of a native `Section`, or above a group of rows outside a `List`.
///
/// ```swift
/// List {
///     Section {
///         ForEach(members) { member in QeetrixListItem(member.name, icon: .users) }
///     } header: {
///         QeetrixSectionHeader("Members", description: Text("People with access to this workspace.")) {
///             QeetrixButton("Invite", variant: .link, size: .sm) { invite() }
///         }
///     }
/// }
/// ```
///
/// Sections stay SwiftUI's: `List` and `Section` own the grouping, the scrolling, sticky headers and
/// the collection. This view gives the header Qeetrix's type and an action slot, and keeps the title
/// in its own case — a `List` header otherwise upper-cases it on some styles.
///
/// The title is a heading for VoiceOver, so the rotor moves between groups; the description is read
/// with it, and the action is a separate button.
public struct QeetrixSectionHeader<Action: View>: View {
    let title: Text
    let description: Text?
    let action: Action

    /// A section header with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - description: A line under the title, muted.
    ///   - action: A control at the trailing end — typically a link-style ``QeetrixButton``.
    public init(_ titleKey: LocalizedStringKey, description: Text? = nil, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.init(title: Text(titleKey), description: description, action: action)
    }

    /// A section header with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, description: Text? = nil, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.init(title: Text(title), description: description, action: action)
    }

    /// A section header with a `Text` title.
    public init(title: Text, description: Text? = nil, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.title = title
        self.description = description
        self.action = action()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(3)) {  // gap-3
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // gap-0.5
                title
                    .qeetrixType(QeetrixSectionHeaderMetrics.titleType)
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .qeetrixType(QeetrixSectionHeaderMetrics.descriptionType)
                        .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            action
        }
        .textCase(nil)
    }
}

enum QeetrixSectionHeaderMetrics {
    /// `font-heading text-sm font-semibold`: a group title, quieter than a page heading.
    static let titleType = QeetrixComponentType.heading(QeetrixWebScale.textSM, .semibold, scalesLike: .subheadline)
    /// `text-sm text-muted-foreground`.
    static let descriptionType = QeetrixListItemMetrics.descriptionType
}
