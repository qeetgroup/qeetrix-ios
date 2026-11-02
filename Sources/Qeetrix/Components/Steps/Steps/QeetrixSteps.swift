import SwiftUI

/// A step's state, as `@qeetrix/react`'s `StepStatus`. ``QeetrixSteps`` works out `done`, `current` and
/// `upcoming` from its `current` index; set a status on a ``QeetrixStep`` only when that can't say it.
public enum QeetrixStepStatus: String, CaseIterable, Sendable {
    /// Finished: an Ember marker with a tick.
    case done
    /// Where the person is: an Ember outline round its number.
    case current
    /// Still to come: a grey outline round a subtle number.
    case upcoming
    /// A check that didn't pass: a danger marker with a cross.
    case failed
    /// It needs work: a warning marker with a warning sign.
    case attention

    /// What VoiceOver reads after the step's position: `steps.done`, `.upcoming`, `.failed`,
    /// `.attention`; "Current step" for the current one, which the web says with `aria-current="step"`.
    var spokenName: String {
        switch self {
        case .done: String(localized: "qeetrix.steps.done", defaultValue: "Completed", bundle: .module)
        case .current: String(localized: "qeetrix.steps.current", defaultValue: "Current step", bundle: .module)
        case .upcoming: String(localized: "qeetrix.steps.upcoming", defaultValue: "Not started", bundle: .module)
        case .failed: String(localized: "qeetrix.steps.failed", defaultValue: "Failed", bundle: .module)
        case .attention: String(localized: "qeetrix.steps.attention", defaultValue: "Needs attention", bundle: .module)
        }
    }
}

/// How ``QeetrixSteps`` lays its steps out, as `@qeetrix/react`'s `StepsOrientation`.
public enum QeetrixStepsOrientation: String, CaseIterable, Sendable {
    /// Across the screen, each label centred under its marker, for a short flow of a few steps. Where
    /// the labels don't fit, the compact form: "Step 2 of 4", the current step and a bar. The default.
    case horizontal
    /// Down the screen, each label beside its marker with its description, for a longer setup.
    case vertical
}

/// One step of a ``QeetrixSteps``: its name and, for the vertical layout, a line under it.
public struct QeetrixStep {
    let label: Text
    let description: Text?
    let status: QeetrixStepStatus?

    /// A step with a localised label and description.
    ///
    /// - Parameters:
    ///   - label: The step's name, short: "Verify phone".
    ///   - description: A line under the label in the vertical layout: what the step is, or what was chosen.
    ///   - status: The step's state over the one `current` gives it — `failed` or `attention` for a check,
    ///     or `done` for a later step that stays done while an earlier one needs work.
    public init(_ label: LocalizedStringKey, description: LocalizedStringKey? = nil, status: QeetrixStepStatus? = nil) {
        self.init(label: Text(label), description: description.map { Text($0) }, status: status)
    }

    /// A step with a label and description shown as given.
    public init<S: StringProtocol>(_ label: S, description: String? = nil, status: QeetrixStepStatus? = nil) {
        self.init(label: Text(label), description: description.map { Text(verbatim: $0) }, status: status)
    }

    /// A step with a `Text` label and description.
    public init(label: Text, description: Text? = nil, status: QeetrixStepStatus? = nil) {
        self.label = label
        self.description = description
        self.status = status
    }
}

/// Where a person is in a flow of a few steps, as `@qeetrix/react`'s Steps: numbered 24 pt square
/// markers — done ones filled Ember with a tick, the current one outlined Ember, those to come grey —
/// joined by a line that turns Ember behind the done steps.
///
/// ```swift
/// QeetrixSteps(
///     [QeetrixStep("Account"), QeetrixStep("Verify phone"), QeetrixStep("Passkey"), QeetrixStep("Done")],
///     current: 1)
/// ```
///
/// `current` is the current step's index from 0, or the number of steps once every step is done.
/// Across the screen each label sits under its marker, in equal columns. Where the labels don't all
/// fit on one line — a narrow screen, many steps, the largest text sizes — it becomes the compact form:
/// the current step's marker and label under "Step 2 of 4", over a bar filled as far as the steps done.
/// `vertical` puts each label beside its marker, with its description. With `onStepSelect`, done steps
/// are buttons back to themselves; steps ahead never are.
///
/// VoiceOver reads every step, in either form, with its position and state: "Verify phone, Step 2 of 4,
/// Current step". Labels never truncate.
public struct QeetrixSteps: View {
    let steps: [QeetrixStep]
    let current: Int
    let orientation: QeetrixStepsOrientation
    let onStepSelect: (@MainActor (Int) -> Void)?

    /// - Parameters:
    ///   - steps: The steps, in order.
    ///   - current: The current step's index from 0; `steps.count` once every step is done.
    ///   - orientation: `horizontal` for a short flow, `vertical` for a longer setup with descriptions.
    ///   - onStepSelect: Called with a done step's index when it is chosen, to go back to it. Without it,
    ///     steps are text.
    public init(
        _ steps: [QeetrixStep], current: Int, orientation: QeetrixStepsOrientation = .horizontal,
        onStepSelect: (@MainActor (Int) -> Void)? = nil
    ) {
        self.steps = steps
        self.current = current
        self.orientation = orientation
        self.onStepSelect = onStepSelect
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal:
                ViewThatFits(in: .horizontal) {
                    QeetrixStepsColumns {
                        ForEach(steps.indices, id: \.self) { index in
                            QeetrixStepColumn(steps: self, index: index)
                        }
                    }
                    QeetrixStepsCompact(steps: self)
                }
            case .vertical:
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(steps.indices, id: \.self) { index in
                        QeetrixStepRow(steps: self, index: index)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .foregroundStyle(QeetrixColor.textDefault)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(QeetrixStepsMetrics.listLabel)  // aria-label: steps.label, "Progress"
    }

    /// Step `index`'s state: its own status, else done before `current`, current at it, upcoming after.
    func state(_ index: Int) -> QeetrixStepStatus {
        steps[index].status ?? (index < current ? .done : index == current ? .current : .upcoming)
    }

    /// The step the compact form shows: the current one, or the last once every step is done.
    var shownIndex: Int {
        min(max(current, 0), max(steps.count - 1, 0))
    }

    /// How far the compact form's bar is filled: the share of steps before `current`.
    var fractionDone: Double {
        steps.isEmpty ? 0 : Double(min(max(current, 0), steps.count)) / Double(steps.count)
    }

    /// Whether step `index` is a button: a done step, with `onStepSelect`.
    func isSelectable(_ index: Int) -> Bool {
        onStepSelect != nil && state(index) == .done
    }

    /// "Step 2 of 4", for step `index`.
    func position(_ index: Int) -> String {
        QeetrixStepsMetrics.position(index + 1, of: steps.count)
    }

    /// What VoiceOver reads after a step's label: its position and its state.
    func accessibilityValue(_ index: Int) -> String {
        "\(position(index)), \(state(index).spokenName)"
    }
}

enum QeetrixStepsMetrics {
    /// steps.css: `.qx-step-marker { block-size: 24px; inline-size: 24px }`.
    static let markerSize: CGFloat = 24
    /// The lines between steps: `var(--qx-border-width-default)`.
    static let lineWidth = QeetrixBorderWidth.default
    /// steps.js: the tick and the cross are drawn at `strokeWidth: 3`, the warning sign at 2.5.
    static let boldStroke = QeetrixIconStroke(3)
    static let attentionStroke = QeetrixIconStroke(2.5)
    /// `.qx-step-label`: `body.md`; the current step's at `title.sm`'s weight (600).
    static let labelType = QeetrixComponentType.role(.bodyMd)
    static let currentLabelType = QeetrixComponentType.role(.bodyMd, QeetrixTextRole.titleSm.tokens.weight)
    /// `.qx-step-marker`: `label.sm` at `title.sm`'s weight, tabular figures.
    static let numberType = QeetrixComponentType.role(.labelSm, QeetrixTextRole.titleSm.tokens.weight)
    /// `body.md`'s line, which a vertical step's label centres on its marker.
    static let labelLine = QeetrixTextRole.bodyMd.tokens.size * CGFloat(QeetrixTextRole.bodyMd.tokens.lineHeight)

    /// Where a vertical step's marker and label start, so the label's first line is centred on the
    /// marker (`margin-block-start: calc(12px - .5lh)`) or, where the line outgrows the marker at large
    /// text sizes, the marker on the line.
    static func offsets(marker: CGFloat, line: CGFloat) -> (marker: CGFloat, label: CGFloat) {
        let centre = max(marker, line) / 2
        return (centre - marker / 2, centre - line / 2)
    }

    /// "Progress" — `steps.label`, the list's name.
    static var listLabel: Text {
        Text(verbatim: String(localized: "qeetrix.steps.label", defaultValue: "Progress", bundle: .module))
    }

    /// "Step 2 of 4" — iOS only: the compact form's line, and each step's position for VoiceOver, which the
    /// web's ordered list gives for free.
    static func position(_ number: Int, of count: Int) -> String {
        String(localized: "qeetrix.steps.position", defaultValue: "Step \(number) of \(count)", bundle: .module)
    }

    /// The marker's fill, ring and ink for a state (steps.css `[data-state]`).
    static func marker(_ state: QeetrixStepStatus) -> (fill: QeetrixColor?, ring: (QeetrixColor, CGFloat)?, ink: QeetrixColor) {
        switch state {
        case .done: (.bgBrandBold, nil, .textOnBrand)
        case .current: (nil, (.borderBrand, QeetrixBorderWidth.strong), .textBrand)
        case .upcoming: (nil, (.borderStrong, QeetrixBorderWidth.default), .textSubtle)
        case .failed: (.bgDangerBold, nil, .textOnBold)
        case .attention: (.bgWarningBold, nil, .textOnWarning)
        }
    }

    /// The line after a step: `color.border.brand` once the step is done, else `color.border.subtle`.
    static func connector(after state: QeetrixStepStatus) -> QeetrixColor {
        state == .done ? .borderBrand : .borderSubtle
    }
}

/// A step's marker (`.qx-step-marker`): a 24 pt square with 4 pt corners, growing with its number.
struct QeetrixStepMarker: View {
    let number: Int
    let state: QeetrixStepStatus
    @ScaledMetric(relativeTo: QeetrixTextRole.labelSm.textStyle) private var side = QeetrixStepsMetrics.markerSize

    var body: some View {
        let look = QeetrixStepsMetrics.marker(state)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        ZStack {
            if let fill = look.fill { shape.fill(fill) }
            if let ring = look.ring { shape.strokeBorder(ring.0, lineWidth: ring.1) }
            Group {
                switch state {
                case .done:
                    QeetrixIcon(.check, size: .xs, stroke: QeetrixStepsMetrics.boldStroke, shape: .sharp, relativeTo: .footnote)
                case .failed:
                    QeetrixIcon(.x, size: .xs, stroke: QeetrixStepsMetrics.boldStroke, shape: .sharp, relativeTo: .footnote)
                case .attention:
                    QeetrixIcon(
                        .triangleAlert, size: .xs, stroke: QeetrixStepsMetrics.attentionStroke, shape: .sharp, relativeTo: .footnote)
                case .current, .upcoming:
                    Text(number, format: .number)
                        .qeetrixType(QeetrixStepsMetrics.numberType)
                        .monospacedDigit()  // font-variant-numeric: tabular-nums
                        .lineLimit(1)
                }
            }
            .foregroundStyle(look.ink)
        }
        .frame(width: side, height: side)
        .accessibilityHidden(true)  // aria-hidden
    }
}

/// A step's label (`.qx-step-label`): the current one at 600, those to come in `color.text.subtle`.
private struct QeetrixStepLabel: View {
    let text: Text
    let state: QeetrixStepStatus

    var body: some View {
        text
            .qeetrixType(state == .current ? QeetrixStepsMetrics.currentLabelType : QeetrixStepsMetrics.labelType)
            .foregroundStyle(state == .upcoming ? QeetrixColor.textSubtle : QeetrixColor.textDefault)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A done step's button back to itself, when the steps take `onStepSelect`; otherwise the content.
private struct QeetrixStepBody<Content: View>: View {
    let steps: QeetrixSteps
    let index: Int
    @ViewBuilder let content: Content

    var body: some View {
        if steps.isSelectable(index) {
            Button {
                steps.onStepSelect?(index)
            } label: {
                content.contentShape(Rectangle())
            }
            .buttonStyle(QeetrixStepButtonStyle())
            .qeetrixHitArea()
        } else {
            content
        }
    }
}

/// `button.qx-step-body`: the step as it is, its label underlined on hover; the focus frame round it.
private struct QeetrixStepButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixStepButtonBody(configuration: configuration)
    }
}

private struct QeetrixStepButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        configuration.label
            .underline(isHovered || configuration.isPressed)
            .onHover { isHovered = $0 }
            .overlay {
                if isFocused { QeetrixOuterFocusFrame(shape: RoundedRectangle(cornerRadius: QeetrixRadius.control)) }
            }
    }
}

/// One column of the horizontal layout (`[data-orientation="horizontal"] > .qx-step`): the marker, the
/// label centred under it, and the line to the next step at the marker's middle, from 8 pt after this
/// marker to 8 pt before the next.
private struct QeetrixStepColumn: View {
    let steps: QeetrixSteps
    let index: Int
    @ScaledMetric(relativeTo: QeetrixTextRole.labelSm.textStyle) private var marker = QeetrixStepsMetrics.markerSize

    var body: some View {
        let state = steps.state(index)
        QeetrixStepBody(steps: steps, index: index) {
            // .qx-step-body: marker over label, gap-xs apart, padding-inline gap-xs, centred.
            VStack(spacing: QeetrixSpace.gapXs) {
                QeetrixStepMarker(number: index + 1, state: state)
                QeetrixStepLabel(text: steps.steps[index].label, state: state)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, QeetrixSpace.gapXs)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(alignment: .top) {
            // Each column draws its half of the lines either side: the one from the step before, in that
            // step's colour, and its own. `inset-inline-start: calc(50% + 12px + gap-sm)`.
            HStack(spacing: marker + 2 * QeetrixSpace.gapSm) {
                connector(index > 0 ? QeetrixStepsMetrics.connector(after: steps.state(index - 1)) : nil)
                connector(index < steps.steps.count - 1 ? QeetrixStepsMetrics.connector(after: state) : nil)
            }
            .padding(.top, marker / 2 - QeetrixStepsMetrics.lineWidth / 2)
            .accessibilityHidden(true)
        }
        .modifier(QeetrixStepAccessibility(steps: steps, index: index, showsDescription: false))
    }

    private func connector(_ color: QeetrixColor?) -> some View {
        Rectangle()
            .fill(color ?? QeetrixColor.borderSubtle)
            .opacity(color == nil ? 0 : 1)
            .frame(height: QeetrixStepsMetrics.lineWidth)
    }
}

/// One row of the vertical layout: the marker, the label beside it (its first line centred on the
/// marker) and the description under it, and a line down from the marker to the next step.
private struct QeetrixStepRow: View {
    let steps: QeetrixSteps
    let index: Int
    @ScaledMetric(relativeTo: QeetrixTextRole.labelSm.textStyle) private var marker = QeetrixStepsMetrics.markerSize
    @ScaledMetric(relativeTo: QeetrixTextRole.bodyMd.textStyle) private var line = QeetrixStepsMetrics.labelLine

    var body: some View {
        let state = steps.state(index)
        let isLast = index == steps.steps.count - 1
        let offsets = QeetrixStepsMetrics.offsets(marker: marker, line: line)
        QeetrixStepBody(steps: steps, index: index) {
            HStack(alignment: .top, spacing: QeetrixSpace.gapSm) {
                QeetrixStepMarker(number: index + 1, state: state)
                    .padding(.top, offsets.marker)
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixStepLabel(text: steps.steps[index].label, state: state)
                        .padding(.top, offsets.label)
                    if let description = steps.steps[index].description {
                        description
                            .qeetrixTextStyle(.bodySm)
                            .foregroundStyle(QeetrixColor.textSubtle)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.bottom, isLast ? 0 : QeetrixSpace.gapLg)  // padding-block-end gap-lg; :last-child 0
        .background(alignment: .topLeading) {
            if !isLast {
                // inset-block: calc(24px + gap-xs) gap-xs; inset-inline-start: 11.5px.
                Rectangle()
                    .fill(QeetrixStepsMetrics.connector(after: state))
                    .frame(width: QeetrixStepsMetrics.lineWidth)
                    .padding(.top, offsets.marker + marker + QeetrixSpace.gapXs)
                    .padding(.bottom, QeetrixSpace.gapXs)
                    .padding(.leading, marker / 2 - QeetrixStepsMetrics.lineWidth / 2)
                    .accessibilityHidden(true)
            }
        }
        .modifier(QeetrixStepAccessibility(steps: steps, index: index, showsDescription: true))
    }
}

/// The compact form, where the labels don't fit across: the current step's marker beside "Step 2 of 4"
/// and its label, over a 4 pt bar (``QeetrixProgressTrack``) filled as far as the steps done. VoiceOver
/// still reads every step.
private struct QeetrixStepsCompact: View {
    let steps: QeetrixSteps

    var body: some View {
        let index = steps.shownIndex
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            if !steps.steps.isEmpty {
                HStack(alignment: .center, spacing: QeetrixSpace.gapSm) {
                    QeetrixStepMarker(number: index + 1, state: steps.state(index))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: steps.position(index))
                            .qeetrixTextStyle(.labelSm)
                            .foregroundStyle(QeetrixColor.textSubtle)
                        QeetrixStepLabel(text: steps.steps[index].label, state: steps.state(index))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            QeetrixProgressTrack(fraction: steps.fractionDone, indicator: .bgBrandBold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityChildren {
            ForEach(steps.steps.indices, id: \.self) { index in
                steps.steps[index].label
                    .modifier(QeetrixStepAccessibility(steps: steps, index: index, showsDescription: false))
            }
        }
    }
}

/// A step as VoiceOver reads it, in every form: one element, its label, then its position and state
/// ("Verify phone", "Step 2 of 4, Current step") and, in the vertical layout, its description; a button
/// back to itself when it is selectable.
private struct QeetrixStepAccessibility: ViewModifier {
    let steps: QeetrixSteps
    let index: Int
    let showsDescription: Bool

    func body(content: Content) -> some View {
        let step = steps.steps[index]
        var value = Text(verbatim: steps.accessibilityValue(index))
        if showsDescription, let description = step.description {
            value = value + Text(verbatim: ", ") + description
        }
        let element =
            content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(step.label)
            .accessibilityValue(value)
        return Group {
            if steps.isSelectable(index) {
                element
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { steps.onStepSelect?(index) }
            } else {
                element
            }
        }
    }
}

/// The horizontal layout's equal columns (`flex: 1 1 0`). Its ideal width is every column at its widest
/// label's single line, so ``QeetrixSteps`` changes to the compact form, rather than wrapping or
/// truncating, where they don't fit.
struct QeetrixStepsColumns: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let count = CGFloat(subviews.count)
        let width = proposal.width ?? count * (subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0)
        let column = ProposedViewSize(width: width / count, height: nil)
        let height = subviews.map { $0.sizeThatFits(column).height }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let width = bounds.width / CGFloat(subviews.count)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + CGFloat(index) * width, y: bounds.minY),
                proposal: ProposedViewSize(width: width, height: bounds.height))
        }
    }
}
