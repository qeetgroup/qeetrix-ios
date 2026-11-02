import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Field")
struct FieldTests {
    @Test("A required field's control is named by the label, then \"Required\"; nothing is drawn for it")
    func requiredName() {
        let required = QeetrixFieldContext(label: Text(verbatim: "Email"), isRequired: true)
        let plain = QeetrixFieldContext(label: Text(verbatim: "Email"))
        #expect(required.accessibilityLabel == Text(verbatim: "Email") + Text(verbatim: ", ") + QeetrixStrings.required)
        #expect(plain.accessibilityLabel == Text(verbatim: "Email"))
    }

    @Test("An error, or isInvalid, marks the control invalid")
    func invalid() {
        #expect(!QeetrixFieldContext(label: Text("Email")).invalid)
        #expect(QeetrixFieldContext(label: Text("Email"), error: "Enter a work email").invalid)
        #expect(QeetrixFieldContext(label: Text("Email"), isInvalid: true).invalid)
    }

    @Test("Every built-in string is @qeetrix/react's English")
    func strings() {
        let keys = [
            "qeetrix.spinner.label": "Loading", "qeetrix.field.optional": "(optional)", "qeetrix.field.error": "Error",
            "qeetrix.password-input.show": "Show password", "qeetrix.password-input.shown": "Password shown",
            "qeetrix.password-input.hidden": "Password hidden", "qeetrix.otp-input.label": "One-time code",
            "qeetrix.number-field.decrement": "Decrease", "qeetrix.number-field.increment": "Increase",
            "qeetrix.error-summary.title": "Fix these to continue", "qeetrix.overlay.close": "Close", "qeetrix.toast.close": "Dismiss",
            "qeetrix.dialog.cancel": "Cancel", "qeetrix.field.required": "Required",
        ]
        for (key, english) in keys {
            #expect(Bundle.module.localizedString(forKey: key, value: nil, table: nil) == english, "\(key)")
        }
    }

    @Test("The label is label.sm; \"(optional)\" takes body.sm's weight")
    func label() {
        #expect(QeetrixFieldLabel.optionalType.tokens.size == QeetrixTextRole.labelSm.tokens.size)
        #expect(QeetrixFieldLabel.optionalType.tokens.weight == .regular)
    }

    @Test("The error replaces the description: one line, not two")
    func errorReplacesDescription() throws {
        let both = try #require(
            Rendered(QeetrixFieldMessages(description: Text("Help text"), error: "Enter a work email").frame(width: 300)))
        let description = try #require(Rendered(QeetrixFieldMessages(description: Text("Help text"), error: nil).frame(width: 300)))
        let error = try #require(Rendered(QeetrixFieldError(text: "Enter a work email").frame(width: 300)))
        #expect(both.height == error.height)
        #expect(description.height < both.height + 1, "One body.sm line, or the error row with its 16 pt icon")
    }

    @Test("A field is label, control and message 4 pt apart")
    func rhythm() throws {
        let bare = try #require(Rendered(QeetrixField("Seats") { Color.red.frame(height: 40) }.frame(width: 200)))
        let hidden = try #require(Rendered(QeetrixField("Seats", isLabelHidden: true) { Color.red.frame(height: 40) }.frame(width: 200)))
        #expect(hidden.height == 40, "A hidden label leaves no gap")
        // label.sm's line is 16 pt; the gap 4 pt.
        // Within a pixel of a scale-1 render's rounding.
        #expect(abs(bare.height - (40 + 4 + 16)) <= 1)
        #expect(bare.height > 40 + 4 + 10, "The label and the 4 pt gap above the control")
    }

    @Test("A group stacks fields a gap apart and choice rows flush")
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

    @Test("Fields render with every part, enabled and disabled")
    func renders() {
        let field = QeetrixField("Seats", description: Text("Help"), error: "Choose at least one seat", isRequired: true) {
            Text("Control")
        }
        #expect(ImageRenderer(content: field.frame(width: 300)).cgImage != nil)
        let optional = QeetrixField("Nickname", description: Text("Help"), isOptional: true) { Text("Control") }.disabled(true)
        #expect(ImageRenderer(content: optional.frame(width: 300)).cgImage != nil)
    }
}
