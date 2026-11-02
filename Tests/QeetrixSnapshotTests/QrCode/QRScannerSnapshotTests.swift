#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    /// A synthetic camera scene: white at the top, the worst case for the scrim, to dark at the bottom.
    private let scene = LinearGradient(colors: [.white, .gray, .black], startPoint: .top, endPoint: .bottom)

    @MainActor
    @Suite("QR scanner snapshots")
    struct QRScannerSnapshotTests {
        @Test("Scanning, with the torch off and the typed-key fallback, then on without the fallback")
        func scanning() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixQRScanner(state: .scanning, isTorchOn: .constant(false), onContinue: {}, onTypeKey: {}) { scene }
                        .frame(height: 600)
                    QeetrixQRScanner(
                        state: .scanning, isTorchOn: .constant(true),
                        messages: QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page")),
                        onContinue: {}
                    ) { scene }
                    .frame(height: 520)
                }
            )
        }

        @Test("Before the camera is allowed, once it's turned off, and without a camera")
        func permissionStates() {
            assertSpecimen(
                VStack(spacing: 16) {
                    ForEach([QeetrixQRScannerState.notDetermined, .denied, .unavailable], id: \.self) { state in
                        QeetrixQRScanner(state: state, onContinue: {}, onTypeKey: {}) { scene }
                            .frame(height: 520)
                    }
                }
            )
        }
    }
#endif
