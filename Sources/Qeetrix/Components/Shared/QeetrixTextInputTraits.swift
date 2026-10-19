import SwiftUI

/// The keyboard and AutoFill configuration a Qeetrix input sets on its native field. iOS only: on the Mac
/// development host these traits do not exist, and the modifier does nothing.
enum QeetrixTextInputTraits {
    /// Password AutoFill for the purpose; no autocapitalisation or autocorrection, so a password is
    /// never sent to a spelling service.
    case password(QeetrixPasswordPurpose)
    /// One-time-code AutoFill (from Messages and Mail), with the keypad for the code's characters.
    case oneTimeCode(QeetrixOTPCharacters)
    /// A numeric keypad: digits only, with the locale's decimal separator, or with a minus sign.
    case number(allowsFraction: Bool, allowsNegative: Bool)
}

extension View {
    @ViewBuilder
    func qeetrixTextInputTraits(_ traits: QeetrixTextInputTraits) -> some View {
        #if os(iOS)
            switch traits {
            case .password(let purpose):
                textContentType(purpose == .new ? .newPassword : .password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            case .oneTimeCode(let characters):
                textContentType(.oneTimeCode)
                    .keyboardType(characters == .digits ? .numberPad : .asciiCapable)
                    .textInputAutocapitalization(characters == .digits ? .never : .characters)
                    .autocorrectionDisabled()
            case .number(let allowsFraction, let allowsNegative):
                // Neither the number pad nor the decimal pad has a minus key.
                keyboardType(allowsNegative ? .numbersAndPunctuation : allowsFraction ? .decimalPad : .numberPad)
                    .autocorrectionDisabled()
            }
        #else
            self
        #endif
    }
}
