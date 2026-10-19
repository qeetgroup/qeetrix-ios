import SwiftUI

/// A message under a field: an error, a warning or a success, as the web's `FieldError`,
/// `FieldWarning` and `FieldSuccess`.
///
/// ```swift
/// QeetrixTextField("Email", text: $email, message: emailIsValid ? nil : .error("Enter an email address."))
/// ```
///
/// The tone colours the field's boundary and the message, and gives the message its icon. The text
/// must say what is wrong on its own: the colour and icon only reinforce it.
public struct QeetrixFieldMessage: Hashable, Sendable {
    /// The kind of message.
    public enum Tone: String, CaseIterable, Sendable {
        /// The value is invalid. VoiceOver announces the message as soon as it appears.
        case error
        /// The value is accepted but needs attention.
        case warning
        /// The value has been checked and is good.
        case success
    }

    public let tone: Tone
    /// The message, already localised.
    public let text: String

    /// A message shown as given, without localisation — for example, an error returned by a server.
    public init(_ tone: Tone, text: String) {
        self.tone = tone
        self.text = text
    }

    /// An error, localised from the main bundle.
    public static func error(_ text: LocalizedStringResource) -> QeetrixFieldMessage {
        QeetrixFieldMessage(.error, text: String(localized: text))
    }

    /// A warning, localised from the main bundle.
    public static func warning(_ text: LocalizedStringResource) -> QeetrixFieldMessage {
        QeetrixFieldMessage(.warning, text: String(localized: text))
    }

    /// A success message, localised from the main bundle.
    public static func success(_ text: LocalizedStringResource) -> QeetrixFieldMessage {
        QeetrixFieldMessage(.success, text: String(localized: text))
    }
}

extension QeetrixFieldMessage.Tone {
    /// The message colour: `text-destructive-text`, `text-warning-text`, `text-success-text`.
    var textColor: QeetrixColor {
        switch self {
        case .error: .textDanger
        case .warning: .textWarning
        case .success: .textSuccess
        }
    }

    /// The field boundary: `input.border-invalid`, `-warning`, `-success`.
    var borderColor: QeetrixComponentColor {
        switch self {
        case .error: QeetrixInputTokens.borderInvalid
        case .warning: QeetrixInputTokens.borderWarning
        case .success: QeetrixInputTokens.borderSuccess
        }
    }

    /// The name VoiceOver reads the message under, with the control it belongs to.
    var accessibilityName: Text {
        switch self {
        case .error: QeetrixStrings.error
        case .warning: QeetrixStrings.warning
        case .success: QeetrixStrings.success
        }
    }

    /// `CircleAlertIcon`, `TriangleAlertIcon`, `CircleCheckIcon`.
    var icon: QeetrixIconName {
        switch self {
        case .error: .circleAlert
        case .warning: .triangleAlert
        case .success: .circleCheck
        }
    }
}

/// A message row: the tone's icon on the first line, and the text.
struct QeetrixFieldMessageView: View {
    let message: QeetrixFieldMessage

    var body: some View {
        HStack(alignment: .top, spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
            QeetrixIcon(message.tone.icon, size: QeetrixFieldMetrics.messageIconSize)
                .padding(.top, QeetrixStroke.hairline)  // mt-px
            Text(verbatim: message.text)
                .qeetrixType(QeetrixFieldMetrics.captionType)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(message.tone.textColor)
        .accessibilityElement(children: .combine)
    }
}
