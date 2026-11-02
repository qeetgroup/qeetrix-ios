import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// A time of day in a form, with its label, help text and error, opening the system's time wheel. iOS
/// only: `@qeetrix/react` has no time field yet (07-components.md, "TimeField, only when a screen needs
/// it"), so it is built as ``QeetrixDatePicker`` is, and as Android's `QeetrixTimeField`.
///
/// ```swift
/// QeetrixTimePicker("Reminder", selection: $reminder, minuteStep: 15)
/// ```
///
/// The field is the Qeetrix field box showing the time as ``QeetrixFormat/time(_:style:locale:timeZone:)``
/// writes it — "2:30 pm" or "14:30" — in tabular figures, with a sharp `clock` icon at its end. The
/// whole box is one button; it opens a popover under the field (a sheet on a phone at the accessibility
/// text sizes, or in landscape) with the system's time wheel, tinted with `color.text.brand`, which
/// shows 12 or 24 hours as the person has set the device. "Done" sets the time; "Clear" empties one
/// that isn't required.
///
/// `minuteStep` offers the minutes in steps — 15 for quarter hours — through `UIDatePicker`'s
/// `minuteInterval`, which SwiftUI's `DatePicker` doesn't have. It must divide an hour (1, 2, 3, 4, 5,
/// 6, 10, 12, 15, 20 or 30); any other step is 1, as UIKit treats it. The time set is rounded to the
/// step, so a time that didn't come from the wheel (the first one offered, from the clock) is a step's
/// time too.
///
/// The time is set on the day `selection` already has, or today's, in the environment's time zone;
/// seconds are zero. VoiceOver reads the field by its label, with the time as its value.
public struct QeetrixTimePicker: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: Binding<Date?>
    let minuteStep: Int
    let placeholder: Text?
    let isReadOnly: Bool
    @State private var isPresented = false
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    /// A time picker with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Date?>,
        minuteStep: Int = 1,
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, minuteStep: minuteStep, placeholder: placeholder, description: description,
            error: error, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A time picker with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Date?>,
        minuteStep: Int = 1,
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, minuteStep: minuteStep, placeholder: placeholder, description: description,
            error: error, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A time picker with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the button for VoiceOver.
    ///   - selection: The time, on its day in the environment's time zone; `nil` for none.
    ///   - minuteStep: The minutes the wheel offers, in steps that divide an hour: 1 by default.
    ///   - placeholder: Shown in `color.text.subtlest` while there is no time.
    ///   - description: Help under the field, read by VoiceOver as its hint.
    ///   - error: What to fix, already localised; it replaces the description and marks the field invalid.
    ///   - isRequired: Tells VoiceOver the field is required, and offers no "Clear".
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - isReadOnly: Shows the time without the fill; it can't be changed.
    public init(
        label: Text,
        selection: Binding<Date?>,
        minuteStep: Int = 1,
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.selection = selection
        self.minuteStep = QeetrixTimePickerStep.valid(minuteStep)
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        let time = selection.wrappedValue.map { QeetrixFormat.time($0, locale: locale, timeZone: timeZone) }
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixPickerField(
                text: time, spokenText: time, placeholder: placeholder, icon: .clock, tooltip: QeetrixTimePickerStrings.choose,
                isReadOnly: isReadOnly, isPresented: $isPresented
            ) {
                QeetrixTimePanel(selection: selection, minuteStep: minuteStep, clear: clear) { [isPresented = $isPresented] in
                    isPresented.wrappedValue = false
                }
            }
        }
    }

    /// "Clear", for a time that isn't required.
    private var clear: (@MainActor () -> Void)? {
        guard !context.isRequired, selection.wrappedValue != nil else { return nil }
        let selection = self.selection
        let isPresented = $isPresented
        return {
            selection.wrappedValue = nil
            isPresented.wrappedValue = false
        }
    }
}

/// The wheel on a draft of the time, which "Done" sets, rounded to the step, on the selection's day.
struct QeetrixTimePanel: View {
    let selection: Binding<Date?>
    let minuteStep: Int
    let clear: (@MainActor () -> Void)?
    let dismiss: @MainActor () -> Void
    @State private var draft: Date?
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    var body: some View {
        let timeZone = self.timeZone
        let minuteStep = self.minuteStep
        // Opens on the time, or now, on a step.
        let draft = Binding<Date> {
            self.draft ?? QeetrixTimePickerStep.rounded(selection.wrappedValue ?? Date(), to: minuteStep, in: timeZone)
        } set: {
            self.draft = $0
        }
        VStack(spacing: QeetrixSpace.gapMd) {
            QeetrixTimeWheel(date: draft, minuteStep: minuteStep, locale: locale, timeZone: timeZone)
            QeetrixPickerActions(clear: clear) {
                selection.wrappedValue = QeetrixTimePickerStep.time(
                    of: draft.wrappedValue, on: selection.wrappedValue ?? Date(), step: minuteStep, in: timeZone)
                dismiss()
            }
        }
    }
}

/// The minute step's arithmetic.
enum QeetrixTimePickerStep {
    /// The steps `UIDatePicker.minuteInterval` takes: those that divide an hour, up to 30.
    static let steps = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30]

    /// The step, or 1 for one UIKit wouldn't take.
    static func valid(_ step: Int) -> Int {
        steps.contains(step) ? step : 1
    }

    /// The nearest time on a step, the seconds dropped, wrapping past midnight within the day (23:58 in
    /// fives is 00:00), as Android's `snapToStep`.
    static func rounded(_ date: Date, to step: Int, in timeZone: TimeZone) -> Date {
        let calendar = QeetrixCalendarDay.calendar(timeZone)
        let parts = calendar.dateComponents([.hour, .minute, .second], from: date)
        let seconds = (parts.hour ?? 0) * 3600 + (parts.minute ?? 0) * 60 + (parts.second ?? 0)
        let stepSeconds = valid(step) * 60
        let snapped = ((seconds + stepSeconds / 2) / stepSeconds * stepSeconds) % 86_400
        return QeetrixCalendarDay(date, in: timeZone).start(in: timeZone).qeetrixTimePicker(adding: snapped, in: timeZone)
    }

    /// `time`'s hour and minute, rounded to the step, on `day`'s day.
    static func time(of time: Date, on day: Date, step: Int, in timeZone: TimeZone) -> Date {
        let calendar = QeetrixCalendarDay.calendar(timeZone)
        let rounded = Self.rounded(time, to: step, in: timeZone)
        let parts = calendar.dateComponents([.hour, .minute], from: rounded)
        let seconds = (parts.hour ?? 0) * 3600 + (parts.minute ?? 0) * 60
        return QeetrixCalendarDay(day, in: timeZone).start(in: timeZone).qeetrixTimePicker(adding: seconds, in: timeZone)
    }
}

extension Date {
    /// A wall-clock time on this day's start: the hour and minute set through the calendar, so a
    /// daylight-saving change in the day doesn't move it by an hour.
    fileprivate func qeetrixTimePicker(adding seconds: Int, in timeZone: TimeZone) -> Date {
        let calendar = QeetrixCalendarDay.calendar(timeZone)
        return calendar.date(bySettingHour: seconds / 3600, minute: seconds % 3600 / 60, second: 0, of: self)
            ?? addingTimeInterval(TimeInterval(seconds))
    }
}

#if canImport(UIKit)
    /// The system's time wheel, `UIDatePicker` in its wheels style — SwiftUI's `DatePicker` has no
    /// `minuteInterval`. It follows the environment's locale (and with it the device's 12 or 24 hours)
    /// and time zone, in the Gregorian calendar.
    struct QeetrixTimeWheel: UIViewRepresentable {
        let date: Binding<Date>
        let minuteStep: Int
        let locale: Locale
        let timeZone: TimeZone

        func makeUIView(context: Context) -> UIDatePicker {
            let picker = UIDatePicker()
            picker.datePickerMode = .time
            picker.preferredDatePickerStyle = .wheels
            picker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
            return picker
        }

        func updateUIView(_ picker: UIDatePicker, context: Context) {
            context.coordinator.date = date
            picker.minuteInterval = minuteStep
            picker.locale = locale
            picker.timeZone = timeZone
            picker.calendar = QeetrixCalendarDay.calendar(timeZone)
            picker.tintColor = UIColor { traits in
                UIColor(QeetrixColor.textBrand.color(for: traits.userInterfaceStyle == .dark ? .dark : .light))
            }
            if abs(picker.date.timeIntervalSince(date.wrappedValue)) >= 1 {
                picker.setDate(date.wrappedValue, animated: false)
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, uiView picker: UIDatePicker, context: Context) -> CGSize? {
            let natural = picker.intrinsicContentSize
            return CGSize(width: proposal.width ?? natural.width, height: natural.height)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(date: date)
        }

        @MainActor
        final class Coordinator: NSObject {
            var date: Binding<Date>

            init(date: Binding<Date>) {
                self.date = date
            }

            @objc func changed(_ picker: UIDatePicker) {
                date.wrappedValue = picker.date
            }
        }
    }
#else
    /// On the Mac host, where there is no `UIDatePicker`, SwiftUI's hour-and-minute picker; it offers every
    /// minute, and the time set is rounded to the step. The Mac is a development host only.
    struct QeetrixTimeWheel: View {
        let date: Binding<Date>
        let minuteStep: Int
        let locale: Locale
        let timeZone: TimeZone

        var body: some View {
            DatePicker(selection: date, displayedComponents: .hourAndMinute) { EmptyView() }
                .labelsHidden()
                .environment(\.locale, locale)
                .environment(\.timeZone, timeZone)
        }
    }
#endif

/// The time picker's built-in strings. iOS only: `@qeetrix/react` has no time field.
enum QeetrixTimePickerStrings {
    /// "Choose time", the field's pointer tooltip, after the web's "Choose date".
    static var choose: Text { Text("qeetrix.time-picker.choose", bundle: .module) }
}
