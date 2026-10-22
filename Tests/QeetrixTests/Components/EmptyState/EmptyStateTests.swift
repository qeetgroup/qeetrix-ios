import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Empty state and data state")
struct EmptyStateTests {
    @Test("Each variant's default glyph and tone, as on the web")
    func variants() {
        #expect(QeetrixEmptyStateMetrics.defaultIcon(.default) == nil)
        #expect(QeetrixEmptyStateMetrics.defaultIcon(.firstUse) == nil)
        #expect(QeetrixEmptyStateMetrics.defaultIcon(.noResults) == .searchX)
        #expect(QeetrixEmptyStateMetrics.defaultIcon(.noPermission) == .lock)
        #expect(QeetrixEmptyStateMetrics.defaultIcon(.error) == .triangleAlert)
        #expect(QeetrixEmptyStateMetrics.tone(.firstUse) == (.surfaceBrandSubtle, .textBrand))
        #expect(QeetrixEmptyStateMetrics.tone(.error) == (.feedbackErrorSubtle, .textDanger))
        #expect(QeetrixEmptyStateMetrics.tone(.noResults) == (.surfaceSunken, .textTertiary))
        #expect(QeetrixEmptyStateVariant.firstUse.rawValue == "first-use")
    }

    @Test("Sizes: tile 36, 44, 48; icon 16, 20, 24; vertical padding 24, 48, 64")
    func sizes() {
        let metrics = QeetrixEmptyStateSize.allCases.map(QeetrixEmptyStateMetrics.init)
        #expect(metrics.map(\.tileSize) == [36, 44, 48])
        #expect(metrics.map(\.iconSize) == [16, 20, 24])
        #expect(metrics.map(\.paddingY) == [24, 48, 64])
        #expect(metrics.map(\.titleType.tokens.size) == [14, 16, 18])
    }

    @Test("Every variant and size renders, light and dark; without actions it takes no room for them")
    func renders() throws {
        for scheme in [ColorScheme.light, .dark] {
            for variant in QeetrixEmptyStateVariant.allCases {
                for size in QeetrixEmptyStateSize.allCases {
                    let view = QeetrixEmptyState("Nothing here", description: Text("Try again later."), variant: variant, size: size) {
                        QeetrixButton("Retry") {}
                    }
                    #expect(ImageRenderer(content: view.frame(width: 360).environment(\.colorScheme, scheme)).cgImage != nil)
                }
            }
        }
        let bare = try #require(Rendered(QeetrixEmptyState("Nothing here").frame(width: 300)))
        let titleOnly = QeetrixEmptyStateMetrics(size: .default)
        #expect(bare.height < Int(titleOnly.paddingY * 2 + 40), "Padding and a title, no action row")
    }

    @Test("The data state's branch: loading, then failure, then empty, then content")
    func phases() {
        #expect(QeetrixDataPhase(isLoading: true, isFailed: true, isEmpty: true) == .loading)
        #expect(QeetrixDataPhase(isLoading: false, isFailed: true, isEmpty: true) == .failed)
        #expect(QeetrixDataPhase(isLoading: false, isFailed: false, isEmpty: true) == .empty)
        #expect(QeetrixDataPhase(isLoading: false, isFailed: false, isEmpty: false) == .content)
    }

    @Test("Each branch renders; the default loading rows are six, 40 pt tall, 12 pt apart in a 16 pt inset")
    func dataState() throws {
        func state(loading: Bool = false, failure: QeetrixDataFailure? = nil, empty: Bool = false) -> some View {
            QeetrixDataState(isLoading: loading, isEmpty: empty, failure: failure) {
                Text("Content")
            } empty: {
                QeetrixEmptyState("No invoices yet")
            }
            .frame(width: 320)
        }
        #expect(ImageRenderer(content: state(loading: true)).cgImage != nil)
        #expect(ImageRenderer(content: state(failure: QeetrixDataFailure("Couldn't load invoices.") {})).cgImage != nil)
        #expect(ImageRenderer(content: state(failure: QeetrixDataFailure())).cgImage != nil)
        #expect(ImageRenderer(content: state(empty: true)).cgImage != nil)
        #expect(ImageRenderer(content: state()).cgImage != nil)
        let rows = try #require(Rendered(QeetrixDataLoadingRows().frame(width: 320)))
        #expect(rows.height == 6 * 40 + 5 * 12 + 2 * 16)
        #expect(try #require(Rendered(QeetrixDataLoadingRows(rows: 0).frame(width: 320))).height == 40 + 2 * 16, "At least one row")
    }

    @Test("A failure keeps its message and retry; without a message the default is used")
    func failure() {
        var retries = 0
        let failure = QeetrixDataFailure("Couldn't load invoices.") { retries += 1 }
        failure.retry?()
        #expect(retries == 1)
        #expect(failure.message == "Couldn't load invoices.")
        #expect(QeetrixDataFailure().message == nil)
        #expect(QeetrixDataFailure().retry == nil)
    }
}
