import SwiftUI

/// How a choice group lays out its options, as `@qeetrix/react`'s `ChoiceOrientation`.
public enum QeetrixChoiceOrientation: String, CaseIterable, Sendable {
    /// One option per row, the default.
    case vertical
    /// Options side by side, wrapping, for short options.
    case horizontal
}

/// How a choice group's options look, as `@qeetrix/react`'s `ChoiceVariant`.
public enum QeetrixChoiceVariant: String, CaseIterable, Sendable {
    /// A row per option, the radio at the start. The default.
    case `default`
    /// A box per option — an icon, a title and a line, the radio at the end — the whole tile the target,
    /// for choices that need explaining.
    case tile
}

/// Pick one of a set, as `@qeetrix/react`'s RadioGroup: the question as the legend, in the field-label
/// style, then a radio per option (design rules §9).
///
/// ```swift
/// QeetrixRadioGroup("Billing cycle", selection: $cycle, options: [
///     QeetrixOption("Monthly", value: Cycle.monthly),
///     QeetrixOption("Yearly", value: Cycle.yearly, description: Text("Two months free")),
/// ])
/// ```
///
/// A 16 pt circle with a 1 pt `color.border.strong` edge on `color.bg.input`; selected, the edge
/// becomes a 5 pt Ember ring around the centre. Each row is a 44 pt target. With an error, every
/// radio takes the danger edge (the chosen one a danger ring) and the error replaces the description,
/// as for a field. Choosing another option plays ``QeetrixFeedback/selection`` feedback. VoiceOver reads
/// each option as a button that is selected or not, with its description as its hint.
///
/// `variant: .tile` draws each option as a box (field.css `[data-variant="tile"]`) and `columns` lays the
/// tiles out in up to that many equal columns, 8 pt apart — fewer where a tile would be narrower than
/// 128 pt, or 192 pt once an option has an icon or a description:
///
/// ```swift
/// QeetrixRadioGroup("Language", selection: $language, options: languages, variant: .tile, columns: 2)
/// ```
public struct QeetrixRadioGroup<Value: Hashable>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let orientation: QeetrixChoiceOrientation
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    /// Rows or tiles.
    var variant = QeetrixChoiceVariant.default
    /// For tiles: the most equal columns.
    var columns = 1
    /// The person's changes of option: each plays the selection feedback, and a change the app makes
    /// doesn't.
    @State private var changes = 0

    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, description: description, error: error,
            orientation: orientation, isRequired: isRequired, isOptional: isOptional)
    }

    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, description: description, error: error,
            orientation: orientation, isRequired: isRequired, isOptional: isOptional)
    }

    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.orientation = orientation
        self.selection = selection
        self.options = options
    }

    /// A radio group with a localised legend, in rows or tiles.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        variant: QeetrixChoiceVariant,
        columns: Int = 1,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, description: description, error: error,
            orientation: orientation, variant: variant, columns: columns, isRequired: isRequired, isOptional: isOptional)
    }

    /// A radio group with a legend shown as given, without localisation, in rows or tiles.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        variant: QeetrixChoiceVariant,
        columns: Int = 1,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, description: description, error: error,
            orientation: orientation, variant: variant, columns: columns, isRequired: isRequired, isOptional: isOptional)
    }

    /// A radio group with a `Text` legend, in rows or tiles.
    ///
    /// - Parameters:
    ///   - label: The question, as the legend; it names the group for VoiceOver.
    ///   - selection: The chosen option's value.
    ///   - options: The options, each with its title and, optionally, a description and an icon.
    ///   - description: Help under the options, hidden while an error shows.
    ///   - error: What to fix, already localised; every radio takes the danger edge.
    ///   - orientation: For rows, one per line or side by side.
    ///   - variant: `default` rows, or `tile`s: each option a box with its icon, title and description,
    ///     the radio at its top end, the whole tile the target.
    ///   - columns: For tiles, the most equal columns that share the width, 8 pt apart (`space.gap.sm`):
    ///     one by default. Fewer where a tile would be narrower than 128 pt — 192 pt once any option has an
    ///     icon or a description — as the web's `--qx-choice-tile-min` (8rem, 12rem). Every tile in a row
    ///     is as tall as the tallest. Rows ignore it; `orientation` lays them out instead, and tiles ignore
    ///     that.
    ///   - isRequired: Says "Required" with the legend.
    ///   - isOptional: Shows "(optional)" after the legend.
    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        variant: QeetrixChoiceVariant,
        columns: Int = 1,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: label, selection: selection, options: options, description: description, error: error, orientation: orientation,
            isRequired: isRequired, isOptional: isOptional)
        self.variant = variant
        self.columns = max(1, columns)
    }

    public var body: some View {
        QeetrixChoiceGroupLayout(context: context, isOptional: isOptional) {
            if variant == .tile {
                // field.css: up to `columns` equal tracks, `space.gap.sm` apart both ways, none narrower
                // than the tile minimum.
                QeetrixTileGridLayout(
                    columns: columns, spacing: QeetrixSpace.gapSm,
                    minimumWidth: QeetrixRadioTileMetrics.minimumWidth(
                        isDetailed: options.contains { $0.icon != nil || $0.description != nil })
                ) { tiles }
            } else {
                switch orientation {
                case .vertical:
                    radios
                case .horizontal:
                    // field.css: options 16 pt apart (`space.gap.lg`), wrapping.
                    QeetrixCardFooterLayout(spacing: QeetrixSpace.gapLg, alignment: .leading) { radios }
                }
            }
        }
        .qeetrixFeedback(.selection, trigger: changes)
    }

    private var radios: some View {
        ForEach(options) { option in
            QeetrixRadio(option: option, isSelected: option.value == selection.wrappedValue) {
                choose(option)
            }
            .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
        }
    }

    private var tiles: some View {
        ForEach(options) { option in
            QeetrixRadioTile(option: option, isSelected: option.value == selection.wrappedValue) {
                choose(option)
            }
        }
    }

    private func choose(_ option: QeetrixOption<Value>) {
        // Choosing the option already chosen changes nothing, and plays nothing.
        if option.value != selection.wrappedValue { changes += 1 }
        selection.wrappedValue = option.value
    }
}

struct QeetrixRadio<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let select: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false
    @ScaledMetric(relativeTo: .body) private var fontSize = QeetrixTextRole.bodyMd.tokens.size

    /// Centres the icon on the title's first line, as the row centres its radio.
    private var iconOffset: CGFloat { fontSize * 0.32 }

    var body: some View {
        let enabled = isEnabled && !option.isDisabled
        let offset = iconOffset
        Button(action: select) {
            QeetrixChoiceRow(description: option.description, isEnabled: enabled) {
                QeetrixRadioDisc(isSelected: isSelected, isHovered: isHovered, isEnabled: enabled)
            } label: {
                if let icon = option.icon {
                    // `.qx-choice-icon`: 16 pt in `color.icon.subtle`, 8 pt before the title.
                    HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapSm) {
                        QeetrixIcon(icon, size: .sm, shape: .sharp, relativeTo: .body)
                            .foregroundStyle(enabled ? QeetrixColor.iconSubtle : QeetrixColor.iconDisabled)
                            .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + offset }
                        option.title
                    }
                } else {
                    option.title
                }
            }
        }
        .buttonStyle(QeetrixRadioButtonStyle())
        .disabled(option.isDisabled)
        .onHover { isHovered = $0 }
        // The button stays the element, so its disabled state reaches VoiceOver; the label replaces the
        // title-and-description it would read from its content.
        .accessibilityLabel(option.title)
        .accessibilityHint(option.description ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .modifier(QeetrixGroupErrorAccessibility())
    }
}

private struct QeetrixRadioButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// An option as a tile (field.css `.qx-choice-group[data-variant="tile"] .qx-choice`): padded
/// `space.inset.md` on `color.surface.default` with a 1 pt `color.border.subtle` edge inside it and
/// `radius.control` corners. Chosen, `color.bg.selected` with a 2 pt `color.border.brand` edge; under a
/// pointer or a held touch, `color.bg.neutral.subtle`; disabled, `color.bg.disabled` with the disabled
/// edge. Inside, `space.gap.md` apart: the icon in a 36 pt box, the title at `title.sm`'s weight with the
/// description under it, and the radio at the end, on the title's first line.
struct QeetrixRadioTile<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let select: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let enabled = isEnabled && !option.isDisabled
        Button(action: select) {
            QeetrixRadioTileContent(option: option, isSelected: isSelected, isEnabled: enabled)
        }
        .buttonStyle(QeetrixRadioTileStyle(isSelected: isSelected, isEnabled: enabled, hasIcon: option.icon != nil))
        .disabled(option.isDisabled)
        // As a row: the button is the element, its title the name and its description the hint.
        .accessibilityLabel(option.title)
        .accessibilityHint(option.description ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .modifier(QeetrixGroupErrorAccessibility())
    }
}

struct QeetrixRadioTileContent<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let isEnabled: Bool
    var isHovered = false
    /// The title's line: the radio is centred on it.
    @ScaledMetric(relativeTo: .body) private var line = QeetrixTextRole.bodyMd.tokens.size * QeetrixTextRole.bodyMd.tokens.lineHeight
    @ScaledMetric(relativeTo: .body) private var iconBox = QeetrixRadioTileMetrics.iconBox

    var body: some View {
        HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
            if let icon = option.icon {
                // `.qx-choice-icon`: a 36 pt box on `color.bg.neutral.subtle` with the 20 pt icon in
                // `color.icon.subtle`; chosen, the box is `color.surface.default` and the icon brand.
                QeetrixIcon(icon, size: .md, shape: .sharp, relativeTo: .body)
                    .foregroundStyle(iconColor)
                    .frame(width: iconBox, height: iconBox)
                    .background(
                        isSelected && isEnabled ? QeetrixColor.surfaceDefault : QeetrixColor.bgNeutralSubtle,
                        in: RoundedRectangle(cornerRadius: QeetrixRadius.control))
            }
            VStack(alignment: .leading, spacing: 0) {
                option.title
                    .qeetrixType(QeetrixRadioTileMetrics.titleType)
                    .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
                if let description = option.description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textSubtlest)
                }
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            // `.qx-choice-label > :first-child { order: 3 }`: the radio at the end, on the first line.
            QeetrixRadioDisc(isSelected: isSelected, isHovered: isHovered, isEnabled: isEnabled)
                .frame(height: line)
        }
    }

    private var iconColor: QeetrixColor {
        if !isEnabled { return .iconDisabled }
        return isSelected ? .iconBrand : .iconSubtle
    }
}

/// The tile's sizes (field.css).
enum QeetrixRadioTileMetrics {
    /// `.qx-choice-icon { inline-size: 36px; block-size: 36px }`.
    static let iconBox: CGFloat = 36

    /// `--qx-choice-tile-min`: 8rem (128 pt) for plain labels, 12rem (192 pt) once any option in the group
    /// has an icon or a description.
    static func minimumWidth(isDetailed: Bool) -> CGFloat {
        isDetailed ? 192 : 128
    }
    /// `.qx-choice-text { font-weight: var(--qx-typography-title-sm-font-weight) }` on `body.md`.
    static let titleType = QeetrixComponentType.role(.bodyMd, QeetrixTextRole.titleSm.tokens.weight)
}

/// A tile's box: its fill, edge and corners round the content, the whole tile the target.
struct QeetrixRadioTileStyle: ButtonStyle {
    let isSelected: Bool
    let isEnabled: Bool
    let hasIcon: Bool

    func makeBody(configuration: Configuration) -> some View {
        QeetrixRadioTileBody(style: self, configuration: configuration)
    }

    /// The fill: chosen `color.bg.selected`; under a pointer or a held touch `color.bg.neutral.subtle`,
    /// which never covers the chosen fill; disabled `color.bg.disabled`; else `color.surface.default`.
    static func fill(isSelected: Bool, isEnabled: Bool, isLit: Bool) -> QeetrixColor {
        if !isEnabled { return .bgDisabled }
        if isSelected { return .bgSelected }
        return isLit ? .bgNeutralSubtle : .surfaceDefault
    }

    /// The edge inside the tile: 2 pt `color.border.brand` when chosen, else 1 pt `color.border.subtle`,
    /// or `color.border.disabled` when disabled.
    static func edge(isSelected: Bool, isEnabled: Bool) -> (color: QeetrixColor, width: CGFloat) {
        if !isEnabled { return (.borderDisabled, QeetrixBorderWidth.default) }
        return isSelected ? (.borderBrand, QeetrixBorderWidth.strong) : (.borderSubtle, QeetrixBorderWidth.default)
    }
}

private struct QeetrixRadioTileBody: View {
    let style: QeetrixRadioTileStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isFocused) private var isFocused
    @ScaledMetric(relativeTo: .body) private var iconBox = QeetrixRadioTileMetrics.iconBox

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        let isLit = isHovered || configuration.isPressed
        let edge = QeetrixRadioTileStyle.edge(isSelected: style.isSelected, isEnabled: style.isEnabled)
        configuration.label
            .padding(QeetrixSpace.insetMd)
            // With an icon, `min-block-size: calc(36px + 2 × space.inset.md)`; a 44 pt target either way.
            .frame(
                maxWidth: .infinity,
                minHeight: max(style.hasIcon ? iconBox + 2 * QeetrixSpace.insetMd : 0, QeetrixAccessibility.minimumTouchTarget),
                maxHeight: .infinity, alignment: .topLeading
            )
            .background(QeetrixRadioTileStyle.fill(isSelected: style.isSelected, isEnabled: style.isEnabled, isLit: isLit), in: shape)
            // `box-shadow: inset 0 0 0 <width> <colour>`.
            .overlay { shape.strokeBorder(edge.color, lineWidth: edge.width) }
            .overlay { if isFocused { QeetrixOuterFocusFrame(shape: shape) } }
            .contentShape(shape)
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: isLit)
            .qeetrixAnimation(.standard, .fast, value: style.isSelected)
    }
}

/// The tiles' grid (field.css: `repeat(auto-fill, minmax(max(<minimum>, <a share of columns>), 1fr))`):
/// up to `columns` equal tracks `spacing` apart — as many as fit when a share of `columns` would be under
/// `minimumWidth`, at least one — rows `spacing` apart, and every tile in a row as tall as the tallest
/// (CSS grid's stretch). SwiftUI mirrors it right to left.
struct QeetrixTileGridLayout: Layout {
    let columns: Int
    let spacing: CGFloat
    var minimumWidth: CGFloat = 0

    /// How many tracks fit `width`: `columns`, or fewer where a share would be narrower than
    /// `minimumWidth`.
    func columnCount(width: CGFloat?) -> Int {
        guard let width, width.isFinite else { return columns }
        let share = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let track = max(minimumWidth, share)
        guard track > 0 else { return columns }
        // CSS's auto-fill: as many tracks of at least `track` as fit (a hair over, for floating point).
        return min(columns, max(1, Int(((width + spacing) / (track + spacing) + 1e-6).rounded(.down))))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let columns = columnCount(width: proposal.width)
        let width = trackWidth(proposal.width, columns: columns, subviews: subviews)
        let heights = rowHeights(width: width, columns: columns, subviews: subviews)
        let count = CGFloat(min(columns, max(subviews.count, 1)))
        return CGSize(
            width: proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? width * count + spacing * (count - 1),
            height: heights.reduce(0, +) + spacing * CGFloat(max(heights.count - 1, 0)))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columns = columnCount(width: bounds.width)
        let width = trackWidth(bounds.width, columns: columns, subviews: subviews)
        let heights = rowHeights(width: width, columns: columns, subviews: subviews)
        var y = bounds.minY
        for (row, height) in heights.enumerated() {
            for column in 0..<columns {
                let index = row * columns + column
                guard index < subviews.count else { break }
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + CGFloat(column) * (width + spacing), y: y), anchor: .topLeading,
                    proposal: ProposedViewSize(width: width, height: height))
            }
            y += height + spacing
        }
    }

    /// One track's width: an equal share of the width less the gaps, or the widest tile's own width.
    private func trackWidth(_ width: CGFloat?, columns: Int, subviews: Subviews) -> CGFloat {
        if let width, width.isFinite {
            return max(0, (width - spacing * CGFloat(columns - 1)) / CGFloat(columns))
        }
        return subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
    }

    private func rowHeights(width: CGFloat, columns: Int, subviews: Subviews) -> [CGFloat] {
        stride(from: 0, to: subviews.count, by: columns).map { start in
            subviews[start..<min(start + columns, subviews.count)]
                .map { $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }
                .max() ?? 0
        }
    }
}

/// The 16 pt circle (radio.css): selected, its border is a 5 pt Ember ring around the input-coloured
/// centre.
struct QeetrixRadioDisc: View {
    let isSelected: Bool
    var isHovered = false
    var isEnabled = true
    @Environment(\.qeetrixGroupIsInvalid) private var isInvalid
    @Environment(\.isFocused) private var isFocused

    static let side: CGFloat = 16
    static let selectedRing: CGFloat = 5

    var body: some View {
        ZStack {
            Circle().fill(isEnabled ? QeetrixColor.bgInput : QeetrixColor.bgDisabled)
            Circle().strokeBorder(border, lineWidth: isSelected ? Self.selectedRing : QeetrixBorderWidth.default)
        }
        .frame(width: Self.side, height: Self.side)
        .overlay { if isFocused { QeetrixOuterFocusFrame(shape: Circle()) } }
        .qeetrixAnimation(.standard, .fast, value: isSelected)
        .qeetrixAnimation(.standard, .fast, value: isHovered)
    }

    var border: QeetrixColor {
        if !isEnabled { return isSelected ? .iconDisabled : .borderDisabled }
        // `.qx-radio[data-invalid]` follows the checked and hover rules: a chosen invalid radio's 5 pt
        // ring is the danger colour, hovered too.
        if isInvalid { return .borderDanger }
        if isSelected { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return isHovered ? .borderStrongHover : .borderStrong
    }
}
