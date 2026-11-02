import SwiftUI

/// The two looks of a ``QeetrixTimeline``, as `@qeetrix/react`'s `TimelineVariant`.
public enum QeetrixTimelineVariant: String, CaseIterable, Sendable {
    /// A 28 pt square marker per event holding its icon, joined to the next by a 1 pt line. The default.
    case `default`
    /// A 6 pt dot per event, centred on its title's first line, and no line: for minor events, a side
    /// panel or a short summary.
    case compact
}

/// An event's colour, as `@qeetrix/react`'s `TimelineTone` (Badge's names). It colours the icon or the
/// dot, and `danger` the title too. It is a second channel only: the title says what happened.
public enum QeetrixTimelineTone: String, CaseIterable, Sendable {
    /// Routine history: `color.icon.subtle` (a `color.border.strong` dot). The default.
    case neutral
    /// `color.icon.brand`: a step the product took.
    case brand
    /// `color.icon.info`: something to know.
    case info
    /// `color.icon.success`: a completion, such as a sign-in approved.
    case success
    /// `color.icon.warning`: something to check, such as a sign-in from a new place.
    case warning
    /// A failure, such as a refused sign-in: the icon or dot and the title in the danger colour.
    case danger

    /// The icon in a marker, or the compact dot.
    func markerColor(_ variant: QeetrixTimelineVariant) -> QeetrixColor {
        switch self {
        case .neutral: variant == .compact ? .borderStrong : .iconSubtle
        case .brand: .iconBrand
        case .info: .iconInfo
        case .success: .iconSuccess
        case .warning: .iconWarning
        case .danger: .iconDanger
        }
    }

    /// `[data-tone="danger"] .qx-timeline-title { color: var(--qx-color-text-danger) }`.
    var titleColor: QeetrixColor {
        self == .danger ? .textDanger : .textDefault
    }
}

/// What happened, newest first — a person's sign-in activity, an audit trail's critical events — as
/// `@qeetrix/react`'s Timeline. Put ``QeetrixTimelineItem``s in it, or ``QeetrixTimelineGroup``s of them,
/// one per day.
///
/// ```swift
/// QeetrixTimeline {
///     QeetrixTimelineGroup("Today") {
///         QeetrixTimelineItem(
///             "Signed in with a passkey", description: "Bengaluru · Safari on iPhone", time: Text("2 min ago"), icon: .keyRound)
///         QeetrixTimelineItem(
///             "Sign-in refused", description: "Unknown device", time: Text("1 h ago"), icon: .circleX, tone: .danger)
///     }
/// }
/// ```
///
/// In the `default` look each event has a 28 pt square marker (`color.bg.neutral.subtle`, a 1 pt
/// `color.border.subtle` edge, 4 pt corners) holding its sharp 16 pt icon, and a 1 pt
/// `color.border.subtle` line runs from it to the next event, broken between groups. Events are 16 pt
/// apart (`compact`: 8 pt), and groups 12 pt. The events, their order, wording and times are the app's;
/// format times before passing them. The full audit log stays a list; this is the short summary on a
/// detail screen.
public struct QeetrixTimeline<Content: View>: View {
    let variant: QeetrixTimelineVariant
    let content: Content

    public init(variant: QeetrixTimelineVariant = .default, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    public var body: some View {
        QeetrixTimelineEvents { content }
            .environment(\.qeetrixTimelineVariant, variant)
            .foregroundStyle(QeetrixColor.textDefault)  // .qx-timeline color
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .contain)
    }
}

/// A heading and the events under it, such as one day's, as `@qeetrix/react`'s TimelineGroup: the label
/// in `label.caps` (`color.text.subtle`), 8 pt above its events.
public struct QeetrixTimelineGroup<Content: View>: View {
    let label: Text
    let content: Content

    /// A group with a localised label.
    public init(_ labelKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(label: Text(labelKey), content: content)
    }

    /// A group with a label shown as given.
    public init<S: StringProtocol>(_ label: S, @ViewBuilder content: () -> Content) {
        self.init(label: Text(label), content: content)
    }

    /// A group with a `Text` label.
    public init(label: Text, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // .qx-timeline-group-label: label.caps, uppercase, color.text.subtle, margin-block-end gap-sm.
            label
                .textCase(.uppercase)
                .qeetrixTextStyle(.labelCaps)
                .foregroundStyle(QeetrixColor.textSubtle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, QeetrixSpace.gapSm)
                .accessibilityLabel(label)
            QeetrixTimelineEvents { content }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .layoutValue(key: QeetrixTimelineChildKey.self, value: .group)
    }
}

/// One event, as `@qeetrix/react`'s TimelineItem: its marker, what happened (`title`), where, by whom
/// or how (`description`), and when (`time`, as shown).
///
/// The title is `body.md` at weight 500 (400 in the compact look; `color.text.danger` for `danger`);
/// the description and the time are `body.sm` in `color.text.subtle`, the time at the end on one line.
/// The first lines are centred on the marker. VoiceOver reads the event as one element — title,
/// description, time — and the marker not at all. At the accessibility text sizes the time moves under
/// the description.
public struct QeetrixTimelineItem: View {
    let title: Text
    let description: Text?
    let time: Text?
    let icon: QeetrixIconName?
    let tone: QeetrixTimelineTone
    @Environment(\.qeetrixTimelineVariant) private var variant
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// The marker grows with its icon (`component.timeline.marker-size`, in px like the icon).
    @ScaledMetric(relativeTo: .body) private var markerSide = QeetrixTimelineMetrics.markerSize
    @ScaledMetric(relativeTo: QeetrixTextRole.bodyMd.textStyle) private var titleLine = QeetrixTimelineMetrics.titleLine
    @ScaledMetric(relativeTo: QeetrixTextRole.bodySm.textStyle) private var timeLine = QeetrixTimelineMetrics.timeLine

    /// An event with a localised title and description.
    ///
    /// - Parameters:
    ///   - titleKey: What happened: "Signed in with a passkey".
    ///   - description: Where, by whom or how: "Bengaluru · Safari on iPhone".
    ///   - time: When, as shown: `Text("2 min ago")`, or `Text(date, style: .relative)`.
    ///   - icon: A 16 pt icon for the kind of event, drawn sharp in the marker. The compact look has none.
    ///   - tone: The event's colour, `neutral` by default.
    public init(
        _ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, time: Text? = nil, icon: QeetrixIconName? = nil,
        tone: QeetrixTimelineTone = .neutral
    ) {
        self.init(title: Text(titleKey), description: description.map { Text($0) }, time: time, icon: icon, tone: tone)
    }

    /// An event with a title and description shown as given.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, time: Text? = nil, icon: QeetrixIconName? = nil, tone: QeetrixTimelineTone = .neutral
    ) {
        self.init(title: Text(title), description: description.map { Text(verbatim: $0) }, time: time, icon: icon, tone: tone)
    }

    /// An event with a `Text` title and description.
    public init(
        title: Text, description: Text? = nil, time: Text? = nil, icon: QeetrixIconName? = nil, tone: QeetrixTimelineTone = .neutral
    ) {
        self.title = title
        self.description = description
        self.time = time
        self.icon = icon
        self.tone = tone
    }

    public var body: some View {
        let compact = variant == .compact
        let timeBelow = dynamicTypeSize.isAccessibilitySize
        let offsets = QeetrixTimelineMetrics.offsets(
            marker: compact ? QeetrixTimelineMetrics.dot : markerSide, titleLine: titleLine, timeLine: timeLine)
        HStack(alignment: .top, spacing: compact ? QeetrixSpace.gapSm : QeetrixSpace.gapMd) {
            markerView
                .padding(.top, offsets.marker)
                .anchorPreference(key: QeetrixTimelineItemKey.self, value: .bounds) { [QeetrixTimelineAnchors(marker: $0)] }
            VStack(alignment: .leading, spacing: 0) {
                title
                    .qeetrixType(compact ? QeetrixComponentType.role(.bodyMd) : QeetrixTimelineMetrics.titleType)
                    .foregroundStyle(tone.titleColor)
                if let description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                }
                if let time, timeBelow {
                    time
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                }
            }
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, offsets.text)
            if let time, !timeBelow {
                // .qx-timeline-time: white-space nowrap, centred on the marker (compact: on the title's line).
                time
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.top, offsets.time)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .transformAnchorPreference(key: QeetrixTimelineItemKey.self, value: .bounds) { value, item in
            value = value.map { QeetrixTimelineAnchors(marker: $0.marker, item: item) }
        }
        .layoutValue(key: QeetrixTimelineChildKey.self, value: .item)
    }

    @ViewBuilder private var markerView: some View {
        if variant == .compact {
            // .qx-timeline[data-variant="compact"] .qx-timeline-marker: a 6 pt dot, radius.full.
            Circle()
                .fill(tone.markerColor(.compact))
                .frame(width: QeetrixTimelineMetrics.dot, height: QeetrixTimelineMetrics.dot)
                .accessibilityHidden(true)
        } else {
            // .qx-timeline-marker: radius.control, bg.neutral.subtle, an inset 1 pt border.subtle edge.
            let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
            ZStack {
                shape.fill(QeetrixColor.bgNeutralSubtle)
                shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixBorderWidth.default)
                if let icon {
                    QeetrixIcon(icon, size: .sm, shape: .sharp)  // drawIcon(Icon, { size: 16 })
                        .foregroundStyle(tone.markerColor(.default))
                }
            }
            .frame(width: markerSide, height: markerSide)
            .accessibilityHidden(true)  // aria-hidden
        }
    }
}

enum QeetrixTimelineMetrics {
    /// `component.timeline.marker-size`, 28px (`Upstream/qeetrix-tokens/dtcg/tokens/component.tokens.json`):
    /// timeline.css's `grid-template-columns: 28px …` and `.qx-timeline-marker { block-size: 28px }`.
    /// Restated: iOS doesn't generate component tokens (ADR 0018 §4).
    static let markerSize: CGFloat = 28
    /// timeline.css, compact: `grid-template-columns: 6px …`, `.qx-timeline-marker { block-size: 6px }`.
    static let dot: CGFloat = 6
    /// The line between events: `inline-size: var(--qx-border-width-default)`.
    static let lineWidth = QeetrixBorderWidth.default
    /// `body.md`'s line, which the title takes (`.qx-timeline { font: var(--qx-typography-body-md) }`).
    static let titleLine = QeetrixTextRole.bodyMd.tokens.size * CGFloat(QeetrixTextRole.bodyMd.tokens.lineHeight)
    /// `body.sm`'s line, the time's.
    static let timeLine = QeetrixTextRole.bodySm.tokens.size * CGFloat(QeetrixTextRole.bodySm.tokens.lineHeight)
    /// `.qx-timeline-title { font-weight: var(--qx-typography-label-md-font-weight) }`: `body.md` at 500.
    static let titleType = QeetrixComponentType.role(.bodyMd, QeetrixTextRole.labelMd.tokens.weight)

    /// Where an event's marker, text and time start, so that their first lines share one centre: the
    /// marker's (`padding-block-start: calc(14px - .5lh)`) or, where the title's line outgrows the
    /// marker at large text sizes, the line's, with the marker moved down to it. The compact dot sits on
    /// the title's line (`margin-block-start: calc(.5lh - 3px)`).
    static func offsets(marker: CGFloat, titleLine: CGFloat, timeLine: CGFloat) -> (marker: CGFloat, text: CGFloat, time: CGFloat) {
        let centre = max(marker, titleLine) / 2
        return (centre - marker / 2, centre - titleLine / 2, max(0, centre - timeLine / 2))
    }

    /// The gap after a child of the events list, before the next: `padding-block-end` on every event but
    /// the last (`gap-lg`, compact `gap-sm`), and `.qx-timeline-group + .qx-timeline-group`'s `gap-md`.
    static func gap(after previous: QeetrixTimelineChild, before next: QeetrixTimelineChild, variant: QeetrixTimelineVariant) -> CGFloat {
        switch (previous, next) {
        case (.item, _): variant == .compact ? QeetrixSpace.gapSm : QeetrixSpace.gapLg
        case (.group, .group): QeetrixSpace.gapMd
        default: 0
        }
    }

    /// The line from one event's marker to the next event: from `gap-xs` under the marker to `gap-xs`
    /// above the next event (`inset-block: calc(28px + var(--qx-space-gap-xs)) var(--qx-space-gap-xs)`).
    static func line(from marker: CGRect, to next: CGRect) -> (top: CGFloat, height: CGFloat) {
        let top = marker.maxY + QeetrixSpace.gapXs
        return (top, max(0, next.minY - QeetrixSpace.gapXs - top))
    }
}

/// Whether a child of the events list is an event, a group or something else.
enum QeetrixTimelineChild: Equatable {
    case item, group, other
}

struct QeetrixTimelineChildKey: LayoutValueKey {
    static let defaultValue = QeetrixTimelineChild.other
}

/// Where an event and its marker are, for the line to the next.
struct QeetrixTimelineAnchors {
    let marker: Anchor<CGRect>
    var item: Anchor<CGRect>?
}

struct QeetrixTimelineItemKey: PreferenceKey {
    static let defaultValue: [QeetrixTimelineAnchors] = []

    static func reduce(value: inout [QeetrixTimelineAnchors], nextValue: () -> [QeetrixTimelineAnchors]) {
        value += nextValue()
    }
}

private struct QeetrixTimelineVariantKey: EnvironmentKey {
    static let defaultValue = QeetrixTimelineVariant.default
}

extension EnvironmentValues {
    /// The look of the timeline an event is in.
    var qeetrixTimelineVariant: QeetrixTimelineVariant {
        get { self[QeetrixTimelineVariantKey.self] }
        set { self[QeetrixTimelineVariantKey.self] = newValue }
    }
}

/// The `ol` of events or groups (`.qx-timeline`, `.qx-timeline-events`): stacked with their gaps, and in
/// the default look a 1 pt `color.border.subtle` line from each event's marker to the next event, centred
/// on the marker. Its events' lines stop here, so a group's line breaks before the next group.
struct QeetrixTimelineEvents<Content: View>: View {
    @ViewBuilder let content: Content
    @Environment(\.qeetrixTimelineVariant) private var variant

    var body: some View {
        QeetrixTimelineStack(variant: variant) { content }
            .backgroundPreferenceValue(QeetrixTimelineItemKey.self) { events in
                if variant == .default {
                    QeetrixTimelineLines(events: events)
                }
            }
            .transformPreference(QeetrixTimelineItemKey.self) { $0 = [] }
    }
}

/// The lines between consecutive events, drawn behind them.
private struct QeetrixTimelineLines: View {
    let events: [QeetrixTimelineAnchors]

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(Array(zip(events, events.dropFirst()).enumerated()), id: \.offset) { _, pair in
                    if let next = pair.1.item {
                        let marker = proxy[pair.0.marker]
                        let line = QeetrixTimelineMetrics.line(from: marker, to: proxy[next])
                        // inset-inline-start: calc(14px - var(--qx-border-width-default) / 2): the marker's centre.
                        Rectangle()
                            .fill(QeetrixColor.borderSubtle)
                            .frame(width: QeetrixTimelineMetrics.lineWidth, height: line.height)
                            .padding(.leading, marker.width / 2 - QeetrixTimelineMetrics.lineWidth / 2)
                            .padding(.top, line.top)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .accessibilityHidden(true)
    }
}

/// Stacks the events list's children at full width with ``QeetrixTimelineMetrics/gap(after:before:variant:)``
/// between them.
struct QeetrixTimelineStack: Layout {
    let variant: QeetrixTimelineVariant

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var height: CGFloat = 0
        var width: CGFloat = 0
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: proposal.width, height: nil))
            height += size.height + gap(before: index, subviews)
            width = max(width, size.width)
        }
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for index in subviews.indices {
            y += gap(before: index, subviews)
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            subviews[index].place(at: CGPoint(x: bounds.minX, y: y), proposal: ProposedViewSize(width: bounds.width, height: size.height))
            y += size.height
        }
    }

    private func gap(before index: Int, _ subviews: Subviews) -> CGFloat {
        guard index > 0 else { return 0 }
        return QeetrixTimelineMetrics.gap(
            after: subviews[index - 1][QeetrixTimelineChildKey.self], before: subviews[index][QeetrixTimelineChildKey.self],
            variant: variant)
    }
}
