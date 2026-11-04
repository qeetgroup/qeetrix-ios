import Qeetrix
import SwiftUI

struct QRScannerPage: View {
    // No camera here: the preview is a stand-in, and the states are switched by hand.
    @State private var state = QeetrixQRScannerState.scanning
    @State private var isTorchOn = false
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack(spacing: 0) {
            Picker("State", selection: $state) {
                ForEach(QeetrixQRScannerState.allCases, id: \.self) { state in
                    Text(state.rawValue).tag(state)
                }
            }
            .pickerStyle(.segmented)
            .padding(QeetrixSpace.insetLg)
            QeetrixQRScanner(
                state: state, isTorchOn: $isTorchOn,
                messages: QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page")),
                onContinue: { state = .scanning }, onOpenSettings: { state = .notDetermined },
                onTypeKey: { toast = QeetrixToast(.info, title: "The key field opens here") }
            ) {
                LinearGradient(
                    colors: [QeetrixColor.datavizSequential2.color(for: .light), QeetrixColor.datavizSequential6.color(for: .light)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .accessibilityHidden(true)
            }
            .accessibilityIdentifier("qr-scanner")
        }
        .background(QeetrixColor.surfaceCanvas)
        .qeetrixToast($toast)
        .navigationTitle("QR scanner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { QRScannerPage() }
}
