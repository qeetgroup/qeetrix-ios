import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Progress")
struct ProgressTests {
    @Test("Tones: brand while it runs, success once done, danger if it failed — each a bold fill")
    func tones() {
        #expect(QeetrixProgressTone.allCases.map(\.rawValue) == ["brand", "success", "danger"])
        #expect(QeetrixProgressTone.allCases.map(\.indicator) == [.bgBrandBold, .bgSuccessBold, .bgDangerBold])
    }

    @Test("A 4 pt square track, border.default in light and surface.sunken in dark; the indicator fills its fraction")
    func track() throws {
        #expect(QeetrixProgressTrack.height == 4)
        #expect(QeetrixProgressTrack.track(.light) == .borderDefault && QeetrixProgressTrack.track(.dark) == .surfaceSunken)
        for theme in [QeetrixTheme.light, .dark] {
            let image = try #require(
                Rendered(
                    QeetrixProgressTrack(fraction: 0.5, indicator: .bgBrandBold).frame(width: 100).environment(
                        \.colorScheme, theme.colorScheme)))
            #expect(image.height == 4)
            #expect(close(theme.resolve(.bgBrandBold).bytes, image.pixel(25, 2)))
            #expect(close(theme.resolve(QeetrixProgressTrack.track(theme.colorScheme)).bytes, image.pixel(75, 2)))
            #expect(close(theme.resolve(.bgBrandBold).bytes, image.pixel(0, 0)), "Square ends")
        }
    }

    @Test("Every tone's indicator keeps 3:1 against the track in both schemes")
    func indicatorContrast() {
        for theme in [QeetrixTheme.light, .dark] {
            let track = theme.resolve(QeetrixProgressTrack.track(theme.colorScheme))
            for tone in QeetrixProgressTone.allCases {
                let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(tone.indicator), on: track)
                #expect(ratio >= 3, "\(tone) \(theme.colorScheme): \(ratio)")
            }
        }
    }

    @Test("The value is a whole percentage, formatted for the locale")
    func percent() {
        #expect(QeetrixProgressBody.percent(0.4, locale: Locale(identifier: "en_US")) == "40%")
        #expect(QeetrixProgressBody.percent(0.666, locale: Locale(identifier: "en_US")) == "67%")
        let french = QeetrixProgressBody.percent(0.4, locale: Locale(identifier: "fr_FR"))
        #expect(french.hasPrefix("40") && french.hasSuffix("%") && french != "40%")
    }

    @Test("Bars render determinate, indeterminate, with a value, and through the style")
    func renders() {
        #expect(ImageRenderer(content: QeetrixProgress("Uploading", value: 0.4, showsValue: true).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixProgress("Import failed", value: 0.6, tone: .danger).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixProgress(label: nil, value: nil).frame(width: 200)).cgImage != nil)
        #expect(
            ImageRenderer(content: ProgressView(value: 2, total: 4).progressViewStyle(.qeetrix(tone: .success)).frame(width: 200)).cgImage
                != nil)
    }
}
