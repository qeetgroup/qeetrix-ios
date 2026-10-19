import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Radio group")
struct RadioGroupTests {
    enum Plan: Hashable { case starter, team }

    @Test("Options identify by their value, so a selection no option has selects nothing")
    func identity() {
        let options: [QeetrixOption<Plan?>] = [QeetrixOption("Starter", value: .starter), QeetrixOption("Team", value: .team)]
        #expect(options.map(\.id) == [.starter, .team])
        let selection: Plan? = nil
        #expect(!options.contains { $0.value == selection })
    }

    @Test("The disc's boundary: control at rest, brand when selected")
    func disc() {
        #expect(QeetrixRadioDisc(isSelected: false).border == QeetrixInputTokens.border)
        #expect(QeetrixRadioDisc(isSelected: true).border == QeetrixComponentColor(.borderBrand))
    }

    @Test("Renders with a selection, without one, and with a disabled option")
    func renders() {
        let options = [QeetrixOption("Starter", value: Plan.starter), QeetrixOption("Team", value: .team, isDisabled: true)]
        #expect(
            ImageRenderer(content: QeetrixRadioGroup("Plan", selection: .constant(Plan.starter), options: options).frame(width: 300))
                .cgImage != nil)
    }
}
