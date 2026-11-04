import SwiftUI

/// A checkbox, radio or switch row (field.css `.qx-choice`): the control, then 8 pt (`space.gap.sm`)
/// later its label in `body.md` and, under the label and aligned with it, an optional description in
/// `body.sm`. The control sits on the label's first line. The whole row is the target, at least 44 pt
/// tall — the iOS minimum, where the web's row is a 24 px target (ADR 0012).
struct QeetrixChoiceRow<Control: View, Label: View>: View {
    let description: Text?
    let isEnabled: Bool
    let control: Control
    let label: Label
    @ScaledMetric(relativeTo: .body) private var fontSize = QeetrixTextRole.bodyMd.tokens.size

    init(description: Text?, isEnabled: Bool, @ViewBuilder control: () -> Control, @ViewBuilder label: () -> Label) {
        self.description = description
        self.isEnabled = isEnabled
        self.control = control()
        self.label = label()
    }

    var body: some View {
        // Centre the control on the first line of the label, at any text size.
        let offset = fontSize * 0.32
        HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapSm) {
            control
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    dimensions[VerticalAlignment.center] + offset
                }
            VStack(alignment: .leading, spacing: 0) {
                label
                    .qeetrixTextStyle(.bodyMd)
                    .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
                if let description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        // A disabled description stays readable: subtlest, not the disabled colour.
                        .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textSubtlest)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, QeetrixSpace.insetXs)
        .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
        .contentShape(Rectangle())
    }
}
