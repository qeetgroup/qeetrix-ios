import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from DatePicker.md, DateRangePicker.md, TimePicker.md, Calendar.md, RangeCalendar.md,
// Stat.md and Slider.md in Sources/Qeetrix/Qeetrix.docc/Components, and from their symbols' doc
// comments, copied verbatim inside views that supply the names they use. If the API changes in a way
// that breaks an example, this file stops compiling, and the page must be updated with it.

private func isHoliday(_ date: Date) -> Bool { false }
private func nextWeekend() -> ClosedRange<Date> { Date()...Date().addingTimeInterval(86_400) }
private func quarter(containing date: Date) -> ClosedRange<Date> { date...date.addingTimeInterval(90 * 86_400) }

/// DatePicker.md and `QeetrixDatePicker`.
private struct DatePickerExamples: View {
    @State private var joiningDate: Date? = nil
    @State private var delivery: Date? = Date()

    var body: some View {
        VStack {
            QeetrixDatePicker("Joining date", selection: $joiningDate, min: .now)
            QeetrixDatePicker("Delivery", selection: $delivery, min: .now, isDateDisabled: { Calendar.current.isDateInWeekend($0) })
        }
    }
}

/// DateRangePicker.md, `QeetrixDateRangePicker` and `QeetrixDateRangePreset`.
private struct DateRangePickerExamples: View {
    @State private var period: ClosedRange<Date>? = nil
    @State private var stay: ClosedRange<Date>? = nil

    var body: some View {
        VStack {
            QeetrixDateRangePicker("Billing period", selection: $period, presets: [.thisMonth, .lastMonth, .last30Days])
            QeetrixDateRangePicker(
                "Stay", selection: $stay, min: .now,
                presets: [QeetrixDateRangePreset("Next weekend") { nextWeekend() }])
            QeetrixDateRangePicker(
                "Period", selection: $period,
                presets: [
                    .last7Days, .thisMonth,
                    QeetrixDateRangePreset("This quarter") { quarter(containing: .now) },
                ])
        }
    }
}

/// TimePicker.md and `QeetrixTimePicker`.
private struct TimePickerExamples: View {
    @State private var reminder: Date? = nil

    var body: some View {
        QeetrixTimePicker("Reminder", selection: $reminder, minuteStep: 15)
    }
}

/// Calendar.md and RangeCalendar.md.
private struct CalendarExamples: View {
    @State private var deliveryDay: Date? = nil
    @State private var stay: ClosedRange<Date>? = nil

    var body: some View {
        VStack {
            QeetrixCalendar(selection: $deliveryDay, min: .now, isDateDisabled: { isHoliday($0) })
            QeetrixRangeCalendar(selection: $stay, min: .now)
        }
    }
}

/// Stat.md, `QeetrixStat`, `QeetrixStatGroup`, `QeetrixStatValue` and `QeetrixStatChange`.
private struct StatExamples: View {
    let weeklyUsers: [Double] = [42, 44, 41, 47, 52]

    var body: some View {
        VStack {
            QeetrixStatGroup {
                QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"), trend: weeklyUsers)
                QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"), note: Text("18 invoices"))
                QeetrixStat("Disputes", value: 3, note: Text("2 need a reply"), tone: .warning)
            }
            QeetrixStat("Failed payments", value: 42, change: .number(6, isIncreaseGood: false), note: Text("since yesterday"))
            QeetrixStat("Latency", value: .text(Text("42 ms")), note: Text("p95"))
            QeetrixStat("Revenue", value: 0, isLoading: true)
            QeetrixStatGroup {
                QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"))
                QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"))
            }
            QeetrixStat("Active users", value: 1_240_512)  // "12,40,512" in en-IN
            QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"))  // "₹18,42,600"
            QeetrixStat("Uptime", value: .percent(0.999, fractionDigits: 1...1))  // "99.9%"
            QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"))
            QeetrixStat("Failed payments", value: 42, change: .number(-6, isIncreaseGood: false), note: Text("since yesterday"))
        }
    }
}

/// Slider.md and `QeetrixSlider`.
private struct SliderExamples: View {
    @State private var discount = 20.0
    @State private var budget = 10_000.0...40_000.0
    @State private var threshold = 0.4

    var body: some View {
        VStack {
            QeetrixSlider("Discount", value: $discount, in: 0...50, step: 5, showsValue: true)
            QeetrixSlider(
                "Budget", range: $budget, in: 0...100_000, step: 500, format: .currency("INR", fractionDigits: 0...0), showsBounds: true)
            QeetrixSlider(
                "Alert threshold", value: $threshold, in: 0...1, step: 0.05, format: .percent, showsValue: true,
                description: Text("Alert when usage passes this share of the quota."))
        }
    }
}

@Suite("Dates documentation examples")
struct DatesDocumentationExamplesTests {
    @Test("Every date, time, stat and slider example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: DatePickerExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: DateRangePickerExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: TimePickerExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: CalendarExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: StatExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SliderExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
