import SwiftUI

/// The package's built-in strings, from `Resources/Localization`.
enum QeetrixStrings {
    /// "Loading".
    static var loading: Text { Text("qeetrix.spinner.label", bundle: .module) }
    /// "Required".
    static var required: Text { Text("qeetrix.field.required", bundle: .module) }
    /// "(optional)".
    static var optional: Text { Text("qeetrix.label.optional", bundle: .module) }
    /// "Error".
    static var error: Text { Text("qeetrix.field.error", bundle: .module) }
    /// "Warning".
    static var warning: Text { Text("qeetrix.field.warning", bundle: .module) }
    /// "Success".
    static var success: Text { Text("qeetrix.field.success", bundle: .module) }
    /// "Show password".
    static var showPassword: Text { Text("qeetrix.password.show", bundle: .module) }
    /// "Hide password".
    static var hidePassword: Text { Text("qeetrix.password.hide", bundle: .module) }
    /// "One-time code".
    static var oneTimeCode: Text { Text("qeetrix.otp.label", bundle: .module) }
    /// "Decrease".
    static var decrease: Text { Text("qeetrix.number-field.decrease", bundle: .module) }
    /// "Increase".
    static var increase: Text { Text("qeetrix.number-field.increase", bundle: .module) }
    /// "There is a problem".
    static var errorSummaryTitle: Text { Text("qeetrix.form.error-summary-title", bundle: .module) }
    /// "There is a problem", for an announcement, which takes a `String`.
    static var errorSummaryTitleString: String { String(localized: "qeetrix.form.error-summary-title", bundle: .module) }
    /// "Close".
    static var close: Text { Text("qeetrix.overlay.close", bundle: .module) }
    /// "Cancel".
    static var cancel: Text { Text("qeetrix.dialog.cancel", bundle: .module) }
}
