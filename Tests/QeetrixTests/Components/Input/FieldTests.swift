import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Field")
struct FieldTests {
    @Test("A required field's control is named by the label, then \"Required\"")
    func requiredName() {
        let required = QeetrixFieldContext(label: Text(verbatim: "Email"), description: nil, message: nil, isRequired: true)
        let optional = QeetrixFieldContext(label: Text(verbatim: "Email"), description: nil, message: nil, isRequired: false)
        #expect(required.accessibilityLabel == Text(verbatim: "Email") + Text(verbatim: ", ") + QeetrixStrings.required)
        #expect(optional.accessibilityLabel == Text(verbatim: "Email"))
    }

    @Test("Each message tone has its own VoiceOver name")
    func toneNames() {
        #expect(QeetrixFieldMessage.Tone.error.accessibilityName == QeetrixStrings.error)
        #expect(QeetrixFieldMessage.Tone.warning.accessibilityName == QeetrixStrings.warning)
        #expect(QeetrixFieldMessage.Tone.success.accessibilityName == QeetrixStrings.success)
    }

    @Test("Every built-in string resolves from the package's table")
    func strings() {
        let keys = [
            "qeetrix.label.optional": "(optional)", "qeetrix.field.error": "Error", "qeetrix.field.warning": "Warning",
            "qeetrix.field.success": "Success", "qeetrix.password.show": "Show password", "qeetrix.password.hide": "Hide password",
            "qeetrix.otp.label": "One-time code", "qeetrix.number-field.decrease": "Decrease", "qeetrix.number-field.increase": "Increase",
            "qeetrix.form.error-summary-title": "There is a problem",
        ]
        for (key, english) in keys {
            #expect(Bundle.module.localizedString(forKey: key, value: nil, table: nil) == english)
        }
    }

    @Test("The rhythm: 6 pt in a field, the legend in the heading face, the optional mark regular")
    func metrics() {
        #expect(QeetrixFieldMetrics.gap == 6)
        #expect(QeetrixFieldMetrics.legendType.tokens.size == 16)
        #expect(QeetrixFieldMetrics.legendType.tokens.geometry == QeetrixTextRole.heading.tokens.geometry)
        #expect(QeetrixFieldMetrics.optionalType.tokens.weight == .regular)
    }

    @Test("A group stacks fields a field gap apart and selection rows flush")
    func fieldStack() throws {
        let rows = try #require(
            Rendered(
                QeetrixFieldStack(spacing: 16) {
                    Color.red.frame(height: 44).layoutValue(key: QeetrixSelectionRowKey.self, value: true)
                    Color.red.frame(height: 44).layoutValue(key: QeetrixSelectionRowKey.self, value: true)
                }
                .frame(width: 50)))
        #expect(rows.height == 88)
        let mixed = try #require(
            Rendered(
                QeetrixFieldStack(spacing: 16) {
                    Color.red.frame(height: 44).layoutValue(key: QeetrixSelectionRowKey.self, value: true)
                    Color.blue.frame(height: 32)
                }
                .frame(width: 50)))
        #expect(mixed.height == 44 + 16 + 32)
    }

    @Test("Fields, field sets and the text field render with every part")
    func renders() {
        let field = QeetrixField("Seats", description: Text("Help"), message: .error("Wrong"), isRequired: true) { Text("Control") }
        #expect(ImageRenderer(content: field.frame(width: 300)).cgImage != nil)
        let set = QeetrixFieldSet("Contact", description: Text("Help"), message: .warning("Check")) {
            QeetrixCheckbox("Email", isOn: .constant(true))
        }
        #expect(ImageRenderer(content: set.frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixTextField("Nickname", text: .constant(""), isOptional: true).frame(width: 300)).cgImage != nil)
    }
}
