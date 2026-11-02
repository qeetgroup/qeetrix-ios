import SwiftUI
import Testing

@testable import Qeetrix

private let enIN = Locale(identifier: "en-IN")
private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

private func day(_ year: Int, _ month: Int, _ day: Int) -> QeetrixCalendarDay {
    QeetrixCalendarDay(year: year, month: month, day: day)
}

@MainActor
@Suite("Date picker")
struct DatePickerTests {
    @Test("The field writes the date as the web's field does, and VoiceOver reads it in words")
    func text() {
        let date = day(2026, 10, 25).start(in: kolkata)
        #expect(QeetrixFormat.numericDate(date, locale: enIN, timeZone: kolkata) == "25/10/2026")
        #expect(QeetrixFormat.numericDate(date, locale: Locale(identifier: "en-US"), timeZone: kolkata) == "10/25/2026")
        #expect(QeetrixFormat.date(date, style: .long, locale: enIN, timeZone: kolkata) == "25 October 2026")
    }

    @Test("The system picker keeps from the start of min's day to the last moment of max's, and survives a max before min")
    func bounds() throws {
        let min = day(2026, 10, 10).start(in: kolkata).addingTimeInterval(5 * 3600)
        let max = day(2026, 10, 20).start(in: kolkata).addingTimeInterval(3600)
        let bounds = QeetrixSystemDateBounds(min: min, max: max, timeZone: kolkata)
        #expect(bounds.lower == day(2026, 10, 10).start(in: kolkata))
        #expect(bounds.upper == day(2026, 10, 21).start(in: kolkata).addingTimeInterval(-1))
        #expect(bounds.clamp(day(2026, 1, 1).start(in: kolkata)) == bounds.lower)
        #expect(bounds.clamp(day(2027, 1, 1).start(in: kolkata)) == bounds.upper)
        let inverted = QeetrixSystemDateBounds(min: max, max: min, timeZone: kolkata)
        #expect(try #require(inverted.lower) <= #require(inverted.upper))
        let open = QeetrixSystemDateBounds(min: nil, max: nil, timeZone: kolkata)
        #expect(open.lower == nil && open.upper == nil)
    }

    @Test("The system calendar is Gregorian and starts the week on the locale's first day")
    func systemCalendar() {
        let india = QeetrixSystemDateBounds.calendar(locale: enIN, timeZone: kolkata)
        #expect(india.identifier == .gregorian && india.firstWeekday == 1 && india.timeZone == kolkata)
        #expect(QeetrixSystemDateBounds.calendar(locale: Locale(identifier: "en-GB"), timeZone: kolkata).firstWeekday == 2)
        #expect(QeetrixSystemDateBounds.calendar(locale: Locale(identifier: "th-TH"), timeZone: kolkata).identifier == .gregorian)
    }

    @Test("It opens a popover on a phone at the default sizes, and a sheet where one wouldn't fit")
    func presentation() {
        #expect(!QeetrixPickerPresentation(horizontalSizeClass: .compact, verticalSizeClass: .regular, dynamicTypeSize: .large).isSheet)
        #expect(
            QeetrixPickerPresentation(horizontalSizeClass: .compact, verticalSizeClass: .regular, dynamicTypeSize: .accessibility1).isSheet)
        #expect(QeetrixPickerPresentation(horizontalSizeClass: .compact, verticalSizeClass: .compact, dynamicTypeSize: .large).isSheet)
        #expect(
            !QeetrixPickerPresentation(horizontalSizeClass: .regular, verticalSizeClass: .regular, dynamicTypeSize: .accessibility5).isSheet
        )
        #expect(QeetrixPickerPopover<EmptyView>.minimumWidth >= 7 * 44 + 2 * QeetrixSpace.insetMd, "seven 44 pt days")
    }

    @Test("The field is the input box: the field height, the value's colour, the invalid and read-only looks")
    func field() {
        let state = QeetrixInputState(isEnabled: true, isReadOnly: false, isFocused: false, isHovered: false, isInvalid: true)
        #expect(state.frame == .borderDanger)
        #expect(QeetrixInputMetrics.height(.default) == QeetrixDensity.default.sizeControlLg)
        let readOnly = QeetrixInputState(isEnabled: true, isReadOnly: true, isFocused: false, isHovered: false, isInvalid: false)
        #expect(readOnly.background == nil && readOnly.bottomLine == .borderStrong)
    }

    @Test("The field's icon is the subtle text colour on the field's fill, at 4.5:1 in both schemes")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for fill in [QeetrixColor.bgNeutralSubtle, .bgNeutralSubtleHover] {
                let pair = ContrastTests.Pair(foreground: .textSubtle, background: [fill], minimum: 4.5)
                #expect(ContrastTests.ratio(pair, theme) >= 4.5, "\(theme.colorScheme): \(pair)")
            }
        }
    }

    #if os(macOS)
        @Test("VoiceOver reads each field as a button named by its label, with the value in words, the help after it")
        func accessibilityTree() {
            let date = day(2026, 10, 25).start(in: kolkata)
            let view = VStack {
                QeetrixDatePicker("Joining date", selection: .constant(date), description: Text("Your first day."))
                QeetrixDateRangePicker("Stay", selection: .constant(nil), isRequired: true)
                QeetrixTimePicker("Reminder", selection: .constant(date.addingTimeInterval(14.5 * 3600)))
            }
            .environment(\.timeZone, kolkata)
            let elements = ListsAccessibilityTree.elements(of: view).map(\.description)
            #expect(elements[0] == "AXButton \"Joining date\" = October 25, 2026")
            #expect(elements[1] == "AXStaticText \"Your first day.\"")
            #expect(elements[2].hasPrefix("AXButton \"Stay, Required\""))
            #expect(elements[3] == "AXButton \"Reminder\" = 2:30 PM")
        }
    #endif

    @Test("It renders empty, with a date, with a placeholder, an error, read-only, disabled and with ruled-out days")
    func renders() {
        let date = day(2026, 10, 25).start(in: .current)
        let views: [AnyView] = [
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(nil))),
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(date), description: Text("Your first day."))),
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(nil), placeholder: Text("Choose a date"), isOptional: true)),
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(date), error: "Choose a weekday")),
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(date), isReadOnly: true)),
            AnyView(QeetrixDatePicker("Joining date", selection: .constant(date)).disabled(true)),
            AnyView(QeetrixDatePicker(verbatim(), selection: .constant(date), isDateDisabled: { _ in false }, isRequired: true)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }

    private func verbatim() -> String { "Delivery" }
}
