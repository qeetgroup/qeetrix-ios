import SwiftUI

/// A group of related fields or choices under a legend — the web's `FieldSet` with a `FieldLegend` and a
/// `FieldGroup`.
///
/// ```swift
/// QeetrixFieldSet("Notifications", description: Text("Choose how we reach you.")) {
///     QeetrixCheckbox("Email", isOn: $email)
///     QeetrixCheckbox("Push", isOn: $push)
/// }
/// ```
///
/// The legend is a heading. Fields inside are spaced by the density's field gap; checkbox, radio and
/// switch rows sit flush, because each row is already a 44 pt target. A message here is for the group as
/// a whole — "Choose at least one" — and VoiceOver reads it with each checkbox in the group; fields in the
/// set carry their own messages.
public struct QeetrixFieldSet<Content: View>: View {
    let legend: Text
    let description: Text?
    let message: QeetrixFieldMessage?
    let isRequired: Bool
    let isOptional: Bool
    let content: Content

    /// A group with a localised legend.
    public init(
        _ legendKey: LocalizedStringKey,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            legend: Text(legendKey), description: description, message: message, isRequired: isRequired, isOptional: isOptional,
            content: content)
    }

    /// A group with a legend shown as given, without localisation.
    public init<S: StringProtocol>(
        _ legend: S,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            legend: Text(legend), description: description, message: message, isRequired: isRequired, isOptional: isOptional,
            content: content)
    }

    /// A group with a `Text` legend.
    ///
    /// - Parameters:
    ///   - legend: The group's heading, and its name for VoiceOver.
    ///   - description: Help shown under the legend.
    ///   - message: A message about the group as a whole, shown after its fields.
    ///   - isRequired: Marks the legend with an asterisk — at least one choice is needed.
    ///   - isOptional: Marks the legend "(optional)" instead. Ignored when `isRequired` is true.
    ///   - content: The fields or choices.
    public init(
        legend: Text,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.legend = legend
        self.description = description
        self.message = message
        self.isRequired = isRequired
        self.isOptional = isOptional
        self.content = content()
    }

    public var body: some View {
        QeetrixGroupLayout(
            legend: legend, legendStyle: .heading, description: description, message: message, isRequired: isRequired,
            isOptional: isOptional
        ) {
            content
        }
    }
}

/// A legend, its description, the group's content and the group's message. The legend is a heading;
/// the group is a VoiceOver container named by it.
struct QeetrixGroupLayout<Content: View>: View {
    enum LegendStyle {
        /// `FieldLegend variant="legend"`: `font-heading text-base font-medium`, for a fieldset.
        case heading
        /// `FieldLegend variant="label"`: the field label's style, for a radio group.
        case label
    }

    let legend: Text
    let legendStyle: LegendStyle
    let description: Text?
    let message: QeetrixFieldMessage?
    let isRequired: Bool
    let isOptional: Bool
    let content: Content
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.isEnabled) private var isEnabled

    init(
        legend: Text, legendStyle: LegendStyle, description: Text?, message: QeetrixFieldMessage?, isRequired: Bool, isOptional: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.legend = legend
        self.legendStyle = legendStyle
        self.description = description
        self.message = message
        self.isRequired = isRequired
        self.isOptional = isOptional
        self.content = content()
    }

    var body: some View {
        // A fieldset spaces its parts by the field gap; a radio group keeps the field's 6 pt rhythm.
        let spacing = legendStyle == .heading ? density.fieldGap : QeetrixFieldMetrics.gap
        let context = QeetrixFieldContext(label: legend, description: description, message: message, isRequired: isRequired)
        VStack(alignment: .leading, spacing: spacing) {
            Group {
                switch legendStyle {
                case .heading:
                    QeetrixFieldLabel(label: legend, isRequired: isRequired, isOptional: isOptional)
                        .qeetrixType(QeetrixFieldMetrics.legendType)
                case .label:
                    QeetrixFieldLabel(label: legend, isRequired: isRequired, isOptional: isOptional)
                }
            }
            .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(context.accessibilityLabel)
            if let description {
                description
                    .qeetrixType(QeetrixFieldMetrics.captionType)
                    .foregroundStyle(QeetrixColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            QeetrixFieldStack(spacing: density.fieldGap) {
                content
            }
            .environment(\.qeetrixGroupMessage, message)
            if let message {
                QeetrixFieldMessageView(message: message)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(context.accessibilityLabel)
        .onChange(of: message) { _, newMessage in
            if let newMessage {
                AccessibilityNotification.Announcement(newMessage.text).post()
            }
        }
    }
}

/// Stacks a group's content: fields `spacing` apart, selection rows — which are 44 pt targets
/// themselves — flush against each other.
struct QeetrixFieldStack: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width
        var height: CGFloat = 0
        var maxWidth: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            height += size.height + (index > 0 ? gap(before: index, subviews) : 0)
            maxWidth = max(maxWidth, size.width)
        }
        return CGSize(width: width ?? maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for (index, subview) in subviews.enumerated() {
            if index > 0 { y += gap(before: index, subviews) }
            let size = subview.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            subview.place(at: CGPoint(x: bounds.minX, y: y), proposal: ProposedViewSize(width: bounds.width, height: size.height))
            y += size.height
        }
    }

    private func gap(before index: Int, _ subviews: Subviews) -> CGFloat {
        subviews[index - 1][QeetrixSelectionRowKey.self] && subviews[index][QeetrixSelectionRowKey.self] ? 0 : spacing
    }
}

/// Marks a checkbox, radio or switch row for ``QeetrixFieldStack``.
struct QeetrixSelectionRowKey: LayoutValueKey {
    static let defaultValue = false
}

private struct QeetrixGroupMessageKey: EnvironmentKey {
    static let defaultValue: QeetrixFieldMessage? = nil
}

extension EnvironmentValues {
    /// The message of the group a control is in, which VoiceOver reads with each control of the group.
    var qeetrixGroupMessage: QeetrixFieldMessage? {
        get { self[QeetrixGroupMessageKey.self] }
        set { self[QeetrixGroupMessageKey.self] = newValue }
    }
}

/// Attaches the group's message to a control in it, as content VoiceOver reads with the control.
struct QeetrixGroupMessageAccessibility: ViewModifier {
    @Environment(\.qeetrixGroupMessage) private var message

    func body(content: Content) -> some View {
        content.accessibilityCustomContent(
            AccessibilityCustomContentKey(message?.tone.accessibilityName ?? QeetrixStrings.error, id: "qeetrix.field.message"),
            message.map { Text(verbatim: $0.text) },
            importance: .high)
    }
}
