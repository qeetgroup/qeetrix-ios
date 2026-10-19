import SwiftUI

/// Every component page, one line each, in index order within its category.
/// `Scripts/new-component.sh` adds a line above the marker; keep the marker last.
enum ShowcaseCatalog {
    static let components: [ShowcaseEntry] = [
        ShowcaseEntry("button", "Button", .actions) { ButtonPage() },
        ShowcaseEntry("icon-button", "Icon button", .actions) { IconButtonPage() },
        ShowcaseEntry("text-field", "Text field", .forms) { TextFieldPage() },
        ShowcaseEntry("switch", "Switch", .forms) { SwitchPage() },
        ShowcaseEntry("field", "Field", .forms) { FieldPage() },
        ShowcaseEntry("textarea", "Textarea", .forms) { TextareaPage() },
        ShowcaseEntry("password-input", "Password input", .forms) { PasswordInputPage() },
        ShowcaseEntry("otp-input", "OTP input", .forms) { OTPInputPage() },
        ShowcaseEntry("checkbox", "Checkbox", .forms) { CheckboxPage() },
        ShowcaseEntry("radio-group", "Radio group", .forms) { RadioGroupPage() },
        ShowcaseEntry("select", "Select", .forms) { SelectPage() },
        ShowcaseEntry("number-field", "Number field", .forms) { NumberFieldPage() },
        ShowcaseEntry("form-patterns", "Form patterns", .forms) { FormPatternsPage() },
        ShowcaseEntry("avatar", "Avatar", .dataDisplay) { AvatarPage() },
        ShowcaseEntry("badge", "Badge", .dataDisplay) { BadgePage() },
        ShowcaseEntry("text", "Text", .dataDisplay) { TextPage() },
        ShowcaseEntry("progress", "Progress", .feedback) { ProgressPage() },
        ShowcaseEntry("spinner", "Spinner", .feedback) { SpinnerPage() },
        ShowcaseEntry("toast", "Toast", .feedback) { ToastPage() },
        ShowcaseEntry("alert-dialog", "Alert dialog", .overlays) { AlertDialogPage() },
        ShowcaseEntry("confirmation-dialog", "Confirmation dialog", .overlays) { ConfirmationDialogPage() },
        ShowcaseEntry("sheet", "Sheet", .overlays) { SheetPage() },
        ShowcaseEntry("popover", "Popover", .overlays) { PopoverPage() },
        ShowcaseEntry("menu", "Menu", .overlays) { MenuPage() },
        ShowcaseEntry("overlay-patterns", "Overlay patterns", .overlays) { OverlayPatternsPage() },
        ShowcaseEntry("tabs", "Tabs", .navigation) { TabsPage() },
        ShowcaseEntry("app-navigation", "App navigation", .navigation) { AppNavigationPage() },
        ShowcaseEntry("card", "Card", .layout) { CardPage() },
        ShowcaseEntry("separator", "Separator", .layout) { SeparatorPage() },
        // new-component: insert above this line
    ]
}
