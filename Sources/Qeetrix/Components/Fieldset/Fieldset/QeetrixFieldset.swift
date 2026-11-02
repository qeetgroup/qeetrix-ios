import Accessibility
import SwiftUI

/// A section of fields under a heading — "Billing address" — as `@qeetrix/react`'s Fieldset: the
/// legend in `title.sm`, an optional line under it, then the fields, spaced by the density's form gap
/// (`space.form.gap`).
///
/// ```swift
/// QeetrixFieldset("Billing address", description: Text("Where invoices are sent.")) {
///     QeetrixTextField("Street", text: $street)
///     QeetrixTextField("City", text: $city)
/// }
/// ```
///
/// `.disabled(true)` on it disables every field inside. A choice question isn't a fieldset: use
/// ``QeetrixRadioGroup`` (or checkboxes under their own question), whose legend looks like every other
/// field label. VoiceOver reads the legend as a heading, and the description when entering the group.
public struct QeetrixFieldset<Content: View>: View {
    let legend: Text
    let description: Text?
    let content: Content
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.isEnabled) private var isEnabled

    public init(_ legendKey: LocalizedStringKey, description: Text? = nil, @ViewBuilder content: () -> Content) {
        self.init(legend: Text(legendKey), description: description, content: content)
    }

    public init<S: StringProtocol>(_ legend: S, description: Text? = nil, @ViewBuilder content: () -> Content) {
        self.init(legend: Text(legend), description: description, content: content)
    }

    public init(legend: Text, description: Text? = nil, @ViewBuilder content: () -> Content) {
        self.legend = legend
        self.description = description
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: density.spaceFormGap) {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                legend
                    .qeetrixTextStyle(.titleSm)
                    .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            QeetrixFieldStack(spacing: density.spaceFormGap) {
                content
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(legend)
    }
}

/// The layout of a choice question (field.css `.qx-choice-group-set`): the question as the legend, in
/// the field-label style, then the options, then the description or the error that replaces it.
struct QeetrixChoiceGroupLayout<Content: View>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let content: Content

    init(context: QeetrixFieldContext, isOptional: Bool, @ViewBuilder content: () -> Content) {
        self.context = context
        self.isOptional = isOptional
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            QeetrixFieldLabel(label: context.label, isOptional: isOptional)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(context.accessibilityLabel)
            QeetrixFieldStack(spacing: QeetrixSpace.gapXs) {
                content
            }
            .environment(\.qeetrixGroupError, context.error)
            .environment(\.qeetrixGroupIsInvalid, context.invalid)
            QeetrixFieldMessages(description: context.description, error: context.error)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(context.accessibilityLabel)
        .qeetrixAnnouncesError(context.error)
    }
}

/// Stacks a group's content: fields `spacing` apart, and choice rows — 44 pt targets themselves, the
/// iOS convention where the web's rows are 24 px targets 4 px apart — flush against each other.
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

private struct QeetrixGroupErrorKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct QeetrixGroupIsInvalidKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// The error of the group a control is in, which VoiceOver reads with each control of the group.
    var qeetrixGroupError: String? {
        get { self[QeetrixGroupErrorKey.self] }
        set { self[QeetrixGroupErrorKey.self] = newValue }
    }

    /// Whether the group a control is in is invalid: its indicators take the danger border.
    var qeetrixGroupIsInvalid: Bool {
        get { self[QeetrixGroupIsInvalidKey.self] }
        set { self[QeetrixGroupIsInvalidKey.self] = newValue }
    }
}

/// Attaches the group's error to a control in it, as content VoiceOver reads with the control.
struct QeetrixGroupErrorAccessibility: ViewModifier {
    @Environment(\.qeetrixGroupError) private var error

    func body(content: Content) -> some View {
        content.accessibilityCustomContent(
            AccessibilityCustomContentKey(QeetrixStrings.error, id: "qeetrix.field.error"), error.map { Text(verbatim: $0) },
            importance: .high)
    }
}
