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

    @Test("radio.css: a strong edge at rest, a 5 pt Ember ring when selected, disabled greys")
    func disc() {
        #expect(QeetrixRadioDisc.side == 16 && QeetrixRadioDisc.selectedRing == 5)
        #expect(QeetrixRadioDisc(isSelected: false).border == .borderStrong)
        #expect(QeetrixRadioDisc(isSelected: false, isHovered: true).border == .borderStrongHover)
        #expect(QeetrixRadioDisc(isSelected: true).border == .bgBrandBold)
        #expect(QeetrixRadioDisc(isSelected: true, isHovered: true).border == .bgBrandBoldHover)
        #expect(QeetrixRadioDisc(isSelected: true, isEnabled: false).border == .iconDisabled)
        #expect(QeetrixRadioDisc(isSelected: false, isEnabled: false).border == .borderDisabled)
    }

    @Test("A selected radio is an Ember ring round an input-coloured centre")
    func drawn() throws {
        let image = try #require(Rendered(QeetrixRadioDisc(isSelected: true).environment(\.colorScheme, .light)))
        #expect(image.width == 16)
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(2, 8)))
        #expect(close(QeetrixTheme.light.resolve(.bgInput).bytes, image.pixel(8, 8)))
    }

    @Test("With an error the chosen radio's ring is the danger colour (QTRX-161)")
    func invalidRing() throws {
        let image = try #require(
            Rendered(QeetrixRadioDisc(isSelected: true).environment(\.qeetrixGroupIsInvalid, true).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, image.pixel(2, 8)))
        #expect(close(QeetrixTheme.light.resolve(.bgInput).bytes, image.pixel(8, 8)))
        let hovered = try #require(
            Rendered(
                QeetrixRadioDisc(isSelected: true, isHovered: true).environment(\.qeetrixGroupIsInvalid, true).environment(
                    \.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, hovered.pixel(2, 8)))
    }

    @Test("Renders vertical and horizontal, with a selection, a disabled option and an error")
    func renders() {
        let options = [QeetrixOption("Starter", value: Plan.starter), QeetrixOption("Team", value: .team, isDisabled: true)]
        for orientation in QeetrixChoiceOrientation.allCases {
            let group = QeetrixRadioGroup(
                "Plan", selection: .constant(Plan.starter), options: options, error: "Choose a plan", orientation: orientation)
            #expect(ImageRenderer(content: group.frame(width: 300)).cgImage != nil)
        }
    }
}
