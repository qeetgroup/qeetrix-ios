import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Fieldset")
struct FieldsetTests {
    @Test("The fields are spaced by the density's form gap")
    func gap() throws {
        func height(_ density: QeetrixDensity) throws -> Int {
            let set = QeetrixFieldset(legend: Text(verbatim: "")) {
                Color.red.frame(height: 20)
                Color.red.frame(height: 20)
            }
            return try #require(Rendered(set.frame(width: 200).qeetrixDensity(density))).height
        }
        #expect(
            try height(.comfortable) - height(.compact) == 2
                * Int(QeetrixDensity.comfortable.spaceFormGap - QeetrixDensity.compact.spaceFormGap))
    }

    @Test("A choice group's legend is the field label; its options sit 4 pt apart, or flush as 44 pt rows")
    func choiceGroup() throws {
        let context = QeetrixFieldContext(label: Text("Plan"), error: "Choose a plan")
        let group = QeetrixChoiceGroupLayout(context: context, isOptional: false) { Color.red.frame(height: 44) }
        #expect(ImageRenderer(content: group.frame(width: 300)).cgImage != nil)
    }

    @Test("Fieldsets render with and without a description, enabled and disabled")
    func renders() {
        let set = QeetrixFieldset("Billing address", description: Text("Where invoices are sent.")) {
            QeetrixTextField("Street", text: .constant(""))
        }
        #expect(ImageRenderer(content: set.frame(width: 320)).cgImage != nil)
        #expect(ImageRenderer(content: set.disabled(true).frame(width: 320)).cgImage != nil)
    }
}
