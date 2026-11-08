import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Text field and the input box")
struct TextFieldTests {
    private func state(
        enabled: Bool = true, readOnly: Bool = false, focused: Bool = false, hovered: Bool = false, invalid: Bool = false
    )
        -> QeetrixInputState
    {
        QeetrixInputState(isEnabled: enabled, isReadOnly: readOnly, isFocused: focused, isHovered: hovered, isInvalid: invalid)
    }

    @Test("Rest and hover: the neutral fill, its hover step, and a 1 pt strong bottom line (input.css)")
    func rest() {
        #expect(state().background == .bgNeutralSubtle)
        #expect(state().bottomLine == .borderStrong)
        #expect(state().frame == nil)
        #expect(state(hovered: true).background == .bgNeutralSubtleHover)
        #expect(state(hovered: true).bottomLine == .borderStrong)
    }

    @Test("Focus: a 2 pt Ember frame replaces the line, on the resting fill")
    func focus() {
        #expect(state(focused: true).frame == .borderFocus)
        #expect(state(focused: true).bottomLine == nil)
        #expect(state(focused: true, hovered: true).background == .bgNeutralSubtle)
        // Focus wins over invalid, as the web's rule order does.
        #expect(state(focused: true, invalid: true).frame == .borderFocus)
    }

    @Test("Invalid: a 2 pt danger frame in place of the line")
    func invalid() {
        #expect(state(invalid: true).frame == .borderDanger)
        #expect(state(invalid: true).bottomLine == nil)
    }

    @Test("Read-only: no fill and the editable line, border.strong; disabled: the disabled fill, line and text")
    func readOnlyAndDisabled() {
        #expect(state(readOnly: true).background == nil)
        #expect(state(readOnly: true).bottomLine == .borderStrong)
        #expect(state(readOnly: true, invalid: true).frame == nil)
        #expect(state(enabled: false).background == .bgDisabled)
        #expect(state(enabled: false).bottomLine == .borderDisabled)
        #expect(state(enabled: false).foreground == .textDisabled)
        #expect(state(enabled: false, focused: true, invalid: true).frame == nil)
        #expect(state().foreground == .textDefault)
    }

    @Test("input.css metrics: size.control.lg tall, 12 pt padding, 8 pt to an adornment, body.md, subtlest placeholder")
    func metrics() {
        #expect(QeetrixInputMetrics.padding == 12)
        #expect(QeetrixInputMetrics.gap == 8)
        #expect(QeetrixInputMetrics.textType == QeetrixTypeSpec(.bodyMd))
        #expect(QeetrixInputMetrics.placeholder == .textSubtlest)
        for density in QeetrixDensity.allCases {
            #expect(QeetrixInputMetrics.height(density) == density.sizeControlLg)
        }
    }

    @Test("4 pt top corners and a square bottom")
    func shape() {
        let shape = QeetrixInputSurface.shape
        let path = shape.path(in: CGRect(x: 0, y: 0, width: 100, height: 40))
        #expect(!path.contains(CGPoint(x: 0.3, y: 0.3)), "Rounded top")
        #expect(path.contains(CGPoint(x: 0.3, y: 39.7)), "Square bottom")
    }

    @Test("The box draws the fill, and the bottom line in border.strong")
    func drawn() throws {
        let field = QeetrixTextField("Email", text: .constant(""), isLabelHidden: true).frame(width: 200).environment(\.colorScheme, .light)
        let image = try #require(Rendered(field))
        #expect(image.height == 40)
        // In the 12 pt padding: on the Mac host ImageRenderer draws the platform text field as a placeholder.
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtle).bytes, image.pixel(6, 20)))
        #expect(close(QeetrixTheme.light.resolve(.borderStrong).bytes, image.pixel(6, 39)))
    }

    @Test("Fields render in every state, with an icon and affixes")
    func renders() {
        let fields: [QeetrixTextField] = [
            QeetrixTextField("Trade name", text: .constant(""), prompt: Text("e.g. Acme Pvt Ltd"), isOptional: true),
            QeetrixTextField("Email", text: .constant("a"), description: Text("Help"), error: "Enter a work email"),
            QeetrixTextField("Tenant", text: .constant("qeet"), isReadOnly: true),
            QeetrixTextField("Amount", text: .constant("100"), startAdornment: Text("₹"), endAdornment: Text("per seat")),
            QeetrixTextField("Search", text: .constant(""), icon: .search, isLabelHidden: true),
        ]
        for field in fields {
            #expect(ImageRenderer(content: field.frame(width: 300)).cgImage != nil)
        }
    }
}
