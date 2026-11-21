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
            // Invalid keeps the danger edge checked and hovered, on the Ember fill.
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

    @Test("A bare checkbox is the box's 16 × 16 pt at any width offered, and takes a tap 44 pt round it")
    func bareSize() throws {
        func size(_ view: some View) throws -> (Int, Int) {
            let renderer = ImageRenderer(content: view)
            renderer.proposedSize = ProposedViewSize(width: 300, height: 100)
            renderer.scale = 1
            let image = try #require(renderer.cgImage)
            return (image.width, image.height)
        }
        struct Item { var isOn: Bool }
        let items: Binding<[Item]> = .constant([Item(isOn: true), Item(isOn: false)])
        #expect(try size(QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: Text("Also report Meera"))) == (16, 16))
        #expect(try size(QeetrixCheckbox(isOn: .constant(false), accessibilityLabel: Text("Also report Meera")).disabled(true)) == (16, 16))
        #expect(try size(QeetrixCheckbox(sources: items, isOn: \.isOn, accessibilityLabel: Text("All channels"))) == (16, 16))
        // The labelled checkbox is a row: it takes the width it's offered.
        #expect(try size(QeetrixCheckbox("Also report Meera", isOn: .constant(true))).0 == 300)
        // The hit area spills 14 pt past each edge, without moving layout.
        let box = CGRect(x: 0, y: 0, width: QeetrixCheckboxBox.side, height: QeetrixCheckboxBox.side)
        #expect(QeetrixHitArea().path(in: box).boundingRect == CGRect(x: -14, y: -14, width: 44, height: 44))
    }

    @Test("A bare checkbox draws as the labelled one's box: Ember when checked, the danger edge in an invalid group")
    func bareDrawn() throws {
        let label = Text("Also report Meera")
        let checked = try #require(
            Rendered(QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: label).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, checked.pixel(2, 8)))
        let invalid = try #require(
            Rendered(
                QeetrixCheckbox(isOn: .constant(false), accessibilityLabel: label).environment(\.qeetrixGroupIsInvalid, true)
                    .environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, invalid.pixel(0, 8), tolerance: 40))
        #expect(close(QeetrixTheme.light.resolve(.bgInput).bytes, invalid.pixel(8, 8)))
    }

    #if os(macOS)
        @Test("A bare checkbox is read as the system's toggle, named by its accessibility label, with its state")
        func bareAccessibility() {
            struct Item { var isOn: Bool }
            let label = Text("Also report Meera")
            let on = ListsAccessibilityTree.elements(of: QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: label))
            #expect(on.map(\.text) == ["Also report Meera"], "\(on)")
            #expect(on.map(\.role) == ["AXCheckBox"])
            #expect(on.map(\.value) == ["1"])
            let off = ListsAccessibilityTree.elements(of: QeetrixCheckbox(isOn: .constant(false), accessibilityLabel: label))
            #expect(off.map(\.value) == ["0"])
            let items: Binding<[Item]> = .constant([Item(isOn: true), Item(isOn: false)])
            let mixed = ListsAccessibilityTree.elements(
                of: QeetrixCheckbox(sources: items, isOn: \.isOn, accessibilityLabel: Text("All channels")))
            #expect(mixed.map(\.text) == ["All channels"], "\(mixed)")
            #expect(mixed.map(\.value) == ["2"], "Mixed, as the system reports a partly checked toggle")
        }
    #endif
}
