import Qeetrix
import SwiftUI

struct PermissionPrimerPage: View {
    // The page asks for nothing: Continue only moves the demo on to the denied state.
    @State private var status = QeetrixPermissionPrimerStatus.notDetermined
    @State private var kind = QeetrixPermissionPrimerKind.camera
    @State private var showsSheet = false

    var body: some View {
        ComponentPage(
            title: "Permission primer",
            summary: "Why the app needs a permission, before iOS asks; Open Settings once it's off. Qeetrix asks for nothing itself."
        ) {
            DemoSection("Kinds") {
                Picker("Kind", selection: $kind) {
                    ForEach(QeetrixPermissionPrimerKind.allCases, id: \.self) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                Picker("Status", selection: $status) {
                    ForEach(QeetrixPermissionPrimerStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                QeetrixCard {
                    QeetrixPermissionPrimer(
                        kind, status: status, title: Text(Self.title(kind, status)), message: Text(Self.message(kind, status)),
                        onContinue: { status = .denied }, onOpenSettings: { status = .notDetermined }, onNotNow: {})
                }
            }
            DemoSection("In a sheet") {
                QeetrixButton("Find branches near you", variant: .soft) { showsSheet = true }
            }
        }
        .qeetrixSheet(isPresented: $showsSheet) {
            QeetrixPermissionPrimer(
                .location, title: "Find branches near you", message: "Qeet People uses your location only while you look for a branch.",
                onContinue: { showsSheet = false }, onNotNow: { showsSheet = false })
        }
    }

    static func title(_ kind: QeetrixPermissionPrimerKind, _ status: QeetrixPermissionPrimerStatus) -> String {
        switch (kind, status) {
        case (.camera, .notDetermined): "Scan the QR code"
        case (.location, .notDetermined): "Find branches near you"
        case (.notifications, .notDetermined): "Know when a payment arrives"
        case (.photos, .notDetermined): "Add a receipt from Photos"
        case (.contacts, .notDetermined): "Invite people you know"
        case (.camera, .denied): "Camera access is off"
        case (.location, .denied): "Location is off"
        case (.notifications, .denied): "Notifications are off"
        case (.photos, .denied): "Photos access is off"
        case (.contacts, .denied): "Contacts access is off"
        }
    }

    static func message(_ kind: QeetrixPermissionPrimerKind, _ status: QeetrixPermissionPrimerStatus) -> String {
        switch status {
        case .notDetermined: "Qeet uses this only for what you're doing now. You can change it in Settings at any time."
        case .denied: "Turn it on for this app in Settings to carry on."
        }
    }
}

#Preview {
    NavigationStack { PermissionPrimerPage() }
}
