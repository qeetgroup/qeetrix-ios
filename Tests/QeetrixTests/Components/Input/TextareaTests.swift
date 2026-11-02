import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Textarea")
struct TextareaTests {
    @Test("Rows: at least one; max rows never below rows")
    func rows() {
        let textarea = QeetrixTextarea("Notes", text: .constant(""), rows: 0, maxRows: 0)
        #expect(textarea.rows == 1)
        #expect(textarea.maxRows == 1)
        #expect(QeetrixTextarea("Notes", text: .constant("")).rows == 3)
        #expect(QeetrixTextarea("Notes", text: .constant(""), rows: 4, maxRows: 8).maxRows == 8)
    }

    @Test("More rows, a taller box: one body.md line (20 pt) per row")
    func height() throws {
        func height(_ rows: Int) throws -> Int {
            try #require(
                Rendered(
                    QeetrixTextareaInput(text: .constant(""), prompt: nil, rows: rows, maxRows: nil, isReadOnly: false).frame(width: 300))
            ).height
        }
        let three = try height(3)
        let five = try height(5)
        #expect(abs(five - three - 40) <= 1)
        // One line sits as in an input: rows × 20 + (control.lg − 20).
        #expect(abs(three - (3 * 20 + 20)) <= 1)
    }

    @Test("Textareas render empty, filled, read-only and with an error")
    func renders() {
        #expect(
            ImageRenderer(content: QeetrixTextarea("Notes", text: .constant(""), prompt: Text("e.g. Deliver after 5 pm")).frame(width: 300))
                .cgImage != nil)
        #expect(ImageRenderer(content: QeetrixTextarea("Notes", text: .constant("Hi"), error: "Too long").frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixTextarea("Notes", text: .constant("Hi"), isReadOnly: true).frame(width: 300)).cgImage != nil)
    }
}
