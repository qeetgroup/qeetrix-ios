import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Circular progress")
struct CircularProgressTests {
    @Test("Sizes are the icon sizes, by the spinner's names: 14, 16, 20 and 24 pt")
    func sizes() {
        #expect(QeetrixCircularProgressSize.allCases.map(\.rawValue) == QeetrixSpinnerSize.allCases.map(\.rawValue))
        #expect(QeetrixCircularProgressSize.allCases.map(\.iconSize.points) == [14, 16, 20, 24])
        #expect(QeetrixCircularProgressSize.allCases.map(\.iconSize) == QeetrixSpinnerSize.allCases.map(\.iconSize))
        #expect(QeetrixCircularProgressRing.width == 2, "spinner.css: border 2px")
    }

    @Test("Tones: the bar's brand, success and danger fills, and warning from --qx-progress-warning")
    func tones() {
        #expect(QeetrixCircularProgressTone.allCases.map(\.rawValue) == ["brand", "success", "warning", "danger"])
        for tone in [QeetrixCircularProgressTone.brand, .success, .danger] {
            let bar = QeetrixProgressTone(rawValue: tone.rawValue)?.indicator
            #expect(tone.indicator(.light) == bar && tone.indicator(.dark) == bar)
        }
        #expect(QeetrixCircularProgressTone.warning.indicator(.light) == .borderWarning)
        #expect(QeetrixCircularProgressTone.warning.indicator(.dark) == .bgWarningBold)
    }

    @Test("Every tone keeps 3:1 against the track in both schemes, warning included; the bold amber wouldn't in light")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            let track = theme.resolve(QeetrixProgressTrack.track(theme.colorScheme))
            for tone in QeetrixCircularProgressTone.allCases {
                let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(tone.indicator(theme.colorScheme)), on: track)
                #expect(ratio >= 3, "\(tone) \(theme.colorScheme): \(ratio)")
            }
        }
        let light = QeetrixTheme.light
        #expect(QeetrixAccessibility.contrastRatio(light.resolve(.bgWarningBold), on: light.resolve(.borderDefault)) < 3)
    }

    @Test("The track all round; the indicator clockwise from twelve o'clock with square ends, the same in right to left")
    func drawing() throws {
        // 100 pt across with an 8 pt line: the line's middle is 46 pt from the centre.
        let ring = QeetrixCircularProgressRing(fraction: 0.25, side: 100, lineWidth: 8, tone: .brand)
        for theme in [QeetrixTheme.light, .dark] {
            for direction in [LayoutDirection.leftToRight, .rightToLeft] {
                let image = try #require(
                    Rendered(ring.environment(\.colorScheme, theme.colorScheme).environment(\.layoutDirection, direction)))
                let indicator = theme.resolve(.bgBrandBold).bytes
                let track = theme.resolve(QeetrixProgressTrack.track(theme.colorScheme)).bytes
                #expect(close(indicator, image.pixel(82, 17)), "Half past twelve to three, \(direction)")
                #expect(close(track, image.pixel(17, 17)), "Nine to twelve, \(direction)")
                #expect(close(track, image.pixel(82, 82)), "Three to six, \(direction)")
                #expect(close(indicator, image.pixel(52, 4)), "Just after twelve, \(direction)")
                #expect(close(track, image.pixel(47, 4)), "Just before twelve, \(direction)")
                #expect(image.pixel(50, 50).a == 0, "Hollow")
            }
        }
    }

    @Test("A timer ring empties over its interval, or with countsDown off fills, and stays in range outside it")
    func timerFraction() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        let period = start...start.addingTimeInterval(30)
        func fraction(_ seconds: TimeInterval, countsDown: Bool = true) -> Double {
            QeetrixCircularProgress.fraction(at: start.addingTimeInterval(seconds), in: period, countsDown: countsDown)
        }
        #expect(fraction(0) == 1 && fraction(15) == 0.5 && fraction(30) == 0)
        #expect(fraction(-5) == 1 && fraction(45) == 0)
        #expect(fraction(0, countsDown: false) == 0 && fraction(18, countsDown: false) == 0.6 && fraction(31, countsDown: false) == 1)
        #expect(QeetrixCircularProgress.fraction(at: start, in: start...start, countsDown: true) == 0)
    }

    @Test("Under Reduce Motion a timer ring steps once a second, on the interval's whole seconds")
    func reducedMotionSteps() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        let schedule = QeetrixCircularProgressTimeline<EmptyView>.reducedSchedule(for: start...start.addingTimeInterval(30))
        let steps = schedule.entries(from: start.addingTimeInterval(12.4), mode: .normal).prefix(3)
        #expect(steps.map { $0.timeIntervalSince(start) } == [12, 13, 14])
    }

    @Test("Without the app's words, VoiceOver reads a timer's time left in whole seconds, in the locale's words")
    func timerValue() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        let period = start...start.addingTimeInterval(30)
        let english = Locale(identifier: "en_US")
        func text(_ seconds: TimeInterval, countsDown: Bool = true) -> String {
            QeetrixCircularProgress.timeText(at: start.addingTimeInterval(seconds), in: period, countsDown: countsDown, locale: english)
        }
        #expect(text(18) == "12 seconds")
        #expect(text(17.6) == "13 seconds", "Counts down to the next whole second, as a countdown shows it")
        #expect(text(29.5) == "1 second")
        #expect(text(40) == "0 seconds")
        #expect(text(18.4, countsDown: false) == "18 seconds")
        let long = start...start.addingTimeInterval(90)
        #expect(QeetrixCircularProgress.timeText(at: start, in: long, countsDown: true, locale: english) == "1 minute, 30 seconds")
    }

    @Test("It renders: by value, by timer, through the style, and without a value as the spinner's ring")
    func renders() {
        let now = Date()
        #expect(ImageRenderer(content: QeetrixCircularProgress(value: 0.4, label: Text("Uploading"))).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCircularProgress(value: 3, total: 4, size: .xl, tone: .success)).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixCircularProgress(
                    timerInterval: now...now.addingTimeInterval(30), tone: .warning, label: Text("Time left"),
                    currentValueLabel: Text("4 seconds left"))
            ).cgImage != nil)
        #expect(ImageRenderer(content: ProgressView(value: 0.25).progressViewStyle(.qeetrixCircular(size: .lg))).cgImage != nil)
        #expect(ImageRenderer(content: ProgressView().progressViewStyle(.qeetrixCircular(tone: .danger))).cgImage != nil)
    }
}
