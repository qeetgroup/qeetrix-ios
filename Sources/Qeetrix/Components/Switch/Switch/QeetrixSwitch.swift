import SwiftUI

/// The sizes of ``QeetrixSwitch``, as on the web.
public enum QeetrixSwitchSize: String, CaseIterable, Sendable {
    /// A 24 × 14 pt track with a 12 pt thumb.
    case sm
    /// A 32 × 18.4 pt track with a 16 pt thumb.
    case `default`
}

/// An on/off control: a label, and the Qeetrix switch at the trailing edge.
///
/// ```swift
/// QeetrixSwitch("Email notifications", isOn: $emailNotifications)
/// ```
///
/// The state never rests on colour alone: the thumb moves to the trailing edge when on (the leading
/// edge in right-to-left layouts), and it is a light disc on both tracks. Tapping anywhere on the row
/// toggles it, as a web label does, and the row is a 44 pt target. VoiceOver reads it as a native
/// switch with its label and value.
///
/// It is a `Toggle` with ``QeetrixSwitchToggleStyle``; use the style directly for any other toggle.
public struct QeetrixSwitch<Label: View>: View {
    let isOn: Binding<Bool>
    let size: QeetrixSwitchSize
    let label: Label

    public init(isOn: Binding<Bool>, size: QeetrixSwitchSize = .default, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.size = size
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: isOn) { label }
            .toggleStyle(QeetrixSwitchToggleStyle(size: size))
            .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
    }
}

extension QeetrixSwitch where Label == Text {
    /// A switch with a localised label.
    public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>, size: QeetrixSwitchSize = .default) {
        self.init(isOn: isOn, size: size) { Text(titleKey) }
    }

    /// A switch with a label shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>, size: QeetrixSwitchSize = .default) {
        self.init(isOn: isOn, size: size) { Text(title) }
    }
}

/// The Qeetrix switch for any `Toggle`.
///
/// ```swift
/// Toggle("Wi-Fi", isOn: $wifi)
///     .toggleStyle(.qeetrixSwitch(size: .sm))
/// ```
public struct QeetrixSwitchToggleStyle: ToggleStyle {
    let size: QeetrixSwitchSize

    public init(size: QeetrixSwitchSize = .default) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixSwitchBody(configuration: configuration, size: size)
    }
}

extension ToggleStyle where Self == QeetrixSwitchToggleStyle {
    /// The Qeetrix switch.
    public static func qeetrixSwitch(size: QeetrixSwitchSize = .default) -> QeetrixSwitchToggleStyle {
        QeetrixSwitchToggleStyle(size: size)
    }
}

struct QeetrixSwitchBody: View {
    let configuration: ToggleStyleConfiguration
    let size: QeetrixSwitchSize
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .center, spacing: QeetrixWebScale.spacing(3)) {
            configuration.label
                .qeetrixType(QeetrixFieldMetrics.labelType)
                .foregroundStyle(QeetrixColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            QeetrixSwitchTrack(isOn: configuration.isOn, size: size, isHovered: isHovered && isEnabled)
        }
        .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
        .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            configuration.isOn.toggle()
        }
        .onHover { isHovered = $0 }
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

struct QeetrixSwitchTrack: View {
    let isOn: Bool
    let size: QeetrixSwitchSize
    let isHovered: Bool

    var body: some View {
        let metrics = Self.metrics(size)
        let border = QeetrixStroke.hairline  // border border-transparent
        Capsule()
            .fill(isOn ? (isHovered ? QeetrixSwitchTokens.trackCheckedHover : QeetrixSwitchTokens.trackChecked) : QeetrixSwitchTokens.track)
            .frame(width: metrics.width, height: metrics.height)
            .overlay(alignment: isOn ? .trailing : .leading) {
                // On, the thumb travels 100% − 2 pt: from the leading border to the trailing one. It
                // carries the web's shadow-xs.
                Color.clear
                    .frame(width: metrics.thumb, height: metrics.thumb)
                    .qeetrixElevation(.rampXs, fill: isOn ? QeetrixSwitchTokens.thumbChecked : QeetrixSwitchTokens.thumb, in: Circle())
                    .padding(.horizontal, border)
            }
            .qeetrixAnimation(.standard, .fast, value: isOn)  // duration-fast ease-standard
    }

    /// `w-8 h-(thumb size)` with a `size-4` thumb; `w-6 h-3.5` with a `size-3` thumb at `sm`.
    static func metrics(_ size: QeetrixSwitchSize) -> (width: CGFloat, height: CGFloat, thumb: CGFloat) {
        switch size {
        case .default: (QeetrixWebScale.spacing(8), QeetrixSwitchTokens.thumbSize, QeetrixWebScale.spacing(4))
        case .sm: (QeetrixWebScale.spacing(6), QeetrixWebScale.spacing(3.5), QeetrixWebScale.spacing(3))
        }
    }
}
