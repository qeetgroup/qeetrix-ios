import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Components, copied verbatim inside views that supply
// the names they use. If the API changes in a way that breaks an example, this file stops compiling,
// and the page must be updated with it.

private enum Route: Hashable { case billing }

/// Text.md, Heading.md, Separator.md, Badge.md, Spinner.md, Progress.md and Avatar.md.
private struct DisplayExamples: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                QeetrixHeading("Security", level: 2)
                QeetrixText("Sign in with a passkey on every device you trust.", size: .lg, tone: .subtle)
                QeetrixText("Last used 2 days ago", size: .sm, tone: .subtle)
                QeetrixText("INV-2026-0042", mono: true)
            }
            QeetrixHeading("Sign in to Qeet", level: 1, size: .displaySm)
            VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
                QeetrixHeading("Profile", level: 3)
                QeetrixSeparator()
                QeetrixText("Your name and photo are visible to your team.")
            }
            HStack {
                QeetrixBadge("Draft")
                QeetrixBadge("Paid", tone: .success, icon: .circleCheck)
                QeetrixBadge("Overdue", tone: .danger, variant: .solid)
            }
            HStack {
                QeetrixSpinner()
                QeetrixSpinner(size: .lg, tone: .brand, label: Text("Loading invoices"))
            }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
                QeetrixProgress("Uploading invoices", value: 0.4, showsValue: true)
                QeetrixProgress("Import failed", value: 0.62, tone: .danger)
                QeetrixProgress("Preparing export", value: nil)
            }
            ProgressView("Syncing", value: 0.25)
                .progressViewStyle(.qeetrix(tone: .success))
            HStack {
                QeetrixAvatar(name: "Priya Sharma")
                QeetrixAvatar(name: "Priya Sharma", size: .lg)
                QeetrixAvatar(name: "Kaveri Foods Private Limited", shape: .square)
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
            QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly")) {
                QeetrixText("Up to 25 members, with audit logs and SSO.")
            } footer: {
                QeetrixButton("Upgrade", size: .lg) { upgrade() }
            }
            QeetrixCard(title: Text("Delete workspace"), tone: .danger) {
                QeetrixText("Removes every project and file, for everyone.")
            } actions: {
                QeetrixButton("Delete", tone: .danger, size: .sm) {}
            }
            Button {
                choose(plan)
            } label: {
                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    QeetrixHeading("Team plan", level: 3, size: .titleSm)
                    QeetrixText("Billed monthly", size: .sm, tone: .subtle)
                }
            }
            .buttonStyle(.qeetrixCard(isSelected: plan == chosen))
            // A card of rows.
            QeetrixCard {
                QeetrixListItem("AutoFill codes", accessory: .chevron) {
                    openAutoFill()
                } leading: {
                    QeetrixListItemIcon(.key)
                }
                QeetrixListItem("Help and privacy", accessory: .chevron) {
                    openHelp()
                } leading: {
                    QeetrixListItemIcon(.circleQuestionMark)
                }
            }
            .flushRows()
        }
    }

    func upgrade() {}
    func choose(_ plan: String) {}
    func openAutoFill() {}
    func openHelp() {}
}

/// Button.md and IconButton.md.
private struct ActionExamples: View {
    let isRevoking = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                QeetrixButton("Create invoice") { create() }
                QeetrixButton("Export", icon: .share2, variant: .soft) { export() }
                QeetrixButton("Revoke key", tone: .danger, isLoading: isRevoking) { revoke() }
                QeetrixButton("Cancel", variant: .ghost) { cancel() }
            }
            NavigationLink("Billing", value: Route.billing)
                .buttonStyle(.qeetrix(.ghost, size: .sm))
            HStack {
                QeetrixIconButton(.x, label: "Close", tone: .neutral, size: .sm) { dismiss() }
                QeetrixIconButton(.share2, label: "Share", variant: .soft) { share() }
            }
        }
    }

    func create() {}
    func export() {}
    func revoke() {}
    func cancel() {}
    func dismiss() {}
    func share() {}
}

/// Switch.md.
private struct SwitchExamples: View {
    @State private var autoRenew = true
    @State private var twoStep = false
    @State private var wifi = true

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                QeetrixSwitch("Auto-renew", isOn: $autoRenew)
                QeetrixSwitch("Two-step sign-in", isOn: $twoStep, description: Text("A code by SMS at each sign-in."))
            }
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.qeetrixSwitch)
        }
    }
}

/// TextField.md. The keyboard modifiers are iOS-only; the guard lets this file also build on the Mac
/// host, and is the one difference from the page.
private struct TextFieldExamples: View {
    @State private var email = ""
    @State private var amount = ""
    @State private var query = ""
    let emailError: String? = "Enter a work email"

    var body: some View {
        VStack {
            QeetrixTextField(
                "Work email", text: $email,
                prompt: Text("e.g. priya@acme.in"),
                description: Text("We send sign-in links here."),
                error: emailError,
                isRequired: true
            )
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            #endif
            QeetrixTextField("Amount", text: $amount, startAdornment: Text("₹"))
            QeetrixTextField("Search", text: $query, icon: .search, isLabelHidden: true)
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
