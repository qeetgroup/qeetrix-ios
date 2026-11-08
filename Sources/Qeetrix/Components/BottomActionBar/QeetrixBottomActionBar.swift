import SwiftUI

/// A screen's main action: the confirming action of a ``QeetrixFullScreenForm``, or one of the two a
/// bottom action bar holds (`qeetrixBottomActionBar(primary:secondary:)`,
/// `qeetrixBottomActionBar(primary:tertiary:)`).
///
/// ```swift
/// QeetrixScreenAction("Pay ₹1,200", icon: .lock, isLoading: isPaying) { pay() }
/// QeetrixScreenAction("Remove member", tone: .danger) { remove() }
/// ```
///
/// The place an action goes decides its emphasis — a primary is `solid`, a bar's secondary `soft`, its
/// tertiary `ghost` — so a screen can't end up with two primaries (design rules §7). Write the title as a verb. A destructive
/// confirmation is the primary with `tone: .danger`; it replaces the primary, never sits beside it.
public struct QeetrixScreenAction {
    /// The label, at the start of the button.
    public let title: Text
    /// An optional trailing icon, in the button's icon zone.
    public let icon: QeetrixIconName?
    /// `.brand` (the default), `.danger` for the confirming action of a destructive flow, or `.neutral`
    /// for a quiet tertiary ("Not now").
    public let tone: QeetrixButtonTone
    /// Shows the spinner in the icon zone and ignores taps; VoiceOver reads the button as busy.
    public let isLoading: Bool
    /// Shows the action but makes it unavailable. Say why nearby; prefer explaining over disabling.
    public let isDisabled: Bool
    let action: @MainActor () -> Void

    /// An action with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, tone: QeetrixButtonTone = .brand, isLoading: Bool = false,
        isDisabled: Bool = false, action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(titleKey), icon: icon, tone: tone, isLoading: isLoading, isDisabled: isDisabled, action: action)
    }

    /// An action with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, tone: QeetrixButtonTone = .brand, isLoading: Bool = false, isDisabled: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(title), icon: icon, tone: tone, isLoading: isLoading, isDisabled: isDisabled, action: action)
    }

    /// An action with a `Text` title.
    public init(
        title: Text, icon: QeetrixIconName? = nil, tone: QeetrixButtonTone = .brand, isLoading: Bool = false, isDisabled: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.tone = tone
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    /// The action as a Qeetrix button of `variant`, `lg` — the field height (design rules §6).
    @MainActor
    func button(_ variant: QeetrixButtonVariant, size: QeetrixControlSize = .lg, isFullWidth: Bool) -> some View {
        QeetrixButton(
            title: title, icon: icon, variant: variant, tone: tone, size: size, isLoading: isLoading, isFullWidth: isFullWidth,
            action: action
        )
        .disabled(isDisabled)
    }
}

extension View {
    /// Pins a screen's main actions to the bottom of the screen: above the keyboard while it is open,
    /// above the home indicator otherwise.
    ///
    /// ```swift
    /// ScrollView {
    ///     InvoiceSummary(invoice)
    /// }
    /// .qeetrixBottomActionBar(
    ///     primary: QeetrixScreenAction("Pay ₹1,200", isLoading: isPaying) { pay() },
    ///     secondary: QeetrixScreenAction("Save for later") { save() })
    /// ```
    ///
    /// The bar holds at most one solid action, the `primary`, and one soft one, the `secondary` (design
    /// rules §7) — or a ghost tertiary instead, with `qeetrixBottomActionBar(primary:tertiary:)`: put
    /// anything else in the screen. Both are `lg` ``QeetrixButton``s. On a phone they span
    /// the bar, side by side when both labels fit in half of it — the secondary first — and stacked, the
    /// primary on top, when they don't; at regular width they keep their own widths, at the end.
    ///
    /// The bar is `color.surface.default`, running under the home indicator. Apply the modifier to the
    /// screen's scroll view: the content scrolls under the bar and can scroll clear of it, and from
    /// iOS 18 a 1 pt `color.border.default` rule appears along the bar's top while content is beneath it.
    /// iOS 17 can't read a scroll view's position without the app's help, so there the rule always shows —
    /// the edge of the chrome, as on a toolbar.
    public func qeetrixBottomActionBar(primary: QeetrixScreenAction, secondary: QeetrixScreenAction? = nil) -> some View {
        modifier(QeetrixBottomActionBarModifier(primary: primary, secondary: secondary, tertiary: nil))
    }

    /// Pins a screen's main action with a quiet ghost action under it — "Continue" over "Not now", "Scan
    /// the code" over "Type the code instead" — or a ghost action on its own, for a quiet "Done" on an
    /// outcome screen.
    ///
    /// ```swift
    /// .qeetrixBottomActionBar(
    ///     primary: QeetrixScreenAction("Continue") { next() },
    ///     tertiary: QeetrixScreenAction("Not now", tone: .neutral) { skip() })
    /// .qeetrixBottomActionBar(tertiary: QeetrixScreenAction("Done", tone: .neutral) { close() })
    /// ```
    ///
    /// The `tertiary` is an `lg` ghost ``QeetrixButton`` — design rules §7 make anything that isn't the
    /// primary or the secondary a tertiary action — under the solid primary: on a phone both span the bar;
    /// at regular width they share the wider one's width, at the end. VoiceOver reads them as drawn, the
    /// primary first. A bar holds a soft secondary or a ghost tertiary, not both. The bar's surface, rule
    /// and keyboard behaviour are those of `qeetrixBottomActionBar(primary:secondary:)`.
    public func qeetrixBottomActionBar(primary: QeetrixScreenAction? = nil, tertiary: QeetrixScreenAction) -> some View {
        modifier(QeetrixBottomActionBarModifier(primary: primary, secondary: nil, tertiary: tertiary))
    }
}

struct QeetrixBottomActionBarModifier: ViewModifier {
    let primary: QeetrixScreenAction?
    let secondary: QeetrixScreenAction?
    let tertiary: QeetrixScreenAction?
    /// Whether content runs beneath the bar, as the scroll view reports it (iOS 18 and later).
    @State private var isContentUnderBar = false

    func body(content: Content) -> some View {
        content
            .modifier(QeetrixBottomActionBarScrollTracking(isContentUnderBar: $isContentUnderBar))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                QeetrixBottomActionBar(primary: primary, secondary: secondary, tertiary: tertiary, showsRule: showsRule)
            }
    }

    /// The rule follows the content from iOS 18; before that, it always shows.
    private var showsRule: Bool {
        if #available(iOS 18, macOS 15, *) {
            return isContentUnderBar
        }
        return true
    }
}

/// Reads, from the scroll view the modifier is applied to, whether its content continues beneath the bar.
struct QeetrixBottomActionBarScrollTracking: ViewModifier {
    @Binding var isContentUnderBar: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content.onScrollGeometryChange(for: Bool.self) { geometry in
                QeetrixBottomActionBarMetrics.isContentUnderBar(
                    contentHeight: geometry.contentSize.height, offset: geometry.contentOffset.y,
                    viewportHeight: geometry.containerSize.height, bottomInset: geometry.contentInsets.bottom)
            } action: { _, isUnder in
                isContentUnderBar = isUnder
            }
        } else {
            content
        }
    }
}

/// The bar's metrics. No `@qeetrix/react` component pins actions to a phone's edge; the bar takes the
/// page's gutter (page-header.css `--qx-page-gutter`) and the footer's 8 pt between buttons.
enum QeetrixBottomActionBarMetrics {
    /// `space.inset.lg` below 840 px wide, `space.layout.md` from it (page-header.css
    /// `--qx-page-gutter`): compact width, then regular.
    static func gutter(isCompact: Bool) -> CGFloat {
        isCompact ? QeetrixSpace.insetLg : QeetrixSpace.layoutMd
    }

    /// Above and below the buttons.
    static let verticalPadding = QeetrixSpace.insetMd
    /// Between the buttons (dialog.css `.qx-dialog-footer` `gap: space.gap.sm`).
    static let gap = QeetrixSpace.gapSm

    /// Whether content continues beneath the bar: the content is longer than the part of it that ends at
    /// the bar's top edge. Half a point of slack, so a list that ends exactly at the bar shows no rule.
    static func isContentUnderBar(contentHeight: CGFloat, offset: CGFloat, viewportHeight: CGFloat, bottomInset: CGFloat) -> Bool {
        contentHeight - (offset + viewportHeight - bottomInset) > 0.5
    }
}

/// The bar itself: the actions on `color.surface.default`, the rule above them while content is under
/// the bar.
struct QeetrixBottomActionBar: View {
    let primary: QeetrixScreenAction?
    let secondary: QeetrixScreenAction?
    let tertiary: QeetrixScreenAction?
    let showsRule: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(
        primary: QeetrixScreenAction?, secondary: QeetrixScreenAction?, tertiary: QeetrixScreenAction? = nil, showsRule: Bool
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.showsRule = showsRule
    }

    var body: some View {
        let isCompact = horizontalSizeClass != .regular
        actions(isCompact: isCompact)
            .padding(.horizontal, QeetrixBottomActionBarMetrics.gutter(isCompact: isCompact))
            .padding(.vertical, QeetrixBottomActionBarMetrics.verticalPadding)
            .frame(maxWidth: .infinity)
            .background(QeetrixColor.surfaceDefault, ignoresSafeAreaEdges: .bottom)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(QeetrixColor.borderDefault)
                    .frame(height: QeetrixBorderWidth.default)
                    .opacity(showsRule ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .qeetrixAnimation(.standard, .fast, value: showsRule)
            .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func actions(isCompact: Bool) -> some View {
        let gap = QeetrixBottomActionBarMetrics.gap
        if let tertiary {
            // The primary over the ghost tertiary, in the order VoiceOver reads them: on a phone both span
            // the bar; at regular width both take the wider one's width, at the end.
            let stack = VStack(spacing: gap) {
                primary?.button(.solid, isFullWidth: true)
                tertiary.button(.ghost, isFullWidth: true)
            }
            if isCompact {
                stack
            } else {
                stack.fixedSize(horizontal: true, vertical: false).frame(maxWidth: .infinity, alignment: .trailing)
            }
        } else if let primary, let secondary {
            if isCompact {
                // Side by side at equal widths while both labels fit in half the bar; else stacked, the
                // primary on top. Each arrangement lists its buttons in the order they are drawn, so
                // VoiceOver reads them as they appear.
                ViewThatFits(in: .horizontal) {
                    QeetrixBottomActionBarRow(spacing: gap) {
                        secondary.button(.soft, isFullWidth: true)
                        primary.button(.solid, isFullWidth: true)
                    }
                    VStack(spacing: gap) {
                        primary.button(.solid, isFullWidth: true)
                        secondary.button(.soft, isFullWidth: true)
                    }
                }
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: gap) {
                        secondary.button(.soft, isFullWidth: false)
                        primary.button(.solid, isFullWidth: false)
                    }
                    VStack(alignment: .trailing, spacing: gap) {
                        primary.button(.solid, isFullWidth: false)
                        secondary.button(.soft, isFullWidth: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        } else if let primary {
            primary.button(.solid, isFullWidth: isCompact)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

/// Two buttons side by side at equal widths. Its ideal width is two of the wider button and the gap, so a
/// `ViewThatFits` takes it only while both labels fit in half the bar.
struct QeetrixBottomActionBarRow: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let count = CGFloat(subviews.count)
        let gaps = spacing * (count - 1)
        guard let width = proposal.width, width.isFinite else {
            let ideal = subviews.map { $0.sizeThatFits(.unspecified) }
            return CGSize(width: (ideal.map(\.width).max() ?? 0) * count + gaps, height: ideal.map(\.height).max() ?? 0)
        }
        let column = max(0, (width - gaps) / count)
        let height = subviews.map { $0.sizeThatFits(ProposedViewSize(width: column, height: nil)).height }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let count = CGFloat(subviews.count)
        let column = max(0, (bounds.width - spacing * (count - 1)) / count)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + CGFloat(index) * (column + spacing), y: bounds.minY),
                proposal: ProposedViewSize(width: column, height: bounds.height))
        }
    }
}
