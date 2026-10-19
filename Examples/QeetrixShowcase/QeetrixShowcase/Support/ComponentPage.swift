import Qeetrix
import SwiftUI

/// The frame every component page shares: a summary, then sections of examples, on the canvas.
struct ComponentPage<Content: View>: View {
    let title: String
    let summary: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.xl2) {
                QeetrixText(summary, variant: .lead)
                content
            }
            .padding(QeetrixSpacing.l)
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
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            QeetrixText(title, variant: .h3)
            content
        }
    }
}

/// Lays children out in rows that wrap, so a row of buttons or badges reflows at large text sizes.
struct FlowLayout: Layout {
    var spacing: CGFloat = QeetrixSpacing.s

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (index, origin) in arrange(subviews, width: bounds.width).origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> (origins: [CGPoint], size: CGSize) {
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return (origins, CGSize(width: maxX, height: y + lineHeight))
    }
}
