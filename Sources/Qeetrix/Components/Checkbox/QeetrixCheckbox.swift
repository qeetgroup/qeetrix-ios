import SwiftUI

/// A checkbox with its label, as `@qeetrix/react`'s Checkbox: it turns one option on or off, or picks
/// several (design rules §9).
///
/// ```swift
/// QeetrixCheckbox("Email me receipts", isOn: $receipts)
/// QeetrixCheckbox("Select all", sources: $invoices, isOn: \.isSelected)  // mixed when some are on
/// ```
///
/// A 16 pt box with 2 pt corners and a 1 pt `color.border.strong` edge on `color.bg.input`; checked or
/// mixed, an Ember fill with a white sharp tick or dash (stroke 3). The label follows the control and
/// the whole row toggles it, with ``QeetrixFeedback/selection`` feedback. In a group with an error the
/// box takes the danger edge, checked too.
/// Disabled, it takes `color.bg.disabled` and the disabled mark. VoiceOver reads it as the system's toggle, with the
/// description as its hint. Settings that apply at once use ``QeetrixSwitch``; this one is for choices
/// a Save step confirms.
public struct QeetrixCheckbox: View {
    let toggle: Toggle<Text>
    let description: Text?

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

/// The Qeetrix checkbox look for any `Toggle`.
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
    /// The Qeetrix checkbox style.
    public static var qeetrixCheckbox: QeetrixCheckboxToggleStyle { QeetrixCheckboxToggleStyle() }
}

struct QeetrixCheckboxBody: View {
    let configuration: ToggleStyleConfiguration
    let description: Text?
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixGroupIsInvalid) private var isInvalid
    /// The person's changes: each plays the selection feedback, and a change the app makes doesn't.
    @State private var changes = 0

    var body: some View {
        QeetrixChoiceRow(description: description, isEnabled: isEnabled) {
            QeetrixCheckboxBox(
                mark: QeetrixCheckboxMark(isOn: configuration.isOn, isMixed: configuration.isMixed), isHovered: isHovered,
                isEnabled: isEnabled, isInvalid: isInvalid, isFocused: isFocused)
        } label: {
            configuration.label
        }
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
        // danger edge checked and hovered, on its Ember fill (QTRX-161).
        if isInvalid { return .borderDanger }
        if mark != .unchecked { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return isHovered ? .borderStrongHover : .borderStrong
    }
}
