import SwiftUI

/// The sizes of a ``QeetrixChip`` — the web's `size`.
public enum QeetrixChipSize: String, CaseIterable, Sendable {
    /// 24 pt tall, `text-xs`.
    case sm
    /// 28 pt tall, `text-sm`. The default.
    case md
    /// 32 pt tall, `text-sm`.
    case lg
}

/// A pill that filters or chooses — the web's `Chip`. Selectable, it toggles; removable, it shows a
/// choice already made, with a button to take it away.
///
/// ```swift
/// QeetrixChip("Unread", isSelected: $showsUnread)
/// QeetrixChip("Design", icon: .tag, onRemove: { tags.remove("Design") })
/// ```
///
/// A selected chip is tinted with the brand, edged with `border-brand`, and shows a check mark unless it
/// has an icon of its own — so selection never rests on colour alone. For a set of chips that choose
/// one value, or several, use ``QeetrixChipGroup``.
///
/// - **Not a badge.** A static status is a ``QeetrixBadge``; a chip is something the person acts on.
/// - **The filtering is yours.** A chip changes the binding; your app decides what it filters.
///
/// A selectable chip is a button that VoiceOver reports as selected or not. A removable chip reads its
/// title, then a "Remove" button that names what it removes. The chip is drawn at the web's height; its
/// touch target reaches 44 pt around it.
public struct QeetrixChip: View {
    enum Kind {
        case toggle(Binding<Bool>)
        case removable(@MainActor () -> Void)
    }

    let title: Text
    let icon: QeetrixIconName?
    let size: QeetrixChipSize
    let kind: Kind

    /// A selectable chip with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - isSelected: Whether the chip is on; a tap toggles it.
    ///   - icon: A leading icon, in place of the check mark a selected chip shows.
    ///   - size: The chip's size.
    public init(_ titleKey: LocalizedStringKey, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md) {
        self.init(title: Text(titleKey), isSelected: isSelected, icon: icon, size: size)
    }

    /// A selectable chip with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md) {
        self.init(title: Text(title), isSelected: isSelected, icon: icon, size: size)
    }

    /// A selectable chip with a `Text` title.
    public init(title: Text, isSelected: Binding<Bool>, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md) {
        self.title = title
        self.icon = icon
        self.size = size
        kind = .toggle(isSelected)
    }

    /// A removable chip with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - icon: A leading icon.
    ///   - size: The chip's size.
    ///   - onRemove: Runs when the person taps the remove button. Removing the chip is yours.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md,
        onRemove: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(titleKey), icon: icon, size: size, onRemove: onRemove)
    }

    /// A removable chip with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md, onRemove: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(title), icon: icon, size: size, onRemove: onRemove)
    }

    /// A removable chip with a `Text` title.
    public init(title: Text, icon: QeetrixIconName? = nil, size: QeetrixChipSize = .md, onRemove: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.size = size
        kind = .removable(onRemove)
    }

    public var body: some View {
        switch kind {
        case .toggle(let isSelected):
            QeetrixChipButton(title: title, icon: icon, size: size, isSelected: isSelected.wrappedValue) {
                isSelected.wrappedValue.toggle()
            }
        case .removable(let remove):
            QeetrixRemovableChip(title: title, icon: icon, size: size, remove: remove)
        }
    }
}

/// Chips that choose one value, or several, from a set — the web's `ChipGroup`.
///
/// ```swift
/// let statuses: [QeetrixOption<Status?>] = [
///     QeetrixOption("All", value: nil),
///     QeetrixOption("Open", value: .open),
///     QeetrixOption("Closed", value: .closed),
/// ]
/// QeetrixChipGroup("Status", selection: $status, options: statuses)
///
/// QeetrixChipGroup("Labels", selection: $labels, options: labelOptions)  // a Set: several at once
/// ```
///
/// With a single value the chips behave as radio buttons; with a `Set` each one toggles. The chips wrap
/// onto more lines when they don't fit — put the group in a horizontal `ScrollView` for a single
/// scrolling row instead. The label names the group for VoiceOver; it is not shown. An option's
/// description becomes its chip's hint, and a disabled option's chip can't be chosen.
public struct QeetrixChipGroup<Value: Hashable>: View {
    enum Selection {
        case single(Binding<Value>)
        case multiple(Binding<Set<Value>>)
    }

    let label: Text
    let selection: Selection
    let options: [QeetrixOption<Value>]
    let size: QeetrixChipSize

    /// A group that chooses one value, named by a localised label.
    public init(_ labelKey: LocalizedStringKey, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md) {
        self.init(label: Text(labelKey), selection: selection, options: options, size: size)
    }

    /// A group that chooses one value, named by a label used as given, without localisation.
    public init<S: StringProtocol>(_ label: S, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md) {
        self.init(label: Text(label), selection: selection, options: options, size: size)
    }

    /// A group that chooses one value, named by a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the group for VoiceOver.
    ///   - selection: The chosen value.
    ///   - options: The chips, in order.
    ///   - size: The chips' size.
    public init(label: Text, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md) {
        self.label = label
        self.selection = .single(selection)
        self.options = options
        self.size = size
    }

    /// A group that chooses any number of values, named by a localised label.
    public init(
        _ labelKey: LocalizedStringKey, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md
    ) {
        self.init(label: Text(labelKey), selection: selection, options: options, size: size)
    }

    /// A group that chooses any number of values, named by a label used as given, without localisation.
    public init<S: StringProtocol>(
        _ label: S, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md
    ) {
        self.init(label: Text(label), selection: selection, options: options, size: size)
    }

    /// A group that chooses any number of values, named by a `Text` label.
    public init(label: Text, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>], size: QeetrixChipSize = .md) {
        self.label = label
        self.selection = .multiple(selection)
        self.options = options
        self.size = size
    }

    public var body: some View {
        QeetrixFlowLayout(spacing: QeetrixWebScale.spacing(2)) {  // flex flex-wrap gap-2
            ForEach(options) { option in
                QeetrixChipButton(title: option.title, icon: nil, size: size, isSelected: isSelected(option.value)) {
                    choose(option.value)
                }
                .disabled(option.isDisabled)
                .accessibilityHint(option.description ?? Text(verbatim: ""))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }

    func isSelected(_ value: Value) -> Bool {
        switch selection {
        case .single(let binding): binding.wrappedValue == value
        case .multiple(let binding): binding.wrappedValue.contains(value)
        }
    }

    func choose(_ value: Value) {
        switch selection {
        case .single(let binding):
            binding.wrappedValue = value
        case .multiple(let binding):
            if binding.wrappedValue.contains(value) {
                binding.wrappedValue.remove(value)
            } else {
                binding.wrappedValue.insert(value)
            }
        }
    }
}

/// A selectable chip: a button that reports its selected state.
struct QeetrixChipButton: View {
    let title: Text
    let icon: QeetrixIconName?
    let size: QeetrixChipSize
    let isSelected: Bool
    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            QeetrixChipLabel(title: title, icon: icon ?? (isSelected ? .check : nil), size: size)
        }
        .buttonStyle(QeetrixChipStyle(size: size, isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// A removable chip: its title, and a button that removes it. Not selectable — it shows a choice already
/// made.
struct QeetrixRemovableChip: View {
    let title: Text
    let icon: QeetrixIconName?
    let size: QeetrixChipSize
    let remove: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let metrics = QeetrixChipMetrics(size: size)
        HStack(spacing: QeetrixWebScale.spacing(0.5)) {  // ms-0.5
            QeetrixChipLabel(title: title, icon: icon, size: size)
            Button(action: remove) {
                QeetrixIcon(.x, size: QeetrixIconSize(QeetrixWebScale.spacing(3)), relativeTo: nil)  // size-3
                    .foregroundStyle(QeetrixColor.textTertiary)
                    .frame(width: QeetrixWebScale.spacing(4), height: QeetrixWebScale.spacing(4))  // size-4
                    .contentShape(Circle())
            }
            .buttonStyle(QeetrixPlainControlStyle())
            .qeetrixHitArea()
            .accessibilityLabel(QeetrixStrings.remove)
            .accessibilityValue(title)
        }
        .padding(.leading, metrics.paddingX)
        .padding(.trailing, QeetrixWebScale.spacing(1))  // pe-1
        .frame(minHeight: metrics.height)
        .background { QeetrixChipSurface(isSelected: false, isPressed: false, isHovered: false) }
        .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
    }
}

/// The chip's content: the leading icon or check mark, then the title.
struct QeetrixChipLabel: View {
    let title: Text
    let icon: QeetrixIconName?
    let size: QeetrixChipSize

    var body: some View {
        let metrics = QeetrixChipMetrics(size: size)
        HStack(spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
            if let icon {
                QeetrixIcon(icon, size: QeetrixIconSize(metrics.iconSize))
            }
            title
                .lineLimit(1)  // whitespace-nowrap
        }
        .qeetrixType(metrics.type)
        .foregroundStyle(QeetrixColor.textPrimary)  // text-foreground
        .fixedSize()
    }
}

/// `inline-flex rounded-full border`: the selected and resting surfaces, their pressed and hovered
/// shades, the height and the inline padding.
struct QeetrixChipStyle: ButtonStyle {
    let size: QeetrixChipSize
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        QeetrixChipStyleBody(configuration: configuration, size: size, isSelected: isSelected)
    }
}

private struct QeetrixChipStyleBody: View {
    let configuration: ButtonStyleConfiguration
    let size: QeetrixChipSize
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        let metrics = QeetrixChipMetrics(size: size)
        configuration.label
            .padding(.horizontal, metrics.paddingX)
            .frame(minHeight: metrics.height)
            .background { QeetrixChipSurface(isSelected: isSelected, isPressed: configuration.isPressed, isHovered: isHovered) }
            .contentShape(Capsule())
            .qeetrixHitArea()
            .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: isSelected)  // transition-colors duration-fast ease-standard
    }
}

struct QeetrixChipSurface: View {
    let isSelected: Bool
    let isPressed: Bool
    let isHovered: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = QeetrixChipMetrics.colors(isSelected: isSelected, isPressed: isPressed, isHovered: isHovered, colorScheme: colorScheme)
        Capsule()
            .fill(colors.background.map { AnyShapeStyle($0) } ?? AnyShapeStyle(Color.clear))  // bg-transparent at rest
            .overlay { Capsule().strokeBorder(colors.border, lineWidth: QeetrixStroke.hairline) }
    }
}

struct QeetrixChipMetrics {
    let height: CGFloat
    let paddingX: CGFloat
    let iconSize: CGFloat
    let type: QeetrixTypeSpec

    init(size: QeetrixChipSize) {
        switch size {
        case .sm:  // h-6 px-2.5 text-xs, icons size-3
            (height, paddingX, iconSize) = (QeetrixWebScale.spacing(6), QeetrixWebScale.spacing(2.5), QeetrixWebScale.spacing(3))
            type = QeetrixComponentType.ui(QeetrixWebScale.textXS, .medium, scalesLike: .caption)
        case .md:  // h-7 px-3 text-sm, icons size-3.5
            (height, paddingX, iconSize) = (QeetrixWebScale.spacing(7), QeetrixWebScale.spacing(3), QeetrixWebScale.spacing(3.5))
            type = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
        case .lg:  // h-8 px-3.5 text-sm, icons size-4
            (height, paddingX, iconSize) = (QeetrixWebScale.spacing(8), QeetrixWebScale.spacing(3.5), QeetrixWebScale.spacing(4))
            type = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
        }
    }

    /// The selected vocabulary — `border-border-brand bg-brand-subtle`, its hover and active shades — and
    /// the resting one — `border-border bg-transparent`, `dark:border-border-strong`, the interactive
    /// surface on hover and press.
    static func colors(
        isSelected: Bool, isPressed: Bool, isHovered: Bool, colorScheme: ColorScheme
    )
        -> (background: QeetrixColor?, border: QeetrixColor)
    {
        if isSelected {
            let background: QeetrixColor =
                isPressed ? .surfaceBrandSubtleActive : isHovered ? .surfaceBrandSubtleHover : .surfaceBrandSubtle
            return (background, .borderBrand)
        }
        let background: QeetrixColor? = isPressed ? .surfaceInteractiveHover : isHovered ? .surfaceInteractive : nil
        return (background, colorScheme == .dark ? .borderStrong : .borderDefault)
    }
}
