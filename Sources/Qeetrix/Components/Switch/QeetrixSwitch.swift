import SwiftUI

/// A setting that applies at once, as `@qeetrix/react`'s Switch: a square 32 × 18 pt track with a
/// 12 pt square thumb (design rules §9).
///
/// ```swift
/// QeetrixSwitch("Auto-renew", isOn: $autoRenew)
/// QeetrixSwitch("Two-step sign-in", isOn: $twoStep, description: Text("A code by SMS at each sign-in."))
/// ```
///
/// Off: the `color.bg.input` track with a `color.border.strong` edge and the graphite thumb on the start
/// side. On: the Ember track and edge, and the white thumb on the end side; it slides over
/// `motion.duration.normal`, not at all under Reduce Motion. The label follows the switch, 8 pt away,
/// and the whole row toggles it, with ``QeetrixFeedback/selection`` feedback. VoiceOver reads it as the
/// system's switch. A setting that waits for a Save step is a ``QeetrixCheckbox`` instead.
public struct QeetrixSwitch<Label: View>: View {
    let isOn: Binding<Bool>
    let description: Text?
    let label: Label

    public init(isOn: Binding<Bool>, description: Text? = nil, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.description = description
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: isOn) { label }
            .toggleStyle(QeetrixSwitchToggleStyle(description: description))
            .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
    }
}

extension QeetrixSwitch where Label == Text {
    public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(isOn: isOn, description: description) { Text(titleKey) }
    }

    public init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>, description: Text? = nil) {
        self.init(isOn: isOn, description: description) { Text(title) }
    }
}

/// The Qeetrix switch look for any `Toggle`.
public struct QeetrixSwitchToggleStyle: ToggleStyle {
    let description: Text?

    public init() {
        description = nil
    }

    init(description: Text?) {
        self.description = description
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixSwitchBody(configuration: configuration, description: description)
    }
}

extension ToggleStyle where Self == QeetrixSwitchToggleStyle {
    /// The Qeetrix switch style.
    public static var qeetrixSwitch: QeetrixSwitchToggleStyle { QeetrixSwitchToggleStyle() }
}

struct QeetrixSwitchBody: View {
    let configuration: ToggleStyleConfiguration
    let description: Text?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixGroupIsInvalid) private var isInvalid
    @State private var isHovered = false
    /// The person's changes: each plays the selection feedback, and a change the app makes doesn't.
    @State private var changes = 0

    var body: some View {
        QeetrixChoiceRow(description: description, isEnabled: isEnabled) {
            QeetrixSwitchTrack(
                isOn: configuration.isOn, isHovered: isHovered, isEnabled: isEnabled, isInvalid: isInvalid, isFocused: isFocused)
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
        .qeetrixFeedback(.selection, trigger: changes)
    }
}

/// The track and thumb (switch.css): 32 × 18 pt, 2 pt corners, a 1 pt edge; the 12 pt thumb with 1 pt
/// corners sits 2 pt in from the start edge, or 16 pt when on.
struct QeetrixSwitchTrack: View {
    let isOn: Bool
    let isHovered: Bool
    let isEnabled: Bool
    var isInvalid = false
    var isFocused = false

    static let width: CGFloat = 32
    static let height: CGFloat = 18
    static let thumb: CGFloat = 12
    static let thumbInsetOff: CGFloat = 2
    static let thumbInsetOn: CGFloat = 16

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.sm)
        let border = QeetrixBorderWidth.default
        ZStack(alignment: .leading) {
            shape.fill(track)
            shape.strokeBorder(edge, lineWidth: border)
            RoundedRectangle(cornerRadius: QeetrixRadius.sm / 2)
                .fill(thumbColor)
                .frame(width: Self.thumb, height: Self.thumb)
                .offset(x: border + (isOn ? Self.thumbInsetOn : Self.thumbInsetOff))
                .qeetrixAnimation(.standard, .normal, value: isOn)
        }
        .frame(width: Self.width, height: Self.height)
        .overlay { if isFocused { QeetrixOuterFocusFrame(shape: shape) } }
        .qeetrixAnimation(.standard, .fast, value: isHovered)
    }

    var track: QeetrixColor {
        if !isEnabled { return .bgDisabled }
        if isOn { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return .bgInput
    }

    var edge: QeetrixColor {
        if !isEnabled { return .borderDisabled }
        // `.qx-switch[data-invalid]` follows the checked and hover rules: an invalid switch keeps the
        // danger edge on and hovered, round its Ember track (QTRX-161).
        if isInvalid { return .borderDanger }
        if isOn { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return isHovered ? .borderStrongHover : .borderStrong
    }

    var thumbColor: QeetrixColor {
        if !isEnabled { return .iconDisabled }
        // `.qx-switch-thumb[data-checked]`: `color.icon.on-brand`, white on Ember in both schemes, as
        // the checkbox's tick (QTRX-162).
        return isOn ? .iconOnBrand : .iconSubtle
    }
}
