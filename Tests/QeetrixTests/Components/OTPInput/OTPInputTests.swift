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
            ("12a3", "12", "123"),  // letters are dropped from a numeric code
            ("123 456", "", "123456"),  // a pasted code with a space
            ("123-456", "", "123456"),  // or a hyphen
            ("12987654", "12", "987654"),  // a whole code pasted into a part-filled field replaces it
            ("١٢٣", "", "123"),  // Arabic-Indic digits are entered as 0–9
            ("१२३", "", "123"),  // so are Devanagari
            ("Ⅻ", "", ""),  // a Roman numeral is not a decimal digit
        ])
    func accepts(text: String, previous: String, expected: String) {
        #expect(QeetrixOTPCode.accept(text, previous: previous, length: 6, validationType: .numeric) == expected)
    }

    @Test("Letters are kept for an alphanumeric code, as typed")
    func alphanumeric() {
        #expect(QeetrixOTPValidationType.allCases.map(\.rawValue) == ["numeric", "alphanumeric"])
        #expect(QeetrixOTPCode.accept("ab12-CD34", previous: "", length: 8, validationType: .alphanumeric) == "ab12CD34")
        #expect(QeetrixOTPCode.accept("ÄB12", previous: "", length: 8, validationType: .alphanumeric) == "B12", "ASCII letters only")
    }

    @Test("groups split the slots: [3, 3] breaks before the fourth; groups past the length are ignored")
    func groups() {
        func breaks(_ groups: [Int], length: Int = 6) -> Set<Int> {
            QeetrixOTPField(code: .constant(""), length: length, groups: groups, size: .md, validationType: .numeric, onValueComplete: nil)
                .breaks
        }
        #expect(breaks([3, 3]) == [3])
        #expect(breaks([2, 2, 2]) == [2, 4])
        #expect(breaks([]) == [])
        #expect(breaks([5, 5], length: 10) == [5])
        #expect(breaks([8]) == [], "A group as long as the code makes no break")
    }

    @Test("Slots: title.md (title.lg at lg) in the A11y letters; md is an input's height, lg 16 pt taller")
    func metrics() throws {
        #expect(QeetrixOTPInput(code: .constant(""), length: 0).length == 1)
        let md = QeetrixOTPMetrics.characterType(.md)
        #expect(md.tokens.size == QeetrixTextRole.titleMd.tokens.size && md.tokens.geometry == .body)
        #expect(QeetrixOTPMetrics.characterType(.lg).tokens.size == QeetrixTextRole.titleLg.tokens.size)
        let mdImage = try #require(Rendered(QeetrixOTPInput(code: .constant("12")).frame(width: 390)))
        let lgImage = try #require(Rendered(QeetrixOTPInput(code: .constant("12"), size: .lg).frame(width: 390)))
        #expect(mdImage.height == 40)
        #expect(lgImage.height == 56)
        #expect(mdImage.width == 390, "It spans its container")
    }

    @Test("Renders empty, part-filled, grouped, invalid and disabled")
    func renders() {
        #expect(ImageRenderer(content: QeetrixOTPInput("Code", code: .constant("")).frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixOTPInput("Code", code: .constant("012"), groups: [3, 3]).frame(width: 390)).cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixOTPInput(code: .constant("12"), error: "That code didn't work").frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixOTPInput(code: .constant("12"), length: 4).disabled(true).frame(width: 390)).cgImage != nil)
    }
}
