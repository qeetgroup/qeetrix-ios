import SwiftUI
import Testing

@testable import Qeetrix

private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

private func at(
    _ hour: Int, _ minute: Int, _ second: Int = 0, on day: QeetrixCalendarDay = QeetrixCalendarDay(year: 2026, month: 10, day: 25)
)
    -> Date
{
    day.start(in: kolkata).addingTimeInterval(TimeInterval(hour * 3600 + minute * 60 + second))
}

@MainActor
@Suite("Time picker")
struct TimePickerTests {
    @Test("Steps are UIDatePicker's minuteInterval values, which divide an hour; any other is 1")
    func steps() {
        #expect(QeetrixTimePickerStep.steps == [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30])
        #expect([5, 15, 30].map(QeetrixTimePickerStep.valid) == [5, 15, 30])
        #expect([0, 7, 45, 60, -5].map(QeetrixTimePickerStep.valid) == [1, 1, 1, 1, 1])
    }

    @Test("Rounding to the step: the nearest step, seconds dropped, wrapping past midnight within the day")
    func rounding() {
        #expect(QeetrixTimePickerStep.rounded(at(14, 7), to: 15, in: kolkata) == at(14, 0))
        #expect(QeetrixTimePickerStep.rounded(at(14, 8), to: 15, in: kolkata) == at(14, 15))
        #expect(QeetrixTimePickerStep.rounded(at(14, 7, 31), to: 15, in: kolkata) == at(14, 15))
        #expect(QeetrixTimePickerStep.rounded(at(9, 41, 59), to: 1, in: kolkata) == at(9, 42))
        #expect(QeetrixTimePickerStep.rounded(at(9, 41, 29), to: 1, in: kolkata) == at(9, 41))
        #expect(QeetrixTimePickerStep.rounded(at(23, 58), to: 5, in: kolkata) == at(0, 0), "Android's snapToStep wraps")
    }

    @Test("A time is set on the day the selection already has, rounded to the step")
    func day() {
        let other = QeetrixCalendarDay(year: 2026, month: 12, day: 31)
        let set = QeetrixTimePickerStep.time(of: at(18, 44), on: at(9, 0, on: other), step: 15, in: kolkata)
        #expect(set == at(18, 45, on: other))
        #expect(QeetrixCalendarDay(set, in: kolkata) == other)
    }

    @Test("The field writes the time as QeetrixFormat.time does: 12 or 24 hours as the locale — and the device — has it")
    func text() {
        let time = at(14, 30)
        #expect(QeetrixFormat.time(time, locale: Locale(identifier: "en-IN"), timeZone: kolkata) == "2:30 pm")
        #expect(QeetrixFormat.time(time, locale: Locale(identifier: "en-GB"), timeZone: kolkata) == "14:30")
    }

    @Test("It renders empty, with a time, an error, read-only and disabled")
    func renders() {
        let time = at(9, 30)
        let views: [AnyView] = [
            AnyView(QeetrixTimePicker("Reminder", selection: .constant(nil), minuteStep: 15)),
            AnyView(QeetrixTimePicker("Reminder", selection: .constant(time), description: Text("We'll send it at this time."))),
            AnyView(QeetrixTimePicker("Reminder", selection: .constant(nil), error: "Choose a time in office hours")),
            AnyView(QeetrixTimePicker("Reminder", selection: .constant(time), isReadOnly: true)),
            AnyView(QeetrixTimePicker("Reminder", selection: .constant(time)).disabled(true)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }
}
