import SwiftUI

/// A checkbox with its label, as `@qeetrix/react`'s Checkbox: it turns one option on or off, or picks
/// several (design rules §9).
///
/// ```swift
/// QeetrixCheckbox("Email me receipts", isOn: $receipts)
/// QeetrixCheckbox("Select all", sources: $invoices, isOn: \.isSelected)  // mixed when some are on
/// QeetrixCheckbox(isOn: $alsoReport, accessibilityLabel: Text("Also report Meera"))
/// ```
///
/// A 16 pt box with 2 pt corners and a 1 pt `color.border.strong` edge on `color.bg.input`; checked or
/// mixed, an Ember fill with a white sharp tick or dash (stroke 3). The label follows the control and
/// the whole row toggles it, with ``QeetrixFeedback/selection`` feedback. In a group with an error the
/// box takes the danger edge, checked too.
/// Disabled, it takes `color.bg.disabled` and the disabled mark. VoiceOver reads it as the system's toggle, with the
/// description as its hint. Settings that apply at once use ``QeetrixSwitch``; this one is for choices
/// a Save step confirms.
///
/// ``init(isOn:accessibilityLabel:)`` draws the box alone, beside words the screen lays out itself.
public struct QeetrixCheckbox: View {
    let toggle: Toggle<Text>
    let description: Text?
    let isLabelHidden: Bool

    public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(titleKey, isOn: isOn), description: description)
    }

    public init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(title, isOn: isOn), description: description)
    }

    public init(label: Text, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(toggle: Toggle(isOn: isOn) { label }, description: description)
    }

    /// A parent checkbox for several: on when all are, mixed when some are — the web's `parent`.
    public init<C: RandomAccessCollection & Sendable>(
        _ titleKey: LocalizedStringKey, sources: C, isOn: KeyPath<C.Element, Binding<Bool>> & Sendable, description: Text? = nil
    ) {
        self.init(toggle: Toggle(titleKey, sources: sources, isOn: isOn), description: description)
    }

    /// A parent checkbox for several, with a `Text` label.
    public init<C: RandomAccessCollection & Sendable>(
        label: Text, sources: C, isOn: KeyPath<C.Element, Binding<Bool>> & Sendable, description: Text? = nil
    ) {
        self.init(toggle: Toggle(sources: sources, isOn: isOn) { label }, description: description)
    }

    /// A checkbox with no visible label, beside a title and note the screen lays out itself, as
    /// `@qeetrix/react`'s Checkbox with an `aria-label`. VoiceOver reads it as the system's toggle named
    /// `accessibilityLabel`.
    ///
    /// It is laid out at the box's 16 × 16 pt and never stretches. A tap anywhere in the 44 × 44 pt round
    /// it toggles it, and that area doesn't move the layout. Checked, invalid and disabled look as they
    /// do with a label, and the selection feedback is the same.
    public init(isOn: Binding<Bool>, accessibilityLabel: Text) {
        self.init(toggle: Toggle(isOn: isOn) { accessibilityLabel }, description: nil, isLabelHidden: true)
    }

    /// A parent checkbox for several with no visible label: on when all are, mixed when some are. The
    /// box alone, as ``init(isOn:accessibilityLabel:)``.
    public init<C: RandomAccessCollection & Sendable>(
        sources: C, isOn: KeyPath<C.Element, Binding<Bool>> & Sendable, accessibilityLabel: Text
    ) {
        self.init(toggle: Toggle(sources: sources, isOn: isOn) { accessibilityLabel }, description: nil, isLabelHidden: true)
    }

    private init(toggle: Toggle<Text>, description: Text?, isLabelHidden: Bool = false) {
        self.toggle = toggle
        self.description = description
        self.isLabelHidden = isLabelHidden
    }

    public var body: some View {
        toggle
            .toggleStyle(QeetrixCheckboxToggleStyle(description: description, isLabelHidden: isLabelHidden))
            // A bare checkbox sits in the screen's own row, so a fieldset spaces it as it spaces any field.
            .layoutValue(key: QeetrixSelectionRowKey.self, value: !isLabelHidden)
    }
}

/// The Qeetrix checkbox look for any `Toggle`.
///
/// The style can't read `.labelsHidden()` on iOS 17, so a toggle in this style always draws its label.
/// For a checkbox without one, use ``QeetrixCheckbox/init(isOn:accessibilityLabel:)``.
public struct QeetrixCheckboxToggleStyle: ToggleStyle {
    let description: Text?
    let isLabelHidden: Bool

    public init() {
        self.init(description: nil)
    }

    init(description: Text?, isLabelHidden: Bool = false) {
        self.description = description
        self.isLabelHidden = isLabelHidden
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixCheckboxBody(configuration: configuration, description: description, isLabelHidden: isLabelHidden)
    }
}

extension ToggleStyle where Self == QeetrixCheckboxToggleStyle {
    /// The Qeetrix checkbox style.
    public static var qeetrixCheckbox: QeetrixCheckboxToggleStyle { QeetrixCheckboxToggleStyle() }
}

struct QeetrixCheckboxBody: View {
    let configuration: ToggleStyleConfiguration
    let description: Text?
    var isLabelHidden = false
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixGroupIsInvalid) private var isInvalid
    /// The person's changes: each plays the selection feedback, and a change the app makes doesn't.
    @State private var changes = 0

    var body: some View {
        control
            .onTapGesture {
                guard isEnabled else { return }
                configuration.isOn.toggle()
                changes += 1
            }
            .onHover { isHovered = $0 }
            .accessibilityRepresentation {
                Toggle(isOn: QeetrixFeedback.counting(configuration.$isOn, in: $changes)) { configuration.label }
            }
            .accessibilityHint(description ?? Text(verbatim: ""))
            .modifier(QeetrixGroupErrorAccessibility())
            .qeetrixFeedback(.selection, trigger: changes)
    }

    @ViewBuilder private var control: some View {
        let box = QeetrixCheckboxBox(
            mark: QeetrixCheckboxMark(isOn: configuration.isOn, isMixed: configuration.isMixed), isHovered: isHovered,
            isEnabled: isEnabled, isInvalid: isInvalid, isFocused: isFocused)
        if isLabelHidden {
            // The box's own size; the 44 pt target round it doesn't take part in layout.
            box.qeetrixHitArea()
        } else {
            QeetrixChoiceRow(description: description, isEnabled: isEnabled) {
                box
            } label: {
                configuration.label
            }
        }
    }
}

enum QeetrixCheckboxMark: Equatable {
    case unchecked
    case checked
    case mixed

    init(isOn: Bool, isMixed: Bool) {
        self = isMixed ? .mixed : isOn ? .checked : .unchecked
    }
}

/// The 16 pt box (checkbox.css).
struct QeetrixCheckboxBox: View {
    let mark: QeetrixCheckboxMark
    let isHovered: Bool
    let isEnabled: Bool
    let isInvalid: Bool
    var isFocused = false

    static let side: CGFloat = 16
    /// The mark: 12 pt, stroke 3, sharp.
    static let markSize = QeetrixIconSize.xs2
    static let markStroke = QeetrixIconStroke(3)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.sm)
        ZStack {
            shape.fill(fill)
            shape.strokeBorder(border, lineWidth: QeetrixBorderWidth.default)
            if mark != .unchecked {
                QeetrixIcon(mark == .mixed ? .minus : .check, size: Self.markSize, stroke: Self.markStroke, shape: .sharp, relativeTo: nil)
                    .foregroundStyle(isEnabled ? QeetrixColor.iconOnBrand : QeetrixColor.iconDisabled)
            }
        }
        .frame(width: Self.side, height: Self.side)
        .overlay { if isFocused { QeetrixOuterFocusFrame(shape: shape) } }
        .qeetrixAnimation(.standard, .fast, value: mark)
        .qeetrixAnimation(.standard, .fast, value: isHovered)
    }

    var fill: QeetrixColor {
        if !isEnabled { return .bgDisabled }
        if mark == .unchecked { return .bgInput }
        return isHovered ? .bgBrandBoldHover : .bgBrandBold
    }

    var border: QeetrixColor {
        if !isEnabled { return .borderDisabled }
        // `.qx-checkbox[data-invalid]` follows the checked and hover rules: an invalid box keeps the
        // danger edge checked and hovered, on its Ember fill.
        if isInvalid { return .borderDanger }
        if mark != .unchecked { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return isHovered ? .borderStrongHover : .borderStrong
    }
}
