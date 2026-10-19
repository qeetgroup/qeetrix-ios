import SwiftUI

/// The track thicknesses of ``QeetrixProgress``, as on the web: a fixed step, not density-resolved.
public enum QeetrixProgressSize: String, CaseIterable, Sendable {
    /// 4 pt.
    case sm
    /// 8 pt.
    case md
    /// 12 pt.
    case lg

    /// The track's thickness.
    public var trackHeight: CGFloat {
        switch self {
        case .sm: QeetrixWebScale.spacing(1)  // h-1
        case .md: QeetrixWebScale.spacing(2)  // h-2
        case .lg: QeetrixWebScale.spacing(3)  // h-3
        }
    }
}

/// Task progress: a bar, with an optional label and percentage above it.
///
/// ```swift
/// QeetrixProgress("Uploading", value: uploaded, total: size)
/// QeetrixProgress("Preparing export", value: nil)   // the total is unknown
/// ```
///
/// A determinate bar eases to each new value. An indeterminate one (`value: nil`) sends a segment
/// along the track, mirrored in right-to-left layouts; with Reduce Motion on it is a still, hatched
/// fill — busy, not done. VoiceOver reads a native progress indicator with its label and percentage,
/// or, while the total is unknown, an activity indicator with its label. A bar without a label needs
/// `accessibilityLabel(_:)`.
public struct QeetrixProgress: View {
    let label: Text?
    let value: Double?
    let total: Double
    let size: QeetrixProgressSize
    let showsValue: Bool

    /// A bar with a localised label.
    public init(_ titleKey: LocalizedStringKey, value: Double?, total: Double = 1, size: QeetrixProgressSize = .md, showsValue: Bool = true)
    {
        self.init(label: Text(titleKey), value: value, total: total, size: size, showsValue: showsValue)
    }

    /// A bar with a label shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, value: Double?, total: Double = 1, size: QeetrixProgressSize = .md, showsValue: Bool = true)
    {
        self.init(label: Text(title), value: value, total: total, size: size, showsValue: showsValue)
    }

    /// A bar with a `Text` label, or a bare bar when `label` is `nil`.
    ///
    /// - Parameters:
    ///   - label: The caption above the bar, which also names it for VoiceOver; `nil` for a bare bar.
    ///   - value: The amount done, from 0 to `total`; `nil` while the total is unknown.
    ///   - total: The amount that means done.
    ///   - size: The track's thickness.
    ///   - showsValue: With a label, whether the percentage is shown opposite it.
    public init(label: Text?, value: Double?, total: Double = 1, size: QeetrixProgressSize = .md, showsValue: Bool = true) {
        self.label = label
        self.value = value
        self.total = total
        self.size = size
        self.showsValue = showsValue
    }

    public var body: some View {
        if let label {
            ProgressView(value: value, total: total) { label }
                .progressViewStyle(QeetrixProgressViewStyle(size: size, showsValue: showsValue))
        } else {
            ProgressView(value: value, total: total)
                .progressViewStyle(QeetrixProgressViewStyle(size: size, showsValue: showsValue))
        }
    }
}

/// The Qeetrix bar for any `ProgressView`.
///
/// ```swift
/// ProgressView("Syncing", value: synced, total: total)
///     .progressViewStyle(.qeetrix(size: .sm))
/// ```
public struct QeetrixProgressViewStyle: ProgressViewStyle {
    let size: QeetrixProgressSize
    let showsValue: Bool

    /// - Parameters:
    ///   - size: The track's thickness.
    ///   - showsValue: With a label, whether the percentage is shown opposite it.
    public init(size: QeetrixProgressSize = .md, showsValue: Bool = true) {
        self.size = size
        self.showsValue = showsValue
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixProgressBody(configuration: configuration, size: size, showsValue: showsValue)
    }
}

extension ProgressViewStyle where Self == QeetrixProgressViewStyle {
    /// The Qeetrix progress bar.
    public static func qeetrix(size: QeetrixProgressSize = .md, showsValue: Bool = true) -> QeetrixProgressViewStyle {
        QeetrixProgressViewStyle(size: size, showsValue: showsValue)
    }
}

struct QeetrixProgressBody: View {
    let configuration: ProgressViewStyleConfiguration
    let size: QeetrixProgressSize
    let showsValue: Bool
    @Environment(\.locale) private var locale

    var body: some View {
        let fraction = configuration.fractionCompleted.map { min(max($0, 0), 1) }
        VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
            if let label = configuration.label {
                HStack(spacing: QeetrixWebScale.spacing(2)) {  // gap-2
                    label
                        .qeetrixType(Self.labelType)
                        .foregroundStyle(QeetrixColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showsValue, let fraction {
                        Text(Self.percent(fraction, locale: locale))
                            .qeetrixType(Self.valueType)
                            .monospacedDigit()  // tabular-nums
                            .foregroundStyle(QeetrixColor.textTertiary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            QeetrixProgressTrack(fraction: fraction, height: size.trackHeight)
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

    /// `text-sm font-medium`.
    static let labelType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
    /// `text-sm`.
    static let valueType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)

    /// The percentage the web's progress value shows: whole percent, formatted for the locale.
    static func percent(_ fraction: Double, locale: Locale) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)).locale(locale))
    }
}

struct QeetrixProgressTrack: View {
    let fraction: Double?
    let height: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(QeetrixProgressTokens.track)
            if let fraction {
                GeometryReader { proxy in
                    Capsule()
                        .fill(QeetrixProgressTokens.indicator)
                        .frame(width: proxy.size.width * fraction)
                        .qeetrixAnimation(.standard, .slow, value: fraction)  // duration-slow ease-standard
                }
            } else if reduceMotion {
                QeetrixProgressHatch().fill(QeetrixProgressTokens.indicator)
            } else {
                QeetrixProgressSweep()
            }
        }
        .frame(height: height)
        .clipShape(Capsule())  // rounded-full overflow-hidden
    }
}

/// The indeterminate segment: 40% of the track, from just off its start (-40%) to just off its end
/// (+100%) in 1.4 s, linear — the web's `translate-x-[250%]` composed with
/// `slide-in-from-start-[350%]`, so it moves one track width a second.
///
/// It is a shape the size of the track that draws the segment at its phase, rather than a moved view:
/// an offset view would stretch the bar's accessibility frame beyond the track.
private struct QeetrixProgressSweep: View {
    @State private var travelled = false

    var body: some View {
        QeetrixProgressSegment(phase: travelled ? 1 : 0)
            .fill(QeetrixProgressTokens.indicator)
            .animation(travelled ? .linear(duration: 1.4).repeatForever(autoreverses: false) : nil, value: travelled)
            .flipsForRightToLeftLayoutDirection(true)
            .onAppear { travelled = true }
    }
}

/// A rounded segment 40% of the rect wide, its leading edge at `-40% + 140% × phase` of the width, cut to
/// the rect — so the path, and with it the bar's VoiceOver frame, never reaches past the track. The track
/// clips to its capsule anyway, so the cut is invisible.
struct QeetrixProgressSegment: Shape {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width * 0.4  // w-2/5
        let x = rect.minX + rect.width * (-0.4 + 1.4 * phase)
        let segment = CGRect(x: x, y: rect.minY, width: width, height: rect.height).intersection(rect)
        guard !segment.isNull, segment.width > 1e-6 else { return Path() }  // floating point leaves slivers at the ends
        return Path(roundedRect: segment, cornerRadius: min(rect.height, segment.width) / 2)
    }
}

/// `repeating-linear-gradient(-45deg, fill 0 4px, transparent 4px 8px)`: 4 pt bands every 8 pt,
/// rising from the lower left.
struct QeetrixProgressHatch: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let period: CGFloat = 8
        let band: CGFloat = 4
        // Bands are lines x + y = c (screen coordinates), measured along the (1, 1) diagonal.
        let span = (rect.width + rect.height) * 2.squareRoot()
        var offset: CGFloat = -rect.height * 2.squareRoot()
        while offset < span {
            let a = offset * 2.squareRoot()
            let b = (offset + band) * 2.squareRoot()
            path.move(to: CGPoint(x: rect.minX + a, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + b, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + b - rect.height, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + a - rect.height, y: rect.maxY))
            path.closeSubpath()
            offset += period
        }
        return path
    }
}
