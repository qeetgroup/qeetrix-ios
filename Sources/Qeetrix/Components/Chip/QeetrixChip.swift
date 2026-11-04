import SwiftUI

/// A tag someone acts on, as `@qeetrix/react`'s Chip: a filter that turns on and off, or a choice
/// already made with a button that takes it away (design rules §14).
///
/// ```swift
/// QeetrixChip("Unread", isSelected: $unread)
/// QeetrixChip("Status: Active") { removeStatusFilter() }
/// ```
///
/// The neutral tint with a 1 pt `color.border.subtle` edge inside, the controls' 4 pt corners, the
/// label in `label.md` (`label.sm` at `sm`), `size.control.sm` / `md` / `lg` tall. A selectable chip
/// takes the neutral tints' hover and pressed steps; chosen, the selected tint (`color.bg.selected`),
/// a 2 pt Ember edge and a 16 pt sharp check before the label — an `icon` takes the check's place —
/// so the choice never rests on colour. Disabled, `color.bg.disabled` with the disabled edge and text.
/// A long label wraps; the chip grows.
///
/// Selectable, VoiceOver reads it as the system's toggle, named by its label, and says when it turns
/// on or off; it is a 44 pt target. Removable, it is a static label — with "Remove {label}" in its
/// actions — then a small neutral remove button with that name; removing the chip, and moving focus
/// to the next, are yours. For chips that choose from a set, use ``QeetrixChipGroup``; a status no one
/// can change is a ``QeetrixBadge``.
public struct QeetrixChip: View {
    let label: Text
    let icon: QeetrixIconName?
    let size: QeetrixControlSize
    let kind: Kind

    enum Kind {
        case selectable(Binding<Bool>)
        case removable(name: Text, action: @MainActor () -> Void)
    }

    /// A chip that turns on and off, with a localised label.
    public init(_ titleKey: LocalizedStringKey, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md) {
        self.init(label: Text(titleKey), isSelected: isSelected, icon: icon, size: size)
    }

    /// A chip that turns on and off, with a label shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md) {
        self.init(label: Text(title), isSelected: isSelected, icon: icon, size: size)
    }

    /// A chip that turns on and off, with a `Text` label.
    public init(label: Text, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md) {
        self.label = label
        self.icon = icon
        self.size = size
        kind = .selectable(isSelected)
    }

    /// A removable chip with a localised label. Its remove button is named "Remove {label}" unless
    /// `removeLabel` names it.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md, removeLabel: Text? = nil,
        onRemove: @escaping @MainActor () -> Void
    ) {
        let label = Text(titleKey)
        self.init(label: label, icon: icon, size: size, removeName: removeLabel ?? QeetrixChipStrings.remove(label), onRemove: onRemove)
    }

    /// A removable chip with a label shown as given, without localisation. Its remove button is named
    /// "Remove {label}" unless `removeLabel` names it.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md, removeLabel: Text? = nil,
        onRemove: @escaping @MainActor () -> Void
    ) {
        self.init(
            label: Text(title), icon: icon, size: size,
            removeName: removeLabel ?? Text(verbatim: QeetrixChipStrings.remove(String(title))), onRemove: onRemove)
    }

    /// A removable chip with a `Text` label. Its remove button is named "Remove {label}" unless
    /// `removeLabel` names it.
    public init(
        label: Text, icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md, removeLabel: Text? = nil,
        onRemove: @escaping @MainActor () -> Void
    ) {
        self.init(label: label, icon: icon, size: size, removeName: removeLabel ?? QeetrixChipStrings.remove(label), onRemove: onRemove)
    }

    private init(
        label: Text, icon: QeetrixIconName?, size: QeetrixControlSize, removeName: Text, onRemove: @escaping @MainActor () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.size = size
        kind = .removable(name: removeName, action: onRemove)
    }

    public var body: some View {
        switch kind {
        case let .selectable(isSelected):
            Toggle(isOn: isSelected) { label }
                .toggleStyle(QeetrixChipToggleStyle(icon: icon, size: size))
        case let .removable(name, action):
            QeetrixRemovableChip(label: label, icon: icon, size: size, removeName: name, onRemove: action)
        }
    }
}

/// The Qeetrix chip look for any `Toggle`: a filter that turns on and off.
///
/// ```swift
/// Toggle("Starred", isOn: $starred)
///     .toggleStyle(.qeetrixChip(icon: .pin))
/// ```
public struct QeetrixChipToggleStyle: ToggleStyle {
    let icon: QeetrixIconName?
    let size: QeetrixControlSize

    /// A chip of `size`; `icon`, a 16 pt sharp icon before the label, takes the check's place.
    public init(icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md) {
        self.icon = icon
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixChipToggleBody(configuration: configuration, icon: icon, size: size)
    }
}

extension ToggleStyle where Self == QeetrixChipToggleStyle {
    /// The Qeetrix chip style.
    public static func qeetrixChip(icon: QeetrixIconName? = nil, size: QeetrixControlSize = .md) -> QeetrixChipToggleStyle {
        QeetrixChipToggleStyle(icon: icon, size: size)
    }
}

struct QeetrixChipToggleBody: View {
    let configuration: ToggleStyleConfiguration
    let icon: QeetrixIconName?
    let size: QeetrixControlSize

    var body: some View {
        // A button draws the pressed state; VoiceOver reads the system toggle it stands for.
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(QeetrixChipButtonStyle(isSelected: configuration.isOn, icon: icon, size: size))
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

/// A selectable chip's look, for the toggle and for a single-choice group's radios.
struct QeetrixChipButtonStyle: ButtonStyle {
    let isSelected: Bool
    let icon: QeetrixIconName?
    let size: QeetrixControlSize

    func makeBody(configuration: Configuration) -> some View {
        QeetrixChipButtonBody(style: self, configuration: configuration)
    }
}

private struct QeetrixChipButtonBody: View {
    let style: QeetrixChipButtonStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        let metrics = QeetrixChipMetrics(size: style.size, density: density)
        let state = QeetrixButtonStyleBody.state(
            isEnabled: isEnabled, isPressed: configuration.isPressed, isHovered: isHovered, isLoading: false)
        let colors = QeetrixChipColors.colors(isSelected: style.isSelected, isRemovable: false, state: state)
        QeetrixChipContent(mark: QeetrixChipMetrics.mark(icon: style.icon, isSelected: style.isSelected), metrics: metrics) {
            configuration.label
        }
        .modifier(QeetrixChipFrame(metrics: metrics, colors: colors, isFocused: isFocused))
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixAnimation(.standard, .fast, value: state)
        .qeetrixAnimation(.standard, .fast, value: style.isSelected)
    }
}

/// A choice already made: the label, then the remove button (chip.css `[data-removable]`).
private struct QeetrixRemovableChip: View {
    let label: Text
    let icon: QeetrixIconName?
    let size: QeetrixControlSize
    let removeName: Text
    let onRemove: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        let metrics = QeetrixChipMetrics(size: size, density: density)
        let colors = QeetrixChipColors.colors(isSelected: false, isRemovable: true, state: isEnabled ? .resting : .disabled)
        HStack(spacing: QeetrixChipMetrics.gap) {
            QeetrixChipContent(mark: icon, metrics: metrics) { label }
                .accessibilityElement(children: .combine)
                .modifier(QeetrixChipRemoveAction(name: removeName, isEnabled: isEnabled, action: onRemove))
            // chip.css `.qx-chip-remove`: a small neutral IconButton, ending the chip.
            QeetrixIconButton(.x, label: removeName, tone: .neutral, size: .sm, action: onRemove)
        }
        .modifier(QeetrixChipFrame(metrics: metrics, colors: colors, isRemovable: true))
        .accessibilityElement(children: .contain)
    }
}

/// "Remove {label}" in the label's actions, so VoiceOver and Switch Control can remove the chip from
/// its label as well as from its button.
private struct QeetrixChipRemoveAction: ViewModifier {
    let name: Text
    let isEnabled: Bool
    let action: @MainActor () -> Void

    func body(content: Content) -> some View {
        if isEnabled {
            content.accessibilityAction(named: name) { action() }
        } else {
            content
        }
    }
}

/// The mark (a 16 pt sharp icon or the check), then the label, `space.gap.xs` apart (chip.css).
struct QeetrixChipContent<Label: View>: View {
    let mark: QeetrixIconName?
    let metrics: QeetrixChipMetrics
    let label: Label

    init(mark: QeetrixIconName?, metrics: QeetrixChipMetrics, @ViewBuilder label: () -> Label) {
        self.mark = mark
        self.metrics = metrics
        self.label = label()
    }

    var body: some View {
        HStack(spacing: QeetrixChipMetrics.gap) {
            if let mark {
                QeetrixIcon(mark, size: QeetrixChipMetrics.iconSize, shape: .sharp)
            }
            label
                .qeetrixType(metrics.type)
                .multilineTextAlignment(.leading)
                // chip.css `.qx-chip-label`: overflow-wrap anywhere, padding-block 2px — a long label wraps.
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, QeetrixChipMetrics.labelPaddingBlock)
        }
    }
}

/// The tag (chip.css `.qx-chip`): `space.gap.sm` either side (none after a remove button), at least
/// the size's control height and growing with Dynamic Type, the fill with its edge drawn inside,
/// 4 pt corners, and the focus frame 2 pt outside.
struct QeetrixChipFrame: ViewModifier {
    let metrics: QeetrixChipMetrics
    let colors: QeetrixChipColors
    var isRemovable = false
    var isFocused = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        content
            .padding(.leading, QeetrixChipMetrics.padding)
            // `.qx-chip[data-removable] { padding-inline-end: 0 }`: the remove button ends the chip.
            .padding(.trailing, isRemovable ? 0 : QeetrixChipMetrics.padding)
            .qeetrixControlBlockSize(metrics.height, type: metrics.type)
            .foregroundStyle(colors.text)
            .background(colors.fill, in: shape)
            .overlay { shape.strokeBorder(colors.edge, lineWidth: colors.edgeWidth).accessibilityHidden(true) }
            .overlay { if isFocused { QeetrixOuterFocusFrame(shape: shape) } }
    }
}

/// A size's metrics (chip.css).
struct QeetrixChipMetrics: Equatable {
    /// `min-block-size`: `size.control.sm` / `md` / `lg` at the density in effect.
    let height: CGFloat
    /// `label.md`; at `sm`, `label.sm`'s size and line height at the same weight (500).
    let type: QeetrixTypeSpec

    /// `padding-inline: space.gap.sm`.
    static let padding = QeetrixSpace.gapSm
    /// `gap: space.gap.xs`, between the mark, the label and the remove button.
    static let gap = QeetrixSpace.gapXs
    /// `.qx-chip-label { padding-block: 2px }`.
    static let labelPaddingBlock: CGFloat = 2
    /// The icon and the check: 16 px (`size.icon.sm`), sharp.
    static let iconSize = QeetrixIconSize.sm

    init(size: QeetrixControlSize, density: QeetrixDensity) {
        height = density.controlHeight(size)
        type =
            size == .sm
            ? QeetrixComponentType.role(.labelSm, QeetrixTextRole.labelMd.tokens.weight)
            : QeetrixComponentType.role(.labelMd)
    }

    /// What stands before the label: the chip's icon, else the check while chosen.
    static func mark(icon: QeetrixIconName?, isSelected: Bool) -> QeetrixIconName? {
        icon ?? (isSelected ? .check : nil)
    }
}

/// A chip's colours in one state (chip.css).
struct QeetrixChipColors: Equatable {
    let fill: QeetrixColor
    let edge: QeetrixColor
    let edgeWidth: CGFloat
    let text: QeetrixColor

    static func colors(isSelected: Bool, isRemovable: Bool, state: QeetrixButtonState) -> QeetrixChipColors {
        if state == .disabled {
            // `.qx-chip[data-removable][data-disabled]`: the label stays information, in `text.subtlest`.
            return QeetrixChipColors(
                fill: .bgDisabled, edge: .borderDisabled, edgeWidth: QeetrixBorderWidth.default,
                text: isRemovable ? .textSubtlest : .textDisabled)
        }
        if isSelected {
            // `.qx-chip[data-checked]`, and `:is(:hover, :active)`: `bg.selected-hover`.
            return QeetrixChipColors(
                fill: state == .resting ? .bgSelected : .bgSelectedHover, edge: .borderBrand, edgeWidth: QeetrixBorderWidth.strong,
                text: .textDefault)
        }
        // A removable chip has no hover or press of its own: its button takes the pointer.
        let fill: QeetrixColor =
            switch isRemovable ? .resting : state {
            case .pressed: .bgNeutralSubtlePressed
            case .hovered: .bgNeutralSubtleHover
            default: .bgNeutralSubtle
            }
        return QeetrixChipColors(fill: fill, edge: .borderSubtle, edgeWidth: QeetrixBorderWidth.default, text: .textDefault)
    }
}

/// The package's chip strings, with their English text as the default until a translation has them.
enum QeetrixChipStrings {
    /// "Remove {label}" — `chip.remove`.
    static func remove(_ label: String) -> String {
        String(localized: "qeetrix.chip.remove", defaultValue: "Remove \(label)", bundle: .module)
    }

    /// "Remove {label}" round a label that is a `Text`: the sentence is localised with a stand-in for
    /// the label, then the label takes the stand-in's place, so word order follows the language.
    static func remove(_ label: Text) -> Text {
        let placeholder = "\u{FFFC}"
        let sentence = remove(placeholder)
        guard let range = sentence.range(of: placeholder) else { return Text(verbatim: sentence) }
        let before = Text(verbatim: String(sentence[..<range.lowerBound]))
        let after = Text(verbatim: String(sentence[range.upperBound...]))
        return Text("\(before)\(label)\(after)")
    }
}
