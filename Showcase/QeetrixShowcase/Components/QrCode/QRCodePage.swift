import Qeetrix
import SwiftUI

struct QRCodePage: View {
    // Synthetic values only: this key and these accounts don't exist.
    @State private var level = QeetrixQRCodeLevel.m
    private let setupLink = "otpauth://totp/Qeet%20ID:priya@acme.in?secret=JBSWY3DPEHPK3PXP&issuer=Qeet%20ID"

    var body: some View {
        ComponentPage(
            title: "QR code",
            summary: "The same modules as the web for the same value and level, always dark on white, with the quiet zone inside the tile."
        ) {
            DemoSection("An authenticator's setup code") {
                QeetrixQRCode(
                    setupLink, label: "QR code to add Qeet ID to your authenticator app", level: level, text: Text("JBSW Y3DP EHPK 3PXP"))
                Picker("Level", selection: $level) {
                    ForEach(QeetrixQRCodeLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
            DemoSection("A UPI payment") {
                QeetrixQRCode(
                    "upi://pay?pa=acme@upi&pn=Acme%20Traders&am=1250.00&cu=INR", label: "QR code to pay Acme Traders by UPI", level: .q,
                    text: Text("acme@upi"))
            }
            DemoSection("Sizes") {
                FlowLayout(spacing: QeetrixSpace.gapLg) {
                    ForEach([96.0, 128, 160], id: \.self) { size in
                        QeetrixQRCode("https://qeet.in", label: "QR code to open qeet.in", level: .l, size: size)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { QRCodePage() }
}
