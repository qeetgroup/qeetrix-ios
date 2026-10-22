import SwiftUI

/// The colour of a timeline event's marker — a second channel only: the event's title must still say
/// what happened. The web's `TimelineTone`.
public enum QeetrixTimelineTone: String, CaseIterable, Sendable {
    /// Routine history. The default.
    case neutral
    case brand
    case info
    case success
    case warning
    case destructive
}

/// How much an event matters — the web's `TimelineEmphasis`.
public enum QeetrixTimelineEmphasis: String, CaseIterable, Sendable {
    /// A meaningful event: a full-size marker and a primary title.
    case `default`
    /// Housekeeping — a label changed, a sync ran: a small neutral marker, a muted title and a tighter
    /// rhythm, so a run of them reads as one quiet block.
    case minor
}

/// A vertical history of events, newest or oldest first as you order them — the web's `Timeline`.
///
/// ```swift
/// QeetrixTimeline {
///     ForEach(events) { event in
///         QeetrixTimelineItem(
///             event.title, time: Text(event.date, style: .relative), description: event.detail.map { Text(verbatim: $0) },
///             tone: event.isFailure ? .destructive : .neutral)
///     }
/// }
/// ```
///
/// Each event has a marker on a rail one marker wide, joined to the next by a connector; give the events
/// that matter most an `icon`, the strongest of the three levels. Spacing follows the web's timeline
/// tokens.
///
/// The events, their order, their wording and their times are yours: the timeline fetches, groups and
/// classifies nothing. Format times before you pass them (`Text(date, style: .relative)`).
///
/// It lays out in a `ScrollView`, a card or a sheet. In a `List`, where rows are separate, the connectors
/// can't join; use ``QeetrixListItem`` rows there.
public struct QeetrixTimeline<Content: View>: View {
    let content: Content

    /// - Parameter content: The ``QeetrixTimelineItem``s.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        QeetrixTimelineLayout {
            content
        }
        .backgroundPreferenceValue(QeetrixTimelineMarkersKey.self) { markers in
            GeometryReader { proxy in
                let frames = markers.map { proxy[$0] }
                ForEach(Array(zip(frames, frames.dropFirst()).enumerated()), id: \.offset) { _, pair in
                    // From this marker's centre to the next one's, under both (bg-border w-px). Down from
                    // the markers' frames; across from the leading edge, where every marker sits, so the
                    // connector mirrors with them in right-to-left layouts. An anchor's x and `position`
                    // don't agree there: placed at the marker's x, the connector landed on the far side.
                    let (from, to) = pair
                    Rectangle()
                        .fill(QeetrixColor.borderDefault)
                        .frame(width: QeetrixStroke.hairline, height: max(0, to.midY - from.midY))
                        .padding(.leading, (from.width - QeetrixStroke.hairline) / 2)
                        .padding(.top, from.midY)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .accessibilityHidden(true)
        }
        .transformPreference(QeetrixTimelineMarkersKey.self) { $0 = [] }
    }
}

/// One event of a ``QeetrixTimeline``: a marker, a title, an optional time at the end of the title line,
/// and an optional description.
///
/// VoiceOver reads the event as one element — title, time, description — and, when you give one, the
/// marker's `label` ("Failed", "Approved") as its value, for a marker whose meaning the text doesn't
/// already say.
public struct QeetrixTimelineItem: View {
    let title: Text
    let time: Text?
    let description: Text?
    let tone: QeetrixTimelineTone
    let icon: QeetrixIconName?
    let emphasis: QeetrixTimelineEmphasis
    let label: Text?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// An event with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: What happened, looked up in the main bundle.
    ///   - time: When — formatted by you.
    ///   - description: More detail, muted.
    ///   - tone: The marker's colour.
    ///   - icon: An icon in a tinted marker, for the events that matter most.
    ///   - emphasis: A full event, or a minor one.
    ///   - label: What the marker conveys, for VoiceOver, when the text doesn't say it.
    public init(
        _ titleKey: LocalizedStringKey, time: Text? = nil, description: Text? = nil, tone: QeetrixTimelineTone = .neutral,
        icon: QeetrixIconName? = nil, emphasis: QeetrixTimelineEmphasis = .default, label: Text? = nil
    ) {
        self.init(
            title: Text(titleKey), time: time, description: description, tone: tone, icon: icon, emphasis: emphasis, label: label)
    }

    /// An event with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, time: Text? = nil, description: Text? = nil, tone: QeetrixTimelineTone = .neutral, icon: QeetrixIconName? = nil,
        emphasis: QeetrixTimelineEmphasis = .default, label: Text? = nil
    ) {
        self.init(title: Text(title), time: time, description: description, tone: tone, icon: icon, emphasis: emphasis, label: label)
    }

    /// An event with a `Text` title.
    public init(
        title: Text, time: Text? = nil, description: Text? = nil, tone: QeetrixTimelineTone = .neutral, icon: QeetrixIconName? = nil,
        emphasis: QeetrixTimelineEmphasis = .default, label: Text? = nil
    ) {
        self.title = title
        self.time = time
        self.description = description
        self.tone = tone
        self.icon = icon
        self.emphasis = emphasis
        self.label = label
    }

    public var body: some View {
        HStack(alignment: .top, spacing: QeetrixWebScale.spacing(3)) {  // gap-3
            QeetrixTimelineMarker(tone: tone, icon: icon, emphasis: emphasis)
                .anchorPreference(key: QeetrixTimelineMarkersKey.self, value: .bounds) { [$0] }
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // gap-0.5
                header
                if let description {
                    description
                        .qeetrixType(QeetrixTimelineMetrics.descriptionType)
                        .foregroundStyle(QeetrixColor.textTertiary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, QeetrixWebScale.spacing(0.5))  // pt-0.5: the first line centred on the marker
        }
        .layoutValue(key: QeetrixTimelineEmphasisKey.self, value: emphasis)
        .accessibilityElement(children: .combine)
        .accessibilityValue(label ?? Text(verbatim: ""))
    }

    /// Title at the start, time at the end; the time drops below the title at the accessibility sizes.
    @ViewBuilder
    private var header: some View {
        let titleView =
            title
            .qeetrixType(emphasis == .minor ? QeetrixTimelineMetrics.minorTitleType : QeetrixTimelineMetrics.titleType)
            .foregroundStyle(emphasis == .minor ? QeetrixColor.textTertiary : QeetrixColor.textPrimary)
        let timeView = time?
            .qeetrixType(QeetrixTimelineMetrics.timeType)
            .monospacedDigit()  // tabular-nums
            .foregroundStyle(QeetrixColor.textTertiary)
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {
                titleView
                timeView
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(3)) {  // gap-x-3
                titleView.frame(maxWidth: .infinity, alignment: .leading)
                timeView?.fixedSize()  // shrink-0 whitespace-nowrap
            }
        }
    }
}

/// The marker in its 24 pt box: a toned dot, a smaller neutral dot for a minor event, or an icon in a
/// tinted, opaque circle that hides the connector behind it.
struct QeetrixTimelineMarker: View {
    let tone: QeetrixTimelineTone
    let icon: QeetrixIconName?
    let emphasis: QeetrixTimelineEmphasis

    var body: some View {
        let side = QeetrixTimelineTokens.markerSize
        ZStack {
            if let icon {
                let colors = QeetrixTimelineMetrics.iconColors(tone)
                Circle()
                    .fill(QeetrixColor.surfaceDefault)  // bg-surface, then the tint over it: opaque
                    .overlay { Circle().fill(colors.tint) }
                    .overlay { Circle().strokeBorder(colors.border, lineWidth: QeetrixStroke.hairline) }
                QeetrixIcon(icon, size: QeetrixIconSize(QeetrixWebScale.spacing(3.5)), relativeTo: nil)  // size-3.5
                    .foregroundStyle(colors.foreground)
            } else {
                let dot = emphasis == .minor ? QeetrixWebScale.spacing(1.5) : QeetrixWebScale.spacing(2.5)  // size-1.5 / size-2.5
                Circle()
                    .fill(emphasis == .minor ? QeetrixColor.borderStrong : QeetrixTimelineMetrics.dotColor(tone))
                    .frame(width: dot, height: dot)
            }
        }
        .frame(width: side, height: side)
        .accessibilityHidden(true)
    }
}

/// Stacks the events with the gap after each one its emphasis asks for, and none after the last — the
/// web's `pb-[--qx-component-timeline-gap] last:pb-0`.
struct QeetrixTimelineLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var height: CGFloat = 0
        var width: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(width: proposal.width, height: nil))
            height += size.height + gap(after: index, of: subviews)
            width = max(width, size.width)
        }
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            subview.place(at: CGPoint(x: bounds.minX, y: y), proposal: ProposedViewSize(width: bounds.width, height: size.height))
            y += size.height + gap(after: index, of: subviews)
        }
    }

    func gap(after index: Int, of subviews: Subviews) -> CGFloat {
        guard index < subviews.count - 1 else { return 0 }
        return subviews[index][QeetrixTimelineEmphasisKey.self] == .minor ? QeetrixTimelineTokens.gapMinor : QeetrixTimelineTokens.gap
    }
}

struct QeetrixTimelineEmphasisKey: LayoutValueKey {
    static let defaultValue = QeetrixTimelineEmphasis.default
}

/// The markers' frames, in order, for the connectors between them.
struct QeetrixTimelineMarkersKey: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

enum QeetrixTimelineMetrics {
    /// `text-sm font-medium text-foreground`.
    static let titleType = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
    /// A minor event's title: `font-normal text-muted-foreground`.
    static let minorTitleType = QeetrixComponentType.ui(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
    /// `text-xs text-muted-foreground tabular-nums`.
    static let timeType = QeetrixComponentType.ui(QeetrixWebScale.textXS, .regular, scalesLike: .caption)
    /// `text-sm text-muted-foreground`.
    static let descriptionType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)

    /// `DOT_TONE`: graphics of at least 3:1 on every surface.
    static func dotColor(_ tone: QeetrixTimelineTone) -> QeetrixColor {
        switch tone {
        case .neutral: .textTertiary  // bg-muted-foreground
        case .brand: .actionPrimary  // bg-primary
        case .info: .feedbackInfo
        case .success: .feedbackSuccess
        case .warning: .feedbackWarning
        case .destructive: .feedbackError
        }
    }

    /// `ICON_TONE`: the edge, the tint laid over the surface, and the icon's colour.
    static func iconColors(_ tone: QeetrixTimelineTone) -> (border: QeetrixColor, tint: QeetrixColor, foreground: QeetrixColor) {
        switch tone {
        case .neutral: (.borderDefault, .surfaceSunken, .textTertiary)
        case .brand: (.borderBrand, .surfaceBrandSubtle, .textBrand)
        case .info: (.borderInfo, .feedbackInfoSubtle, .textInfo)
        case .success: (.borderSuccess, .feedbackSuccessSubtle, .textSuccess)
        case .warning: (.borderWarning, .feedbackWarningSubtle, .textWarning)
        case .destructive: (.borderDanger, .feedbackErrorSubtle, .textDanger)
        }
    }
}
