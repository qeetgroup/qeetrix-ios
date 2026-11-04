import SwiftUI

/// The outline of a ``QeetrixSkeleton``, as `@qeetrix/react`'s `SkeletonVariant`.
public enum QeetrixSkeletonVariant: String, CaseIterable, Sendable {
    /// One line of text: a `body.md` line tall, the full width, 2 pt corners. The default.
    case text
    /// A card, an image or a chart: 64 pt tall, the full width, `radius.surface` corners.
    case block
    /// An avatar: a circle of the avatar's sizes (``QeetrixSkeletonSize``).
    case circle
}

/// A circle skeleton's diameter, as `@qeetrix/react`'s `SkeletonSize` — ``QeetrixAvatarSize``'s sizes.
public enum QeetrixSkeletonSize: String, CaseIterable, Sendable {
    /// 24 pt.
    case sm
    /// 32 pt, the default.
    case md
    /// 40 pt.
    case lg
    /// 48 pt.
    case xl

    /// skeleton.css: `[data-variant="circle"]` 32px; `[data-size="sm"]` 24px, `"lg"` 40px, `"xl"` 48px.
    public var points: CGFloat {
        switch self {
        case .sm: 24
        case .md: 32
        case .lg: 40
        case .xl: 48
        }
    }
}

/// A placeholder shaped like the content that is loading, as `@qeetrix/react`'s Skeleton: a
/// `color.bg.neutral.subtle-pressed` shape whose opacity pulses to 45% and back, 1.6 s each way
/// (4 × `motion.duration.slower`, `motion.easing.standard`), and stands still under Reduce Motion.
///
/// ```swift
/// HStack(spacing: QeetrixSpace.gapMd) {
///     QeetrixSkeleton(.circle, size: .lg)
///     QeetrixSkeleton(lines: 2)
/// }
/// .qeetrixSkeletonGroup()
/// ```
///
/// A `text` or `block` skeleton takes the width it is offered — narrow it with `frame(width:)` — and
/// `height` replaces its default height; a circle is `size` across. For a paragraph, use
/// ``init(lines:role:)``. VoiceOver never sees a skeleton: put `qeetrixSkeletonGroup(label:)` on the
/// view that holds them, so the region says once that it is loading, as the web's `aria-busy` region
/// with its spinner or text does.
public struct QeetrixSkeleton: View {
    let shape: QeetrixSkeletonShape

    /// A line, a block or a circle.
    ///
    /// - Parameters:
    ///   - variant: The outline: `text` by default.
    ///   - size: A circle's diameter; the other variants ignore it.
    ///   - height: A `text` or `block` skeleton's height, to match what will arrive; `nil` for a line of
    ///     `body.md` or 64 pt. A circle ignores it.
    public init(_ variant: QeetrixSkeletonVariant = .text, size: QeetrixSkeletonSize = .md, height: CGFloat? = nil) {
        shape = .single(variant, size, height)
    }

    /// A paragraph of `lines` placeholder lines in `role`, as `@qeetrix/react`'s `lines`: bars as tall as
    /// the role's text, centred in its lines, the last one 60% wide. It takes the lines' height exactly,
    /// so the text that replaces it moves nothing below.
    ///
    /// - Parameters:
    ///   - lines: How many lines; at least one is drawn.
    ///   - role: The text the lines stand in for, `body.md` by default. The bars grow with Dynamic Type,
    ///     as that text will.
    public init(lines: Int, role: QeetrixTextRole = .bodyMd) {
        shape = .lines(max(1, lines), role)
    }

    public var body: some View {
        Group {
            switch shape {
            case let .single(variant, size, height):
                QeetrixSkeletonSingle(variant: variant, size: size, height: height)
            case let .lines(count, role):
                QeetrixSkeletonLines(count: count, role: role)
            }
        }
        .modifier(QeetrixSkeletonPulse())
        .accessibilityHidden(true)  // aria-hidden
    }
}

extension View {
    /// Makes this view — the skeletons standing in for content — one VoiceOver element that says the
    /// content is loading: "Loading" unless you give a `label`, such as "Loading accounts". The web marks
    /// the region `aria-busy` and announces the wait with a spinner or text; the skeletons themselves are
    /// hidden either way.
    public func qeetrixSkeletonGroup(label: Text? = nil) -> some View {
        modifier(QeetrixSpinnerAccessibility(label: label, isDecorative: false))
    }
}

/// What a ``QeetrixSkeleton`` draws.
enum QeetrixSkeletonShape: Equatable {
    case single(QeetrixSkeletonVariant, QeetrixSkeletonSize, CGFloat?)
    case lines(Int, QeetrixTextRole)
}

enum QeetrixSkeletonMetrics {
    /// skeleton.css: `.qx-skeleton[data-variant="block"] { block-size: 64px }`.
    static let blockHeight: CGFloat = 64
    /// `.qx-skeleton-lines > .qx-skeleton:last-child:not(:first-child) { inline-size: 60% }`.
    static let lastLineFraction: CGFloat = 0.6
    /// `@keyframes qx-skeleton-pulse { to { opacity: .45 } }`.
    static let pulseOpacity: Double = 0.45
    /// `animation-duration: calc(4 * var(--qx-motion-duration-slower))`, each way (`alternate`).
    static let pulse = QeetrixDuration(seconds: 4 * QeetrixDuration.slower.seconds)

    /// The fill: `color.bg.neutral.subtle-pressed`.
    static let fill = QeetrixColor.bgNeutralSubtlePressed

    /// The corners: `radius.sm` for text, `radius.surface` for a block, `radius.full` for a circle.
    static func radius(_ variant: QeetrixSkeletonVariant) -> CGFloat {
        switch variant {
        case .text: QeetrixRadius.sm
        case .block: QeetrixRadius.surface
        case .circle: QeetrixRadius.full
        }
    }

    /// A paragraph's geometry for a role at a scaled size: each bar 1em tall, the bars `1lh − 1em` apart
    /// with half that above the first and below the last (`.qx-skeleton-lines`).
    static func lines(count: Int, em: CGFloat, lineHeight: CGFloat) -> (bar: CGFloat, gap: CGFloat, height: CGFloat) {
        let gap = max(0, lineHeight - em)
        return (em, gap, CGFloat(count) * lineHeight)
    }
}

/// One line, block or circle.
struct QeetrixSkeletonSingle: View {
    let variant: QeetrixSkeletonVariant
    let size: QeetrixSkeletonSize
    let height: CGFloat?
    /// `block-size: 1lh` of `body.md`, growing with Dynamic Type as the text will.
    @ScaledMetric(relativeTo: QeetrixTextRole.bodyMd.textStyle) private var line = QeetrixSkeletonSingle.bodyLine

    static let bodyLine = QeetrixTextRole.bodyMd.tokens.size * CGFloat(QeetrixTextRole.bodyMd.tokens.lineHeight)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixSkeletonMetrics.radius(variant))
        switch variant {
        case .text:
            shape.fill(QeetrixSkeletonMetrics.fill).frame(maxWidth: .infinity).frame(height: height ?? line)
        case .block:
            shape.fill(QeetrixSkeletonMetrics.fill).frame(maxWidth: .infinity).frame(height: height ?? QeetrixSkeletonMetrics.blockHeight)
        case .circle:
            Circle().fill(QeetrixSkeletonMetrics.fill).frame(width: size.points, height: size.points)
        }
    }
}

/// A paragraph of bars (`.qx-skeleton-lines`).
struct QeetrixSkeletonLines: View {
    let count: Int
    let role: QeetrixTextRole
    @ScaledMetric private var em: CGFloat

    init(count: Int, role: QeetrixTextRole) {
        self.count = count
        self.role = role
        _em = ScaledMetric(wrappedValue: role.tokens.size, relativeTo: role.textStyle)
    }

    var body: some View {
        let metrics = QeetrixSkeletonMetrics.lines(count: count, em: em, lineHeight: em * CGFloat(role.tokens.lineHeight))
        VStack(alignment: .leading, spacing: metrics.gap) {
            ForEach(0..<count, id: \.self) { index in
                let isShort = count > 1 && index == count - 1
                QeetrixSkeletonFractionLayout(fraction: isShort ? QeetrixSkeletonMetrics.lastLineFraction : 1) {
                    RoundedRectangle(cornerRadius: QeetrixRadius.sm)
                        .fill(QeetrixSkeletonMetrics.fill)
                        .frame(height: metrics.bar)
                }
            }
        }
        .padding(.vertical, metrics.gap / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Sizes a bar to a fraction of the width it is offered, from the start of the line.
struct QeetrixSkeletonFractionLayout: Layout {
    let fraction: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.first?.sizeThatFits(.unspecified).height ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            proposal: ProposedViewSize(width: bounds.width * fraction, height: bounds.height))
    }
}

/// The pulse: opacity to 45% and back, each way over 1.6 s on `motion.easing.standard`, for as long as
/// the skeleton is on screen. Under Reduce Motion the durations are 0 (tokens.css), so it stands still at
/// full opacity. Each mode owns its animation, so switching Reduce Motion restarts the right one, and a
/// snapshot or a first frame is drawn at rest.
struct QeetrixSkeletonPulse: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.modifier(Pulsing())
        }
    }

    struct Pulsing: ViewModifier {
        @State private var isDimmed = false

        func body(content: Content) -> some View {
            content
                .opacity(isDimmed ? QeetrixSkeletonMetrics.pulseOpacity : 1)
                .animation(
                    isDimmed
                        ? QeetrixEasing.standard.animation(duration: QeetrixSkeletonMetrics.pulse).repeatForever(autoreverses: true) : nil,
                    value: isDimmed
                )
                .onAppear { isDimmed = true }
        }
    }
}
