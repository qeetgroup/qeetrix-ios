#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Copy field snapshots")
    struct CopyFieldSnapshotTests {
        static let acsURL = "https://id.qeet.in/saml/acme-traders-private-limited/assertion-consumer-service"

        @Test("A field with a description, a long value wrapping and kept to one line, a secret, disabled")
        func fields() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixCopyField("ACS URL", value: Self.acsURL, description: Text("Paste it into your identity provider."))
                    QeetrixCopyField("Entity ID", value: Self.acsURL, wrap: .none)
                    QeetrixCopyField("Client secret", value: "qs_test_4f9a0c71e2b8", isSensitive: true)
                    QeetrixCopyField("Tenant ID", value: "tn_01HZX4B7Q2").disabled(true)
                }
            )
        }

        @Test("Rows in a description list, ruled and lined up with its items, and a row on its own")
        func rows() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixDescriptionList {
                        QeetrixDescriptionItem("Name", value: "Acme Traders")
                        QeetrixCopyField("Tenant ID", value: "tn_01HZX4B7Q2", layout: .row)
                        QeetrixCopyField(
                            "Redirect URI", value: Self.acsURL, description: Text("Add it to your app's settings."), layout: .row)
                    }
                    QeetrixCopyField("Client ID", value: "cl_7Hq2Xk9", layout: .row)
                }
            )
        }
    }
#endif
