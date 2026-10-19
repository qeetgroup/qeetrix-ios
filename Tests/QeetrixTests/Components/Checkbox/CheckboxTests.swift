import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Checkbox")
struct CheckboxTests {
    @Test("Mixed wins over on: a partly checked group shows a minus")
    func marks() {
        #expect(QeetrixCheckboxMark(isOn: false, isMixed: false) == .unchecked)
        #expect(QeetrixCheckboxMark(isOn: true, isMixed: false) == .checked)
        #expect(QeetrixCheckboxMark(isOn: false, isMixed: true) == .mixed)
        #expect(QeetrixCheckboxMark(isOn: true, isMixed: true) == .mixed)
    }

    @Test("The boundary: control at rest, brand when checked or mixed, error colour in an invalid group")
    func borders() {
        #expect(QeetrixCheckboxBox(mark: .unchecked, isHovered: false, tone: nil).border == QeetrixInputTokens.border)
        #expect(QeetrixCheckboxBox(mark: .unchecked, isHovered: true, tone: nil).border == QeetrixInputTokens.borderHover)
        #expect(QeetrixCheckboxBox(mark: .checked, isHovered: false, tone: nil).border == QeetrixComponentColor(.borderBrand))
        #expect(QeetrixCheckboxBox(mark: .mixed, isHovered: false, tone: nil).border == QeetrixComponentColor(.borderBrand))
        #expect(QeetrixCheckboxBox(mark: .checked, isHovered: false, tone: .error).border == QeetrixInputTokens.borderInvalid)
    }

    @Test("A checkbox row is a 44 pt target")
    func target() throws {
        let rendered = try #require(Rendered(QeetrixCheckbox("Email", isOn: .constant(true)).frame(width: 300)))
        #expect(rendered.height >= Int(QeetrixAccessibility.minimumTouchTarget))
    }
}
