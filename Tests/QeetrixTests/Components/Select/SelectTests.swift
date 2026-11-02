import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Select")
struct SelectTests {
    @Test("The trigger is a field box at size.control.lg by default, or a toolbar's md and sm")
    func heights() throws {
        let options = [QeetrixOption("India", value: "IN")]
        func height(_ size: QeetrixControlSize) throws -> Int {
            let trigger = QeetrixSelectTrigger(
                selection: .constant("IN"), options: options, placeholder: nil, size: size, isReadOnly: false)
            return try #require(Rendered(trigger.frame(width: 200))).height
        }
        #expect(try height(.lg) == 40)
        #expect(try height(.md) == 32)
        #expect(try height(.sm) == 28)
    }

    @Test("Renders chosen, with a placeholder, with an error, read-only and disabled")
    func renders() {
        let options = [QeetrixOption("India", value: Optional("IN")), QeetrixOption("Nepal", value: "NP", isDisabled: true)]
        let selects = [
            QeetrixSelect("Country", selection: .constant(Optional("IN")), options: options),
            QeetrixSelect(
                "Country", selection: .constant(String?.none), options: options, placeholder: Text("Choose a country"),
                error: "Choose a country"),
            QeetrixSelect("Country", selection: .constant(Optional("IN")), options: options, isReadOnly: true),
        ]
        for select in selects {
            #expect(ImageRenderer(content: select.frame(width: 300)).cgImage != nil)
            #expect(ImageRenderer(content: select.disabled(true).frame(width: 300)).cgImage != nil)
        }
    }
}
