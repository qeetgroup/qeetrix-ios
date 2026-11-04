import Accessibility
import SwiftUI

/// What a password field holds, for AutoFill — `@qeetrix/react`'s PasswordInput `autoComplete`.
public enum QeetrixPasswordAutoComplete: String, CaseIterable, Sendable {
    /// The user's password, to sign in (the default).
    case currentPassword
    /// A password being created.
    case newPassword
    /// A secret that isn't the user's password, such as an API key: no AutoFill.
    case off
}

/// A password or secret with its label, help text and error, and a Show password toggle at its end —
/// `@qeetrix/react`'s PasswordInput in a Field.
///
/// ```swift
/// QeetrixPasswordInput("Password", text: $password)
/// QeetrixPasswordInput("New password", text: $new, autoComplete: .newPassword, description: Text("At least 12 characters."))
/// ```
///
/// The box is the Qeetrix field. The value is hidden by default — people may not be alone — and the
/// toggle, a neutral `sm` ``QeetrixIconButton`` named "Show password", shows it (eye ↔ eye-off),
/// keeping the keyboard; VoiceOver reads the toggle as selected while the password shows, and says
/// "Password shown" or "Password hidden". Pass `isVisible` to own that state. Spelling, capitals and
/// correction are off; paste and password managers work, and there's no length cap (WCAG 3.3.8).
public struct QeetrixPasswordInput: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let text: Binding<String>
    let autoComplete: QeetrixPasswordAutoComplete
    let prompt: Text?
    let isVisible: Binding<Bool>?

    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        autoComplete: QeetrixPasswordAutoComplete = .currentPassword,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isVisible: Binding<Bool>? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), text: text, autoComplete: autoComplete, prompt: prompt, description: description, error: error,
            isVisible: isVisible, isRequired: isRequired, isOptional: isOptional)
    }

    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        autoComplete: QeetrixPasswordAutoComplete = .currentPassword,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isVisible: Binding<Bool>? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), text: text, autoComplete: autoComplete, prompt: prompt, description: description, error: error,
            isVisible: isVisible, isRequired: isRequired, isOptional: isOptional)
    }

    public init(
        label: Text,
        text: Binding<String>,
        autoComplete: QeetrixPasswordAutoComplete = .currentPassword,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isVisible: Binding<Bool>? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.text = text
        self.autoComplete = autoComplete
        self.prompt = prompt
        self.isVisible = isVisible
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixPasswordField(text: text, autoComplete: autoComplete, prompt: prompt, isVisible: isVisible)
        }
    }
}

struct QeetrixPasswordField: View {
    let text: Binding<String>
    let autoComplete: QeetrixPasswordAutoComplete
    let prompt: Text?
    let isVisible: Binding<Bool>?
    @State private var ownVisible: Bool
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    init(text: Binding<String>, autoComplete: QeetrixPasswordAutoComplete, prompt: Text?, isVisible: Binding<Bool>?, visible: Bool = false)
    {
        self.text = text
        self.autoComplete = autoComplete
        self.prompt = prompt
        self.isVisible = isVisible
        _ownVisible = State(initialValue: visible)
    }

    var shown: Bool { isVisible?.wrappedValue ?? ownVisible }

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused, isHovered: isHovered, isInvalid: context?.invalid ?? false)
        HStack(spacing: QeetrixInputMetrics.gap) {
            entry
                .qeetrixTextInputTraits(.password(autoComplete))
                .tint(QeetrixColor.borderFocus)
                .focused($isFocused)
                .privacySensitive()
                .qeetrixFieldControlAccessibility()
            toggle
        }
        .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
        .padding(.leading, QeetrixInputMetrics.padding)
        // password-input.css: the toggle sits 4 pt from the end.
        .padding(.trailing, QeetrixSpace.gapXs)
        .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: QeetrixInputMetrics.textType)
        .qeetrixInputSurface(state)
        // A 44 pt target, as the text field's: a tap on the padding, or just outside a short field, focuses
        // it. The reveal button keeps its own tap, which a child's gesture wins over this one.
        .qeetrixHitArea()
        .onTapGesture {
            if isEnabled { isFocused = true }
        }
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var entry: some View {
        let prompt = (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputMetrics.placeholder)
        let label = context?.label ?? Text(verbatim: "")
        if shown {
            TextField(text: text, prompt: prompt) { label }
        } else {
            SecureField(text: text, prompt: prompt) { label }
        }
    }

    private var toggle: some View {
        QeetrixIconButton(shown ? .eyeOff : .eye, label: QeetrixStrings.showPassword, tone: .neutral, size: .sm) {
            let hadFocus = isFocused
            let next = !shown
            if let isVisible { isVisible.wrappedValue = next } else { ownVisible = next }
            AccessibilityNotification.Announcement(next ? QeetrixStrings.passwordShownString : QeetrixStrings.passwordHiddenString).post()
            // The field is replaced; give the new one the keyboard the old one had.
            if hadFocus {
                Task { @MainActor in isFocused = true }
            }
        }
        .accessibilityAddTraits(shown ? .isSelected : [])
    }
}
