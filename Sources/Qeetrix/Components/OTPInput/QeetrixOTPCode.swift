import SwiftUI

/// The size of a ``QeetrixOTPCode``, by the names qeetrix-android's `QeetrixOTPCodeSize` shares.
public enum QeetrixOTPCodeSize: String, CaseIterable, Sendable {
    /// The code at `title.lg`'s size (20 pt) with a 20 pt ring: a row in a list of several.
    case md
    /// The code at `heading.md`'s size (28 pt) with a 24 pt ring: one code on its own screen. The default.
    case lg
}

/// A one-time code to read or paste elsewhere, with the time it has left — an authenticator's code,
/// beside ``QeetrixOTPInput``, which takes one.
///
/// ```swift
/// QeetrixOTPCode(account.code, periodStart: step.start, label: Text(verbatim: "Acme, priya@acme.in"), size: .md, toast: $toast)
/// QeetrixOTPCode(recovery.code, validity: recovery.window, isHidden: true, toast: $toast)
/// ```
///
/// - **The code** in Fira Code at weight 500 with tabular figures, in two groups to read back — 123 456,
///   and 1234 5678 for eight digits — `space.gap.md` apart, left to right in every language.
/// - **The time left**: a ``QeetrixCircularProgress`` emptying over the period, and the seconds beside it
///   (`label.md`, tabular, `color.text.subtle`). In the last 5 seconds both take the warning tone. The
///   ring follows the clock smoothly, and under Reduce Motion steps once a second.
/// - **Tap to copy.** The code goes on the clipboard on this device only — never the universal
///   clipboard — and the system removes it after 60 seconds; a light haptic confirms it and, given the
///   screen's toast binding, a "Copied" toast says when it leaves the clipboard. With `isHidden` the code
///   shows as dots until a first tap shows it; the next tap copies, and the next code is hidden again.
/// - **VoiceOver** reads one button: the `label` ("Acme, priya@acme.in"), the digits one by one, then
///   the time left — "Acme, priya@acme.in, 4 8 2 9 1 3, 12 seconds left" — with "Copies the code" (or
///   "Shows the code") as its hint.
///
/// **Qeetrix doesn't compute TOTP.** The app generates the code (RFC 6238) and passes it with its period
/// window, and gives the next code when the window ends: Qeetrix only shows it. The code is marked
/// `privacySensitive()` and never logged. At large text sizes the time moves under the code, and the
/// groups under each other.
public struct QeetrixOTPCode: View {
    let code: String
    let validity: ClosedRange<Date>
    let label: Text?
    let size: QeetrixOTPCodeSize
    let isHidden: Bool
    let toast: Binding<QeetrixToast?>?
    let onCopied: (@MainActor (String) -> Void)?
    /// A fixed clock, for tests and snapshots: the countdown stops there.
    let now: Date?

    init(
        code: String, validity: ClosedRange<Date>, label: Text?, size: QeetrixOTPCodeSize, isHidden: Bool, toast: Binding<QeetrixToast?>?,
        onCopied: (@MainActor (String) -> Void)?, now: Date? = nil
    ) {
        self.code = code
        self.validity = validity
        self.label = label
        self.size = size
        self.isHidden = isHidden
        self.toast = toast
        self.onCopied = onCopied
        self.now = now
    }

    /// A code valid through `validity`, the window its time step covers.
    ///
    /// - Parameters:
    ///   - code: The code, usually six or eight digits.
    ///   - validity: When the code is valid: from the start of its time step to the end.
    ///   - label: Whose code it is, read by VoiceOver before the digits: "Acme, priya@acme.in".
    ///   - size: `lg` on its own screen, `md` in a list.
    ///   - isHidden: Shows dots until a first tap shows the code.
    ///   - toast: The binding the screen's `qeetrixToast(_:)` hosts, to confirm the copy with a toast.
    ///   - onCopied: Runs with the code once it is on the clipboard.
    public init(
        _ code: String,
        validity: ClosedRange<Date>,
        label: Text? = nil,
        size: QeetrixOTPCodeSize = .lg,
        isHidden: Bool = false,
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(code: code, validity: validity, label: label, size: size, isHidden: isHidden, toast: toast, onCopied: onCopied)
    }

    /// A code whose time step starts at `periodStart` and lasts `period`: 30 seconds for most
    /// authenticators, 60 for some.
    public init(
        _ code: String,
        periodStart: Date,
        period: Duration = .seconds(30),
        label: Text? = nil,
        size: QeetrixOTPCodeSize = .lg,
        isHidden: Bool = false,
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            code: code, validity: QeetrixOTPCodeTiming.validity(from: periodStart, period: period), label: label, size: size,
            isHidden: isHidden, toast: toast, onCopied: onCopied)
    }

    public var body: some View {
        QeetrixCopyControl(
            value: { code }, isSensitive: true, resetAfter: QeetrixCopy.resetAfter, toast: toast, onCopied: onCopied
        ) { _, copy in
            QeetrixOTPCodeBody(code: code, validity: validity, label: label, size: size, isHidden: isHidden, now: now, copy: copy)
        }
    }
}

/// The code as a button, redrawn each second of its window.
struct QeetrixOTPCodeBody: View {
    let code: String
    let validity: ClosedRange<Date>
    let label: Text?
    let size: QeetrixOTPCodeSize
    let isHidden: Bool
    let now: Date?
    let copy: @MainActor () -> Void
    @State private var isRevealed = false
    @Environment(\.locale) private var locale

    var body: some View {
        clock { date in
            let secondsLeft = QeetrixOTPCodeTiming.secondsLeft(at: date, in: validity)
            let isShown = !isHidden || isRevealed
            Button {
                if isShown { copy() } else { isRevealed = true }
            } label: {
                QeetrixOTPCodeContent(
                    code: code, isShown: isShown, size: size, secondsLeft: secondsLeft,
                    ring: now.map { .value(QeetrixOTPCodeTiming.fraction(at: $0, in: validity)) } ?? .timer(validity))
            }
            .buttonStyle(QeetrixOTPCodeButtonStyle())
            .accessibilityLabel(QeetrixOTPCodeSpeech.label(label, code: code, isShown: isShown))
            .accessibilityValue(Text(verbatim: QeetrixOTPCodeSpeech.timeLeft(secondsLeft, locale: locale)))
            .accessibilityHint(isShown ? QeetrixOTPCodeSpeech.copyHint : QeetrixOTPCodeSpeech.revealHint)
            .accessibilityAddTraits(.updatesFrequently)
        }
        .privacySensitive()
        // The next code starts hidden again.
        .onChange(of: code) { isRevealed = false }
    }

    @ViewBuilder
    private func clock<Content: View>(@ViewBuilder _ content: @escaping (Date) -> Content) -> some View {
        if let now {
            content(now)
        } else {
            // Each whole second of the window, from its start: the seconds and the tone change on them.
            TimelineView(.periodic(from: validity.lowerBound, by: 1)) { context in content(context.date) }
        }
    }
}

/// How the ring follows the time: the clock itself, or a fixed share for a fixed `now`.
enum QeetrixOTPCodeRing: Equatable {
    case timer(ClosedRange<Date>)
    case value(Double)
}

/// The code's groups and the time left (or, at large text sizes, under it).
struct QeetrixOTPCodeContent: View {
    let code: String
    let isShown: Bool
    let size: QeetrixOTPCodeSize
    let secondsLeft: Int
    let ring: QeetrixOTPCodeRing

    var body: some View {
        // Reflow rather than truncate: side by side, the time under the code, then the groups stacked.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: QeetrixSpace.gapMd) {
                groups(.horizontal)
                time
            }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                groups(.horizontal)
                time
            }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                groups(.vertical)
                time
            }
        }
        .accessibilityHidden(true)  // the button reads the code and the time
    }

    @ViewBuilder
    private func groups(_ axis: Axis) -> some View {
        let layout =
            axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: QeetrixSpace.gapMd)) : AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
        layout {
            ForEach(Array(QeetrixOTPCodeTiming.groups(code).enumerated()), id: \.offset) { _, group in
                QeetrixOTPCodeGroup(text: isShown ? group : QeetrixOTPCodeMetrics.hidden(group), isShown: isShown, size: size)
            }
        }
        // A code reads left to right in every script.
        .environment(\.layoutDirection, .leftToRight)
    }

    private var time: some View {
        let isUrgent = QeetrixOTPCodeTiming.isUrgent(secondsLeft)
        let tone: QeetrixCircularProgressTone = isUrgent ? .warning : .brand
        return HStack(spacing: QeetrixSpace.gapXs) {
            switch ring {
            case let .timer(validity):
                QeetrixCircularProgress(timerInterval: validity, countsDown: true, size: QeetrixOTPCodeMetrics.ringSize(size), tone: tone)
            case let .value(fraction):
                QeetrixCircularProgress(value: fraction, size: QeetrixOTPCodeMetrics.ringSize(size), tone: tone)
            }
            QeetrixOTPCodeSeconds(secondsLeft: secondsLeft, isUrgent: isUrgent)
        }
    }
}

/// One group of digits, or its dots while hidden.
private struct QeetrixOTPCodeGroup: View {
    let text: String
    let isShown: Bool
    let size: QeetrixOTPCodeSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Text(verbatim: text)
            .qeetrixType(QeetrixOTPCodeMetrics.codeType(size))
            .monospacedDigit()
            .foregroundStyle(QeetrixOTPCodeMetrics.codeColor(isShown: isShown, isEnabled: isEnabled))
            .lineLimit(1)
            .fixedSize()
    }
}

/// The seconds beside the ring, in the locale's digits.
private struct QeetrixOTPCodeSeconds: View {
    let secondsLeft: Int
    let isUrgent: Bool
    @Environment(\.locale) private var locale

    var body: some View {
        Text(verbatim: QeetrixFormat.number(secondsLeft, locale: locale))
            .qeetrixTextStyle(.labelMd)
            .monospacedDigit()
            .foregroundStyle(isUrgent ? QeetrixColor.textWarning : QeetrixColor.textSubtle)
            .fixedSize()
    }
}

/// The code's press: the neutral ghost button's tints, `space.inset.sm` and `space.inset.xs` round the
/// code without moving it, with the focus frame inside them; at least 44 pt to touch.
struct QeetrixOTPCodeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixOTPCodeButtonBody(configuration: configuration)
    }
}

private struct QeetrixOTPCodeButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        let fill = QeetrixOTPCodeMetrics.background(isPressed: configuration.isPressed, isHovered: isHovered, isEnabled: isEnabled)
        configuration.label
            .background {
                if let fill { shape.fill(fill).modifier(QeetrixOTPCodeTintInsets()) }
            }
            .overlay {
                if isFocused { QeetrixInnerFocusFrame(shape: shape).modifier(QeetrixOTPCodeTintInsets()) }
            }
            .qeetrixHitArea()
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
            .qeetrixAnimation(.standard, .fast, value: isHovered)
    }
}

/// The tint reaches past the code by `space.inset.sm` at the sides and `space.inset.xs` above and below.
private struct QeetrixOTPCodeTintInsets: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.horizontal, -QeetrixSpace.insetSm).padding(.vertical, -QeetrixSpace.insetXs)
    }
}

/// The code's type, colours and ring.
enum QeetrixOTPCodeMetrics {
    /// A hidden character.
    static let hiddenCharacter: Character = "•"

    /// Fira Code (`code.md`'s family) at weight 500 (`label.md`'s), at the size and on the line of
    /// `title.lg` (`md`) or `heading.md` (`lg`), scaling as that role does. Fira Code has no letter
    /// style axis.
    static func codeType(_ size: QeetrixOTPCodeSize) -> QeetrixTypeSpec {
        let role: QeetrixTextRole = size == .lg ? .headingMd : .titleLg
        let tokens = role.tokens
        return QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: QeetrixTextRole.codeMd.tokens.family, size: tokens.size, weight: QeetrixTextRole.labelMd.tokens.weight,
                lineHeight: tokens.lineHeight, letterSpacing: 0, geometry: nil),
            scalesLike: role.textStyle)
    }

    /// The ring: 20 pt (`lg`) beside an `md` code, 24 pt (`xl`) beside an `lg` one.
    static func ringSize(_ size: QeetrixOTPCodeSize) -> QeetrixCircularProgressSize {
        size == .lg ? .xl : .lg
    }

    /// `color.text.default`; the dots `color.text.subtle`; disabled `color.text.disabled`.
    static func codeColor(isShown: Bool, isEnabled: Bool) -> QeetrixColor {
        guard isEnabled else { return .textDisabled }
        return isShown ? .textDefault : .textSubtle
    }

    /// The ghost neutral button's tints (button.css): `bg.neutral.subtle-pressed` pressed,
    /// `bg.neutral.subtle` under a pointer.
    static func background(isPressed: Bool, isHovered: Bool, isEnabled: Bool) -> QeetrixColor? {
        guard isEnabled else { return nil }
        if isPressed { return .bgNeutralSubtlePressed }
        return isHovered ? .bgNeutralSubtle : nil
    }

    /// A group as dots, one per character.
    static func hidden(_ group: String) -> String {
        String(repeating: hiddenCharacter, count: group.count)
    }
}

/// The code's window and its groups.
enum QeetrixOTPCodeTiming {
    /// The last seconds, in the warning tone.
    static let urgentSeconds = 5

    /// The window from `start`, `period` long.
    static func validity(from start: Date, period: Duration) -> ClosedRange<Date> {
        start...start.addingTimeInterval(max(0, QeetrixCopyEntry.seconds(period)))
    }

    /// Whole seconds left at `date`, rounded up as a countdown shows them, from the window's length down
    /// to 0.
    static func secondsLeft(at date: Date, in validity: ClosedRange<Date>) -> Int {
        let length = validity.upperBound.timeIntervalSince(validity.lowerBound)
        let left = min(max(validity.upperBound.timeIntervalSince(date), 0), max(length, 0))
        return Int(left.rounded(.up))
    }

    /// The share of the window still to run at `date`, as the ring shows it.
    static func fraction(at date: Date, in validity: ClosedRange<Date>) -> Double {
        let length = validity.upperBound.timeIntervalSince(validity.lowerBound)
        guard length > 0 else { return 0 }
        return 1 - min(max(date.timeIntervalSince(validity.lowerBound) / length, 0), 1)
    }

    static func isUrgent(_ secondsLeft: Int) -> Bool {
        secondsLeft <= urgentSeconds
    }

    /// How the code is split to read back: 123 456; 1234 5678; any other even length of six or more in
    /// halves; anything else whole.
    static func groups(_ code: String) -> [String] {
        guard code.count >= 6, code.count.isMultiple(of: 2) else { return [code] }
        return [String(code.prefix(code.count / 2)), String(code.suffix(code.count / 2))]
    }
}

/// What VoiceOver reads.
enum QeetrixOTPCodeSpeech {
    /// The digits one by one: "4 8 2 9 1 3".
    static func digits(_ code: String) -> String {
        code.map(String.init).joined(separator: " ")
    }

    /// The label, then the digits — or "Code hidden" while hidden.
    static func label(_ label: Text?, code: String, isShown: Bool) -> Text {
        let code = isShown ? Text(verbatim: digits(code)) : hidden
        guard let label else { return code }
        return label + Text(verbatim: ", ") + code
    }

    /// "12 seconds left", in the locale's words.
    static func timeLeft(_ seconds: Int, locale: Locale) -> String {
        let duration = QeetrixFormat.duration(.seconds(seconds), style: .long, locale: locale)
        return String(localized: "qeetrix.otp-code.time-left", defaultValue: "\(duration) left", bundle: .module)
    }

    /// "Code hidden".
    static var hidden: Text { Text("qeetrix.otp-code.hidden", bundle: .module) }
    /// "Copies the code".
    static var copyHint: Text { Text("qeetrix.otp-code.copy-hint", bundle: .module) }
    /// "Shows the code".
    static var revealHint: Text { Text("qeetrix.otp-code.reveal-hint", bundle: .module) }
}
