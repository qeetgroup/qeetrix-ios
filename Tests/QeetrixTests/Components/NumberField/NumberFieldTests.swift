import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Number field")
struct NumberFieldTests {
    typealias Reading = QeetrixNumberParser.Reading

    private func read(_ text: String, _ locale: String = "en_US", fraction: Bool = true, negative: Bool = true) -> Reading {
        QeetrixNumberParser.read(text, locale: Locale(identifier: locale), allowsFraction: fraction, allowsNegative: negative)
    }

    @Test("In-between states of typing are partial, not errors")
    func partial() {
        #expect(read("") == .empty)
        #expect(read("-") == .partial)
        #expect(read("12.") == .partial)
        #expect(read("-.") == .partial)
        #expect(read("−") == .partial, "U+2212 minus")
    }

    @Test("A trailing decimal separator stands for the number before it; a lone sign stands for none")
    func partialValue() {
        func value(_ text: String, _ locale: String = "en_US") -> Decimal? {
            QeetrixNumberParser.partialValue(text, locale: Locale(identifier: locale), allowsFraction: true, allowsNegative: true)
        }
        #expect(value("-12.") == Decimal(-12), "Typed fast, the field may never see \"-12\" alone")
        #expect(value("12,", "de_DE") == Decimal(12))
        #expect(value("-") == nil)
        #expect(value("-.") == nil)
        #expect(value("12") == nil, "Not partial")
    }

    @Test("Text that is not a number is invalid — unlike Foundation's lenient parser")
    func invalid() {
        #expect(read("12abc") == .invalid)
        #expect(read("1.2.3") == .invalid)
        #expect(read("5-") == .invalid)
        #expect(read("1.5", fraction: false) == .invalid, "No fraction in a whole-number field")
        #expect(read("-3", negative: false) == .invalid, "No minus when the range has no negatives")
    }

    @Test("Each locale's separators, grouping and digits")
    func locales() {
        #expect(read("1,234.5") == .number(Decimal(string: "1234.5")!))
        #expect(read("1.234,5", "de_DE") == .number(Decimal(string: "1234.5")!))
        #expect(read("1234.5", "de_DE") == .number(Decimal(string: "12345")!), "In German the dot groups")
        #expect(read("1 234,5", "fr_FR") == .number(Decimal(string: "1234.5")!))
        #expect(read("1\u{202F}234,5", "fr_FR") == .number(Decimal(string: "1234.5")!), "French groups with a narrow no-break space")
        #expect(read("١٢٣٫٥", "ar_EG") == .number(Decimal(string: "123.5")!), "Arabic-Indic digits and separator")
        #expect(read("\u{061C}-١٢", "ar_EG") == .number(-12), "Arabic minus with its letter mark")
    }

    @Test("Values stay exact: 0.1 + 0.2 is 0.3")
    func exact() {
        guard case .number(let a) = read("0.1"), case .number(let b) = read("0.2") else {
            Issue.record("0.1 and 0.2 must read")
            return
        }
        #expect(a + b == Decimal(string: "0.3")!)
    }

    @Test("Formatting is the locale's, with grouping and up to the fraction digits")
    func format() {
        let value = Decimal(string: "1234.5")!
        #expect(QeetrixNumberParser.format(value, locale: Locale(identifier: "en_US"), fractionDigits: 2) == "1,234.5")
        #expect(QeetrixNumberParser.format(value, locale: Locale(identifier: "de_DE"), fractionDigits: 2) == "1.234,5")
        #expect(QeetrixNumberParser.format(value, locale: Locale(identifier: "en_US"), fractionDigits: 0) == "1,234")
    }

    @Test("Rounding is half away from zero, in Decimal")
    func rounding() {
        #expect(QeetrixNumberParser.rounded(Decimal(string: "2.345")!, fractionDigits: 2) == Decimal(string: "2.35")!)
        #expect(QeetrixNumberParser.rounded(Decimal(string: "-2.345")!, fractionDigits: 2) == Decimal(string: "-2.35")!)
        #expect(QeetrixNumberParser.rounded(Decimal(string: "2.5")!, fractionDigits: 0) == 3)
    }

    @Test("Clamping and stepping stay inside the range")
    func range() {
        let range: ClosedRange<Decimal> = 1...250
        #expect(QeetrixNumberParser.clamped(900, to: range) == 250)
        #expect(QeetrixNumberParser.clamped(-3, to: range) == 1)
        #expect(QeetrixNumberParser.clamped(-3, to: nil) == -3)
        #expect(QeetrixNumberParser.stepped(5, by: 1, range: range) == 6)
        #expect(QeetrixNumberParser.stepped(250, by: 1, range: range) == 250)
        #expect(QeetrixNumberParser.stepped(nil, by: 1, range: nil) == 1, "An empty field stepped up holds the step")
        #expect(QeetrixNumberParser.stepped(nil, by: 1, range: 10...20) == 10, "or the minimum when that is higher")
    }

    @Test("An Int binding never overflows")
    func integers() {
        #expect(QeetrixNumberParser.integer(Decimal(string: "42")!) == 42)
        #expect(QeetrixNumberParser.integer(Decimal(string: "1e30")!) == Int.max)
        #expect(QeetrixNumberParser.integer(Decimal(string: "-1e30")!) == Int.min)
    }
}

@MainActor
@Suite("Number field view")
struct NumberFieldViewTests {
    @Test("The box is a field's height; steppers are control.sm squares behind a hairline")
    func box() throws {
        let with = try #require(Rendered(QeetrixNumberField("Seats", value: .constant(5), in: 1...10).frame(width: 300)))
        let field = try #require(
            Rendered(QeetrixNumberInput(value: .constant(5), range: 1...10, step: 1, fractionDigits: 0, prompt: nil).frame(width: 300)))
        #expect(field.height == Int(QeetrixDensity.default.sizeControlLg))
        #expect(with.height > field.height, "The label above it")
    }

    @Test("Renders with steppers, without, with affixes, an error and disabled")
    func renders() {
        let fields: [QeetrixNumberField] = [
            QeetrixNumberField("Seats", value: .constant(5), in: 1...250),
            QeetrixNumberField(
                "Discount", value: .constant(Decimal(5)), in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1,
                endAdornment: Text("%")),
            QeetrixNumberField("Amount", value: .constant(Decimal?.none), startAdornment: Text("₹"), showsSteppers: false),
            QeetrixNumberField("Seats", value: .constant(500), error: "Up to 250 seats"),
        ]
        for field in fields {
            #expect(ImageRenderer(content: field.frame(width: 300)).cgImage != nil)
            #expect(ImageRenderer(content: field.disabled(true).frame(width: 300)).cgImage != nil)
        }
    }
}
