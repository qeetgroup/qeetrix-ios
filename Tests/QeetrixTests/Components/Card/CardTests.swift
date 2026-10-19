import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Card")
struct CardTests {
    private func surface(
        _ variant: QeetrixCardVariant, _ interaction: QeetrixCardSurface<EmptyView, EmptyView>.Interaction
    )
        -> QeetrixCardSurface<EmptyView, EmptyView>
    {
        QeetrixCardSurface(variant: variant, size: .default, isSelected: false, interaction: interaction) {
            EmptyView()
        } footer: {
            nil
        }
    }

    @Test("Padding and gap: 16 pt, 12 pt when small")
    func padding() {
        #expect(QeetrixCardMetrics.padding(.default) == 16)
        #expect(QeetrixCardMetrics.padding(.sm) == 12)
    }

    @Test("Elevation by variant: card tokens for default and elevated, none for outline")
    func elevation() {
        #expect(surface(.default, .none).elevation == QeetrixCardTokens.elevation)
        #expect(surface(.outline, .none).elevation == .flat)
        #expect(surface(.elevated, .none).elevation == QeetrixCardTokens.elevationElevated)
        #expect(surface(.elevated, .none).background == QeetrixCardTokens.backgroundElevated)
        #expect(surface(.default, .none).background == QeetrixCardTokens.background)
    }

    @Test("An interactive card lifts under a pointer and shows the hover boundary while pressed")
    func interaction() {
        #expect(surface(.outline, .hovered).elevation == QeetrixCardTokens.elevationHover)
        #expect(surface(.default, .pressed).elevation == QeetrixCardTokens.elevation)
        #expect(surface(.default, .hovered).border == QeetrixCardTokens.borderHover)
        #expect(surface(.default, .pressed).border == QeetrixCardTokens.borderHover)
        #expect(surface(.default, .resting).border == QeetrixCardTokens.ring)
    }

    @Test("Titles: heading letter style, 16 pt, 14 pt in a small card")
    func titles() {
        #expect(QeetrixCardHeader<EmptyView>.titleType(.default).tokens.size == 16)
        #expect(QeetrixCardHeader<EmptyView>.titleType(.sm).tokens.size == 14)
        #expect(QeetrixCardHeader<EmptyView>.titleType(.default).tokens.weight == .medium)
        #expect(QeetrixCardHeader<EmptyView>.titleType(.default).tokens.geometry == QeetrixTextRole.heading.tokens.geometry)
    }

    @Test("Cards render, with and without a footer, as views and as button styles")
    func renders() {
        #expect(ImageRenderer(content: QeetrixCard { QeetrixCardHeader("Plan", description: "Monthly") }.frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixCard(variant: .elevated, isSelected: true) {
                    Text("Body")
                } footer: {
                    Text("Footer")
                }.frame(width: 300)
            )
            .cgImage != nil)
        #expect(ImageRenderer(content: Button("Open") {}.buttonStyle(.qeetrixCard()).frame(width: 300)).cgImage != nil)
    }
}
