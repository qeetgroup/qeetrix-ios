#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("QR code snapshots")
    struct QRCodeSnapshotTests {
        /// The same modules in every configuration: dark on white in dark mode too, and never mirrored.
        @Test("An authenticator link with its key, a UPI link at Q, and a small code at L")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixQRCode(
                        "otpauth://totp/Qeet%20ID:priya@acme.in?secret=JBSWY3DPEHPK3PXP&issuer=Qeet%20ID",
                        label: "QR code to add Qeet ID to your authenticator app", text: Text("JBSW Y3DP EHPK 3PXP"))
                    HStack(alignment: .top, spacing: 16) {
                        QeetrixQRCode(
                            "upi://pay?pa=acme@upi&pn=Acme&am=1250.00&cu=INR", label: "QR code to pay Acme by UPI", level: .q, size: 120,
                            text: Text("acme@upi"))
                        QeetrixQRCode("https://qeet.in", label: "QR code to open qeet.in", level: .l, size: 96)
                    }
                }
            )
        }
    }
#endif
