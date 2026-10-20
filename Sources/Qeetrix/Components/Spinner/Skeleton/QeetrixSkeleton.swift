import SwiftUI

/// The outline of a ``QeetrixSkeleton``.
public enum QeetrixSkeletonShape: String, CaseIterable, Sendable {
    /// A block with the control corner (`rounded-md`): a thumbnail, a button, a line of text.
    case rectangle
    /// A circle: an avatar.
    case circle
    /// A pill (`rounded-full`): a badge or a chip.
    case capsule
}

/// A placeholder for content that is loading — the web's `Skeleton`. Size it with `frame(width:height:)`,
/// and compose several in the shape of what will arrive.
///
/// ```swift
/// HStack(spacing: 12) {
///     QeetrixSkeleton(.circle).frame(width: 40, height: 40)
///     QeetrixSkeletonText(lines: 2)
/// }
/// ```
///
/// Its colour is a translucent tint of the foreground (`component.skeleton.background`), so it keeps the
/// same weight on the canvas, a card or a sheet, in both themes. A highlight sweeps across it every
/// 1.6 s, as on the web; with Reduce Motion on it stands still.
///
/// A skeleton is hidden from VoiceOver: it has nothing to say. Say that the region is loading where it
/// is — ``QeetrixDataState`` does, as one "Loading" element — rather than letting each placeholder
/// speak.
public struct QeetrixSkeleton: View {
    let shape: QeetrixSkeletonShape

    /// - Parameter shape: The placeholder's outline.
    public init(_ shape: QeetrixSkeletonShape = .rectangle) {
        self.shape = shape
    }

    public var body: some View {
        Group {
            switch shape {
            case .rectangle: QeetrixSkeletonFill(shape: RoundedRectangle(cornerRadius: QeetrixCorner.chip))  // rounded-md
            case .circle: QeetrixSkeletonFill(shape: Circle())
            case .capsule: QeetrixSkeletonFill(shape: Capsule())
            }
        }
        .accessibilityHidden(true)
    }
}

/// Placeholder lines for a paragraph, each the height of a line of text in a typography role, the last
/// one shorter — so the skeleton takes the room the text will.
///
/// ```swift
/// QeetrixSkeletonText(lines: 3, role: .body)
/// ```
///
/// The lines grow with Dynamic Type, as the text will.
public struct QeetrixSkeletonText: View {
    let lines: Int
    let role: QeetrixTextRole
    @ScaledMetric private var size: CGFloat

    /// - Parameters:
    ///   - lines: How many lines. At least one is drawn.
    ///   - role: The role of the text the lines stand for, which sets their height and spacing.
    public init(lines: Int = 1, role: QeetrixTextRole = .body) {
        self.lines = max(1, lines)
        self.role = role
        _size = ScaledMetric(wrappedValue: role.tokens.size, relativeTo: role.textStyle)
    }

    public var body: some View {
        let metrics = QeetrixSkeletonTextMetrics(size: size, lineHeight: role.tokens.lineHeight)
        VStack(alignment: .leading, spacing: metrics.spacing) {
            ForEach(0..<lines, id: \.self) { line in
                QeetrixFractionalWidth(fraction: line == lines - 1 && lines > 1 ? QeetrixSkeletonTextMetrics.lastLineFraction : 1) {
                    QeetrixSkeleton().frame(height: metrics.barHeight)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }
}

struct QeetrixSkeletonTextMetrics {
    /// A bar the height of the font's size; the rest of the line height is the gap to the next.
    let barHeight: CGFloat
    let spacing: CGFloat
    /// The last line of a paragraph rarely runs the full width.
    static let lastLineFraction: CGFloat = 0.6

    init(size: CGFloat, lineHeight: Double) {
        barHeight = size
        spacing = max(0, size * lineHeight - size)
    }
}

/// Its child at a fraction of the width it is offered, at the leading edge.
struct QeetrixFractionalWidth: Layout {
    let fraction: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = (proposal.width ?? 0) * fraction
        let height = subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
    }
}

/// The placeholder fill with its shimmer, clipped to the shape.
struct QeetrixSkeletonFill<S: Shape>: View {
    let shape: S
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSweeping = false

    var body: some View {
        shape
            .fill(QeetrixSkeletonTokens.background)  // bg-(--qx-component-skeleton-background)
            .overlay {
                if !reduceMotion {
                    GeometryReader { proxy in
                        // A highlight of the foreground at 8 %, swept from -100 % to 100 % of the width.
                        LinearGradient(
                            colors: [.clear, QeetrixColor.textPrimary.color(for: colorScheme).opacity(0.08), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: proxy.size.width)
                        .offset(x: isSweeping ? proxy.size.width : -proxy.size.width)
                    }
                    .clipShape(shape)
                    .onAppear {
                        withAnimation(QeetrixSkeletonMetrics.sweep) { isSweeping = true }
                    }
                    .onDisappear { isSweeping = false }
                }
            }
    }
}

enum QeetrixSkeletonMetrics {
    /// `animation: qx-shimmer 1.6s var(--ease-standard) infinite`.
    static let sweep = QeetrixEasing.standard.animation(duration: QeetrixDuration(seconds: 1.6)).repeatForever(autoreverses: false)
}
