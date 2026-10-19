import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Text field")
struct TextFieldTests {
    private func state(
        enabled: Bool = true, readOnly: Bool = false, focused: Bool = false, hovered: Bool = false, tone: QeetrixFieldMessage.Tone? = nil
    )
        -> QeetrixFieldState
    {
        QeetrixFieldState(isEnabled: enabled, isReadOnly: readOnly, isFocused: focused, isHovered: hovered, tone: tone)
    }

    @Test("Boundary: rest, hover, then a status, which hover never repaints")
    func boundary() {
        #expect(state().border == QeetrixInputTokens.border)
        #expect(state(hovered: true).border == QeetrixInputTokens.borderHover)
        #expect(state(hovered: true, tone: .warning).border == QeetrixInputTokens.borderWarning)
        #expect(state(tone: .success).border == QeetrixInputTokens.borderSuccess)
        #expect(state(tone: .error).border == QeetrixInputTokens.borderInvalid)
        #expect(state(readOnly: true, hovered: true).border == QeetrixInputTokens.border, "Hover is for editable fields only")
    }

    @Test("Focus turns the boundary and outline to the ring — or to the error colour on an invalid field")
    func focus() {
        #expect(state(focused: true).border == QeetrixInputTokens.borderFocus)
        #expect(state(focused: true).outline == QeetrixInputTokens.borderFocus)
        #expect(state(focused: true, tone: .warning).border == QeetrixInputTokens.borderFocus)
        #expect(state(focused: true, tone: .error).border == QeetrixInputTokens.borderInvalid)
        #expect(state(focused: true, tone: .error).outline == QeetrixInputTokens.borderInvalid)
        #expect(state().outline == nil)
    }

    @Test("Backgrounds: the field, read-only's none, disabled's sunken surface")
    func backgrounds() {
        #expect(state().background == QeetrixInputTokens.background)
        #expect(state(readOnly: true).background == QeetrixInputTokens.backgroundReadonly)
        #expect(state(enabled: false).background == QeetrixInputTokens.backgroundDisabled)
    }

    @Test("Messages: each tone's colour, boundary and icon")
    func messages() {
        #expect(QeetrixFieldMessage.Tone.error.textColor == .textDanger)
        #expect(QeetrixFieldMessage.Tone.warning.textColor == .textWarning)
        #expect(QeetrixFieldMessage.Tone.success.textColor == .textSuccess)
        #expect(QeetrixFieldMessage.Tone.allCases.map(\.icon) == [.circleAlert, .triangleAlert, .circleCheck])
        #expect(QeetrixFieldMessage.error("Enter an email address.") == QeetrixFieldMessage(.error, text: "Enter an email address."))
    }

    @Test("Field text is the web's 16 pt mobile size; labels 14 pt snug medium; messages the caption role")
    func type() {
        #expect(QeetrixTextFieldMetrics.textType.tokens.size == 16)
        #expect(QeetrixFieldMetrics.labelType.tokens.size == 14)
        #expect(QeetrixFieldMetrics.labelType.tokens.lineHeight == QeetrixWebScale.leadingSnug)
        #expect(QeetrixFieldMetrics.labelType.tokens.weight == .medium)
        #expect(QeetrixFieldMetrics.captionType == QeetrixTypeSpec(.caption))
        #expect(QeetrixFieldMetrics.gap == 6)
    }

    @Test("Fields render in every state")
    func renders() {
        let fields: [QeetrixTextField] = [
            QeetrixTextField("Email", text: .constant(""), prompt: Text("name@company.com"), isRequired: true),
            QeetrixTextField("Email", text: .constant("a"), description: Text("Help"), message: .error("Wrong")),
            QeetrixTextField("Tenant", text: .constant("qeet"), isReadOnly: true),
        ]
        for field in fields {
            #expect(ImageRenderer(content: field.frame(width: 300)).cgImage != nil)
        }
    }
}
