import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Heading")
struct HeadingTests {
    @Test("The level sets the default look: 1 heading-lg … 6 title-sm")
    func defaults() {
        #expect((1...6).map { QeetrixHeadingSize.default(for: $0) } == [.headingLg, .headingMd, .headingSm, .titleLg, .titleMd, .titleSm])
        #expect(QeetrixHeading("Billing", level: 3).size == .headingSm)
        #expect(QeetrixHeading("Sign in", level: 1, size: .displaySm).size == .displaySm)
    }

    @Test("Sizes are the display, heading and title roles, all at 600")
    func sizes() {
        #expect(
            QeetrixHeadingSize.allCases.map(\.rawValue)
                == ["display-lg", "display-md", "display-sm", "heading-lg", "heading-md", "heading-sm", "title-lg", "title-md", "title-sm"])
        for size in QeetrixHeadingSize.allCases {
            #expect(size.role.tokens.weight == .semibold)
            #expect(
                size.role.tokens.geometry == (size.rawValue.hasPrefix("display") ? .display : .heading),
                "Geo for display, Base for the rest")
        }
    }

    @Test("Tones: default, subtle, inverse")
    func tones() {
        #expect(QeetrixHeadingTone.allCases.map(\.color) == [.textDefault, .textSubtle, .textInverse])
    }

    @Test("Levels clamp to 1–6 and map to VoiceOver's heading levels")
    func levels() {
        #expect(QeetrixHeading("x", level: 0).level == 1)
        #expect(QeetrixHeading("x", level: 9).level == 6)
        #expect((1...6).map(QeetrixHeading.accessibilityLevel) == [.h1, .h2, .h3, .h4, .h5, .h6])
    }

    @Test("Every size renders")
    func renders() {
        for size in QeetrixHeadingSize.allCases {
            #expect(ImageRenderer(content: QeetrixHeading("Billing", level: 2, size: size, tone: .subtle, truncate: 1)).cgImage != nil)
        }
    }
}
