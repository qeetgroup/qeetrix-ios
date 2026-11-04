import SwiftUI

/// A date in a form, with its label, help text and error — `@qeetrix/react`'s DatePicker in a Field,
/// opening the system's calendar.
///
/// ```swift
/// QeetrixDatePicker("Joining date", selection: $joiningDate, min: .now)
/// QeetrixDatePicker("Delivery", selection: $delivery, min: .now, isDateDisabled: { Calendar.current.isDateInWeekend($0) })
/// ```
///
/// The field is the Qeetrix field box (design rules §8) showing the date in the locale's all-number
/// form, as the web's field writes it — "25/10/2026" in India, "10/25/2026" in the US — in tabular
/// figures, with a sharp `calendar` icon at its end. The whole box is one button; it opens a popover
/// under the field (a sheet on a phone at the accessibility text sizes, or in landscape):
///
/// - **The system's calendar**, `DatePicker` in its graphical style, tinted with `color.text.brand`, in
///   the locale's language, week and the Gregorian calendar. It keeps to `min` and `max`; its month and
///   year wheel reaches a distant date. "Done" sets the date.
/// - **Qeetrix's calendar** (``QeetrixCalendar``) when `isDateDisabled` rules out days, which the system's
///   can't: choosing a day sets it and closes the popover.
///
/// "Clear" empties a date that isn't required. A date is the day it falls on in the environment's time
/// zone, and a chosen day is written as the moment it starts there. VoiceOver reads the field by its
/// label, with the date in words — "25 October 2026" — as its value. Validation is the app's: report a
/// date your rules don't allow with `error`.
public struct QeetrixDatePicker: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: Binding<Date?>
    let min: Date?
    let max: Date?
    let isDateDisabled: ((Date) -> Bool)?
    let placeholder: Text?
    let isReadOnly: Bool
    @State private var isPresented = false
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    /// A date picker with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Date?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, placeholder: placeholder,
            description: description, error: error, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A date picker with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Date?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, placeholder: placeholder,
            description: description, error: error, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A date picker with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the button for VoiceOver.
    ///   - selection: The date, as the moment its day starts in the environment's time zone; `nil` for
    ///     none.
    ///   - min: The earliest day that can be chosen.
    ///   - max: The latest day that can be chosen.
    ///   - isDateDisabled: Rules out more days, such as weekends or holidays; it is given each day's
    ///     start. With it, the field opens Qeetrix's calendar instead of the system's.
    ///   - placeholder: Shown in `color.text.subtlest` while there is no date.
    ///   - description: Help under the field, read by VoiceOver as its hint.
    ///   - error: What to fix, already localised; it replaces the description and marks the field invalid.
    ///   - isRequired: Tells VoiceOver the field is required, and offers no "Clear".
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - isReadOnly: Shows the date without the fill; it can't be changed.
    public init(
        label: Text,
        selection: Binding<Date?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
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
        self.min = min
        self.max = max
        self.isDateDisabled = isDateDisabled
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        let date = selection.wrappedValue
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixPickerField(
                text: date.map { QeetrixFormat.numericDate($0, locale: locale, timeZone: timeZone) },
                spokenText: date.map { QeetrixFormat.date($0, style: .long, locale: locale, timeZone: timeZone) },
                placeholder: placeholder, icon: .calendar, tooltip: QeetrixDatePickerStrings.choose, isReadOnly: isReadOnly,
                isPresented: $isPresented
            ) {
                panel
            }
        }
    }

    /// "Clear", for a date that isn't required.
    private var clear: (@MainActor () -> Void)? {
        guard !context.isRequired, selection.wrappedValue != nil else { return nil }
        let selection = self.selection
        let isPresented = $isPresented
        return {
            selection.wrappedValue = nil
            isPresented.wrappedValue = false
        }
    }

    @ViewBuilder
    private var panel: some View {
        let isPresented = $isPresented
        if isDateDisabled != nil {
            VStack(spacing: QeetrixSpace.gapMd) {
                QeetrixCalendar(selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, fillsWidth: true) {
                    isPresented.wrappedValue = false
                }
                QeetrixPickerActions(clear: clear, done: nil)
            }
        } else {
            QeetrixSystemDatePanel(label: context.label, selection: selection, min: min, max: max, clear: clear) {
                isPresented.wrappedValue = false
            }
        }
    }
}

/// The system's graphical calendar on a draft of the date, which "Done" commits: a change of month or
/// year in its wheel moves the date too, so the popover can't close on every change, as the web's does.
struct QeetrixSystemDatePanel: View {
    let label: Text
    let selection: Binding<Date?>
    let min: Date?
    let max: Date?
    let clear: (@MainActor () -> Void)?
    let dismiss: @MainActor () -> Void
    @State private var draft: Date?
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    init(
        label: Text, selection: Binding<Date?>, min: Date?, max: Date?, clear: (@MainActor () -> Void)?,
        dismiss: @escaping @MainActor () -> Void
    ) {
        self.label = label
        self.selection = selection
        self.min = min
        self.max = max
        self.clear = clear
        self.dismiss = dismiss
    }

    var body: some View {
        let timeZone = self.timeZone
        let bounds = QeetrixSystemDateBounds(min: min, max: max, timeZone: timeZone)
        // Opens on the date, or today, kept inside the limits.
        let draft = Binding<Date> {
            self.draft ?? bounds.clamp(selection.wrappedValue ?? Date())
        } set: {
            self.draft = $0
        }
        VStack(spacing: QeetrixSpace.gapMd) {
            Group {
                switch (bounds.lower, bounds.upper) {
                case let (lower?, upper?):
                    DatePicker(selection: draft, in: lower...upper, displayedComponents: .date) { label }
                case let (lower?, nil):
                    DatePicker(selection: draft, in: lower..., displayedComponents: .date) { label }
                case let (nil, upper?):
                    DatePicker(selection: draft, in: ...upper, displayedComponents: .date) { label }
                case (nil, nil):
                    DatePicker(selection: draft, displayedComponents: .date) { label }
                }
            }
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(QeetrixColor.textBrand)
            .environment(\.calendar, QeetrixSystemDateBounds.calendar(locale: locale, timeZone: timeZone))
            QeetrixPickerActions(clear: clear) {
                selection.wrappedValue = QeetrixCalendarDay(draft.wrappedValue, in: timeZone).start(in: timeZone)
                dismiss()
            }
        }
    }
}

/// The system picker's limits, as moments: from the start of the first day allowed to the last moment
/// of the last.
struct QeetrixSystemDateBounds {
    let lower: Date?
    let upper: Date?

    init(min: Date?, max: Date?, timeZone: TimeZone) {
        let lower = min.map { QeetrixCalendarDay($0, in: timeZone).start(in: timeZone) }
        let upper = max.map { QeetrixCalendarDay($0, in: timeZone).adding(days: 1).start(in: timeZone).addingTimeInterval(-1) }
        self.lower = lower
        // A `max` before `min` leaves only `min`'s day, rather than an empty range.
        if let lower, let upper, upper < lower {
            self.upper = lower
        } else {
            self.upper = upper
        }
    }

    func clamp(_ date: Date) -> Date {
        if let lower, date < lower { return lower }
        if let upper, date > upper { return upper }
        return date
    }

    /// The Gregorian calendar the system's picker draws, starting the week on the locale's first day, as
    /// the web's does whatever the locale's own calendar.
    static func calendar(locale: Locale, timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = timeZone
        calendar.firstWeekday = locale.qeetrixCalendarFirstWeekday + 1
        return calendar
    }
}

/// The date picker's built-in strings (`datePicker` in `@qeetrix/react`'s catalogue).
enum QeetrixDatePickerStrings {
    /// "Choose date" — `datePicker.choose`, the field's pointer tooltip.
    static var choose: Text { Text("qeetrix.date-picker.choose", bundle: .module) }
}
