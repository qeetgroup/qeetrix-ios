import SwiftUI
import Testing

@testable import Qeetrix

/// Synthetic values only.
@MainActor
@Suite("Password input")
struct PasswordInputTests {
    @Test("autoComplete takes @qeetrix/react's values")
    func autoComplete() {
        #expect(QeetrixPasswordAutoComplete.allCases.map(\.rawValue) == ["currentPassword", "newPassword", "off"])
        #if os(iOS)
            #expect(QeetrixPasswordAutoComplete.currentPassword.contentType == .password)
            #expect(QeetrixPasswordAutoComplete.newPassword.contentType == .newPassword)
            #expect(QeetrixPasswordAutoComplete.off.contentType == nil, "A secret that isn't the user's password: no AutoFill")
        #endif
    }

    @Test("The component keeps no copy of the password: it lives only in the binding")
    func noCopy() {
        var stored = "sample-only"
        let binding = Binding(get: { stored }, set: { stored = $0 })
        let input = QeetrixPasswordInput("Password", text: binding)
        for child in Mirror(reflecting: input).children {
            #expect(!(child.value is String), "\(child.label ?? "?") holds a String")
        }
        binding.wrappedValue = "changed"
        #expect(stored == "changed")
    }

    @Test("Hidden by default; a visibility binding owns the state")
    func visibility() {
        let own = QeetrixPasswordField(text: .constant("sample-only"), autoComplete: .currentPassword, prompt: nil, isVisible: nil)
        #expect(!own.shown)
        let owned = QeetrixPasswordField(
            text: .constant("sample-only"), autoComplete: .newPassword, prompt: nil, isVisible: .constant(true))
        #expect(owned.shown)
    }

    @Test("The box takes a field's height, with the toggle inside it")
    func height() throws {
        let field = QeetrixPasswordField(text: .constant("sample-only"), autoComplete: .currentPassword, prompt: nil, isVisible: nil)
        let image = try #require(Rendered(field.frame(width: 300)))
        #expect(image.height == Int(QeetrixDensity.default.sizeControlLg))
    }

    @Test("Masked and shown both render, with an error")
    func renders() {
        let masked = QeetrixPasswordInput("Password", text: .constant("sample-only"), error: "Enter your password")
        let shown = QeetrixPasswordInput(
            "New password", text: .constant("sample-only"), autoComplete: .newPassword, isVisible: .constant(true))
        #expect(ImageRenderer(content: masked.frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: shown.frame(width: 300)).cgImage != nil)
    }
}
