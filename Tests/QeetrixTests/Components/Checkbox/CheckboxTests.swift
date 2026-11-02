import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Checkbox")
struct CheckboxTests {
    @Test("Mixed wins over on: a partly checked group shows a dash")
    func marks() {
        #expect(QeetrixCheckboxMark(isOn: false, isMixed: false) == .unchecked)
        #expect(QeetrixCheckboxMark(isOn: true, isMixed: false) == .checked)
        #expect(QeetrixCheckboxMark(isOn: false, isMixed: true) == .mixed)
        #expect(QeetrixCheckboxMark(isOn: true, isMixed: true) == .mixed)
    }

    private func box(_ mark: QeetrixCheckboxMark, hovered: Bool = false, enabled: Bool = true, invalid: Bool = false) -> QeetrixCheckboxBox
    {
        QeetrixCheckboxBox(mark: mark, isHovered: hovered, isEnabled: enabled, isInvalid: invalid)
    }

    @Test("checkbox.css: a 16 pt box on bg.input with a strong edge; Ember when checked or mixed")
    func colours() {
        #expect(QeetrixCheckboxBox.side == 16)
        #expect(QeetrixCheckboxBox.markSize == .xs2 && QeetrixCheckboxBox.markStroke.width == 3)
        #expect((box(.unchecked).fill, box(.unchecked).border) == (.bgInput, .borderStrong))
        #expect(box(.unchecked, hovered: true).border == .borderStrongHover)
        #expect(box(.unchecked, invalid: true).border == .borderDanger)
        #expect(box(.unchecked, hovered: true, invalid: true).border == .borderDanger)
        for mark in [QeetrixCheckboxMark.checked, .mixed] {
            // Invalid keeps the danger edge checked and hovered, on the Ember fill (QTRX-161).
            #expect((box(mark, invalid: true).fill, box(mark, invalid: true).border) == (.bgBrandBold, .borderDanger))
            #expect(box(mark, hovered: true, invalid: true).border == .borderDanger)
            #expect(box(mark, enabled: false, invalid: true).border == .borderDisabled)
            #expect((box(mark).fill, box(mark).border) == (.bgBrandBold, .bgBrandBold))
            #expect((box(mark, hovered: true).fill, box(mark, hovered: true).border) == (.bgBrandBoldHover, .bgBrandBoldHover))
            #expect((box(mark, enabled: false).fill, box(mark, enabled: false).border) == (.bgDisabled, .borderDisabled))
        }
        #expect((box(.unchecked, enabled: false).fill, box(.unchecked, enabled: false).border) == (.bgDisabled, .borderDisabled))
    }

    @Test("The box is 16 pt; a checked one fills with Ember")
    func drawn() throws {
        let image = try #require(Rendered(box(.checked).environment(\.colorScheme, .light)))
        #expect(image.width == 16 && image.height == 16)
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(2, 8)))
    }

    @Test("A checkbox row is a 44 pt target")
    func target() throws {
        let rendered = try #require(Rendered(QeetrixCheckbox("Email", isOn: .constant(true)).frame(width: 300)))
        #expect(rendered.height >= Int(QeetrixAccessibility.minimumTouchTarget))
    }

    @Test("Checkboxes render on, off, mixed, described and disabled")
    func renders() {
        struct Item { var isOn: Bool }
        let items: Binding<[Item]> = .constant([Item(isOn: true), Item(isOn: false)])
        #expect(
            ImageRenderer(content: QeetrixCheckbox("Email", isOn: .constant(true), description: Text("Receipts")).frame(width: 300)).cgImage
                != nil)
        #expect(ImageRenderer(content: QeetrixCheckbox("All", sources: items, isOn: \.isOn).frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCheckbox("Email", isOn: .constant(false)).disabled(true).frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(content: Toggle("Email", isOn: .constant(true)).toggleStyle(.qeetrixCheckbox).frame(width: 300)).cgImage != nil)
    }
}
