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

    @Test("Square slots: a 2-digit number match keeps two 40 pt slots, 8 pt apart, at the leading edge")
    @MainActor
    func squareSlots() throws {
        func image(_ direction: LayoutDirection, _ width: QeetrixOTPSlotWidth) throws -> Rendered {
            try #require(
                Rendered(
                    QeetrixOTPInput(code: .constant(""), length: 2)
                        .qeetrixOTPSlotWidth(width)
                        .frame(width: 300)
                        .background(Color.white)
                        .environment(\.layoutDirection, direction)
                        .qeetrixTheme(.light)))
        }
        // Read 5 pt above the slots' bottom line: the native text field over the slots, which the Mac renderer
        // draws as a placeholder, covers their middle rows.
        func filled(_ image: Rendered, _ x: Int) -> Bool { image.pixel(x, 35).r < 250 }
        let ltr = try image(.leftToRight, .square)
        #expect(ltr.width == 300, "The input still spans its container")
        for x in [2, 38, 50, 86] { #expect(filled(ltr, x), "slot at \(x)") }
        for x in [44, 92, 200, 297] { #expect(!filled(ltr, x), "no slot at \(x)") }
        // In right to left the slots sit at the leading edge, the right, still reading left to right.
        let rtl = try image(.rightToLeft, .square)
        for x in [298, 262, 250, 214] { #expect(filled(rtl, x), "rtl slot at \(x)") }
        for x in [256, 208, 3] { #expect(!filled(rtl, x), "rtl: no slot at \(x)") }
        // The default still shares the width.
        #expect(filled(try image(.leftToRight, .fill), 297))
        #expect(QeetrixOTPSlotWidth.allCases.map(\.rawValue) == ["fill", "square"])
    }

    @Test("An unlabelled code can take the name VoiceOver reads, the label hidden")
    @MainActor
    func accessibilityLabel() {
        let named = QeetrixOTPInput(code: .constant(""), accessibilityLabel: Text("Number on your other device"), length: 2)
        #expect(named.context != nil)
        #expect(named.isLabelHidden)
        #expect(QeetrixOTPInput(code: .constant("")).context == nil, "Without one it stays One-time code")
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
