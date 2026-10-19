import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Text")
struct TextTests {
    @Test("Headings take the web's mobile sizes in compact width and its sm sizes in regular width")
    func headingSizes() {
        let sizes = { (variant: QeetrixTextVariant, regular: Bool) in QeetrixText.spec(variant, isRegularWidth: regular).tokens.size }
        #expect(sizes(.h1, false) == 24)
        #expect(sizes(.h1, true) == QeetrixTextRole.title.tokens.size)
        #expect(sizes(.h2, false) == 20)
        #expect(sizes(.h2, true) == 24)
        #expect(sizes(.h3, false) == 18)
        #expect(sizes(.h3, true) == QeetrixTextRole.heading.tokens.size)
        #expect(sizes(.h4, false) == 16)
        #expect(sizes(.h4, true) == 16)
    }

    @Test("Headings are semibold in the heading letter style; copy uses the body role")
    func faces() {
        for variant in [QeetrixTextVariant.h1, .h2, .h3, .h4] {
            let tokens = QeetrixText.spec(variant, isRegularWidth: false).tokens
            #expect(tokens.weight == .semibold)
            #expect(tokens.geometry == QeetrixTextRole.heading.tokens.geometry)
        }
        #expect(QeetrixText.spec(.p, isRegularWidth: false) == QeetrixTypeSpec(.body))
        #expect(QeetrixText.spec(.muted, isRegularWidth: true) == QeetrixTypeSpec(.body))
        #expect(QeetrixText.spec(.small, isRegularWidth: false).tokens.size == QeetrixTextRole.label.tokens.size)
        #expect(QeetrixText.spec(.lead, isRegularWidth: false).tokens.lineHeight == QeetrixWebScale.leadingRelaxed)
        let code = QeetrixText.spec(.inlineCode, isRegularWidth: false).tokens
        #expect(code.family == .mono)
        #expect(code.size == QeetrixTextRole.body.tokens.size * QeetrixTypographyTokens.codeFontSize)
    }

    @Test("Colours follow the web variants")
    func colours() {
        #expect(QeetrixText.color(.lead) == .textSecondary)
        #expect(QeetrixText.color(.muted) == .textTertiary)
        #expect(QeetrixText.color(.blockquote) == .textTertiary)
        #expect(QeetrixText.color(.p) == .textPrimary)
        #expect(QeetrixText.color(.h1) == .textPrimary)
    }

    @Test("h1–h4 are VoiceOver headings at their level; nothing else is")
    func headings() {
        #expect(QeetrixTextVariant.allCases.filter(\.isHeading) == [.h1, .h2, .h3, .h4])
        #expect(QeetrixText.headingLevel(.h1) == .h1)
        #expect(QeetrixText.headingLevel(.h4) == .h4)
        #expect(QeetrixText.headingLevel(.p) == .unspecified)
    }

    @Test("Every variant renders")
    func renders() {
        for variant in QeetrixTextVariant.allCases {
            #expect(ImageRenderer(content: QeetrixText("Sign in", variant: variant)).cgImage != nil)
        }
    }
}
