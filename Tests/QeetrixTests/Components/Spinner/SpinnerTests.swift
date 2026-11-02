import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Spinner")
struct SpinnerTests {
    @Test("Sizes: sm 14, md 16, lg 20, xl 24; tones neutral and brand")
    func sizes() {
        #expect(QeetrixSpinnerSize.allCases.map(\.iconSize.points) == [14, 16, 20, 24])
        #expect(QeetrixSpinnerTone.allCases.map(\.rawValue) == ["neutral", "brand"])
    }

    @Test("One turn every 2 × motion.duration.slower; under Reduce Motion a 1.6 s pulse")
    func timing() {
        #expect(QeetrixSpinnerRing.turn == 0.8)
        #expect(QeetrixSpinnerRing.pulse == 1.6)
        #expect(QeetrixSpinnerRing.width == 2)
    }

    @Test("A 2 pt ring in the foreground colour, with a gap at the inline end")
    func ring() throws {
        let image = try #require(Rendered(QeetrixSpinner(size: .xl).foregroundStyle(Color.black).background(Color.white)))
        #expect(image.width == 24 && image.height == 24)
        #expect(image.pixel(12, 1).r < 100, "Ink at twelve o'clock")
        #expect(image.pixel(1, 12).r < 100, "and at nine")
        #expect(image.pixel(22, 12).r > 200, "The gap at three")
        let brand = try #require(Rendered(QeetrixSpinner(size: .xl, tone: .brand).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.iconBrand).bytes, brand.pixel(12, 1), tolerance: 20))
    }

    @Test("Spinners render, labelled or decorative, and both ring modes draw")
    func renders() {
        #expect(ImageRenderer(content: QeetrixSpinner(label: Text("Loading invoices"))).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixSpinner(isDecorative: true)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixSpinnerRing.Turn().frame(width: 16, height: 16)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixSpinnerRing.Pulse().frame(width: 16, height: 16)).cgImage != nil)
    }
}
