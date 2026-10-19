import SwiftUI

/// A checkbox: a label, an optional description, and the Qeetrix box at the leading edge.
///
/// ```swift
/// QeetrixCheckbox("Email me about product updates", isOn: $updates)
/// QeetrixCheckbox("Accept the terms", isOn: $accepted, description: Text("You can read them at any time."))
/// ```
///
/// For a checkbox that stands for a group, pass the items it controls: it shows a minus while some of
/// them are on (mixed), and a tap turns them all on, then all off — SwiftUI's own mixed-toggle
/// behaviour.
///
/// ```swift
/// QeetrixCheckbox("All notifications", sources: $channels, isOn: \.isOn)
/// ```
///
/// It is a `Toggle` with ``QeetrixCheckboxToggleStyle``. The whole row is the target, at least 44 pt tall;
/// VoiceOver reads a native toggle with its label and state — the system's own mixed state for a group
/// checkbox — and the description as its hint. Group several under a ``QeetrixFieldSet``.
public struct QeetrixCheckbox: View {
    let toggle: Toggle<Text>
    let description: Text?

    /// A checkbox with a localised label.
    public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(titleKey, isOn: isOn), description: description)
    }

    /// A checkbox with a label shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(title, isOn: isOn), description: description)
    }

    /// A checkbox with a `Text` label.
    public init(label: Text, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(isOn: isOn) { label }, description: description)
    }

    /// A checkbox standing for the items in `sources`: checked when all of them are on, mixed when some
    /// are, unchecked when none are. Toggling it sets them all.
    ///
    /// - Parameters:
    ///   - titleKey: The localised label.
    ///   - sources: The items the checkbox controls.
    ///   - isOn: The path from an item to its on/off binding.
    ///   - description: Help shown under the label.
    public init<C: RandomAccessCollection & Sendable>(
        _ titleKey: LocalizedStringKey, sources: C, isOn: KeyPath<C.Element, Binding<Bool>> & Sendable, description: Text? = nil
    ) {
        self.init(toggle: Toggle(titleKey, sources: sources, isOn: isOn), description: description)
    }

    /// A checkbox with a `Text` label standing for the items in `sources`.
    ///
    /// - Parameters:
    ///   - label: The label.
    ///   - sources: The items the checkbox controls.
    ///   - isOn: The path from an item to its on/off binding.
    ///   - description: Help shown under the label.
    public init<C: RandomAccessCollection & Sendable>(
        label: Text, sources: C, isOn: KeyPath<C.Element, Binding<Bool>> & Sendable, description: Text? = nil
    ) {
        self.init(toggle: Toggle(sources: sources, isOn: isOn) { label }, description: description)
    }

    private init(toggle: Toggle<Text>, description: Text?) {
        self.toggle = toggle
        self.description = description
    }

    public var body: some View {
        toggle
            .toggleStyle(QeetrixCheckboxToggleStyle(description: description))
            .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
    }
}

/// The Qeetrix checkbox for any `Toggle`.
///
/// ```swift
/// Toggle("Remember this device", isOn: $remember)
///     .toggleStyle(.qeetrixCheckbox)
/// ```
public struct QeetrixCheckboxToggleStyle: ToggleStyle {
    let description: Text?

    public init() {
        description = nil
    }

    init(description: Text?) {
        self.description = description
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixCheckboxBody(configuration: configuration, description: description)
    }
}

extension ToggleStyle where Self == QeetrixCheckboxToggleStyle {
    /// The Qeetrix checkbox.
    public static var qeetrixCheckbox: QeetrixCheckboxToggleStyle { QeetrixCheckboxToggleStyle() }
}

struct QeetrixCheckboxBody: View {
    let configuration: ToggleStyleConfiguration
    let description: Text?
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixGroupMessage) private var groupMessage

    var body: some View {
        QeetrixSelectionRow(description: description, isEnabled: isEnabled) {
            QeetrixCheckboxBox(
                mark: QeetrixCheckboxMark(isOn: configuration.isOn, isMixed: configuration.isMixed), isHovered: isHovered && isEnabled,
                tone: groupMessage?.tone)
        } label: {
            configuration.label
        }
        .onTapGesture {
            guard isEnabled else { return }
            configuration.isOn.toggle()
        }
        .onHover { isHovered = $0 }
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
        .accessibilityHint(description ?? Text(verbatim: ""))
        .modifier(QeetrixGroupMessageAccessibility())
    }
}

/// What the box shows.
enum QeetrixCheckboxMark: Equatable {
    case unchecked
    case checked
    case mixed

    init(isOn: Bool, isMixed: Bool) {
        self = isMixed ? .mixed : isOn ? .checked : .unchecked
    }
}

/// The 16 pt box: the field fill and control boundary at rest, the brand fill with the `border-brand`
/// edge and a white glyph when checked or mixed — the glyph, not the colour, carries the state.
struct QeetrixCheckboxBox: View {
    let mark: QeetrixCheckboxMark
    let isHovered: Bool
    let tone: QeetrixFieldMessage.Tone?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCorner.sm)  // rounded-(--qx-corner-sm)
        ZStack {
            shape.fill(mark == .unchecked ? QeetrixInputTokens.background : QeetrixComponentColor(.actionPrimary))
            shape.strokeBorder(border, lineWidth: QeetrixStroke.hairline)
            if mark != .unchecked {
                QeetrixIcon(
                    mark == .mixed ? .minus : .check, size: QeetrixIconSize(QeetrixWebScale.spacing(3)), stroke: QeetrixIconStroke(3)
                )
                .foregroundStyle(QeetrixColor.textOnBrand)  // text-primary-foreground
            }
        }
        .frame(width: QeetrixWebScale.spacing(4), height: QeetrixWebScale.spacing(4))  // size-4
        .qeetrixAnimation(.standard, .fast, value: mark)
    }

    var border: QeetrixComponentColor {
        if tone == .error { return QeetrixInputTokens.borderInvalid }
        if mark != .unchecked { return QeetrixComponentColor(.borderBrand) }
        return isHovered ? QeetrixInputTokens.borderHover : QeetrixInputTokens.border
    }
}

/// A checkbox or radio row: the control, then the label and description 8 pt after it — the web's
/// horizontal `Field`. At least 44 pt tall, the whole row the target; faded when disabled.
struct QeetrixSelectionRow<Control: View, Label: View>: View {
    let description: Text?
    let isEnabled: Bool
    let control: Control
    let label: Label

    init(description: Text?, isEnabled: Bool, @ViewBuilder control: () -> Control, @ViewBuilder label: () -> Label) {
        self.description = description
        self.isEnabled = isEnabled
        self.control = control()
        self.label = label()
    }

    var body: some View {
        let offset = QeetrixSelectionMetrics.baselineOffset
        HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(2)) {  // gap-2
            control
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    // Centre the 16 pt control on the first line of the 14 pt label.
                    dimensions[VerticalAlignment.center] + offset
                }
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // FieldContent gap-0.5
                label
                    .qeetrixType(QeetrixFieldMetrics.labelType)
                    .foregroundStyle(QeetrixColor.textPrimary)
                if let description {
                    description
                        .qeetrixType(QeetrixFieldMetrics.captionType)
                        .foregroundStyle(QeetrixColor.textTertiary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, QeetrixWebScale.spacing(1))
        .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
    }
}

enum QeetrixSelectionMetrics {
    /// From the middle of a 14 pt line to its baseline: about a third of the size.
    static let baselineOffset: CGFloat = QeetrixWebScale.textSM.size * 0.32
}
