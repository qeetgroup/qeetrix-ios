import SwiftUI

/// The look of a ``QeetrixTabs`` list, as `@qeetrix/react`'s TabsList `variant`.
public enum QeetrixTabsVariant: String, CaseIterable, Sendable {
    /// The views of a page: a 2 pt `color.border.subtle` line under the list and the 3 pt Ember bar under
    /// the selected tab. The default.
    case line
    /// A segmented strip for a few views of one panel or card: a 1 pt `color.border.default` edge round
    /// it and between segments, the neutral fill, the selected segment on `color.surface.default` with
    /// the Ember bar.
    case contained
}

/// One tab of a ``QeetrixTabs`` list, as `@qeetrix/react`'s Tab.
public struct QeetrixTab<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: Text
    public let icon: QeetrixIconName?
    /// Draws the icon filled while the tab is selected, where the icon has a filled drawing; on by
    /// default, as the filled icon is part of the selected state (design rules §11, react's Tab).
    public let filledWhenSelected: Bool
    /// A count after the label, as a neutral badge.
    public let badge: Int?
    public let isDisabled: Bool
    public var id: Value { value }

    public init(
        _ titleKey: LocalizedStringKey, value: Value, icon: QeetrixIconName? = nil, filledWhenSelected: Bool = true, badge: Int? = nil,
        isDisabled: Bool = false
    ) {
        self.init(
            title: Text(titleKey), value: value, icon: icon, filledWhenSelected: filledWhenSelected, badge: badge, isDisabled: isDisabled)
    }

    public init<S: StringProtocol>(
        _ title: S, value: Value, icon: QeetrixIconName? = nil, filledWhenSelected: Bool = true, badge: Int? = nil,
        isDisabled: Bool = false
    ) {
        self.init(
            title: Text(title), value: value, icon: icon, filledWhenSelected: filledWhenSelected, badge: badge, isDisabled: isDisabled)
    }

    public init(
        title: Text, value: Value, icon: QeetrixIconName? = nil, filledWhenSelected: Bool = true, badge: Int? = nil,
        isDisabled: Bool = false
    ) {
        self.value = value
        self.title = title
        self.icon = icon
        self.filledWhenSelected = filledWhenSelected
        self.badge = badge
        self.isDisabled = isDisabled
    }
}

/// Switch between views of the same context — `@qeetrix/react`'s Tabs list. The selection is yours;
/// show the selected view below it.
///
/// ```swift
/// QeetrixTabs(selection: $section, tabs: [
///     QeetrixTab("Overview", value: Section.overview),
///     QeetrixTab("Invoices", value: Section.invoices, badge: 3),
///     QeetrixTab("Settings", value: Section.settings, isDisabled: true),
/// ])
/// ```
///
/// Tabs are `size.control.lg` tall with 16 pt inline padding (12 pt at compact density), `label.md` in
/// `color.text.subtle`; the selected tab is `color.text.default` at weight 600, marked by the Ember bar
/// (`border.width.accent`), which slides between tabs over `motion.duration.normal` — not at all under
/// Reduce Motion. The list scrolls sideways when its tabs don't fit, keeping the selected one in view.
/// VoiceOver reads it as a tab bar: each tab as a button that is selected or not.
public struct QeetrixTabs<Value: Hashable>: View {
    let selection: Binding<Value>
    let tabs: [QeetrixTab<Value>]
    let variant: QeetrixTabsVariant
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var bar

    public init(selection: Binding<Value>, tabs: [QeetrixTab<Value>], variant: QeetrixTabsVariant = .line) {
        self.selection = selection
        self.tabs = tabs
        self.variant = variant
    }

    /// tabs.css `--qx-tabs-inset`: clamp(12px, control.lg − 20px, 16px).
    static func inset(_ density: QeetrixDensity) -> CGFloat {
        min(max(12, density.sizeControlLg - 20), 16)
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                strip
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            // tabs.css: the line variant's rule is the list's inset shadow, the full width of the
            // container, not just under the tabs.
            .background(alignment: .bottom) {
                if variant == .line {
                    Rectangle().fill(QeetrixColor.borderSubtle).frame(height: QeetrixBorderWidth.strong)
                }
            }
            .onChange(of: selection.wrappedValue) { _, value in
                withAnimation(QeetrixMotion.animation(.standard, .normal, reduceMotion: reduceMotion)) {
                    proxy.scrollTo(value)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isTabBar)
    }

    @ViewBuilder
    private var strip: some View {
        let border = QeetrixBorderWidth.default
        switch variant {
        case .line:
            HStack(spacing: 0) {
                tabButtons(height: density.sizeControlLg)
            }
        case .contained:
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    if index > 0 {
                        Rectangle().fill(QeetrixColor.borderDefault).frame(width: border)
                    }
                    tabButton(tab, height: density.sizeControlLg - 2 * border)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(border)
            .background(QeetrixColor.bgNeutralSubtle, in: RoundedRectangle(cornerRadius: QeetrixRadius.control))
            .clipShape(RoundedRectangle(cornerRadius: QeetrixRadius.control))
            .overlay {
                RoundedRectangle(cornerRadius: QeetrixRadius.control).strokeBorder(QeetrixColor.borderDefault, lineWidth: border)
            }
        }
    }

    private func tabButtons(height: CGFloat) -> some View {
        ForEach(tabs) { tab in
            tabButton(tab, height: height)
        }
    }

    private func tabButton(_ tab: QeetrixTab<Value>, height: CGFloat) -> some View {
        QeetrixTabButton(
            tab: tab, isSelected: tab.value == selection.wrappedValue, variant: variant, height: height, inset: Self.inset(density),
            bar: bar
        ) {
            withAnimation(QeetrixMotion.animation(.standard, .normal, reduceMotion: reduceMotion)) {
                selection.wrappedValue = tab.value
            }
        }
        .id(tab.value)
    }
}

struct QeetrixTabButton<Value: Hashable>: View {
    let tab: QeetrixTab<Value>
    let isSelected: Bool
    let variant: QeetrixTabsVariant
    let height: CGFloat
    let inset: CGFloat
    let bar: Namespace.ID
    let select: @MainActor () -> Void
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        let enabled = isEnabled && !tab.isDisabled
        Button(action: select) {
            HStack(spacing: QeetrixSpace.gapSm) {
                if let icon = tab.icon {
                    QeetrixIcon(icon, size: .sm, shape: .sharp, variant: tab.filledWhenSelected && isSelected ? .filled : .outline)
                }
                HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapSm) {
                    tab.title
                        .lineLimit(1)
                    if let badge = tab.badge {
                        QeetrixBadge(badge.formatted(), size: .sm)
                            .monospacedDigit()
                    }
                }
            }
            // Full width always: the strip scrolls rather than truncating a label.
            .fixedSize(horizontal: true, vertical: false)
            .qeetrixTypeEnvironment(isSelected ? QeetrixTabsMetrics.selectedType : QeetrixTabsMetrics.labelType)
            .foregroundStyle(color(enabled: enabled))
            .padding(.horizontal, inset)
            .frame(minHeight: height)
            .background { background(enabled: enabled) }
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(QeetrixColor.borderBrand)
                        .frame(height: QeetrixBorderWidth.accent)
                        .matchedGeometryEffect(id: "qeetrix.tabs.bar", in: bar)
                        .accessibilityHidden(true)
                }
            }
            // tabs.css: the focus frame is drawn inside the tab, where a scrolling list can't clip it.
            .overlay { if isFocused { Rectangle().strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth) } }
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .disabled(tab.isDisabled)
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixAnimation(.standard, .fast, value: isHovered)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func color(enabled: Bool) -> QeetrixColor {
        if !enabled { return .textDisabled }
        return isSelected || isHovered ? .textDefault : .textSubtle
    }

    @ViewBuilder
    private func background(enabled: Bool) -> some View {
        if variant == .contained {
            if isSelected {
                Rectangle().fill(QeetrixColor.surfaceDefault)
            } else if isHovered && enabled {
                Rectangle().fill(QeetrixColor.bgNeutralSubtleHover)
            }
        }
    }
}

enum QeetrixTabsMetrics {
    /// `label.md`.
    static let labelType = QeetrixComponentType.role(.labelMd)
    /// `label.md` at `title.sm`'s weight (600), for the selected tab.
    static let selectedType = QeetrixComponentType.role(.labelMd, QeetrixTextRole.titleSm.tokens.weight)
}
