import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the security-flow pages of Sources/Qeetrix/Qeetrix.docc — Components/CircularProgress.md,
// QRCode.md, QRScanner.md and PermissionPrimer.md — copied verbatim inside views that supply the names
// they use. Every value is synthetic: no real key, account or camera is involved.

/// A stand-in for the app's `AVCaptureSession`.
private struct CaptureSession {}

/// A stand-in for the app's camera preview, an `AVCaptureVideoPreviewLayer` in a representable.
private struct CameraPreview: View {
    let session: CaptureSession

    var body: some View {
        Color.black
    }
}

/// CircularProgress.md.
private struct CircularProgressExamples: View {
    let period = Date.now...Date.now.addingTimeInterval(30)

    var body: some View {
        VStack {
            HStack(spacing: QeetrixSpace.gapLg) {
                QeetrixCircularProgress(value: 0.4, label: Text("Uploading invoice.pdf"))
                QeetrixCircularProgress(value: 1, size: .lg, tone: .success, label: Text("Upload complete"))
            }
            TimelineView(.periodic(from: period.lowerBound, by: 1)) { context in
                let secondsLeft = Int(period.upperBound.timeIntervalSince(context.date).rounded(.up))
                QeetrixCircularProgress(
                    timerInterval: period, size: .lg, tone: secondsLeft <= 5 ? .warning : .brand,
                    label: Text("Time left on this code"), currentValueLabel: Text("\(secondsLeft) seconds left"))
            }
            ProgressView(value: 0.25)
                .progressViewStyle(.qeetrixCircular(size: .lg, tone: .success))
        }
    }
}

/// QRCode.md.
private struct QRCodeExamples: View {
    let setupLink = "otpauth://totp/Acme:priya@acme.in?secret=JBSWY3DPEHPK3PXP&issuer=Acme"
    let setupKey = "JBSW Y3DP EHPK 3PXP"
    let upiLink = "upi://pay?pa=acme@upi&pn=Acme%20Traders&am=1250.00&cu=INR"

    var body: some View {
        VStack(spacing: QeetrixSpace.gapLg) {
            QeetrixQRCode(setupLink, label: "QR code to add Acme to your authenticator app", text: Text(setupKey))
            QeetrixQRCode(upiLink, label: "QR code to pay Acme Traders by UPI", level: .q, text: Text("acme@upi"))
        }
    }
}

/// QRScanner.md.
private struct QRScannerExample: View {
    let scannerState: QeetrixQRScannerState
    let session = CaptureSession()
    @State private var isTorchOn = false
    @State private var isTypingKey = false

    var body: some View {
        QeetrixQRScanner(
            state: scannerState, isTorchOn: $isTorchOn,
            messages: QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page")),
            onContinue: requestCameraAccess, onTypeKey: { isTypingKey = true }
        ) {
            CameraPreview(session: session)
        }
    }

    func requestCameraAccess() {}
}

/// PermissionPrimer.md.
private struct PermissionPrimerExamples: View {
    let status: QeetrixPermissionPrimerStatus
    @State private var asksForLocation = false

    var body: some View {
        VStack {
            QeetrixPermissionPrimer(
                .notifications, status: status,
                title: "Know when a payment arrives",
                message: "Qeet Pay sends a notification when a customer pays an invoice. Nothing else.",
                onContinue: requestAuthorization, onNotNow: dismiss)
            // PermissionPrimer.md: a footnote under the actions.
            QeetrixPermissionPrimer(
                .notifications, title: "Approve sign-ins from this phone",
                message: "Qeet ID notifies you when you sign in somewhere new.",
                onContinue: requestAuthorization, onNotNow: dismiss
            )
            .footnote(Text("Only sign-in requests. Nothing else, no marketing."))
            Text("Branches")
                .qeetrixSheet(isPresented: $asksForLocation) {
                    QeetrixPermissionPrimer(
                        .location, title: "Find branches near you",
                        message: "Qeet People uses your location only while you look for a branch.",
                        onContinue: requestLocation, onNotNow: { asksForLocation = false })
                }
        }
    }

    func requestAuthorization() {}
    func dismiss() {}
    func requestLocation() {}
}

@MainActor
@Suite("Security-flow documentation examples")
struct AuthDocumentationExamplesTests {
    @Test("Every circular progress, QR code, scanner and permission primer example compiles against the public API and renders")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: CircularProgressExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: QRCodeExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            for state in QeetrixQRScannerState.allCases {
                #expect(
                    ImageRenderer(content: QRScannerExample(scannerState: state).frame(width: 390, height: 640).qeetrixThemeMode(theme))
                        .cgImage != nil)
            }
            for status in QeetrixPermissionPrimerStatus.allCases {
                let primer = PermissionPrimerExamples(status: status).frame(width: 390).qeetrixThemeMode(theme)
                #expect(ImageRenderer(content: primer).cgImage != nil)
            }
        }
    }
}
