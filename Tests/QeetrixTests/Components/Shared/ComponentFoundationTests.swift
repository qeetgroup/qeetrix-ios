import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Component foundations")
struct ComponentFoundationTests {
    @Test("The hit area is at least 44 pt, centred, and never smaller than the view")
    func hitArea() {
        let small = QeetrixHitArea().path(in: CGRect(x: 0, y: 0, width: 32, height: 24)).boundingRect
        #expect(small == CGRect(x: -6, y: -10, width: 44, height: 44))
        let large = QeetrixHitArea().path(in: CGRect(x: 0, y: 0, width: 120, height: 48)).boundingRect
        #expect(large == CGRect(x: 0, y: 0, width: 120, height: 48))
    }

    @Test("Control sizes take their height from the density")
    func controlSizes() {
        #expect(QeetrixControlSize.allCases.map(\.rawValue) == ["sm", "md", "lg"])
        for density in QeetrixDensity.allCases {
            #expect(density.controlHeight(.sm) == density.sizeControlSm)
            #expect(density.controlHeight(.md) == density.sizeControlMd)
            #expect(density.controlHeight(.lg) == density.sizeControlLg)
        }
    }

    @Test("Text tones are @qeetrix/react's, each its text token")
    func textTones() {
        #expect(
            QeetrixTextTone.allCases.map(\.rawValue)
                == ["default", "subtle", "subtlest", "disabled", "inverse", "brand", "danger", "success", "warning", "info"])
        for tone in QeetrixTextTone.allCases {
            #expect(tone.color.rawValue == "color.text.\(tone.rawValue)")
        }
        #expect(QeetrixTextAlign.start.textAlignment == .leading)
        #expect(QeetrixTextAlign.end.frameAlignment == .trailing)
    }

    @Test("Component text styles are roles, at another weight where the web changes it; fixed ones don't scale")
    func types() {
        #expect(QeetrixComponentType.role(.labelMd) == QeetrixTypeSpec(.labelMd))
        let selected = QeetrixComponentType.role(.labelMd, .semibold)
        #expect(selected.tokens.weight == .semibold && selected.tokens.size == 14)
        let fixed = QeetrixComponentType.fixed(.labelSm)
        #expect(fixed.textStyle == nil)
        #expect(fixed.fixedSize == fixed)
    }

    @Test("Options are identified by their value")
    func options() {
        let option = QeetrixOption("Monthly", value: 1, description: Text("Billed each month"), isDisabled: true)
        #expect(option.id == 1)
        #expect(option.isDisabled)
        #expect(option.description != nil)
    }
}
