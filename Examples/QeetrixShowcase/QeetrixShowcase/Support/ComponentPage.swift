import Qeetrix
import SwiftUI

/// The frame every component page shares: a summary, then sections of examples, on the canvas.
struct ComponentPage<Content: View>: View {
    let title: String
    let summary: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.layoutMd) {
                QeetrixText(summary, size: .lg, tone: .subtle)
                content
            }
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A titled group of examples.
struct DemoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            QeetrixHeading(title, level: 2, size: .titleMd)
            content
        }
    }
}

/// Lays children out in rows that wrap, so a row of buttons or badges reflows at large text sizes.
struct FlowLayout: Layout {
    var spacing: CGFloat = QeetrixSpace.gapSm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = arrange(subviews, width: bounds.width)
        for (index, origin) in layout.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: ProposedViewSize(layout.sizes[index]))
        }
    }

    /// Each child at its ideal size, except that one wider than the row is offered the row's width, so
    /// at the largest text sizes a long button label wraps instead of pushing the page off screen.
    private func arrange(_ subviews: Subviews, width: CGFloat) -> (origins: [CGPoint], sizes: [CGSize], size: CGSize) {
        var origins: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for subview in subviews {
            var size = subview.sizeThatFits(.unspecified)
            if size.width > width {
                size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            if x > 0 && x + size.width > width {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            sizes.append(size)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return (origins, sizes, CGSize(width: maxX, height: y + lineHeight))
    }
}
