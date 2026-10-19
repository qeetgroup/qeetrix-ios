import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Textarea")
struct TextareaTests {
    @Test("Starts two control heights tall, at every density")
    func minimumHeight() {
        for density in QeetrixDensity.allCases {
            #expect(QeetrixTextareaMetrics.minimumHeight(density) == 2 * density.controlHeight)
        }
    }

    @Test("Grows to the web's 24 rem cap — 15 lines of 16 pt text at 1.5 — then scrolls")
    func cap() {
        let tokens = QeetrixTextareaMetrics.textType.tokens
        #expect(tokens.size == 16)
        #expect(tokens.lineHeight == 1.5)
        let padding = 2 * QeetrixWebScale.spacing(2)
        #expect(CGFloat(QeetrixTextareaMetrics.maximumLines) * tokens.size * tokens.lineHeight + padding <= 384)
        #expect(CGFloat(QeetrixTextareaMetrics.maximumLines + 1) * tokens.size * tokens.lineHeight + padding > 384)
    }

    @Test("Renders editable, read-only and with a message")
    func renders() {
        #expect(ImageRenderer(content: QeetrixTextarea("Note", text: .constant("Line one\nLine two")).frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixTextarea("Note", text: .constant("Fixed"), isReadOnly: true).frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixTextarea("Note", text: .constant(""), message: .error("Required")).frame(width: 300)).cgImage
                != nil)
    }
}
