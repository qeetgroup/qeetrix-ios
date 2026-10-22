import SwiftUI

/// What a password field is for, which tells Password AutoFill what to offer.
public enum QeetrixPasswordPurpose: String, CaseIterable, Sendable {
    /// Signing in: AutoFill offers the saved password (`.password`, the web's `current-password`).
    case current
    /// Signing up or resetting: AutoFill offers a strong new password and to save it (`.newPassword`, the
    /// web's `new-password`).
    case new
}

/// A labelled password field with a reveal toggle — the web's `Field` with a `PasswordInput`.
///
/// ```swift
/// QeetrixPasswordInput("Password", text: $password, purpose: .current, isRequired: true)
///     .submitLabel(.go)
///     .onSubmit(signIn)
/// ```
///
/// It is a native `SecureField`: the system's secure entry, screen-recording protection and Password
/// AutoFill all apply. `purpose` sets the content type AutoFill uses; autocapitalisation and
/// autocorrection are off, so a password is never sent to a spelling service. The toggle after the field
/// reveals the password as plain text and hides it again — named "Show password" or "Hide password" for
/// what it will do — and keeps the keyboard where it was. Pass `showsToggle: false` to leave it out.
///
/// The component holds the text only in the binding you give it: it never logs, stores or describes it.
/// Strength meters and password rules are the app's.
public struct QeetrixPasswordInput: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let text: Binding<String>
    let purpose: QeetrixPasswordPurpose
    let prompt: Text?
    let showsToggle: Bool

    /// A password field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        purpose: QeetrixPasswordPurpose = .current,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        showsToggle: Bool = true
    ) {
        self.init(
            label: Text(titleKey), text: text, purpose: purpose, prompt: prompt, description: description, message: message,
            isRequired: isRequired, isOptional: isOptional, showsToggle: showsToggle)
    }

    /// A password field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        purpose: QeetrixPasswordPurpose = .current,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        showsToggle: Bool = true
    ) {
        self.init(
            label: Text(title), text: text, purpose: purpose, prompt: prompt, description: description, message: message,
            isRequired: isRequired, isOptional: isOptional, showsToggle: showsToggle)
    }

    /// A password field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - text: The password. It lives only in this binding.
    ///   - purpose: `current` to sign in, `new` to sign up or reset, for Password AutoFill.
    ///   - prompt: Placeholder text, shown while the field is empty.
    ///   - description: Help shown under the field, such as the app's password rules.
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    ///   - showsToggle: Whether the reveal toggle is shown.
    public init(
        label: Text,
        text: Binding<String>,
        purpose: QeetrixPasswordPurpose = .current,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        showsToggle: Bool = true
    ) {
        context = QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired)
        self.isOptional = isOptional
        self.text = text
        self.purpose = purpose
        self.prompt = prompt
        self.showsToggle = showsToggle
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixPasswordField(text: text, purpose: purpose, prompt: prompt, showsToggle: showsToggle)
        }
    }
}

struct QeetrixPasswordField: View {
    let text: Binding<String>
    let purpose: QeetrixPasswordPurpose
    let prompt: Text?
    let showsToggle: Bool

    @State private var isRevealed: Bool
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    /// - Parameter revealed: The starting state, for snapshot tests; the toggle owns it afterwards.
    init(text: Binding<String>, purpose: QeetrixPasswordPurpose, prompt: Text?, showsToggle: Bool, revealed: Bool = false) {
        self.text = text
        self.purpose = purpose
        self.prompt = prompt
        self.showsToggle = showsToggle
        _isRevealed = State(initialValue: revealed)
    }

    var body: some View {
        let state = QeetrixFieldState(
            isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused, isHovered: isHovered, tone: context?.message?.tone)
        let height = QeetrixInputTokens.height(density)
        HStack(spacing: 0) {
            passwordEntry
                .qeetrixTextInputTraits(.password(purpose))
                .focused($isFocused)
                .privacySensitive()
                .qeetrixFieldControlAccessibility()
                .padding(.leading, QeetrixWebScale.spacing(2.5))  // px-2.5
                .padding(.trailing, showsToggle ? QeetrixWebScale.spacing(1) : QeetrixWebScale.spacing(2.5))
                .padding(.vertical, QeetrixWebScale.spacing(1))  // py-1
                // A 44 pt target: a tap on the padding, or just outside a short field, focuses it — as for a
                // text field. The reveal button keeps its own.
                .contentShape(Rectangle())
                .qeetrixHitArea()
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if isEnabled { isFocused = true }
                    }
                )
            if showsToggle {
                toggle(height: height)
                    .padding(.trailing, QeetrixWebScale.spacing(1))  // inset-e-1
            }
        }
        .qeetrixType(QeetrixTextFieldMetrics.textType)
        .foregroundStyle(QeetrixInputTokens.foreground)
        .frame(minHeight: height)
        .qeetrixFieldSurface(state)
        .onHover { isHovered = $0 }
    }

    /// One stable field at a time: the secure field, or — revealed — a plain one on the same binding.
    @ViewBuilder
    private var passwordEntry: some View {
        let prompt = (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputTokens.placeholder)
        let label = context?.label ?? Text(verbatim: "")
        if isRevealed {
            TextField(text: text, prompt: prompt) { label }
        } else {
            SecureField(text: text, prompt: prompt) { label }
        }
    }

    /// `fieldAction`: a square of the field height less 8 pt (at least 24 pt), inside the field's corner,
    /// a 16 pt eye in the tertiary colour, a 44 pt target. The square grows with the eye at larger text
    /// sizes.
    private func toggle(height: CGFloat) -> some View {
        let side = max(QeetrixWebScale.spacing(6), height - QeetrixWebScale.spacing(2))
        return Button {
            let hadFocus = isFocused
            isRevealed.toggle()
            // The field is replaced; give the new one the keyboard the old one had.
            if hadFocus {
                Task { @MainActor in isFocused = true }
            }
        } label: {
            QeetrixIcon(isRevealed ? .eyeOff : .eye, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))
                .qeetrixIconSquare(side, icon: QeetrixWebScale.spacing(4))
                .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixFieldActionStyle(cornerRadius: max(0, QeetrixInputTokens.corner - 2)))
        .qeetrixHitArea()
        .accessibilityLabel(isRevealed ? QeetrixStrings.hidePassword : QeetrixStrings.showPassword)
    }
}

/// `fieldAction`: a compact action inside a field — the password toggle, a stepper — tertiary at rest,
/// the primary text colour on the interactive hover and press surfaces.
struct QeetrixFieldActionStyle: ButtonStyle {
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        QeetrixFieldActionBody(configuration: configuration, cornerRadius: cornerRadius)
    }
}

private struct QeetrixFieldActionBody: View {
    let configuration: ButtonStyleConfiguration
    let cornerRadius: CGFloat
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let background: QeetrixColor? = configuration.isPressed ? .surfaceInteractiveActive : isHovered ? .surfaceInteractiveHover : nil
        configuration.label
            .foregroundStyle(
                !isEnabled
                    ? QeetrixColor.textDisabled
                    : (configuration.isPressed || isHovered) ? QeetrixColor.textPrimary : QeetrixColor.textTertiary
            )
            .background {
                if let background {
                    RoundedRectangle(cornerRadius: cornerRadius).fill(background)
                }
            }
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
    }
}
