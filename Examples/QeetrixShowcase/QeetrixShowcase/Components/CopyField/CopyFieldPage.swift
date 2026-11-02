import Qeetrix
import SwiftUI

struct CopyFieldPage: View {
    @State private var toast: QeetrixToast?
    // Synthetic values: no real tenant, URL or secret is involved.
    let acsURL = "https://id.qeet.in/saml/acme-traders-private-limited/assertion-consumer-service"

    var body: some View {
        ComponentPage(
            title: "Copy field",
            summary: "A read-only value with its Copy button: an ID, a URL to paste elsewhere, a secret shown once. Long values wrap."
        ) {
            DemoSection("Field") {
                QeetrixCopyField("ACS URL", value: acsURL, description: Text("Paste it into your identity provider."), toast: $toast)
                QeetrixCopyField("Entity ID", value: acsURL, wrap: .none, toast: $toast)
            }
            DemoSection("A secret shown once") {
                QeetrixCopyField(
                    "Client secret", value: "qs_test_4f9a0c71e2b8d6", description: Text("You won't see it again."), isSensitive: true,
                    toast: $toast)
            }
            DemoSection("Rows on a record page") {
                QeetrixDescriptionList {
                    QeetrixDescriptionItem("Name", value: "Acme Traders")
                    QeetrixCopyField("Tenant ID", value: "tn_01HZX4B7Q2", layout: .row, toast: $toast)
                    QeetrixCopyField("Client ID", value: "cl_7Hq2Xk9", layout: .row, toast: $toast)
                    QeetrixCopyField(
                        "Redirect URI", value: "https://acme.in/auth/callback", description: Text("Add it to your app's settings."),
                        layout: .row, toast: $toast)
                }
            }
            DemoSection("Disabled") {
                QeetrixCopyField("Tenant ID", value: "tn_01HZX4B7Q2").disabled(true)
            }
        }
        .qeetrixToast($toast)
    }
}

#Preview {
    NavigationStack { CopyFieldPage() }
}
