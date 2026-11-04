import SwiftUI

/// The calendar ``QeetrixCalendar`` and ``QeetrixRangeCalendar`` both draw, as `@qeetrix/react`'s
/// CalendarCore: the month between its arrows, the grid of days, and the months and years behind the
/// title. What a day's selection is (`mark`) and what a pick does are the caller's.
struct QeetrixCalendarCore: View {
    /// The day shown first: the chosen day, or a range's start.
    let initial: QeetrixCalendarDay?
    /// The day the months and years views mark as chosen.
    let chosen: QeetrixCalendarDay?
    let mark: (QeetrixCalendarDay) -> QeetrixCalendarMark?
    let limits: QeetrixCalendarLimits
    let today: QeetrixCalendarDay
    let isReadOnly: Bool
    /// range-calendar.css: the band, and the middle days' look.
    let isRange: Bool
    /// Whether the grid fills the width it's offered (in a picker) or keeps its own (inline).
    let fillsWidth: Bool
    let onPick: (QeetrixCalendarDay) -> Void
    var onPoint: ((QeetrixCalendarDay?) -> Void)? = nil
    var onEscape: (() -> Bool)? = nil

    @State private var focused: QeetrixCalendarDay
    @State private var zoom: QeetrixCalendarZoom = .days
    @State private var hovered: QeetrixCalendarDay?
    @State private var picks = 0
    @FocusState private var hasKeyboardFocus: Bool
    /// VoiceOver's place: moved, as the web moves focus, to the day, month or year a new view opens on.
    @AccessibilityFocusState private var voiceOverFocus: QeetrixCalendarDay?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.locale) private var locale
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 100

    init(
        initial: QeetrixCalendarDay?, chosen: QeetrixCalendarDay?, mark: @escaping (QeetrixCalendarDay) -> QeetrixCalendarMark?,
        limits: QeetrixCalendarLimits, today: QeetrixCalendarDay, isReadOnly: Bool, isRange: Bool, fillsWidth: Bool,
        zoom: QeetrixCalendarZoom = .days, onPick: @escaping (QeetrixCalendarDay) -> Void,
        onPoint: ((QeetrixCalendarDay?) -> Void)? = nil, onEscape: (() -> Bool)? = nil
    ) {
        self.initial = initial
        self.chosen = chosen
        self.mark = mark
        self.limits = limits
        self.today = today
        self.isReadOnly = isReadOnly
        self.isRange = isRange
        self.fillsWidth = fillsWidth
        self.onPick = onPick
        self.onPoint = onPoint
        self.onEscape = onEscape
        // Opens on the chosen day, or today, kept inside the limits — on the days, unless a test asks for
        // the months or years.
        _focused = State(initialValue: limits.clamp(initial ?? today))
        _zoom = State(initialValue: zoom)
    }

    var body: some View {
        let metrics = QeetrixCalendarMetrics(density: density, scale: max(1, scale / 100))
        let title = self.title
        VStack(spacing: QeetrixSpace.gapSm) {
            header(title: title, metrics: metrics)
            // Under the months or years the days are hidden from VoiceOver one by one: hiding the grid
            // would override the weekdays' and blank days' own hiding when it is shown.
            dayGrid(metrics)
                .opacity(zoom == .days ? 1 : 0)
                .allowsHitTesting(zoom == .days)
                // Every view is the same size: the months or years cover the days, which stay in place
                // unseen, so a picker never jumps.
                .overlay {
                    if zoom != .days { panel(metrics) }
                }
                .focusable(isEnabled)
                .focused($hasKeyboardFocus)
                .focusEffectDisabled()
                .onKeyPress(phases: [.down, .repeat]) { press in handle(press.key, shift: press.modifiers.contains(.shift)) }
        }
        .frame(maxWidth: fillsWidth ? .infinity : metrics.ownWidth)
        .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
        // VoiceOver's escape gesture steps back as Escape does; with nothing to undo it dismisses what the
        // calendar is in — a picker's popover, a sheet, a pushed screen — as it would anywhere else. It is
        // always attached: attaching it only while there's something to undo would rebuild the grid, and
        // lose VoiceOver's and the keyboard's place, at the first day of a range. A container, so every day
        // stays its own element.
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) {
            if !escape() { dismiss() }
        }
        // The title is a polite live region on the web: a new month, year or decade is announced.
        .onChange(of: title) { _, newTitle in
            AccessibilityNotification.Announcement(newTitle).post()
        }
        .qeetrixFeedback(.selection, trigger: picks)
        // In a picker, VoiceOver starts on the chosen day, or today, as the web's popover puts focus there.
        .task {
            if fillsWidth { voiceOverFocus = focused }
        }
    }

    // MARK: Header

    private var isRightToLeft: Bool { layoutDirection == .rightToLeft }

    private var firstWeekday: Int { locale.qeetrixCalendarFirstWeekday }

    /// "October 2026", "2026" or "2020 – 2029".
    var title: String {
        switch zoom {
        case .days:
            return QeetrixFormat.calendarMonthTitle(focused, locale: locale)
        case .months:
            return QeetrixFormat.calendarYear(focused.year, locale: locale)
        case .years:
            let decade = QeetrixCalendarModel.decade(focused.year)
            return "\(QeetrixFormat.calendarYear(decade, locale: locale)) – \(QeetrixFormat.calendarYear(decade + 9, locale: locale))"
        }
    }

    private func header(title: String, metrics: QeetrixCalendarMetrics) -> some View {
        HStack(spacing: QeetrixSpace.gapXs) {
            // calendar.css: `[dir="rtl"] .qx-calendar-step .qx-button-icon { scale: -1 1 }` — each arrow
            // points outwards in either direction.
            QeetrixIconButton(
                isRightToLeft ? .chevronRight : .chevronLeft, label: QeetrixCalendarStrings.previous(zoom), tone: .neutral, size: .sm
            ) { step(by: -1) }
            .disabled(QeetrixCalendarModel.isPreviousOut(focused, zoom: zoom, limits: limits))
            titleView(title, metrics: metrics)
                .frame(maxWidth: .infinity)
            QeetrixIconButton(
                isRightToLeft ? .chevronLeft : .chevronRight, label: QeetrixCalendarStrings.next(zoom), tone: .neutral, size: .sm
            ) { step(by: 1) }
            .disabled(QeetrixCalendarModel.isNextOut(focused, zoom: zoom, limits: limits))
        }
    }

    /// The title: in the days and months, a button that opens the years ("October 2026 ⌄"); in the years,
    /// the decade.
    @ViewBuilder
    private func titleView(_ title: String, metrics: QeetrixCalendarMetrics) -> some View {
        if zoom == .years {
            Text(verbatim: title)
                .qeetrixType(QeetrixCalendarMetrics.titleType)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: metrics.title)
                .accessibilityAddTraits(.isHeader)
        } else {
            Button {
                show(.years, at: focused)
            } label: {
                HStack(spacing: QeetrixSpace.gapXs) {
                    Text(verbatim: title)
                        .qeetrixType(QeetrixCalendarMetrics.titleType)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    QeetrixIcon(.chevronDown, size: .sm, shape: .sharp)
                        .foregroundStyle(isEnabled ? QeetrixColor.iconSubtle : QeetrixColor.iconDisabled)
                }
                .padding(.horizontal, QeetrixSpace.insetSm)
                .frame(minHeight: metrics.title)
            }
            .buttonStyle(QeetrixCalendarZoomStyle())
            .qeetrixHitArea()
            .accessibilityLabel(Text(verbatim: QeetrixCalendarStrings.chooseYear(title, locale: locale)))
            .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: Days

    private func dayGrid(_ metrics: QeetrixCalendarMetrics) -> some View {
        let cells = QeetrixCalendarModel.cells(focused, firstWeekday: firstWeekday)
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(QeetrixCalendarModel.weekdays(firstWeekday: firstWeekday), id: \.self) { day in
                    Text(verbatim: QeetrixFormat.calendarWeekday(day, locale: locale))
                        .qeetrixType(QeetrixCalendarMetrics.weekdayType)
                        .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(minWidth: metrics.minimumColumn, idealWidth: metrics.column, maxWidth: .infinity)
                        .frame(height: metrics.weekday)
                }
            }
            // Each day is read with its weekday, so the header would only repeat it.
            .accessibilityHidden(true)
            ForEach(0..<6, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        dayCell(cells[week * 7 + column], metrics: metrics)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ day: QeetrixCalendarDay?, metrics: QeetrixCalendarMetrics) -> some View {
        if let day {
            let isToday = day == today
            let full = QeetrixFormat.calendarFullDate(day, locale: locale)
            QeetrixCalendarDayCell(
                number: QeetrixFormat.calendarDayNumber(day, locale: locale),
                label: isToday ? QeetrixCalendarStrings.today(full, locale: locale) : full,
                state: QeetrixCalendarDayState(
                    mark: mark(day), isToday: isToday, isDisabled: limits.isDisabled(day), isCalendarEnabled: isEnabled,
                    isReadOnly: isReadOnly, isRange: isRange, isHovered: hovered == day, isCursor: hasKeyboardFocus && day == focused),
                metrics: metrics
            ) {
                choose(day)
            }
            .accessibilityHidden(zoom != .days)
            .accessibilityFocused($voiceOverFocus, equals: day)
            .onHover { isInside in hover(day, isInside) }
        } else {
            // A day of another month: blank, a day high.
            Color.clear
                .frame(minWidth: metrics.minimumColumn, idealWidth: metrics.column, maxWidth: .infinity)
                .frame(height: metrics.row)
                .accessibilityHidden(true)
        }
    }

    // MARK: Months and years

    private func panel(_ metrics: QeetrixCalendarMetrics) -> some View {
        let options = QeetrixCalendarModel.options(focused, zoom: zoom, chosen: chosen, today: today, limits: limits)
        return VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { column in
                        option(options[row * 3 + column], metrics: metrics)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private func option(_ option: QeetrixCalendarOption, metrics: QeetrixCalendarMetrics) -> some View {
        let isMonth = zoom == .months
        let text =
            isMonth
            ? QeetrixFormat.calendarMonth(option.day, locale: locale) : QeetrixFormat.calendarYear(option.day.year, locale: locale)
        let spoken = isMonth ? QeetrixFormat.calendarMonthTitle(option.day, locale: locale) : text
        return Button {
            show(isMonth ? .days : .months, at: option.day)
        } label: {
            Text(verbatim: text)
        }
        .buttonStyle(
            QeetrixCalendarOptionStyle(
                state: QeetrixCalendarDayState(
                    mark: option.isSelected ? .single : nil, isToday: option.isCurrent, isDisabled: option.isDisabled,
                    isCalendarEnabled: isEnabled, isReadOnly: false, isRange: false, isHovered: false,
                    isCursor: hasKeyboardFocus && option.isFocused, isOutside: option.isOutside),
                metrics: metrics)
        )
        .disabled(option.isDisabled)
        .accessibilityFocused($voiceOverFocus, equals: option.day)
        .accessibilityLabel(Text(verbatim: spoken))
        .accessibilityAddTraits(option.isSelected ? .isSelected : [])
    }

    // MARK: Moving and choosing

    /// The arrows: a month, a year or a decade, kept inside the limits.
    private func step(by direction: Int) {
        focused = limits.clamp(focused.adding(months: direction * QeetrixCalendarModel.months(per: zoom)))
    }

    private func show(_ newZoom: QeetrixCalendarZoom, at day: QeetrixCalendarDay) {
        guard isEnabled else { return }
        focused = limits.clamp(day)
        zoom = newZoom
        voiceOverFocus = focused
    }

    private func choose(_ day: QeetrixCalendarDay) {
        focused = day
        guard isEnabled, !isReadOnly, !limits.isDisabled(day) else { return }
        picks += 1
        onPick(day)
    }

    private func point(_ day: QeetrixCalendarDay?) {
        guard let onPoint else { return }
        if let day, !isEnabled || isReadOnly || limits.isDisabled(day) { return }
        onPoint(day)
    }

    private func hover(_ day: QeetrixCalendarDay, _ isInside: Bool) {
        if isInside {
            hovered = day
            point(day)
        } else if hovered == day {
            hovered = nil
            point(nil)
        }
    }

    /// Escape goes back to the days, then undoes the caller's half-done choice; only then may a picker
    /// close. Returns whether it did something.
    private func escape() -> Bool {
        if zoom != .days {
            show(.days, at: focused)
            return true
        }
        return onEscape?() ?? false
    }

    /// A hardware keyboard on the focused grid: arrows, Home, End, Page Up and Page Down move (with
    /// Shift, Page Up and Page Down move a year), Return or Space choose, Escape steps back.
    private func handle(_ key: KeyEquivalent, shift: Bool) -> KeyPress.Result {
        guard isEnabled else { return .ignored }
        switch key {
        case .escape:
            return escape() ? .handled : .ignored
        case .return, .space:
            switch zoom {
            case .days: choose(focused)
            case .months: show(.days, at: focused)
            case .years: show(.months, at: focused)
            }
            return .handled
        default:
            break
        }
        guard let move = QeetrixCalendarKey(key) else { return .ignored }
        focused = limits.clamp(
            QeetrixCalendarModel.target(
                of: move, shift: shift, from: focused, zoom: zoom, firstWeekday: firstWeekday, isRightToLeft: isRightToLeft))
        if zoom == .days { point(focused) }
        return .handled
    }
}

extension QeetrixCalendarKey {
    init?(_ key: KeyEquivalent) {
        switch key {
        case .leftArrow: self = .left
        case .rightArrow: self = .right
        case .upArrow: self = .up
        case .downArrow: self = .down
        case .home: self = .home
        case .end: self = .end
        case .pageUp: self = .pageUp
        case .pageDown: self = .pageDown
        default: return nil
        }
    }
}

// MARK: - Metrics and looks

/// The calendar's lengths (calendar.css): days `size.control.md` with 4 pt corners, 1 pt apart; weekday
/// names and the title `size.control.sm` tall. Each grows with Dynamic Type, as the text inside does.
///
/// On iOS each day is the middle of a cell at least 44 pt square, so the cells are touch targets that
/// tile without overlapping: the web's 34 px rows would make extended targets overlap (ADR 0012).
struct QeetrixCalendarMetrics {
    let density: QeetrixDensity
    /// The text scale, at least 1.
    let scale: CGFloat

    /// `.qx-calendar-day { block-size: var(--qx-size-control-md) }`.
    var day: CGFloat { density.sizeControlMd * scale }
    /// `.qx-calendar-cell { padding: 1px }`: the web's column and row.
    var minimumColumn: CGFloat { day + 2 }
    /// A column at the calendar's own size, and every row: a 44 pt target.
    var column: CGFloat { max(QeetrixAccessibility.minimumTouchTarget, day + 2) }
    var row: CGFloat { column }
    /// `.qx-calendar-weekday { block-size: var(--qx-size-control-sm) }`.
    var weekday: CGFloat { density.sizeControlSm * scale }
    /// `.qx-calendar-zoom { block-size: var(--qx-size-control-sm) }`.
    var title: CGFloat { density.sizeControlSm * scale }
    /// `inline-size: fit-content`: as wide as its days.
    var ownWidth: CGFloat { 7 * column }

    /// `.qx-calendar-title`: `label.md` at `title.sm`'s weight.
    static let titleType = QeetrixComponentType.role(.labelMd, QeetrixTextRole.titleSm.tokens.weight)
    /// `.qx-calendar-weekday`: `label.sm`.
    static let weekdayType = QeetrixComponentType.role(.labelSm)
    /// `.qx-calendar-day`: `body.md`, tabular figures.
    static let dayType = QeetrixComponentType.role(.bodyMd)
}

/// A day's (or a month's, or a year's) look, from calendar.css and range-calendar.css.
struct QeetrixCalendarDayState: Hashable {
    let mark: QeetrixCalendarMark?
    let isToday: Bool
    /// Outside the limits or ruled out (`aria-disabled`).
    let isDisabled: Bool
    let isCalendarEnabled: Bool
    let isReadOnly: Bool
    let isRange: Bool
    let isHovered: Bool
    /// The keyboard's day, while the grid has focus.
    let isCursor: Bool
    /// The years either side of a decade (`data-outside`).
    var isOutside = false
    var isPressed = false

    func pressed(_ isPressed: Bool) -> QeetrixCalendarDayState {
        var state = self
        state.isPressed = isPressed
        return state
    }

    /// Filled Ember: the chosen day, or a range's end (`[aria-selected]`, not the middle).
    var isFilled: Bool { mark?.isFilled ?? false }
    var isMiddle: Bool { mark == .middle }
    /// Whether a pointer or a touch can tint it.
    private var reacts: Bool { isCalendarEnabled && !isReadOnly && !isDisabled }

    /// The day's fill.
    var fill: QeetrixColor? {
        if isFilled {
            if !isCalendarEnabled { return .bgDisabled }
            if isReadOnly { return .bgBrandBold }
            return isPressed ? .bgBrandBoldPressed : isHovered ? .bgBrandBoldHover : .bgBrandBold
        }
        guard reacts else { return nil }
        if isMiddle { return isPressed ? .bgBrandSubtlePressed : isHovered ? .bgBrandSubtleHover : nil }
        return isPressed ? .overlayPressed : isHovered ? .overlayHover : nil
    }

    /// The number's colour.
    var foreground: QeetrixColor {
        if isFilled { return isCalendarEnabled ? .textOnBrand : .textDisabled }
        if isDisabled || !isCalendarEnabled { return .textDisabled }
        return isOutside ? .textSubtle : .textDefault
    }

    /// Today's, this month's or this year's thin outline, which a fill takes over.
    var outline: QeetrixColor? {
        guard isToday, !isFilled else { return nil }
        return isCalendarEnabled ? .borderBrand : .borderDisabled
    }

    /// The range's band under the day (range-calendar.css: `bg.brand.subtle`, grey when disabled).
    var band: QeetrixColor? {
        guard isRange, let mark, mark != .single else { return nil }
        return isCalendarEnabled ? .bgBrandSubtle : .bgDisabled
    }
}

/// One day of the grid: the whole cell is its touch target; the day is drawn in the middle, on the
/// range's band when it's in one.
struct QeetrixCalendarDayCell: View {
    let number: String
    let label: String
    let state: QeetrixCalendarDayState
    let metrics: QeetrixCalendarMetrics
    let action: () -> Void

    var body: some View {
        Group {
            if state.isReadOnly {
                QeetrixCalendarDayFace(number: number, state: state, metrics: metrics)
                    .accessibilityElement(children: .ignore)
            } else {
                Button(action: action) {
                    Text(verbatim: number)
                }
                .buttonStyle(QeetrixCalendarDayStyle(state: state, metrics: metrics))
                .disabled(state.isDisabled)
            }
        }
        .accessibilityLabel(Text(verbatim: label))
        .accessibilityAddTraits(state.mark != nil ? .isSelected : [])
    }
}

struct QeetrixCalendarDayStyle: ButtonStyle {
    let state: QeetrixCalendarDayState
    let metrics: QeetrixCalendarMetrics

    func makeBody(configuration: Configuration) -> some View {
        QeetrixCalendarDayFace(state: state.pressed(configuration.isPressed), metrics: metrics) {
            configuration.label
        }
    }
}

/// A day's drawing in its cell.
struct QeetrixCalendarDayFace<Label: View>: View {
    let state: QeetrixCalendarDayState
    let metrics: QeetrixCalendarMetrics
    let label: Label

    init(state: QeetrixCalendarDayState, metrics: QeetrixCalendarMetrics, @ViewBuilder label: () -> Label) {
        self.state = state
        self.metrics = metrics
        self.label = label()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        ZStack {
            if let band = state.band {
                // A day high, across the gutters; from the middle of an end towards the rest of the range.
                // `[data-range="start"]:before { inset-inline-start: 50% }`, `"end"`: `inset-inline-end: 50%`.
                HStack(spacing: 0) {
                    Rectangle().fill(band).opacity(state.mark == .start ? 0 : 1)
                    Rectangle().fill(band).opacity(state.mark == .end ? 0 : 1)
                }
                .frame(height: metrics.day)
                .accessibilityHidden(true)
            }
            label
                .qeetrixType(QeetrixCalendarMetrics.dayType)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(state.foreground)
                .frame(maxWidth: metrics.day)
                .frame(height: metrics.day)
                .background {
                    if let fill = state.fill { shape.fill(fill) }
                }
                .overlay {
                    if let outline = state.outline {
                        shape.strokeBorder(outline, lineWidth: QeetrixBorderWidth.default)
                    }
                }
                .overlay {
                    if state.isCursor { QeetrixCalendarFocusFrame(shape: shape, isOnFill: state.isFilled) }
                }
                .padding(.horizontal, 1)
        }
        .frame(minWidth: metrics.minimumColumn, idealWidth: metrics.column, maxWidth: .infinity)
        .frame(height: metrics.row)
        .contentShape(Rectangle())
        .qeetrixAnimation(.standard, .fast, value: state)
    }
}

extension QeetrixCalendarDayFace where Label == Text {
    init(number: String, state: QeetrixCalendarDayState, metrics: QeetrixCalendarMetrics) {
        self.init(state: state, metrics: metrics) { Text(verbatim: number) }
    }
}

/// The keyboard's frame (calendar.css `:focus-visible`): 2 pt of `border.focus` inside the day, with a
/// surface ring between it and a filled day's Ember.
struct QeetrixCalendarFocusFrame: View {
    let shape: RoundedRectangle
    let isOnFill: Bool

    var body: some View {
        if isOnFill {
            QeetrixInnerFocusFrame(shape: shape)
        } else {
            shape.strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth).accessibilityHidden(true)
        }
    }
}

/// A month or a year in the months and years views (`.qx-calendar-option`): the day's look, a day high
/// and as wide as its cell of a 3 × 4 grid, 4 pt in from its edges; the whole cell is its target.
struct QeetrixCalendarOptionStyle: ButtonStyle {
    let state: QeetrixCalendarDayState
    let metrics: QeetrixCalendarMetrics

    func makeBody(configuration: Configuration) -> some View {
        let state = self.state.pressed(configuration.isPressed)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        configuration.label
            .qeetrixType(QeetrixCalendarMetrics.dayType)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(state.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: metrics.day)
            .background {
                if let fill = state.fill { shape.fill(fill) }
            }
            .overlay {
                if let outline = state.outline { shape.strokeBorder(outline, lineWidth: QeetrixBorderWidth.default) }
            }
            .overlay {
                if state.isCursor { QeetrixCalendarFocusFrame(shape: shape, isOnFill: state.isFilled) }
            }
            // `.qx-calendar-panel .qx-calendar-cell { padding: var(--qx-space-gap-xs) }`.
            .padding(QeetrixSpace.gapXs)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .qeetrixAnimation(.standard, .fast, value: state)
    }
}

/// The title's button (`.qx-calendar-zoom`): no fill at rest, `color.overlay.hover` under a pointer or
/// `color.overlay.pressed` under a touch, 4 pt corners, the focus frame inside.
struct QeetrixCalendarZoomStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixCalendarZoomBody(configuration: configuration)
    }
}

struct QeetrixCalendarZoomBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @State private var isHovered = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        configuration.label
            .background {
                if isEnabled, configuration.isPressed || isHovered {
                    shape.fill(configuration.isPressed ? QeetrixColor.overlayPressed : QeetrixColor.overlayHover)
                }
            }
            .overlay {
                if isFocused { shape.strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth) }
            }
            .onHover { isHovered = $0 }
    }
}

// MARK: - Strings

/// The calendar's built-in strings (`calendar` in `@qeetrix/react`'s catalogue).
enum QeetrixCalendarStrings {
    /// "Previous month", "Previous year" or "Previous 10 years".
    static func previous(_ zoom: QeetrixCalendarZoom) -> Text {
        switch zoom {
        case .days: Text("qeetrix.calendar.previous-month", bundle: .module)
        case .months: Text("qeetrix.calendar.previous-year", bundle: .module)
        case .years: Text("qeetrix.calendar.previous-years", bundle: .module)
        }
    }

    /// "Next month", "Next year" or "Next 10 years".
    static func next(_ zoom: QeetrixCalendarZoom) -> Text {
        switch zoom {
        case .days: Text("qeetrix.calendar.next-month", bundle: .module)
        case .months: Text("qeetrix.calendar.next-year", bundle: .module)
        case .years: Text("qeetrix.calendar.next-years", bundle: .module)
        }
    }

    /// "October 2026, choose year".
    static func chooseYear(_ title: String, locale: Locale) -> String {
        String(localized: "qeetrix.calendar.choose-year", defaultValue: "\(title), choose year", bundle: .module, locale: locale)
    }

    /// "Today, Sunday, 25 October 2026".
    static func today(_ date: String, locale: Locale) -> String {
        String(localized: "qeetrix.calendar.today", defaultValue: "Today, \(date)", bundle: .module, locale: locale)
    }

    /// "Starts Monday, 12 October 2026. Now choose the end date."
    static func rangeStart(_ date: String, locale: Locale) -> String {
        String(
            localized: "qeetrix.calendar.range-start", defaultValue: "Starts \(date). Now choose the end date.", bundle: .module,
            locale: locale)
    }

    /// "Monday, 12 October 2026 to Friday, 16 October 2026".
    static func rangeSelected(_ start: String, _ end: String, locale: Locale) -> String {
        String(localized: "qeetrix.calendar.range-selected", defaultValue: "\(start) to \(end)", bundle: .module, locale: locale)
    }
}
