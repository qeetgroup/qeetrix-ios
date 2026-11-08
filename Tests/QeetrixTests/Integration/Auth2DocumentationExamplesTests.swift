import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the copy and one-time-code pages of Sources/Qeetrix/Qeetrix.docc — Components/CopyButton.md,
// CopyField.md and OTPCode.md — and the doc comments of QeetrixCopyButton, QeetrixCopyField and QeetrixOTPCode,
// copied verbatim inside views that supply the names they use. Every value is synthetic: no real identifier,
// secret or account is involved, and nothing is copied.

/// A stand-in for the app's OAuth client.
private struct Client {
    let id = "cl_7Hq2Xk9"
}

/// A stand-in for the screen a copy button sits on.
private struct ClientDetails: View {
    let client: Client

    var body: some View {
        QeetrixText(client.id, mono: true)
    }
}

/// A stand-in for the app's API keys, revealed on demand.
private struct APIKey {
    let id = "key_01"
}

private struct APIKeys {
    func reveal(_ id: String) async throws -> String { "qk_test_\(id)" }
}

/// A stand-in for the app's tenant and user records.
private struct Record {
    let id: String
    let name: String
}

/// A stand-in for the app's TOTP account: a code it computed and the step it belongs to.
private struct Step {
    let start: Date
}

private struct ComputedAccount {
    let code: String
    let name = "Acme, priya@acme.in"
    let window = Date.now...Date.now.addingTimeInterval(30)
}

/// A stand-in for an account's row in the app's list.
private struct AccountRow: View {
    let account: ComputedAccount

    init(_ account: ComputedAccount) {
        self.account = account
    }

    var body: some View {
        QeetrixText(account.name)
    }
}

private struct RecoveryCode {
    let code: String
    let window: ClosedRange<Date>
}

/// A stand-in for the app's TOTP generator, which Qeetrix doesn't provide.
private struct TOTPAccount {
    let name = "Acme, priya@acme.in"
    let period = Duration.seconds(30)

    func step(at date: Date) -> Step {
        Step(start: Date(timeIntervalSince1970: (date.timeIntervalSince1970 / 30).rounded(.down) * 30))
    }

    func code(for step: Step) -> String { "482913" }
}

/// CopyButton.md and QeetrixCopyButton's doc comment.
private struct CopyButtonExamples: View {
    let client = Client()
    let inviteLink = "https://id.qeet.in/invite/7Hq2Xk9"
    let keys = APIKeys()
    let key = APIKey()
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack {
            ClientDetails(client: client)
                .qeetrixToast($toast)

            QeetrixCopyButton(value: client.id, label: Text("Copy client ID"), toast: $toast)
            QeetrixCopyButton("Copy link", value: inviteLink, variant: .soft, toast: $toast)
            QeetrixCopyButton(label: Text("Copy API key"), isSensitive: true, toast: $toast) { try await keys.reveal(key.id) }
            QeetrixCopyButton(label: Text("Copy API key"), isSensitive: true, toast: $toast) {
                try await keys.reveal(key.id)
            }
        }
    }
}

/// CopyButton.md and QeetrixCopy's doc comment: a copy from a menu. Rendering opens no menu, so
/// nothing is copied.
private struct CopyFromAnyTriggerExamples: View {
    let account = ComputedAccount(code: "482913")
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack {
            AccountRow(account)
                .contextMenu {
                    Button("Copy code") { QeetrixCopy.copy(account.code, isSensitive: true, toast: $toast) }
                }
            Button("Copy code") { QeetrixCopy.copy(account.code, isSensitive: true, toast: $toast) }
        }
        .qeetrixToast($toast)
    }
}

/// CopyField.md and QeetrixCopyField's doc comment.
private struct CopyFieldExamples: View {
    let acsURL = "https://id.qeet.in/saml/acme/acs"
    let secret = "qs_test_4f9a0c"
    let tenant = Record(id: "tn_01HZX4B7Q2", name: "Acme Traders")
    let user = Record(id: "usr_01HZX4B7Q2", name: "Priya Sharma")
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack {
            QeetrixCopyField("ACS URL", value: acsURL, description: Text("Paste it into your identity provider."), toast: $toast)
            QeetrixCopyField("Client secret", value: secret, isSensitive: true, toast: $toast)
            QeetrixDescriptionList {
                QeetrixDescriptionItem("Name", value: tenant.name)
                QeetrixCopyField("Tenant ID", value: tenant.id, layout: .row, toast: $toast)
            }
            QeetrixDescriptionList {
                QeetrixCopyField("User ID", value: user.id, layout: .row, toast: $toast)
            }
        }
        .qeetrixToast($toast)
    }
}

/// OTPCode.md and QeetrixOTPCode's doc comment.
private struct OTPCodeExamples: View {
    let account = ComputedAccount(code: "482913")
    let step = Step(start: .now)
    let recovery = RecoveryCode(code: "48291375", window: Date.now...Date.now.addingTimeInterval(60))
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack {
            QeetrixOTPCode(account.code, periodStart: step.start, label: Text(verbatim: "Acme, priya@acme.in"), size: .md, toast: $toast)
            QeetrixOTPCode(recovery.code, validity: recovery.window, isHidden: true, toast: $toast)
            // The app's action instead of the copy.
            QeetrixOTPCode(
                account.code, periodStart: step.start, label: Text(account.name), size: .md,
                actionHint: Text("Fills the code")
            ) { code in fill(code) }
            QeetrixOTPCode(
                account.code, validity: account.window, label: Text(account.name), size: .md,
                actionHint: Text("Fills the code")
            ) { code in fill(code) }
        }
        .qeetrixToast($toast)
    }

    /// A stand-in for an AutoFill credential provider's completion.
    private func fill(_ code: String) {}
}

/// OTPCode.md: the app computes the code and refreshes it.
private struct OTPCodeRefreshExample: View {
    let account = TOTPAccount()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let step = account.step(at: context.date)
            QeetrixOTPCode(account.code(for: step), periodStart: step.start, period: account.period, label: Text(account.name))
        }
    }
}

@MainActor
@Suite("Copy and one-time-code documentation examples")
struct Auth2DocumentationExamplesTests {
    @Test("Every copy button, copy field and OTP code example compiles against the public API and renders")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: CopyButtonExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: CopyFromAnyTriggerExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: CopyFieldExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: OTPCodeExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: OTPCodeRefreshExample().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
