import SwiftUI
import Testing

@testable import Qeetrix

// Every code here is synthetic: no secret or account is involved.
@MainActor
@Suite("OTP code")
struct OTPCodeTests {
    let start = Date(timeIntervalSinceReferenceDate: 800_000_010)

    @Test("Sizes are qeetrix-android's: md and lg, lg by default")
    func sizes() {
        #expect(QeetrixOTPCodeSize.allCases.map(\.rawValue) == ["md", "lg"])
        let code = QeetrixOTPCode("482913", periodStart: start)
        #expect(code.size == .lg && !code.isHidden && code.label == nil && code.toast == nil)
    }

    @Test("Groups to read back: 123 456, 1234 5678; other even lengths of six or more in halves; anything else whole")
    func groups() {
        #expect(QeetrixOTPCodeTiming.groups("482913") == ["482", "913"])
        #expect(QeetrixOTPCodeTiming.groups("48291375") == ["4829", "1375"])
        #expect(QeetrixOTPCodeTiming.groups("4829137560") == ["48291", "37560"])
        #expect(QeetrixOTPCodeTiming.groups("4829137") == ["4829137"])
        #expect(QeetrixOTPCodeTiming.groups("4829") == ["4829"])
        #expect(QeetrixOTPCodeTiming.groups("") == [""])
        #expect(QeetrixOTPCodeMetrics.hidden("482") == "•••")
    }

    @Test("A code's window runs from its period's start for 30 or 60 seconds")
    func windows() {
        #expect(QeetrixOTPCode("482913", periodStart: start).validity == start...start.addingTimeInterval(30))
        #expect(QeetrixOTPCode("482913", periodStart: start, period: .seconds(60)).validity == start...start.addingTimeInterval(60))
        let window = start...start.addingTimeInterval(30)
        #expect(QeetrixOTPCode("48291375", validity: window).validity == window)
        #expect(QeetrixOTPCodeTiming.validity(from: start, period: .seconds(-5)) == start...start, "Never backwards")
    }

    @Test("The seconds count down in whole seconds, rounded up, from the period to 0")
    func secondsLeft() {
        func left(_ seconds: TimeInterval, period: TimeInterval = 30) -> Int {
            QeetrixOTPCodeTiming.secondsLeft(at: start.addingTimeInterval(seconds), in: start...start.addingTimeInterval(period))
        }
        #expect(left(0) == 30)
        #expect(left(12) == 18 && left(12.4) == 18)
        #expect(left(29.5) == 1)
        #expect(left(30) == 0 && left(45) == 0, "An expired code shows 0 until the app gives the next")
        #expect(left(-5) == 30, "A window not yet started shows its whole length")
        #expect(left(0, period: 60) == 60 && left(55.2, period: 60) == 5)
    }

    @Test("The last 5 seconds are urgent: the ring's warning tone and the seconds in text.warning")
    func urgency() {
        #expect(QeetrixOTPCodeTiming.urgentSeconds == 5)
        #expect(!QeetrixOTPCodeTiming.isUrgent(6))
        #expect(QeetrixOTPCodeTiming.isUrgent(5) && QeetrixOTPCodeTiming.isUrgent(1) && QeetrixOTPCodeTiming.isUrgent(0))
    }

    @Test("The ring's share matches the circular progress's own countdown")
    func ringShare() {
        let window = start...start.addingTimeInterval(30)
        for seconds in [-3.0, 0, 7.5, 12, 29.9, 30, 41] {
            let date = start.addingTimeInterval(seconds)
            #expect(
                QeetrixOTPCodeTiming.fraction(at: date, in: window)
                    == QeetrixCircularProgress.fraction(at: date, in: window, countsDown: true))
        }
        #expect(QeetrixOTPCodeTiming.fraction(at: start, in: start...start) == 0)
    }

    @Test("Fira Code at 500 with tabular figures, at title.lg's size and line (md) or heading.md's (lg)")
    func type() {
        for (size, role) in [(QeetrixOTPCodeSize.md, QeetrixTextRole.titleLg), (.lg, .headingMd)] {
            let spec = QeetrixOTPCodeMetrics.codeType(size)
            #expect(spec.tokens.family == .mono)
            #expect(spec.tokens.weight == .medium)
            #expect(spec.tokens.size == role.tokens.size)
            #expect(spec.tokens.lineHeight == role.tokens.lineHeight)
            #expect(spec.tokens.geometry == nil, "Fira Code has no letter-style axis")
            #expect(spec.textStyle == role.textStyle)
        }
        #expect(QeetrixOTPCodeMetrics.codeType(.md).tokens.size == 20)
        #expect(QeetrixOTPCodeMetrics.codeType(.lg).tokens.size == 28)
    }

    @Test("A 20 pt ring beside an md code, 24 pt beside an lg one")
    func rings() {
        #expect(QeetrixOTPCodeMetrics.ringSize(.md) == .lg && QeetrixOTPCodeMetrics.ringSize(.md).iconSize.points == 20)
        #expect(QeetrixOTPCodeMetrics.ringSize(.lg) == .xl && QeetrixOTPCodeMetrics.ringSize(.lg).iconSize.points == 24)
    }

    @Test("Colours: the code text.default, its dots text.subtle, disabled text.disabled; pressed, the neutral ghost's tint")
    func colours() {
        #expect(QeetrixOTPCodeMetrics.codeColor(isShown: true, isEnabled: true) == .textDefault)
        #expect(QeetrixOTPCodeMetrics.codeColor(isShown: false, isEnabled: true) == .textSubtle)
        #expect(QeetrixOTPCodeMetrics.codeColor(isShown: true, isEnabled: false) == .textDisabled)
        #expect(QeetrixOTPCodeMetrics.background(isPressed: false, isHovered: false, isEnabled: true) == nil)
        #expect(QeetrixOTPCodeMetrics.background(isPressed: true, isHovered: true, isEnabled: true) == .bgNeutralSubtlePressed)
        #expect(QeetrixOTPCodeMetrics.background(isPressed: false, isHovered: true, isEnabled: true) == .bgNeutralSubtle)
        #expect(QeetrixOTPCodeMetrics.background(isPressed: true, isHovered: false, isEnabled: false) == nil)
    }

    @Test("The code, its dots and the urgent seconds keep 4.5:1 on the surfaces and the pressed tint, in both schemes")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for background in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceRaised, .bgNeutralSubtle, .bgNeutralSubtlePressed] {
                for text in [QeetrixColor.textDefault, .textSubtle, .textWarning] {
                    let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(text), on: theme.resolve(background))
                    #expect(ratio >= 4.5, "\(text) on \(background), \(theme.colorScheme): \(ratio)")
                }
            }
        }
    }

    @Test("VoiceOver: the label, the digits one by one, then the time left; Code hidden while hidden")
    func speech() {
        let english = Locale(identifier: "en_US")
        #expect(QeetrixOTPCodeSpeech.digits("482913") == "4 8 2 9 1 3")
        #expect(QeetrixOTPCodeSpeech.digits("48291375") == "4 8 2 9 1 3 7 5")
        #expect(QeetrixOTPCodeSpeech.label(nil, code: "482913", isShown: true) == Text(verbatim: "4 8 2 9 1 3"))
        #expect(QeetrixOTPCodeSpeech.label(nil, code: "482913", isShown: false) == QeetrixOTPCodeSpeech.hidden)
        #expect(QeetrixOTPCodeSpeech.timeLeft(12, locale: english) == "12 seconds left")
        #expect(QeetrixOTPCodeSpeech.timeLeft(1, locale: english) == "1 second left")
        #expect(QeetrixOTPCodeSpeech.timeLeft(60, locale: english) == "1 minute left")
    }

    @Test("With the app's action: no copy, the app's hint once shown, and the reveal hint while hidden")
    func action() {
        var filled: [String] = []
        let code = QeetrixOTPCode("482913", periodStart: start, size: .md, isHidden: true, actionHint: Text(verbatim: "Fills the code")) {
            filled.append($0)
        }
        #expect(code.validity == start...start.addingTimeInterval(30) && code.size == .md && code.isHidden)
        #expect(code.toast == nil && code.onCopied == nil)
        code.action?.run(code.code)
        #expect(filled == ["482913"])
        let window = start...start.addingTimeInterval(60)
        #expect(QeetrixOTPCode("482913", validity: window, actionHint: Text(verbatim: "Fills")) { _ in }.validity == window)
        #expect(QeetrixOTPCode("482913", periodStart: start).action == nil, "Without one, a tap copies")

        let hint = Text(verbatim: "Fills the code")
        #expect(QeetrixOTPCodeSpeech.hint(isShown: true, actionHint: hint) == hint)
        #expect(QeetrixOTPCodeSpeech.hint(isShown: false, actionHint: hint) == QeetrixOTPCodeSpeech.revealHint)
        #expect(QeetrixOTPCodeSpeech.hint(isShown: true, actionHint: nil) == QeetrixOTPCodeSpeech.copyHint)
        #expect(QeetrixOTPCodeSpeech.hint(isShown: false, actionHint: nil) == QeetrixOTPCodeSpeech.revealHint)
    }

    @Test("With the app's action the code draws pixel for pixel as the copying code: groups, ring, seconds, warning, hidden")
    func actionLooksTheSame() throws {
        let window = start...start.addingTimeInterval(30)
        func render(_ size: QeetrixOTPCodeSize, secondsIn: TimeInterval, isHidden: Bool, action: QeetrixOTPCodeAction?) throws -> Rendered {
            let code = QeetrixOTPCode(
                code: "48291375", validity: window, label: nil, size: size, isHidden: isHidden, toast: nil, onCopied: nil, action: action,
                now: start.addingTimeInterval(secondsIn))
            return try #require(Rendered(code.frame(width: 390).environment(\.colorScheme, .light)))
        }
        func differs(_ a: Rendered, _ b: Rendered) -> Bool {
            guard a.width == b.width, a.height == b.height else { return true }
            return (0..<a.height).contains { y in (0..<a.width).contains { x in a.pixel(x, y) != b.pixel(x, y) } }
        }
        let fill = QeetrixOTPCodeAction(hint: Text(verbatim: "Fills the code")) { _ in }
        for size in QeetrixOTPCodeSize.allCases {
            for (secondsIn, isHidden) in [(12.0, false), (27.0, false), (3.0, true)] {
                let copying = try render(size, secondsIn: secondsIn, isHidden: isHidden, action: nil)
                let acting = try render(size, secondsIn: secondsIn, isHidden: isHidden, action: fill)
                #expect(!differs(copying, acting), "\(size) at \(secondsIn) s, hidden: \(isHidden)")
            }
        }
        // The comparison sees a change: the last 5 seconds' warning tone.
        #expect(
            try differs(
                render(.lg, secondsIn: 12, isHidden: false, action: fill), render(.lg, secondsIn: 27, isHidden: false, action: fill)))
    }

    @Test("The input's code helpers still read digits from any script, now on QeetrixOTPCode")
    func inputHelpers() {
        #expect(QeetrixOTPCode.decimalDigit("٧") == 7)
        #expect(QeetrixOTPCode.normalise("48-29 13", validationType: .numeric) == "482913")
    }

    @Test("It renders: six and eight digits, both sizes, hidden, urgent and expired, disabled, right to left and at AX5")
    func renders() {
        let window = start...start.addingTimeInterval(30)
        for size in QeetrixOTPCodeSize.allCases {
            for code in ["482913", "48291375"] {
                for (offset, isHidden) in [(12.0, false), (26.0, false), (31.0, false), (3.0, true)] {
                    let view = QeetrixOTPCode(
                        code: code, validity: window, label: Text(verbatim: "Acme, priya@acme.in"), size: size, isHidden: isHidden,
                        toast: nil,
                        onCopied: nil, now: start.addingTimeInterval(offset))
                    #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
                    #expect(ImageRenderer(content: view.frame(width: 390).environment(\.layoutDirection, .rightToLeft)).cgImage != nil)
                }
            }
        }
        let large = QeetrixOTPCode(
            code: "48291375", validity: window, label: nil, size: .lg, isHidden: false, toast: nil, onCopied: nil, now: start)
        #expect(ImageRenderer(content: large.frame(width: 390).environment(\.dynamicTypeSize, .accessibility5)).cgImage != nil)
        #expect(ImageRenderer(content: large.frame(width: 390).disabled(true)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixOTPCode("482913", periodStart: .now, size: .md)).cgImage != nil, "On the clock")
    }
}
