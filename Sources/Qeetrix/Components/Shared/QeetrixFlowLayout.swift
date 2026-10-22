import SwiftUI

/// Lays children out in rows that wrap — the web's `flex flex-wrap gap-*`, for chips and for actions
/// that reflow at large text sizes. Rows start at the leading edge, or are centred; SwiftUI mirrors
/// the placement in right-to-left layouts, as it does for its own stacks.
struct QeetrixFlowLayout: Layout {
    enum RowAlignment {
        case leading, center
    }

    var spacing: CGFloat
    var alignment: RowAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(subviews, width: bounds.width)
        for (index, frame) in arrangement.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    /// Each child at its ideal size, no wider than the row; rows break before a child that would overflow.
    func arrange(_ subviews: Subviews, width: CGFloat) -> (frames: [CGRect], size: CGSize) {
        var rows: [[(index: Int, size: CGSize)]] = [[]]
        var rowWidth: CGFloat = 0
        for (index, subview) in subviews.enumerated() {
            var size = subview.sizeThatFits(.unspecified)
            if size.width > width {
                size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            let needed = rows[rows.count - 1].isEmpty ? size.width : rowWidth + spacing + size.width
            if needed > width && !rows[rows.count - 1].isEmpty {
                rows.append([(index, size)])
                rowWidth = size.width
            } else {
                rows[rows.count - 1].append((index, size))
                rowWidth = needed
            }
        }

        var frames = [CGRect](repeating: .zero, count: subviews.count)
        var y: CGFloat = 0
        var widest: CGFloat = 0
        for row in rows where !row.isEmpty {
            let used = row.map(\.size.width).reduce(0, +) + spacing * CGFloat(row.count - 1)
            let height = row.map(\.size.height).max() ?? 0
            var x = alignment == .center && width.isFinite ? max(0, (width - used) / 2) : 0
            for item in row {
                frames[item.index] = CGRect(x: x, y: y + (height - item.size.height) / 2, width: item.size.width, height: item.size.height)
                x += item.size.width + spacing
            }
            widest = max(widest, used)
            y += height + spacing
        }
        let height = max(0, y - spacing)
        return (frames, CGSize(width: width.isFinite && alignment == .center ? width : widest, height: subviews.isEmpty ? 0 : height))
    }
}
