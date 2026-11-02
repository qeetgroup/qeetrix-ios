import SwiftUI

/// How a task stands, as `@qeetrix/react`'s Progress `tone`.
public enum QeetrixProgressTone: String, CaseIterable, Sendable {
    /// While it runs, the default.
    case brand
    /// Once it's done.
    case success
    /// If it failed.
    case danger

    var indicator: QeetrixColor {
        switch self {
        case .brand: .bgBrandBold
        case .success: .bgSuccessBold
        case .danger: .bgDangerBold
        }
    }
}

/// A task advancing — an upload, an import — as `@qeetrix/react`'s Progress: a label and, with
/// `showsValue`, the percentage above a 4 pt square-ended track (`color.border.default`, in dark
/// `color.surface.sunken`) with the tone's indicator.
///
/// ```swift
/// QeetrixProgress("Uploading invoices", value: 0.4, showsValue: true)
/// QeetrixProgress("Import failed", value: 0.62, tone: .danger)
/// QeetrixProgress("Preparing export", value: nil)  // indeterminate
/// ```
///
/// `value` is a fraction of `total`; `nil` means the total isn't known, and a 30%-wide segment slides
/// along the track every 1.6 s. Under Reduce Motion the segment spans the track and fades instead, so
/// the wait stays visible. VoiceOver reads it as the system's progress indicator, with its label and
/// percentage. ``QeetrixProgressViewStyle`` styles any `ProgressView` the same way.
public struct QeetrixProgress: View {
    let label: Text?
    let value: Double?
    let total: Double
    let tone: QeetrixProgressTone
    let showsValue: Bool

    public init(
        _ titleKey: LocalizedStringKey, value: Double?, total: Double = 1, tone: QeetrixProgressTone = .brand, showsValue: Bool = false
    ) {
        self.init(label: Text(titleKey), value: value, total: total, tone: tone, showsValue: showsValue)
    }

    public init<S: StringProtocol>(
        _ title: S, value: Double?, total: Double = 1, tone: QeetrixProgressTone = .brand, showsValue: Bool = false
    ) {
        self.init(label: Text(title), value: value, total: total, tone: tone, showsValue: showsValue)
    }

    public init(label: Text?, value: Double?, total: Double = 1, tone: QeetrixProgressTone = .brand, showsValue: Bool = false) {
        self.label = label
        self.value = value
        self.total = total
        self.tone = tone
        self.showsValue = showsValue
    }

    public var body: some View {
        if let label {
            ProgressView(value: value, total: total) { label }
                .progressViewStyle(QeetrixProgressViewStyle(tone: tone, showsValue: showsValue))
        } else {
            ProgressView(value: value, total: total)
                .progressViewStyle(QeetrixProgressViewStyle(tone: tone, showsValue: showsValue))
        }
    }
}

/// The Qeetrix progress look for any `ProgressView`.
public struct QeetrixProgressViewStyle: ProgressViewStyle {
    let tone: QeetrixProgressTone
    let showsValue: Bool

    public init(tone: QeetrixProgressTone = .brand, showsValue: Bool = false) {
        self.tone = tone
        self.showsValue = showsValue
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixProgressBody(configuration: configuration, tone: tone, showsValue: showsValue)
    }
}

extension ProgressViewStyle where Self == QeetrixProgressViewStyle {
    /// The Qeetrix progress style.
    public static func qeetrix(tone: QeetrixProgressTone = .brand, showsValue: Bool = false) -> QeetrixProgressViewStyle {
        QeetrixProgressViewStyle(tone: tone, showsValue: showsValue)
    }
}

struct QeetrixProgressBody: View {
    let configuration: ProgressViewStyleConfiguration
    let tone: QeetrixProgressTone
    let showsValue: Bool
    @Environment(\.locale) private var locale

    var body: some View {
        let fraction = configuration.fractionCompleted.map { min(max($0, 0), 1) }
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            if configuration.label != nil || (showsValue && fraction != nil) {
                HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapMd) {
                    configuration.label
                        .qeetrixTextStyle(.labelSm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showsValue, let fraction {
                        Text(Self.percent(fraction, locale: locale))
                            .qeetrixTextStyle(.labelSm)
                            .monospacedDigit()
                            .foregroundStyle(QeetrixColor.textDefault)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            QeetrixProgressTrack(fraction: fraction, indicator: tone.indicator)
        }
        // VoiceOver gets the native control: a progress indicator with its label and percentage, or —
        // while the total is unknown — an activity indicator with its label and no percentage.
        .accessibilityRepresentation {
            if let fraction {
                ProgressView(value: fraction) { configuration.label }
                    .progressViewStyle(.linear)
            } else {
                ProgressView { configuration.label }
                    .progressViewStyle(.circular)
            }
        }
    }

    static func percent(_ fraction: Double, locale: Locale) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)).locale(locale))
    }
}

/// The 4 pt track and its indicator (progress.css). Square ends: Qeetrix rounds only people and
/// status.
struct QeetrixProgressTrack: View {
    let fraction: Double?
    let indicator: QeetrixColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    static let height: CGFloat = 4

    /// `--qx-progress-track`: `color.border.default` in light, `color.surface.sunken` in dark, so every
    /// tone's indicator keeps 3:1 against it (QTRX-176).
    static func track(_ colorScheme: ColorScheme) -> QeetrixColor {
        colorScheme == .dark ? .surfaceSunken : .borderDefault
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Self.track(colorScheme))
            if let fraction {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(indicator)
                        .frame(width: proxy.size.width * fraction)
                        .qeetrixAnimation(.standard, .normal, value: fraction)
                }
            } else if reduceMotion {
                QeetrixProgressFade(indicator: indicator)
            } else {
                QeetrixProgressSlide(indicator: indicator)
            }
        }
        .frame(height: Self.height)
        .clipped()
        .flipsForRightToLeftLayoutDirection(true)
    }
}

/// The indeterminate segment: 30% of the track, sliding from just before its start to past its end
/// (`translate: -100%` → `334%` of its own width) every `4 × motion.duration.slower`, eased
/// `standard`.
private struct QeetrixProgressSlide: View {
    let indicator: QeetrixColor
    @State private var isSliding = false

    static let period = 4 * QeetrixDuration.slower.seconds

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * 0.3
            Rectangle()
                .fill(indicator)
                .frame(width: width)
                .offset(x: isSliding ? width * 3.34 : -width)
                .animation(
                    isSliding
                        ? QeetrixEasing.standard.animation(duration: QeetrixDuration(seconds: Self.period)).repeatForever(
                            autoreverses: false) : nil,
                    value: isSliding)
        }
        .onAppear { isSliding = true }
    }
}

/// Under Reduce Motion: the whole track's width, fading to 35% and back every 1.6 s.
private struct QeetrixProgressFade: View {
    let indicator: QeetrixColor
    @State private var isFaded = false

    var body: some View {
        Rectangle()
            .fill(indicator)
            .opacity(isFaded ? 0.35 : 1)
            .animation(isFaded ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : nil, value: isFaded)
            .onAppear { isFaded = true }
    }
}
