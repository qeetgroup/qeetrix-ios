import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Spinner")
struct SpinnerTests {
    @Test("Sizes: 16, 20, 24, 32")
    func sizes() {
        #expect(QeetrixSpinnerSize.allCases.map(\.iconSize.points) == [16, 20, 24, 32])
    }

    @Test("It turns once a second, as animate-spin does")
    func duration() {
        #expect(QeetrixWebScale.spinDuration == 1)
    }

    @Test("Its default name comes from the package's strings: \"Loading\"")
    func defaultLabel() {
        #expect(Bundle.module.localizedString(forKey: "qeetrix.spinner.label", value: nil, table: nil) == "Loading")
        #expect(Bundle.module.localizedString(forKey: "qeetrix.field.required", value: nil, table: nil) == "Required")
    }

    @Test("A spinner renders at rest")
    func renders() throws {
        let rendered = try #require(Rendered(QeetrixSpinner(size: .xl)))
        #expect(rendered.width == 32)
    }
}
