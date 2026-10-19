import SwiftUI
import Testing

@testable import Qeetrix

/// Synthetic values only.
@MainActor
@Suite("Password input")
struct PasswordInputTests {
    @Test("Purposes are the web's autocomplete values")
    func purposes() {
        #expect(QeetrixPasswordPurpose.allCases.map(\.rawValue) == ["current", "new"])
    }

    @Test("The component keeps no copy of the password: it lives only in the binding")
    func noCopy() {
        var stored = "sample-only"
        let binding = Binding(get: { stored }, set: { stored = $0 })
        let input = QeetrixPasswordInput("Password", text: binding)
        let mirror = Mirror(reflecting: input)
        for child in mirror.children {
            #expect(!(child.value is String), "\(child.label ?? "?") holds a String")
        }
        binding.wrappedValue = "changed"
        #expect(stored == "changed")
    }

    @Test("Masked and revealed both render")
    func renders() {
        let masked = QeetrixPasswordField(text: .constant("sample-only"), purpose: .current, prompt: nil, showsToggle: true)
        let revealed = QeetrixPasswordField(text: .constant("sample-only"), purpose: .new, prompt: nil, showsToggle: true, revealed: true)
        #expect(ImageRenderer(content: masked.frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: revealed.frame(width: 300)).cgImage != nil)
    }
}
