import SwiftUI

/// The sizes of ``QeetrixCircularProgress``: the icon sizes, by ``QeetrixSpinnerSize``'s names, so a
/// ring and a spinner of one size are the same size.
public enum QeetrixCircularProgressSize: String, CaseIterable, Sendable {
    /// 14 pt.
    case sm
    /// 16 pt, the default.
    case md
    /// 20 pt.
    case lg
    /// 24 pt.
    case xl

    /// The ring's width and height (`size.icon.xs` … `lg`).
    public var iconSize: QeetrixIconSize {
        switch self {
        case .sm: .xs
        case .md: .sm
        case .lg: .md
        case .xl: .lg
        }
    }
}

/// How the value stands: ``QeetrixProgressTone``'s tones, and `warning`, as `@qeetrix/react`'s Meter
/// has it.
public enum QeetrixCircularProgressTone: String, CaseIterable, Sendable {
    /// While it runs, the default (`color.bg.brand.bold`).
    case brand
    /// Once it's done (`color.bg.success.bold`).
    case success
    /// Nearly out, such as a one-time code in its last seconds: `color.border.warning` in light and
    /// `color.bg.warning.bold` in dark (`--qx-progress-warning`), which keep 3:1 against the track
    /// where the bold amber in light does not.
    case warning
    /// If it failed (`color.bg.danger.bold`).
    case danger

    /// The indicator's colour in a colour scheme (progress.css `[data-tone] .qx-progress-indicator`).
    func indicator(_ colorScheme: ColorScheme) -> QeetrixColor {
        switch self {
        case .brand: .bgBrandBold
        case .success: .bgSuccessBold
        case .warning: colorScheme == .dark ? .bgWarningBold : .borderWarning
        case .danger: .bgDangerBold
        }
    }
}

/// A value as a ring — the seconds left on a one-time code, an upload beside a file name — the circular
/// counterpart of ``QeetrixProgress``. `@qeetrix/react` has no circular progress; the ring takes the
/// linear one's track and tones and the spinner's sizes and 2 pt line.
///
/// ```swift
/// QeetrixCircularProgress(value: 0.4, label: Text("Uploading invoice.pdf"))
/// QeetrixCircularProgress(
///     timerInterval: period, size: .lg, tone: secondsLeft <= 5 ? .warning : .brand,
///     label: Text("Time left on this code"), currentValueLabel: Text("\(secondsLeft) seconds left"))
/// ```
///
/// - **Look:** a 2 pt ring (spinner.css) of the progress track — `color.border.default` in light,
///   `color.surface.sunken` in dark — with the tone's indicator running clockwise from twelve o'clock
///   to `value`, square-ended as the bar is. It reads like a clock face, so it doesn't mirror in right to
///   left. It scales with Dynamic Type, as an icon does.
/// - **Motion:** a new `value` moves over `motion.duration.normal`, eased `standard`, as the bar does.
///   The `timerInterval` form follows the clock itself: smoothly, frame by frame, and under Reduce Motion
///   in one step a second, on the second.
/// - **VoiceOver** reads it as the system's progress indicator: `label`, then `currentValueLabel` as
///   its value ("12 seconds left") — or, without one, the percentage, or the time left on a timer.
///
/// `value` is a fraction of `total`. ``QeetrixCircularProgressViewStyle`` gives any `ProgressView` the
/// ring; a `ProgressView` without a value shows the spinner's ring in the tone's colour.
public struct QeetrixCircularProgress: View {
    let source: Source
    let size: QeetrixCircularProgressSize
    let tone: QeetrixCircularProgressTone
    let label: Text?
    let currentValueLabel: Text?
    @Environment(\.locale) private var locale

    enum Source: Equatable {
        case value(Double, total: Double)
        case timer(ClosedRange<Date>, countsDown: Bool)
    }

    /// A ring showing `value` out of `total`.
    public init(
        value: Double, total: Double = 1, size: QeetrixCircularProgressSize = .md, tone: QeetrixCircularProgressTone = .brand,
        label: Text? = nil, currentValueLabel: Text? = nil
    ) {
        self.source = .value(value, total: total)
        self.size = size
        self.tone = tone
        self.label = label
        self.currentValueLabel = currentValueLabel
    }

    /// A ring that follows the clock through `timerInterval`: emptying as it runs out with
    /// `countsDown` (the default), or filling.
    public init(
        timerInterval: ClosedRange<Date>, countsDown: Bool = true, size: QeetrixCircularProgressSize = .md,
        tone: QeetrixCircularProgressTone = .brand, label: Text? = nil, currentValueLabel: Text? = nil
    ) {
        self.source = .timer(timerInterval, countsDown: countsDown)
        self.size = size
        self.tone = tone
        self.label = label
        self.currentValueLabel = currentValueLabel
    }

    public var body: some View {
        switch source {
        case let .value(value, total):
            ring(fraction: total > 0 ? value / total : 0, animates: true, valueLabel: currentValueLabel)
        case let .timer(interval, countsDown):
            QeetrixCircularProgressTimeline(interval: interval) { date in
                ring(
                    fraction: Self.fraction(at: date, in: interval, countsDown: countsDown), animates: false,
                    valueLabel: currentValueLabel ?? Text(Self.timeText(at: date, in: interval, countsDown: countsDown, locale: locale)))
            }
            .accessibilityAddTraits(.updatesFrequently)
        }
    }

    private func ring(fraction: Double, animates: Bool, valueLabel: Text?) -> some View {
        ProgressView(value: min(max(fraction, 0), 1)) {
            label
        }
        .progressViewStyle(QeetrixCircularProgressViewStyle(size: size, tone: tone, animatesChanges: animates))
        .modifier(QeetrixCircularProgressValue(text: valueLabel))
    }

    /// How full the ring is at `date`: the share of `interval` still to run, or with `countsDown` off
    /// the share gone.
    static func fraction(at date: Date, in interval: ClosedRange<Date>, countsDown: Bool) -> Double {
        let length = interval.upperBound.timeIntervalSince(interval.lowerBound)
        guard length > 0 else { return countsDown ? 0 : 1 }
        let elapsed = min(max(date.timeIntervalSince(interval.lowerBound) / length, 0), 1)
        return countsDown ? 1 - elapsed : elapsed
    }

    /// The time left (or gone) in whole seconds, in words for the locale ("12 seconds"): what VoiceOver
    /// reads when the app gives no `currentValueLabel`.
    static func timeText(at date: Date, in interval: ClosedRange<Date>, countsDown: Bool, locale: Locale) -> String {
        let reference = countsDown ? interval.upperBound.timeIntervalSince(date) : date.timeIntervalSince(interval.lowerBound)
        let length = interval.upperBound.timeIntervalSince(interval.lowerBound)
        let seconds = Int(min(max(reference, 0), max(length, 0)).rounded(countsDown ? .up : .down))
        return Duration.seconds(seconds).formatted(.units(allowed: [.minutes, .seconds], width: .wide).locale(locale))
    }
}

/// The app's words for the value, replacing the percentage VoiceOver would read.
private struct QeetrixCircularProgressValue: ViewModifier {
    let text: Text?

    func body(content: Content) -> some View {
        if let text { content.accessibilityValue(text) } else { content }
    }
}

/// The clock a timer ring follows: every frame, or under Reduce Motion once a second from the start of
/// its interval, so each step lands on a whole second of the countdown.
struct QeetrixCircularProgressTimeline<Content: View>: View {
    let interval: ClosedRange<Date>
    @ViewBuilder let content: (Date) -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            TimelineView(Self.reducedSchedule(for: interval)) { context in content(context.date) }
        } else {
            TimelineView(.animation(minimumInterval: nil, paused: Date() >= interval.upperBound)) { context in content(context.date) }
        }
    }

    static func reducedSchedule(for interval: ClosedRange<Date>) -> PeriodicTimelineSchedule {
        .periodic(from: interval.lowerBound, by: 1)
    }
}

/// The ring look for any `ProgressView`: ``QeetrixCircularProgress``'s track and indicator, or for a
/// `ProgressView` without a value the spinner's turning ring, in the tone's colour.
public struct QeetrixCircularProgressViewStyle: ProgressViewStyle {
    let size: QeetrixCircularProgressSize
    let tone: QeetrixCircularProgressTone
    var animatesChanges = true

    /// The ring in a size and tone.
    public init(size: QeetrixCircularProgressSize = .md, tone: QeetrixCircularProgressTone = .brand) {
        self.size = size
        self.tone = tone
    }

    init(size: QeetrixCircularProgressSize, tone: QeetrixCircularProgressTone, animatesChanges: Bool) {
        self.size = size
        self.tone = tone
        self.animatesChanges = animatesChanges
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixCircularProgressBody(configuration: configuration, size: size, tone: tone, animatesChanges: animatesChanges)
    }
}

extension ProgressViewStyle where Self == QeetrixCircularProgressViewStyle {
    /// The Qeetrix ring style.
    public static func qeetrixCircular(
        size: QeetrixCircularProgressSize = .md, tone: QeetrixCircularProgressTone = .brand
    ) -> QeetrixCircularProgressViewStyle {
        QeetrixCircularProgressViewStyle(size: size, tone: tone)
    }
}

struct QeetrixCircularProgressBody: View {
    let configuration: ProgressViewStyleConfiguration
    let tone: QeetrixCircularProgressTone
    let animatesChanges: Bool
    @ScaledMetric private var side: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    private let baseSide: CGFloat

    init(
        configuration: ProgressViewStyleConfiguration, size: QeetrixCircularProgressSize, tone: QeetrixCircularProgressTone,
        animatesChanges: Bool
    ) {
        self.configuration = configuration
        self.tone = tone
        self.animatesChanges = animatesChanges
        baseSide = size.iconSize.points
        _side = ScaledMetric(wrappedValue: size.iconSize.points, relativeTo: .body)
    }

    var body: some View {
        if let fraction = configuration.fractionCompleted.map({ min(max($0, 0), 1) }) {
            let lineWidth = QeetrixCircularProgressRing.width * side / baseSide
            QeetrixCircularProgressRing(fraction: fraction, side: side, lineWidth: lineWidth, tone: tone)
                .qeetrixAnimation(.standard, animatesChanges ? .normal : .instant, value: fraction)
                // VoiceOver gets the native control: a progress indicator with its label and value.
                .accessibilityRepresentation {
                    ProgressView(value: fraction) { configuration.label }
                        .progressViewStyle(.linear)
                }
        } else {
            QeetrixSpinnerRing(side: side)
                .foregroundStyle(tone.indicator(colorScheme))
                .accessibilityRepresentation {
                    ProgressView { configuration.label }
                        .progressViewStyle(.circular)
                }
        }
    }
}

/// The ring: the progress track all the way round, and the indicator from twelve o'clock clockwise to
/// `fraction`, with square ends.
struct QeetrixCircularProgressRing: View {
    let fraction: Double
    let side: CGFloat
    let lineWidth: CGFloat
    let tone: QeetrixCircularProgressTone
    @Environment(\.colorScheme) private var colorScheme

    /// spinner.css: `.qx-spinner { border: 2px solid }`, at the icon size; it scales with the ring.
    static let width: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(QeetrixProgressTrack.track(colorScheme), lineWidth: lineWidth)
            QeetrixCircularProgressArc(fraction: fraction, inset: lineWidth / 2)
                .stroke(tone.indicator(colorScheme), style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
        }
        .frame(width: side, height: side)
        // A clock face turns clockwise in every language; SwiftUI would mirror the shapes in right to left.
        .environment(\.layoutDirection, .leftToRight)
    }
}

/// The indicator's arc, from twelve o'clock clockwise; it animates between fractions.
struct QeetrixCircularProgressArc: Shape {
    var fraction: Double
    let inset: CGFloat

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard fraction > 0 else { return path }
        // Angles grow clockwise on screen; `clockwise: false` is clockwise in y-down coordinates.
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY), radius: min(rect.width, rect.height) / 2 - inset,
            startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * min(fraction, 1)), clockwise: false)
        return path
    }
}
