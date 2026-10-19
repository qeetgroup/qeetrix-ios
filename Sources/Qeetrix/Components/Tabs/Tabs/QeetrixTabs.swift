import SwiftUI

/// The treatments of ``QeetrixTabs``, as on the web.
public enum QeetrixTabsVariant: String, CaseIterable, Sendable {
    /// Contained: a sunken well holds the tabs, and the selected one is the raised surface inside it — a
    /// view switch for a card, a toolbar or a panel.
    case `default`
    /// Underline: the tabs sit on a 1 pt track and the selected one carries a 2 pt brand indicator — for
    /// switching sections of a page.
    case line
}

/// One tab of a ``QeetrixTabs``: the value it selects, its title, an optional icon, and whether it can be
/// chosen.
public struct QeetrixTab<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: Text
    public let icon: QeetrixIconName?
    public let isDisabled: Bool

    public var id: Value { value }

    /// A tab with a localised title.
    public init(_ titleKey: LocalizedStringKey, value: Value, icon: QeetrixIconName? = nil, isDisabled: Bool = false) {
        self.init(title: Text(titleKey), value: value, icon: icon, isDisabled: isDisabled)
    }

    /// A tab with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, value: Value, icon: QeetrixIconName? = nil, isDisabled: Bool = false) {
        self.init(title: Text(title), value: value, icon: icon, isDisabled: isDisabled)
    }

    /// A tab with a `Text` title.
    public init(title: Text, value: Value, icon: QeetrixIconName? = nil, isDisabled: Bool = false) {
        self.value = value
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
    }
}

/// A row of tabs that switches between panels of related content in one place — the web's `Tabs`.
///
/// ```swift
/// QeetrixTabs(selection: $section, tabs: [
///     QeetrixTab("Overview", value: Section.overview),
///     QeetrixTab("Activity", value: Section.activity, icon: .bell),
/// ])
/// switch section {
/// case .overview: OverviewPanel()
/// case .activity: ActivityPanel()
/// }
/// ```
///
/// The strip only selects: you own the selection and draw the panel for it, so state survives however
/// your view keeps it. Place the panel 12 pt below the strip, as the web does. A strip wider than its
/// container scrolls sideways and keeps the selected tab in view.
///
/// This is in-content tab selection. For the app's main sections use a `TabView` with
/// `qeetrixTabItem(_:icon:badge:)`; for two or three mutually exclusive options in a form,
/// a ``QeetrixRadioGroup``.
///
/// For VoiceOver the strip carries the tab-bar trait, and each tab is a button with the selected state on
/// the chosen one.
public struct QeetrixTabs<Value: Hashable>: View {
    let selection: Binding<Value>
    let tabs: [QeetrixTab<Value>]
    let variant: QeetrixTabsVariant
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - selection: The selected tab's value.
    ///   - tabs: The tabs, in order.
    ///   - variant: Contained (`default`) or underlined (`line`).
    public init(selection: Binding<Value>, tabs: [QeetrixTab<Value>], variant: QeetrixTabsVariant = .default) {
        self.selection = selection
        self.tabs = tabs
        self.variant = variant
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                strip
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .onChange(of: selection.wrappedValue) { _, value in
                withAnimation(QeetrixMotion.animation(.standard, .fast, reduceMotion: reduceMotion)) {
                    proxy.scrollTo(value)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isTabBar)
    }

    @ViewBuilder
    private var strip: some View {
        let height = density.controlHeight
        switch variant {
        case .default:
            HStack(spacing: QeetrixWebScale.spacing(1)) {  // gap-1
                tabButtons(height: height - 2 * QeetrixTabsMetrics.wellPadding)
            }
            .padding(QeetrixTabsMetrics.wellPadding)  // p-0.75
            .frame(minHeight: height)  // h-(--qx-control-height); a minimum, so larger text grows it
            // rounded-lg bg-surface-sunken
            .background(QeetrixColor.surfaceSunken, in: RoundedRectangle(cornerRadius: QeetrixCorner.control))
        case .line:
            HStack(spacing: QeetrixWebScale.spacing(1)) {  // gap-1
                tabButtons(height: height + QeetrixWebScale.spacing(2))  // h-[calc(control-height + 0.5rem)]
            }
            .frame(minWidth: 0, alignment: .leading)
            .background(alignment: .bottom) {
                Rectangle().fill(QeetrixColor.borderDefault).frame(height: QeetrixStroke.hairline)  // border-b border-border
            }
        }
    }

    private func tabButtons(height: CGFloat) -> some View {
        ForEach(tabs) { tab in
            QeetrixTabButton(
                tab: tab, isSelected: tab.value == selection.wrappedValue, variant: variant, height: height
            ) {
                selection.wrappedValue = tab.value
            }
            .id(tab.value)
        }
    }
}

struct QeetrixTabButton<Value: Hashable>: View {
    let tab: QeetrixTab<Value>
    let isSelected: Bool
    let variant: QeetrixTabsVariant
    let height: CGFloat
    let select: @MainActor () -> Void
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: select) {
            HStack(spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
                if let icon = tab.icon {
                    QeetrixIcon(icon, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // size-4
                }
                tab.title
                    .lineLimit(1)  // whitespace-nowrap
            }
            // Full width always: the strip scrolls rather than truncating a label.
            .fixedSize(horizontal: true, vertical: false)
            .qeetrixType(QeetrixTabsMetrics.labelType)
            // text-muted-foreground, hover/active:text-foreground
            .foregroundStyle(isSelected || isHovered ? QeetrixColor.textPrimary : QeetrixColor.textTertiary)
            .padding(.horizontal, variant == .line ? QeetrixWebScale.spacing(3) : QeetrixWebScale.spacing(2.5))  // px-3 / px-2.5
            .frame(minHeight: height)
            .background { background }
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .disabled(tab.isDisabled)
        .opacity(tab.isDisabled || !isEnabled ? QeetrixOpacity.disabled : 1)
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixAnimation(.standard, .fast, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var background: some View {
        switch variant {
        case .default:
            if isSelected {
                // The raised surface in the sunken well: bg-surface-elevated shadow-rest, rounded-md.
                Color.clear.qeetrixElevation(.raised, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.chip))
            }
        case .line:
            // A 2 pt indicator on the track: the brand when selected, a neutral preview under a pointer.
            VStack {
                Spacer(minLength: 0)
                Capsule()
                    .fill(isSelected ? QeetrixColor.borderBrand : QeetrixColor.borderStrong)
                    .frame(height: 2 * QeetrixStroke.hairline)  // h-0.5
                    .opacity(isSelected || isHovered ? 1 : 0)
            }
        }
    }
}

enum QeetrixTabsMetrics {
    /// `font-ui text-sm font-medium`.
    static let labelType = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
    /// `p-0.75` around the contained tabs.
    static let wellPadding: CGFloat = QeetrixWebScale.spacing(0.75)
}
