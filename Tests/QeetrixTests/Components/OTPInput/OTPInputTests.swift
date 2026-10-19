import SwiftUI
import Testing

@testable import Qeetrix

/// Synthetic codes only.
@MainActor
@Suite("OTP input")
struct OTPInputTests {
    @Test(
        "What the field accepts",
        arguments: [
            // typed text, previous code, expected code
            ("0", "", "0"),  // a leading zero is a digit like any other
            ("012345", "01234", "012345"),
            ("0123456", "012345", "012345"),  // nothing past the length
            ("12a3", "12", "123"),  // letters are dropped from a digit code
            ("123 456", "", "123456"),  // a pasted code with a space
            ("123-456", "", "123456"),  // or a hyphen
            ("12987654", "12", "987654"),  // a whole code pasted into a part-filled field replaces it
            ("١٢٣", "", "123"),  // Arabic-Indic digits are entered as 0–9
            ("१२३", "", "123"),  // so are Devanagari
            ("Ⅻ", "", ""),  // a Roman numeral is not a decimal digit
        ])
    func accepts(text: String, previous: String, expected: String) {
        #expect(QeetrixOTPCode.accept(text, previous: previous, length: 6, characters: .digits) == expected)
    }

    @Test("Letters are kept for an alphanumeric code, as typed")
    func alphanumeric() {
        #expect(QeetrixOTPCode.accept("ab12-CD34", previous: "", length: 8, characters: .alphanumeric) == "ab12CD34")
        #expect(QeetrixOTPCode.accept("ÄB12", previous: "", length: 8, characters: .alphanumeric) == "B12", "ASCII letters only")
    }

    @Test("Length is at least one; the cells are 48 pt tall at default density, in Fira Code 18 pt")
    func metrics() {
        #expect(QeetrixOTPInput(code: .constant(""), length: 0).length == 1)
        #expect(QeetrixOTPMetrics.characterType.tokens.family == .mono)
        #expect(QeetrixOTPMetrics.characterType.tokens.size == 18)
        #expect(QeetrixInputTokens.height(.default) + QeetrixWebScale.spacing(4) == 48)
    }

    @Test("Renders empty, part-filled, grouped and disabled")
    func renders() {
        #expect(ImageRenderer(content: QeetrixOTPInput("Code", code: .constant("")).frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixOTPInput("Code", code: .constant("012"), groupSize: 3).frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixOTPInput(code: .constant("12"), length: 4).disabled(true).frame(width: 390)).cgImage != nil)
    }
}
