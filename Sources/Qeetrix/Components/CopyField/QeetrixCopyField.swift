import SwiftUI

/// How a ``QeetrixCopyField`` is laid out, as `@qeetrix/react`'s `CopyFieldLayout`.
public enum QeetrixCopyFieldLayout: String, CaseIterable, Sendable {
    /// A read-only field: the label above the value and its Copy button, the description below. The
    /// default.
    case field
    /// A fact row on a record page: the label, then the value with Copy at its end — a
    /// ``QeetrixDescriptionItem``'s row, so it lines up with the items around it in a
    /// ``QeetrixDescriptionList``.
    case row
}

/// How a ``QeetrixCopyField``'s value breaks, as `@qeetrix/react`'s `wrap`.
public enum QeetrixCopyFieldWrap: String, CaseIterable, Sendable {
    /// A long value breaks onto more lines, anywhere it has to. The default.
    case anywhere
    /// The value stays on one line, ending in an ellipsis — except at the accessibility text sizes,
    /// where it wraps rather than hide what it says.
    case none
}

/// A read-only value with its Copy button — `@qeetrix/react`'s CopyField: an ID, a URL to paste
/// elsewhere, a secret shown once.
///
/// ```swift
/// QeetrixCopyField("ACS URL", value: acsURL, description: Text("Paste it into your identity provider."), toast: $toast)
/// QeetrixCopyField("Client secret", value: secret, isSensitive: true, toast: $toast)
/// QeetrixDescriptionList {
///     QeetrixCopyField("User ID", value: user.id, layout: .row, toast: $toast)
/// }
/// ```
///
/// - **`field`** (copy-field.css): a ``QeetrixField`` — the label in `label.sm`, `color.text.subtle`, the
///   description in `body.sm` under it — round the read-only field box: no fill and the field's
///   `color.border.strong` bottom line, at least `size.control.lg` tall, with the value
///   `space.inset.md` from its start and a neutral ghost `sm` ``QeetrixCopyButton`` `space.inset.xs` from
///   its end.
/// - **`row`**: the label and the value side by side as a ``QeetrixDescriptionItem`` lays them out — and,
///   as it does, the label above the value where the row is narrow — with Copy at the end of the value
///   and no line. In a ``QeetrixDescriptionList`` it is ruled like the items around it.
/// - **The value** is `code.sm` in `color.text.default`, reads left to right in every language, wraps
///   rather than scrolls (`wrap: .none` keeps it on one line), and a long press selects it to copy part
///   of it.
/// - **Copy** is named after the label — "Copy ACS URL" — and copies the whole value, with a light
///   haptic and, given the screen's toast binding, a "Copied" toast. `isSensitive` keeps the entry on
///   this device and has it removed from the clipboard after 60 seconds, for a secret; the value is then
///   also marked `privacySensitive()`.
///
/// VoiceOver reads the value as text named by the label ("ACS URL, https://…"), with the description as
/// its hint, then the Copy button. Disable the field with `disabled(_:)`.
public struct QeetrixCopyField: View {
    let label: Text
    let value: String
    let description: Text?
    let layout: QeetrixCopyFieldLayout
    let wrap: QeetrixCopyFieldWrap
    let isSensitive: Bool
    let toast: Binding<QeetrixToast?>?
    let onCopied: (@MainActor (String) -> Void)?
    @Environment(\.qeetrixDescriptionListLayout) private var listLayout
    @ScaledMetric(relativeTo: .body) private var rem: CGFloat = QeetrixDescriptionListMetrics.rem

    /// A copy field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: String,
        description: Text? = nil,
        layout: QeetrixCopyFieldLayout = .field,
        wrap: QeetrixCopyFieldWrap = .anywhere,
        isSensitive: Bool = false,
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), value: value, description: description, layout: layout, wrap: wrap, isSensitive: isSensitive,
            toast: toast, onCopied: onCopied)
    }

    /// A copy field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: String,
        description: Text? = nil,
        layout: QeetrixCopyFieldLayout = .field,
        wrap: QeetrixCopyFieldWrap = .anywhere,
        isSensitive: Bool = false,
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), value: value, description: description, layout: layout, wrap: wrap, isSensitive: isSensitive,
            toast: toast, onCopied: onCopied)
    }

    /// A copy field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the value, and through it the Copy button: "ACS URL" makes "Copy ACS URL".
    ///   - value: The value, read-only, as it is copied.
    ///   - description: A line under the value on where it goes: "Paste it into your identity provider."
    ///   - layout: `field`, or `row` for a record page.
    ///   - wrap: `anywhere` breaks a long value onto more lines; `none` keeps it on one.
    ///   - isSensitive: Keeps the entry on this device and has it removed after 60 seconds, for a secret.
    ///   - toast: The binding the screen's `qeetrixToast(_:)` hosts, to confirm the copy with a toast.
    ///   - onCopied: Runs with the value once it is on the clipboard.
    public init(
        label: Text,
        value: String,
        description: Text? = nil,
        layout: QeetrixCopyFieldLayout = .field,
        wrap: QeetrixCopyFieldWrap = .anywhere,
        isSensitive: Bool = false,
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.label = label
        self.value = value
        self.description = description
        self.layout = layout
        self.wrap = wrap
        self.isSensitive = isSensitive
        self.toast = toast
        self.onCopied = onCopied
    }

    public var body: some View {
        let context = QeetrixFieldContext(label: label, description: description)
        switch layout {
        case .field:
            QeetrixFieldLayout(context: context, isOptional: false) {
                box.modifier(QeetrixCopyFieldSurface())
            }
        case .row:
            QeetrixDescriptionItemLayout(isColumns: false, rem: rem, rowHeight: 0) {
                label
                    .qeetrixTextStyle(.labelSm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)  // the value carries the label
                    .layoutValue(key: QeetrixDescriptionItemPart.self, value: .term)
                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    box.environment(\.qeetrixFieldContext, context)
                    QeetrixFieldMessages(description: description, error: nil)
                }
                .layoutValue(key: QeetrixDescriptionItemPart.self, value: .value)
            }
            .background(alignment: .top) {
                if listLayout == .rows { QeetrixDescriptionListRule() }
            }
        }
    }

    private var box: some View {
        QeetrixCopyFieldBoxLayout(spacing: QeetrixCopyFieldMetrics.gap) {
            QeetrixCopyFieldValue(value: value, wrap: wrap, isSensitive: isSensitive)
            QeetrixCopyButton(
                value: { value }, label: QeetrixCopyStrings.copy(label), title: nil, isSensitive: isSensitive, variant: .ghost,
                tone: .neutral, size: .sm, resetAfter: QeetrixCopy.resetAfter, toast: toast, onCopied: onCopied)
        }
    }
}

/// The value (copy-field.css `.qx-copy-field-value`): `code.sm` in `color.text.default`, `space.inset.xs`
/// above and below, left to right in every language, selectable. It carries the field for VoiceOver:
/// the label names it, the value is what it reads, the description is its hint.
struct QeetrixCopyFieldValue: View {
    let value: String
    let wrap: QeetrixCopyFieldWrap
    let isSensitive: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Text(verbatim: value)
            .qeetrixType(QeetrixCopyFieldMetrics.valueType)
            .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
            .lineLimit(Self.lineLimit(wrap, dynamicTypeSize: dynamicTypeSize))
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            // An ID, a URL or a key reads left to right in every script, as a code does.
            .environment(\.layoutDirection, .leftToRight)
            .padding(.vertical, QeetrixCopyFieldMetrics.valuePadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .modifier(QeetrixCopyFieldPrivacy(isSensitive: isSensitive))
            .qeetrixFieldControlAccessibility()
            .accessibilityValue(Text(verbatim: value))
    }

    /// One line for `wrap: .none`, except at the accessibility sizes; no limit otherwise.
    static func lineLimit(_ wrap: QeetrixCopyFieldWrap, dynamicTypeSize: DynamicTypeSize) -> Int? {
        wrap == .none && !dynamicTypeSize.isAccessibilitySize ? 1 : nil
    }
}

private struct QeetrixCopyFieldPrivacy: ViewModifier {
    let isSensitive: Bool

    func body(content: Content) -> some View {
        if isSensitive { content.privacySensitive() } else { content }
    }
}

/// The `field` layout's box (copy-field.css `.qx-copy-field-box`): at least `size.control.lg` tall,
/// `space.inset.md` before the value and `space.inset.xs` after the button, on the read-only field
/// surface — no fill and the `color.border.strong` bottom line (`box-shadow: inset 0 -1px`); disabled,
/// the field's disabled fill and line.
struct QeetrixCopyFieldSurface: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density

    func body(content: Content) -> some View {
        content
            .padding(.leading, QeetrixCopyFieldMetrics.leading)
            .padding(.trailing, QeetrixCopyFieldMetrics.trailing)
            .frame(minHeight: QeetrixCopyFieldMetrics.minimumHeight(density))
            .qeetrixInputSurface(Self.state(isEnabled: isEnabled))
    }

    static func state(isEnabled: Bool) -> QeetrixInputState {
        QeetrixInputState(isEnabled: isEnabled, isReadOnly: true, isFocused: false, isHovered: false, isInvalid: false)
    }
}

/// copy-field.css's lengths.
enum QeetrixCopyFieldMetrics {
    /// `.qx-copy-field-box`'s `padding-inline-start`: `space.inset.md`, the input's.
    static let leading = QeetrixSpace.insetMd
    /// `padding-inline-end`: `space.inset.xs`, so the button sits close to the edge.
    static let trailing = QeetrixSpace.insetXs
    /// `gap: space.gap.sm` between the value and Copy.
    static let gap = QeetrixSpace.gapSm
    /// `.qx-copy-field-value`'s `padding-block: space.inset.xs`.
    static let valuePadding = QeetrixSpace.insetXs
    /// `font: typography.code.sm`.
    static let valueType = QeetrixTypeSpec(.codeSm)

    /// `min-block-size: size.control.lg`, the input's height.
    static func minimumHeight(_ density: QeetrixDensity) -> CGFloat {
        QeetrixInputMetrics.height(density)
    }
}

/// The value and its Copy button (`.qx-copy-field-box`: `display: flex; align-items: center; gap`): the
/// value takes the room the button leaves, and the two are centred on each other. Its first baseline is
/// the value's, as a flex box's is the first item's, so a row's label sits on the value's first line.
struct QeetrixCopyFieldBoxLayout: Layout {
    let spacing: CGFloat

    struct Frames: Equatable {
        var value: CGRect = .zero
        var button: CGRect = .zero
        var size: CGSize = .zero
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        frames(width: proposal.width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = frames(width: bounds.width, subviews: subviews)
        for (index, frame) in [frames.value, frames.button].enumerated() where index < subviews.count {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    func explicitAlignment(
        of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGFloat? {
        guard guide == .firstTextBaseline, let value = subviews.first else { return nil }
        let frame = frames(width: bounds.width, subviews: subviews).value
        return bounds.minY + frame.minY + value.dimensions(in: ProposedViewSize(frame.size))[VerticalAlignment.firstTextBaseline]
    }

    func frames(width proposed: CGFloat?, subviews: Subviews) -> Frames {
        guard let value = subviews.first else { return Frames() }
        let button = subviews.count > 1 ? subviews[1].sizeThatFits(.unspecified) : .zero
        let gap = subviews.count > 1 ? spacing : 0
        let width = proposed.flatMap { $0.isFinite ? $0 : nil } ?? (value.sizeThatFits(.unspecified).width + gap + button.width)
        let valueWidth = max(0, width - gap - button.width)
        let valueHeight = value.sizeThatFits(ProposedViewSize(width: valueWidth, height: nil)).height
        let height = max(valueHeight, button.height)
        return Frames(
            value: CGRect(x: 0, y: (height - valueHeight) / 2, width: valueWidth, height: valueHeight),
            button: CGRect(x: width - button.width, y: (height - button.height) / 2, width: button.width, height: button.height),
            size: CGSize(width: width, height: height))
    }
}
