import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Haptics")
struct FeedbackTests {
    @Test("Five roles: selection, success, warning, error and light impact")
    func roles() {
        #expect(QeetrixFeedback.allCases == [.selection, .success, .warning, .error, .lightImpact])
        #expect(QeetrixFeedback.allCases.map(\.rawValue) == ["selection", "success", "warning", "error", "light-impact"])
    }

    @Test("Each role is the system's haptic for that moment")
    func sensoryFeedback() {
        #expect(QeetrixFeedback.selection.sensoryFeedback == .selection)
        #expect(QeetrixFeedback.success.sensoryFeedback == .success)
        #expect(QeetrixFeedback.warning.sensoryFeedback == .warning)
        #expect(QeetrixFeedback.error.sensoryFeedback == .error)
        #expect(QeetrixFeedback.lightImpact.sensoryFeedback == .impact(weight: .light))
        // Distinct: no two roles feel the same.
        let all = QeetrixFeedback.allCases.map(\.sensoryFeedback)
        for (index, feedback) in all.enumerated() {
            #expect(!all[(index + 1)...].contains(feedback))
        }
    }

    @Test("Played imperatively, each role takes the UIKit generator for the same haptic")
    func generators() {
        #expect(QeetrixFeedback.selection.generator == .selection)
        #expect(QeetrixFeedback.success.generator == .notification(.success))
        #expect(QeetrixFeedback.warning.generator == .notification(.warning))
        #expect(QeetrixFeedback.error.generator == .notification(.error))
        #expect(QeetrixFeedback.lightImpact.generator == .impact(.light))
    }

    @Test("Playing needs no setup and does nothing on the Mac")
    func play() {
        for feedback in QeetrixFeedback.allCases {
            feedback.play()
        }
    }

    @Test("A toggle's accessibility binding counts the person's changes, not a value set to itself")
    func counting() {
        var isOn = false
        var changes = 0
        let binding = QeetrixFeedback.counting(
            Binding(get: { isOn }, set: { isOn = $0 }), in: Binding(get: { changes }, set: { changes = $0 }))
        binding.wrappedValue = true
        #expect((isOn, changes) == (true, 1))
        binding.wrappedValue = true
        #expect((isOn, changes) == (true, 1))
        binding.wrappedValue = false
        #expect((isOn, changes) == (false, 2))
        #expect(binding.wrappedValue == false)
    }

    @Test("The modifiers render, and so do the toggles that play selection feedback")
    func renders() {
        #expect(ImageRenderer(content: Text("Copied").qeetrixFeedback(.success, trigger: 1)).cgImage != nil)
        #expect(ImageRenderer(content: Text("Pull").qeetrixFeedback(.lightImpact, trigger: true) { _, new in new }).cgImage != nil)
        #expect(ImageRenderer(content: Text("Sent").qeetrixFeedback(trigger: 0) { _, _ in .error }).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixSwitch("Auto-renew", isOn: .constant(true)).frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCheckbox("Email me receipts", isOn: .constant(false)).frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixRadioGroup(
                    "Cycle", selection: .constant(1), options: [QeetrixOption("Monthly", value: 1), QeetrixOption("Yearly", value: 2)]
                )
                .frame(width: 300)
            ).cgImage != nil)
    }
}
