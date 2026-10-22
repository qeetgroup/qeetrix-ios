import SwiftUI

/// Why there is nothing to show — the web's `EmptyState` variants. The variant sets the icon tile's tone
/// and default glyph; the words and actions are always yours.
public enum QeetrixEmptyStateVariant: String, CaseIterable, Sendable {
    /// A neutral empty collection: "No invoices yet".
    case `default`
    /// An invitation to create the first thing. The only variant with the brand tint; pair it with a
    /// primary ``QeetrixButton``.
    case firstUse = "first-use"
    /// The data exists and the search or filter excluded it. Shows search-x; offer a way to clear.
    case noResults = "no-results"
    /// The data exists and the person can't see it. Shows lock; say who can grant access.
    case noPermission = "no-permission"
    /// Loading failed. The tile alone takes the destructive tint, so the failure reads as recoverable;
    /// shows triangle-alert.
    case error
}

/// How much room an empty state takes — the web's `size`.
public enum QeetrixEmptyStateSize: String, CaseIterable, Sendable {
    /// For a table body, a side panel or a section of a screen.
    case sm
    /// The default, for a collection's whole area.
    case `default`
    /// For a whole screen.
    case lg
}

/// What a surface shows when it has nothing to show: an icon on a tinted tile, a title, a description and
/// actions — the web's `EmptyState`.
///
/// ```swift
/// QeetrixEmptyState("No invoices yet", description: Text("Invoices appear here once you bill a customer."),
///                   variant: .firstUse, icon: .fileText) {
///     QeetrixButton("Create invoice") { create() }
/// }
///
/// QeetrixEmptyState("No results", description: Text("Nothing matches “\(query)”."), variant: .noResults) {
///     QeetrixButton("Clear search", variant: .outline) { query = "" }
/// }
/// ```
///
/// It renders what you give it. Whether a surface is empty because there is no data, because a filter
/// excluded it, because the person lacks permission or because loading failed is your app's to decide —
/// and so is what an action does. Never put a raw error, a status code or a stack trace in the
/// description; say what happened and what the person can do.
///
/// For the loading, failure and empty branches of one surface together, see ``QeetrixDataState``.
///
/// ## Platform differences
///
/// SwiftUI's `ContentUnavailableView` draws the system's large symbol in the system font. The Qeetrix
/// contract — a 20 pt icon on a tinted tile, a tone per variant, three sizes and Qeet Sans — is drawn by
/// this view instead, so an empty state looks the same in a list, a card and a full screen.
public struct QeetrixEmptyState<Actions: View>: View {
    let title: Text?
    let description: Text?
    let variant: QeetrixEmptyStateVariant
    let size: QeetrixEmptyStateSize
    let icon: QeetrixIconName?
    let actions: Actions

    /// An empty state with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - description: What happened and what the person can do, under the title.
    ///   - variant: Why there is nothing to show.
    ///   - size: How much room it takes.
    ///   - icon: The tile's glyph. `nil` uses the variant's: search-x, lock or triangle-alert for no
    ///     results, no permission and an error, none otherwise.
    ///   - actions: Buttons under the description.
    public init(
        _ titleKey: LocalizedStringKey, description: Text? = nil, variant: QeetrixEmptyStateVariant = .default,
        size: QeetrixEmptyStateSize = .default, icon: QeetrixIconName? = nil, @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.init(title: Text(titleKey), description: description, variant: variant, size: size, icon: icon, actions: actions)
    }

    /// An empty state with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, description: Text? = nil, variant: QeetrixEmptyStateVariant = .default,
        size: QeetrixEmptyStateSize = .default, icon: QeetrixIconName? = nil, @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.init(title: Text(title), description: description, variant: variant, size: size, icon: icon, actions: actions)
    }

    /// An empty state with a `Text` title, or none.
    public init(
        title: Text?, description: Text? = nil, variant: QeetrixEmptyStateVariant = .default,
        size: QeetrixEmptyStateSize = .default, icon: QeetrixIconName? = nil, @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.title = title
        self.description = description
        self.variant = variant
        self.size = size
        self.icon = icon
        self.actions = actions()
    }

    public var body: some View {
        let metrics = QeetrixEmptyStateMetrics(size: size)
        VStack(spacing: metrics.gap) {
            if let glyph = icon ?? QeetrixEmptyStateMetrics.defaultIcon(variant) {
                QeetrixEmptyStateTile(icon: glyph, variant: variant, metrics: metrics)
                    .padding(.bottom, metrics.tileMargin)
            }
            if let title {
                title
                    .qeetrixType(metrics.titleType)
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
            }
            if let description {
                description
                    .qeetrixType(QeetrixEmptyStateMetrics.descriptionType)
                    .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                    .frame(maxWidth: QeetrixEmptyStateMetrics.descriptionWidth)  // max-w-sm
            }
            if Actions.self != EmptyView.self {
                QeetrixEmptyStateActions { actions }
                    .padding(.top, metrics.actionsMargin)
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, metrics.paddingX)
        .padding(.vertical, metrics.paddingY)
        .frame(maxWidth: .infinity)
    }
}

/// The 20 pt icon on its tinted tile: graphite for most reasons, the brand for a first use, the
/// destructive tint for an error. Decorative: the title says it.
struct QeetrixEmptyStateTile: View {
    let icon: QeetrixIconName
    let variant: QeetrixEmptyStateVariant
    let metrics: QeetrixEmptyStateMetrics

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCorner.surface)  // rounded-xl
        let tone = QeetrixEmptyStateMetrics.tone(variant)
        QeetrixIcon(icon, size: QeetrixIconSize(metrics.iconSize), relativeTo: nil)
            .foregroundStyle(tone.foreground)
            .frame(width: metrics.tileSize, height: metrics.tileSize)
            .background(tone.background, in: shape)
            .overlay { shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixStroke.hairline) }  // ring-1 ring-inset
            .accessibilityHidden(true)
    }
}

/// The actions, centred and wrapping when they don't fit on one line (`flex flex-wrap justify-center
/// gap-2`).
private struct QeetrixEmptyStateActions<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        QeetrixFlowLayout(spacing: QeetrixWebScale.spacing(2), alignment: .center) {
            content
        }
    }
}

struct QeetrixEmptyStateMetrics {
    let gap: CGFloat
    let paddingX: CGFloat
    let paddingY: CGFloat
    let tileSize: CGFloat
    let iconSize: CGFloat
    let tileMargin: CGFloat
    let actionsMargin: CGFloat
    let titleType: QeetrixTypeSpec

    init(size: QeetrixEmptyStateSize) {
        switch size {
        case .sm:
            // gap-1.5 px-4 py-6; tile mb-0.5 size-9, icon size-4; title text-sm; actions mt-2
            (gap, paddingX, paddingY) = (QeetrixWebScale.spacing(1.5), QeetrixWebScale.spacing(4), QeetrixWebScale.spacing(6))
            (tileSize, iconSize, tileMargin) = (QeetrixWebScale.spacing(9), QeetrixWebScale.spacing(4), QeetrixWebScale.spacing(0.5))
            actionsMargin = QeetrixWebScale.spacing(2) - gap
            titleType = QeetrixComponentType.heading(QeetrixWebScale.textSM, .semibold, scalesLike: .subheadline)
        case .default:
            // gap-2 px-6 py-12; tile mb-1 size-11, icon size-5; title text-base; actions mt-3
            (gap, paddingX, paddingY) = (QeetrixWebScale.spacing(2), QeetrixWebScale.spacing(6), QeetrixWebScale.spacing(12))
            (tileSize, iconSize, tileMargin) = (QeetrixWebScale.spacing(11), QeetrixWebScale.spacing(5), QeetrixWebScale.spacing(1))
            actionsMargin = QeetrixWebScale.spacing(3) - gap
            titleType = QeetrixComponentType.heading(QeetrixWebScale.textBase, .semibold, scalesLike: .body)
        case .lg:
            // gap-2.5 px-6 py-16; tile mb-1.5 size-12, icon size-6; title text-lg; actions mt-3
            (gap, paddingX, paddingY) = (QeetrixWebScale.spacing(2.5), QeetrixWebScale.spacing(6), QeetrixWebScale.spacing(16))
            (tileSize, iconSize, tileMargin) = (QeetrixWebScale.spacing(12), QeetrixWebScale.spacing(6), QeetrixWebScale.spacing(1.5))
            actionsMargin = QeetrixWebScale.spacing(3) - gap
            titleType = QeetrixComponentType.heading(QeetrixWebScale.textLG, .semibold, scalesLike: .title3)
        }
    }

    /// `text-sm text-pretty text-muted-foreground`.
    static let descriptionType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
    /// `max-w-sm`.
    static let descriptionWidth = QeetrixWebScale.containerSM

    static func defaultIcon(_ variant: QeetrixEmptyStateVariant) -> QeetrixIconName? {
        switch variant {
        case .default, .firstUse: nil
        case .noResults: .searchX
        case .noPermission: .lock
        case .error: .triangleAlert
        }
    }

    static func tone(_ variant: QeetrixEmptyStateVariant) -> (background: QeetrixColor, foreground: QeetrixColor) {
        switch variant {
        case .default, .noResults, .noPermission: (.surfaceSunken, .textTertiary)  // bg-surface-sunken text-muted-foreground
        case .firstUse: (.surfaceBrandSubtle, .textBrand)  // bg-brand-subtle text-brand
        case .error: (.feedbackErrorSubtle, .textDanger)  // bg-destructive-subtle text-destructive-text
        }
    }
}
