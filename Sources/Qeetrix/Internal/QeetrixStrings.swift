import SwiftUI

/// The package's built-in strings, from `Resources/Localization`: `@qeetrix/react`'s message catalogue
/// (`src/internal/messages.ts`), plus the few iOS needs that the web gets from the browser.
enum QeetrixStrings {
    /// "Loading" — `spinner.label`.
    static var loading: Text { Text("qeetrix.spinner.label", bundle: .module) }
    /// "Required".
    static var required: Text { Text("qeetrix.field.required", bundle: .module) }
    /// "(optional)" — `field.optional`.
    static var optional: Text { Text("qeetrix.field.optional", bundle: .module) }
    /// "Error".
    static var error: Text { Text("qeetrix.field.error", bundle: .module) }
    /// "Show password" — `passwordInput.show`.
    static var showPassword: Text { Text("qeetrix.password-input.show", bundle: .module) }
    /// "Password shown" — `passwordInput.shown`, an announcement.
    static var passwordShownString: String { String(localized: "qeetrix.password-input.shown", bundle: .module) }
    /// "Password hidden" — `passwordInput.hidden`, an announcement.
    static var passwordHiddenString: String { String(localized: "qeetrix.password-input.hidden", bundle: .module) }
    /// "One-time code".
    static var oneTimeCode: Text { Text("qeetrix.otp-input.label", bundle: .module) }
    /// "Decrease" — `numberField.decrement`.
    static var decrease: Text { Text("qeetrix.number-field.decrement", bundle: .module) }
    /// "Increase" — `numberField.increment`.
    static var increase: Text { Text("qeetrix.number-field.increment", bundle: .module) }
    /// "Fix these to continue" — `errorSummary.title`.
    static var errorSummaryTitle: Text { Text("qeetrix.error-summary.title", bundle: .module) }
    /// "Fix these to continue", for an announcement, which takes a `String`.
    static var errorSummaryTitleString: String { String(localized: "qeetrix.error-summary.title", bundle: .module) }
    /// "Close" — `overlay.close`.
    static var close: Text { Text("qeetrix.overlay.close", bundle: .module) }
    /// "Dismiss" — `toast.close`.
    static var dismiss: Text { Text("qeetrix.toast.close", bundle: .module) }
    /// "Cancel".
    static var cancel: Text { Text("qeetrix.dialog.cancel", bundle: .module) }
}
