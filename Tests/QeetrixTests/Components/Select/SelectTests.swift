import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Select")
struct SelectTests {
    @Test("Renders the placeholder and a selection, enabled and disabled")
    func renders() {
        let options: [QeetrixOption<String?>] = [QeetrixOption("India", value: "IN"), QeetrixOption("Germany", value: "DE")]
        let empty = QeetrixSelect("Country", selection: .constant(nil), options: options, placeholder: Text("Choose"))
        let chosen = QeetrixSelect("Country", selection: .constant("DE"), options: options, message: .error("Wrong"))
        #expect(ImageRenderer(content: empty.frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: chosen.disabled(true).frame(width: 300)).cgImage != nil)
    }
}
