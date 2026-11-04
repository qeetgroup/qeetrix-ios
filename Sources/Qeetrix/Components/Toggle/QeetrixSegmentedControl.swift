import SwiftUI

/// One choice among a few that applies at once — a filter (All, Pending) or a short setting (Light,
/// Dark, System) — as `@qeetrix/react`'s segmented ToggleGroup.
///
/// ```swift
/// QeetrixSegmentedControl("Show", selection: $filter, options: [
///     QeetrixOption("All", value: Filter.all),
///     QeetrixOption("Pending", value: Filter.pending),
/// ])
/// ```
///
/// One joined control: a 1 pt `color.border.strong` edge with 4 pt corners round it and between the
/// segments, `size.control.sm` / `md` / `lg` tall. A segment is `label.md` (`label.sm` at `sm`) in
/// `color.text.subtle`; the chosen one is the warm graphite of the secondary button
/// (`color.bg.neutral.bold`) with `color.text.inverse`. Pointer hover gives the neutral tint, and a
/// touch shows it while held. Colours change over `motion.duration.fast`, at once under Reduce Motion.
///
/// One segment is always chosen. The label names the control for VoiceOver and isn't shown; each
/// segment is a button that is selected or not, at least 44 pt square. Two to five short labels:
/// more options want a ``QeetrixSelect``, and a choice in a form a ``QeetrixRadioGroup``.
public struct QeetrixSegmentedControl<Value: Hashable>: View {
    let label: Text
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    let size: QeetrixControlSize
    @Environment(\.qeetrixDensity) private var density

    /// A segmented control named by a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md
    ) {
        self.init(label: Text(titleKey), selection: selection, options: options, size: size)
    }

    /// A segmented control named by a label used as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md
    ) {
        self.init(label: Text(title), selection: selection, options: options, size: size)
    }

    /// A segmented control named by a `Text`.
    public init(label: Text, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md) {
        self.label = label
        self.selection = selection
        self.options = options
        self.size = size
    }

    public var body: some View {
        let border = QeetrixBorderWidth.default
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        let metrics = QeetrixSegmentedControlMetrics(size: size, density: density)
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                if index > 0 {
                    // toggle.css: `.qx-toggle + .qx-toggle { border-inline-start }`.
                    Rectangle().fill(QeetrixColor.borderStrong).frame(width: border).accessibilityHidden(true)
                }
                QeetrixSegment(
                    option: option, isSelected: option.value == selection.wrappedValue,
                    position: QeetrixSegmentPosition(index: index, count: options.count), metrics: metrics
                ) {
                    selection.wrappedValue = option.value
                }
            }
        }
        // Every segment as tall as the tallest, when a label wraps at the largest text sizes.
        .fixedSize(horizontal: false, vertical: true)
        .padding(border)
        .overlay { shape.strokeBorder(QeetrixColor.borderStrong, lineWidth: border).accessibilityHidden(true) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
}

/// Where a segment sits, which decides the corners of its fill.
enum QeetrixSegmentPosition: Equatable {
    case only
    case first
    case middle
    case last

    init(index: Int, count: Int) {
        if count <= 1 {
            self = .only
        } else if index == 0 {
            self = .first
        } else if index == count - 1 {
            self = .last
        } else {
            self = .middle
        }
    }

    /// The fill's shape: the group's corners on its outer side, inside the 1 pt edge (4 − 1 = 3 pt),
    /// square joins between segments (`.qx-toggle-group[data-variant="segmented"]`, overflow hidden).
    var shape: UnevenRoundedRectangle {
        let radius = QeetrixRadius.control - QeetrixBorderWidth.default
        let leading: CGFloat = self == .first || self == .only ? radius : 0
        let trailing: CGFloat = self == .last || self == .only ? radius : 0
        return UnevenRoundedRectangle(
            topLeadingRadius: leading, bottomLeadingRadius: leading, bottomTrailingRadius: trailing, topTrailingRadius: trailing)
    }
}

/// A size's metrics (toggle.css).
struct QeetrixSegmentedControlMetrics: Equatable {
    /// `calc(size.control.<size> − 2 × border.width.default)`: inside the group's edge.
    let height: CGFloat
    /// `padding-inline`: 12 px, 8 px at `sm`, 16 px at `lg`.
    let padding: CGFloat
    /// `label.md`; at `sm`, `label.sm`'s size and line height at the same weight (500).
    let type: QeetrixTypeSpec

    init(size: QeetrixControlSize, density: QeetrixDensity) {
        height = density.controlHeight(size) - 2 * QeetrixBorderWidth.default
        switch size {
        case .sm:
            padding = 8
            type = QeetrixComponentType.role(.labelSm, QeetrixTextRole.labelMd.tokens.weight)
        case .md:
            padding = 12
            type = QeetrixComponentType.role(.labelMd)
        case .lg:
            padding = 16
            type = QeetrixComponentType.role(.labelMd)
        }
    }
}

/// A segment's colours (toggle.css `.qx-toggle`).
struct QeetrixSegmentColors: Equatable {
    var fill: QeetrixColor?
    var text: QeetrixColor

    static func colors(isSelected: Bool, state: QeetrixButtonState) -> QeetrixSegmentColors {
        // `[data-pressed]`: graphite with inverse text; `[data-disabled]` changes only the text.
        let fill: QeetrixColor? =
            isSelected ? .bgNeutralBold : (state == .hovered || state == .pressed ? .bgNeutralSubtle : nil)
        let text: QeetrixColor =
            if state == .disabled {
                .textDisabled
            } else if isSelected {
                .textInverse
            } else {
                state == .resting ? .textSubtle : .textDefault
            }
        return QeetrixSegmentColors(fill: fill, text: text)
    }
}

private struct QeetrixSegment<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let position: QeetrixSegmentPosition
    let metrics: QeetrixSegmentedControlMetrics
    let select: @MainActor () -> Void

    var body: some View {
        Button(action: select) {
            option.title
        }
        .buttonStyle(QeetrixSegmentStyle(isSelected: isSelected, position: position, metrics: metrics))
        .disabled(option.isDisabled)
        .accessibilityHint(option.description ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct QeetrixSegmentStyle: ButtonStyle {
    let isSelected: Bool
    let position: QeetrixSegmentPosition
    let metrics: QeetrixSegmentedControlMetrics

    func makeBody(configuration: Configuration) -> some View {
        QeetrixSegmentBody(style: self, configuration: configuration)
    }
}

private struct QeetrixSegmentBody: View {
    let style: QeetrixSegmentStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        let state = QeetrixButtonStyleBody.state(
            isEnabled: isEnabled, isPressed: configuration.isPressed, isHovered: isHovered, isLoading: false)
        let colors = QeetrixSegmentColors.colors(isSelected: style.isSelected, state: state)
        let shape = style.position.shape
        configuration.label
            .qeetrixType(style.metrics.type)
            // The web keeps one line; here a label wraps at the largest text sizes rather than truncating.
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, style.metrics.padding)
            .qeetrixControlBlockSize(style.metrics.height, type: style.metrics.type)
            .frame(minWidth: QeetrixAccessibility.minimumTouchTarget, maxHeight: .infinity)
            .foregroundStyle(colors.text)
            .background { if let fill = colors.fill { shape.fill(fill) } }
            // toggle.css `:focus-visible`: the Ember frame inside, with the surface-coloured gap.
            .overlay { if isFocused { QeetrixInnerFocusFrame(shape: shape) } }
            .qeetrixHitArea()
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: state)
            .qeetrixAnimation(.standard, .fast, value: style.isSelected)
    }
}
