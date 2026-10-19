import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Components, copied verbatim inside views that supply
// the names they use. If the API changes in a way that breaks an example, this file stops compiling,
// and the page must be updated with it.

private enum Route: Hashable { case billing }

/// Text.md, Separator.md, Badge.md, Spinner.md, Progress.md and Avatar.md.
private struct DisplayExamples: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
                QeetrixText("Security", variant: .h2)
                QeetrixText("Sign in with a passkey on every device you trust.", variant: .lead)
                QeetrixText("Last used 2 days ago", variant: .muted)
            }
            VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
                QeetrixText("Profile", variant: .h3)
                QeetrixSeparator()
                QeetrixText("Your name and photo are visible to your team.")
            }
            HStack {
                QeetrixBadge("New")
                QeetrixBadge("Beta", variant: .brand)
                QeetrixBadge("Paid", variant: .success, icon: .circleCheck)
            }
            HStack {
                QeetrixSpinner()
                QeetrixSpinner(size: .lg, label: Text("Loading invoices"))
            }
            VStack(alignment: .leading, spacing: QeetrixSpacing.l) {
                QeetrixProgress("Uploading", value: 0.4)
                QeetrixProgress("Preparing export", value: nil)
            }
            ProgressView("Syncing", value: 0.25)
                .progressViewStyle(.qeetrix(size: .sm))
            HStack {
                QeetrixAvatar(name: "Asha Rao")
                QeetrixAvatar(name: "Asha Rao", size: .lg, badge: Text("Online"))
                QeetrixAvatar(name: "Qeet Group", shape: .square)
            }
        }
    }
}

/// Card.md.
private struct CardExamples: View {
    let plan = "team"
    let chosen = "team"

    var body: some View {
        VStack {
            QeetrixCard {
                QeetrixCardHeader("Team plan", description: "Billed monthly") {
                    QeetrixBadge("Current", variant: .brand)
                }
                QeetrixText("Up to 25 members, with audit logs and single sign-on.")
            } footer: {
                QeetrixButton("Upgrade") {}
            }
            Button {
                choose(plan)
            } label: {
                QeetrixCardHeader("Team plan", description: "Billed monthly")
            }
            .buttonStyle(.qeetrixCard(isSelected: plan == chosen))
        }
    }

    func choose(_ plan: String) {}
}

/// Button.md and IconButton.md.
private struct ActionExamples: View {
    let isSaving = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                QeetrixButton("Save changes", isLoading: isSaving, loadingLabel: "Saving") { save() }
                QeetrixButton("Search", leadingIcon: .search, variant: .outline) { search() }
                QeetrixButton("Delete", variant: .destructive, size: .sm) { delete() }
            }
            NavigationLink("Billing", value: Route.billing)
                .buttonStyle(.qeetrix(.outline, size: .sm))
            HStack {
                QeetrixIconButton(.x, label: "Close") { dismiss() }
                QeetrixIconButton(.bell, label: "Notifications", variant: .outline, size: .sm) { openInbox() }
            }
        }
    }

    func save() {}
    func search() {}
    func delete() {}
    func dismiss() {}
    func openInbox() {}
}

/// Switch.md.
private struct SwitchExamples: View {
    @State private var email = true
    @State private var digest = false
    @State private var wifi = true

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                QeetrixSwitch("Email notifications", isOn: $email)
                QeetrixSwitch("Weekly digest", isOn: $digest, size: .sm)
            }
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.qeetrixSwitch())
        }
    }
}

/// TextField.md. The keyboard modifiers are iOS-only; the guard lets this file also build on the Mac
/// host, and is the one difference from the page.
private struct TextFieldExamples: View {
    @State private var email = ""
    let emailError: String? = "Enter an email address."

    var body: some View {
        VStack {
            QeetrixTextField(
                "Work email", text: $email,
                prompt: Text("name@company.com"),
                description: Text("We send sign-in links here."),
                message: emailError.map { QeetrixFieldMessage(.error, text: $0) },
                isRequired: true
            )
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif
        }
    }
}

@Suite("Component documentation examples")
struct ComponentDocumentationExamplesTests {
    @Test("Every component example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: DisplayExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: CardExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(
                ImageRenderer(content: NavigationStack { ActionExamples() }.frame(width: 390, height: 400).qeetrixThemeMode(theme)).cgImage
                    != nil)
            #expect(ImageRenderer(content: SwitchExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: TextFieldExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
