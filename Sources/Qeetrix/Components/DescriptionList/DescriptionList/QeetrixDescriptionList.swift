import SwiftUI

/// How a ``QeetrixDescriptionList`` arranges its terms and values — the web's `layout` values.
public enum QeetrixDescriptionListLayout: String, CaseIterable, Sendable {
    /// A term column beside a value column in a regular-width window; each term above its value in
    /// compact width (an iPhone, a narrow sheet). The default.
    case horizontal
    /// Each term above its value at every width — for narrow panels and sheets.
    case vertical
    /// A grid of term-over-value cells, at least 192 pt wide, filling the width — for summaries (plan,
    /// region, created, owner).
    case grid
}

/// Labelled details — the settings and properties of one thing: a plan, a device, a file. The web's
/// `DescriptionList`.
///
/// ```swift
/// QeetrixDescriptionList(isDivided: true) {
///     QeetrixDescriptionItem("Plan", value: Text("Team"))
///     QeetrixDescriptionItem("Region", value: Text("Mumbai (ap-south-1)"))
///     QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
/// }
/// ```
///
/// Terms are quiet labels and values are the data, in `text-sm`. Pairs are spaced by the density's cell
/// padding — a compact subtree tightens the list as it tightens a table — and `isDivided` rules them.
/// Long values wrap rather than truncate.
///
/// Values are what you pass: format dates, amounts and identifiers before they get here, and decide
/// whether a value is safe to show. The list never logs, copies or announces anything you haven't
/// displayed.
///
/// Inside a `List`, where each row is separate, use one ``QeetrixDescriptionItem`` per row: the list
/// draws the separators.
public struct QeetrixDescriptionList<Content: View>: View {
    let layout: QeetrixDescriptionListLayout
    let isDivided: Bool
    let content: Content
    @Environment(\.qeetrixDensity) private var density

    /// - Parameters:
    ///   - layout: How terms and values are arranged.
    ///   - isDivided: Draws a rule between pairs.
    ///   - content: The ``QeetrixDescriptionItem``s.
    public init(layout: QeetrixDescriptionListLayout = .horizontal, isDivided: Bool = false, @ViewBuilder content: () -> Content) {
        self.layout = layout
        self.isDivided = isDivided
        self.content = content()
    }

    public var body: some View {
        let gap = density.cellPaddingY
        Group {
            switch layout {
            case .grid:
                // grid-cols-[repeat(auto-fill,minmax(min(100%,12rem),1fr))] gap-x-6 gap-y-[cell-padding × 1.5]
                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: QeetrixDescriptionListMetrics.cellMinimumWidth), spacing: QeetrixWebScale.spacing(6),
                            alignment: .topLeading)
                    ],
                    alignment: .leading, spacing: isDivided ? 0 : gap * 1.5
                ) {
                    content
                }
            case .horizontal, .vertical:
                // Divided pairs carry their own padding, so the stack's first and last lose it again.
                VStack(alignment: .leading, spacing: isDivided ? 0 : gap) {
                    content
                }
                .padding(.vertical, isDivided ? -gap : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.qeetrixDescriptionListStyle, QeetrixDescriptionListStyle(layout: layout, isDivided: isDivided))
        .qeetrixRules(isDivided ? QeetrixColor.borderSubtle : nil)  // border-t border-border-subtle
    }
}

/// One term and its value in a ``QeetrixDescriptionList`` — the web's `DescriptionItem` with its
/// `DescriptionTerm` and `DescriptionDetails`. On its own, in a `List` row, it lays out as a list's
/// default `horizontal` item.
///
/// VoiceOver reads the term and value together, as one element. A value that holds a control (a
/// button, a link) should sit outside the item, where it stays reachable on its own.
public struct QeetrixDescriptionItem<Value: View>: View {
    let term: Text
    let value: Value
    @Environment(\.qeetrixDescriptionListStyle) private var style
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// An item with a localised term and a value view.
    public init(_ termKey: LocalizedStringKey, @ViewBuilder value: () -> Value) {
        self.init(term: Text(termKey), value: value)
    }

    /// An item with a term shown as given, without localisation, and a value view.
    public init<S: StringProtocol>(_ term: S, @ViewBuilder value: () -> Value) {
        self.init(term: Text(term), value: value)
    }

    /// An item with a `Text` term and a value view.
    ///
    /// - Parameters:
    ///   - term: What the value is.
    ///   - value: The value: text, a badge, any view. It is set in `text-sm`, primary.
    public init(term: Text, @ViewBuilder value: () -> Value) {
        self.term = term
        self.value = value()
    }

    public var body: some View {
        let besideTerm = style.layout == .horizontal && horizontalSizeClass == .regular
        Group {
            if besideTerm {
                // sm:grid-cols-[minmax(8rem,12rem)_minmax(0,1fr)] gap-x-6: the term track reaches its 12rem.
                HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(6)) {
                    termView.frame(width: QeetrixDescriptionListMetrics.termColumnWidth, alignment: .leading)
                    valueView.frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // gap-y-0.5, mt-0.5
                    termView
                    valueView
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, style.isDivided ? density.cellPaddingY : 0)  // py-(--qx-control-cell-padding-y)
        .accessibilityElement(children: .combine)
        .qeetrixRuledItem()
    }

    private var termView: some View {
        term
            .qeetrixType(QeetrixDescriptionListMetrics.textType)
            .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
            .fixedSize(horizontal: false, vertical: true)
    }

    private var valueView: some View {
        value
            .qeetrixType(QeetrixDescriptionListMetrics.textType)
            .foregroundStyle(QeetrixColor.textPrimary)  // text-foreground
            .fixedSize(horizontal: false, vertical: true)  // wrap-break-word
    }
}

extension QeetrixDescriptionItem where Value == Text {
    /// An item with a localised term and a text value.
    public init(_ termKey: LocalizedStringKey, value: Text) {
        self.init(term: Text(termKey)) { value }
    }

    /// An item with a term shown as given, without localisation, and a text value.
    public init<S: StringProtocol>(_ term: S, value: Text) {
        self.init(term: Text(term)) { value }
    }
}

struct QeetrixDescriptionListStyle: Sendable {
    var layout: QeetrixDescriptionListLayout = .horizontal
    var isDivided = false
}

private struct QeetrixDescriptionListStyleKey: EnvironmentKey {
    static let defaultValue = QeetrixDescriptionListStyle()
}

extension EnvironmentValues {
    /// The enclosing description list's layout, which its items follow.
    var qeetrixDescriptionListStyle: QeetrixDescriptionListStyle {
        get { self[QeetrixDescriptionListStyleKey.self] }
        set { self[QeetrixDescriptionListStyleKey.self] = newValue }
    }
}

enum QeetrixDescriptionListMetrics {
    /// `text-sm`, for terms and values.
    static let textType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
    /// `12rem`, the term track's maximum, which it reaches beside a value.
    static let termColumnWidth = QeetrixWebScale.spacing(48)
    /// `12rem`, a grid cell's minimum width.
    static let cellMinimumWidth = QeetrixWebScale.spacing(48)
}
