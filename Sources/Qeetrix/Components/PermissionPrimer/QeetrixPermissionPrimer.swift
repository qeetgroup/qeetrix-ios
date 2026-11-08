import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// What a ``QeetrixPermissionPrimer`` asks for, each with its icon.
public enum QeetrixPermissionPrimerKind: String, CaseIterable, Sendable {
    /// `camera`: scanning a code, taking a photo.
    case camera
    /// `map-pin`.
    case location
    /// `bell`.
    case notifications
    /// `image`: the photo library.
    case photos
    /// `contact-round`.
    case contacts

    /// The primer's icon.
    public var icon: QeetrixIconName {
        switch self {
        case .camera: .camera
        case .location: .mapPin
        case .notifications: .bell
        case .photos: .image
        case .contacts: .contactRound
        }
    }
}

/// Where a permission stands, as the app reads it from the framework that owns it
/// (`AVCaptureDevice.authorizationStatus(for:)`, `CLLocationManager.authorizationStatus`, …).
public enum QeetrixPermissionPrimerStatus: String, CaseIterable, Sendable {
    /// Not asked yet: the primer says why the app needs it, and Continue leads to the system's prompt.
    case notDetermined
    /// Turned off: iOS won't ask again, so Open Settings takes the person to the app's settings.
    case denied
}

/// A ``QeetrixPermissionPrimer``'s built-in button titles, as `@qeetrix/react`'s `messages`: each one you
/// set replaces the default.
public struct QeetrixPermissionPrimerMessages {
    /// "Continue".
    public var continueTitle: Text?
    /// "Not now".
    public var notNowTitle: Text?
    /// "Open Settings".
    public var openSettingsTitle: Text?

    /// The titles to replace; any left `nil` keep their default.
    public init(continueTitle: Text? = nil, notNowTitle: Text? = nil, openSettingsTitle: Text? = nil) {
        self.continueTitle = continueTitle
        self.notNowTitle = notNowTitle
        self.openSettingsTitle = openSettingsTitle
    }
}

/// Why the app needs a permission, before iOS asks for it — camera, location, notifications, photos or
/// contacts — and, once it has been turned off, the way back to it. On a screen of its own or in a
/// sheet.
///
/// ```swift
/// QeetrixPermissionPrimer(
///     .notifications, status: status,
///     title: "Know when a payment arrives",
///     message: "Qeet Pay sends a notification when a customer pays an invoice. Nothing else.",
///     onContinue: requestAuthorization, onNotNow: dismiss)
/// ```
///
/// Laid out as `@qeetrix/react`'s EmptyState is (empty-state.css): centred and at most 480 pt wide, the
/// kind's 24 pt sharp icon in `color.icon.subtle`, the title in `title.md` as a heading, the message in
/// `body.md` and `color.text.subtle`, then the actions — the primary full width with a trailing icon, as
/// Qeet's full-width buttons carry, and Not now short and centred under it:
///
/// - `notDetermined`: **Continue** (`solid`, `arrow-right`). Run the system's request in `onContinue`;
///   Qeetrix never asks for a permission itself.
/// - `denied`: **Open Settings** (`solid`, `external-link`), which opens the app's page in Settings — its
///   notification settings for `notifications` — unless `onOpenSettings` does something else.
/// - Both: **Not now** (`ghost`, short) when there's an `onNotNow`.
///
/// The arrows point the way the layout reads: they mirror right to left. `footnote(_:)` adds a short
/// reassurance under the actions — "Only sign-in requests. Nothing else, no marketing.".
///
/// "Continue" rather than "Allow", as Apple's guidelines ask, since the system's alert that follows is
/// where the person allows it. Say in `message` what the app does with the permission, in a sentence or
/// two; the system's alert shows your `Info.plist` purpose string as well. A restricted permission
/// (Screen Time, a device-management profile) can't be granted from here: show `denied`, and say who
/// manages the device.
public struct QeetrixPermissionPrimer: View {
    let kind: QeetrixPermissionPrimerKind
    let status: QeetrixPermissionPrimerStatus
    let title: Text
    let message: Text
    let headingLevel: Int
    let messages: QeetrixPermissionPrimerMessages
    let onContinue: @MainActor () -> Void
    let onOpenSettings: (@MainActor () -> Void)?
    let onNotNow: (@MainActor () -> Void)?
    /// A short reassurance under the actions.
    private(set) var footnoteText: Text?
    @Environment(\.openURL) private var openURL

    /// A primer with `Text` for its title and message.
    public init(
        _ kind: QeetrixPermissionPrimerKind,
        status: QeetrixPermissionPrimerStatus = .notDetermined,
        title: Text,
        message: Text,
        headingLevel: Int = 2,
        messages: QeetrixPermissionPrimerMessages = QeetrixPermissionPrimerMessages(),
        onContinue: @escaping @MainActor () -> Void,
        onOpenSettings: (@MainActor () -> Void)? = nil,
        onNotNow: (@MainActor () -> Void)? = nil
    ) {
        self.kind = kind
        self.status = status
        self.title = title
        self.message = message
        self.headingLevel = headingLevel
        self.messages = messages
        self.onContinue = onContinue
        self.onOpenSettings = onOpenSettings
        self.onNotNow = onNotNow
    }

    /// A primer with a localised title and message.
    public init(
        _ kind: QeetrixPermissionPrimerKind,
        status: QeetrixPermissionPrimerStatus = .notDetermined,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        headingLevel: Int = 2,
        messages: QeetrixPermissionPrimerMessages = QeetrixPermissionPrimerMessages(),
        onContinue: @escaping @MainActor () -> Void,
        onOpenSettings: (@MainActor () -> Void)? = nil,
        onNotNow: (@MainActor () -> Void)? = nil
    ) {
        self.init(
            kind, status: status, title: Text(title), message: Text(message), headingLevel: headingLevel, messages: messages,
            onContinue: onContinue, onOpenSettings: onOpenSettings, onNotNow: onNotNow)
    }

    /// Adds a short reassurance under the actions, centred in `body.sm` and `color.text.subtle`: what the
    /// permission is used for and what it isn't — "Only sign-in requests. Nothing else, no marketing."
    public func footnote(_ text: Text) -> Self {
        var primer = self
        primer.footnoteText = text
        return primer
    }

    public var body: some View {
        QeetrixPermissionPrimerLayout(
            icon: kind.icon, title: title, message: message, headingLevel: headingLevel, footnote: footnoteText
        ) {
            Group {
                switch status {
                case .notDetermined:
                    let title = messages.continueTitle ?? Text(QeetrixPermissionPrimerStrings.continueTitle)
                    QeetrixButton(title: title, icon: QeetrixPermissionPrimerMetrics.continueIcon, size: .lg, isFullWidth: true) {
                        onContinue()
                    }
                case .denied:
                    let title = messages.openSettingsTitle ?? Text(QeetrixPermissionPrimerStrings.openSettings)
                    QeetrixButton(title: title, icon: QeetrixPermissionPrimerMetrics.openSettingsIcon, size: .lg, isFullWidth: true) {
                        openSettings()
                    }
                }
            }
            // "Continue" and "open" are directions: the arrows follow the layout.
            .environment(\.qeetrixButtonIconMirrors, true)
            if let onNotNow {
                // Short, without an icon: a full-width button carries one.
                let notNow = messages.notNowTitle ?? Text(QeetrixPermissionPrimerStrings.notNow)
                QeetrixButton(title: notNow, variant: .ghost, size: .lg) {
                    onNotNow()
                }
            }
        }
    }

    private func openSettings() {
        if let onOpenSettings {
            onOpenSettings()
        } else if let url = Self.settingsURL(for: kind) {
            openURL(url)
        }
    }

    /// The app's own page in Settings, or for notifications its notification settings.
    static func settingsURL(for kind: QeetrixPermissionPrimerKind) -> URL? {
        #if canImport(UIKit)
            URL(string: kind == .notifications ? UIApplication.openNotificationSettingsURLString : UIApplication.openSettingsURLString)
        #else
            nil
        #endif
    }
}

/// The primer's icons.
enum QeetrixPermissionPrimerMetrics {
    /// On Continue: on to the system's request.
    static let continueIcon = QeetrixIconName.arrowRight
    /// On Open Settings: out to the Settings app.
    static let openSettingsIcon = QeetrixIconName.externalLink
}

/// EmptyState's column (empty-state.css): the icon, the title, the message and, when there are any, the
/// actions and a footnote, `space.gap.sm` apart, centred in at most 480 pt with `space.layout.lg` above and below and
/// `space.inset.lg` at the sides. ``QeetrixQRScanner`` draws its no-camera state with it too.
struct QeetrixPermissionPrimerLayout<Actions: View>: View {
    let icon: QeetrixIconName
    let title: Text
    let message: Text
    let headingLevel: Int
    let footnote: Text?
    let actions: Actions?

    /// empty-state.css: `.qx-empty-state { max-inline-size: 480px }`.
    static var maxWidth: CGFloat { 480 }

    init(
        icon: QeetrixIconName, title: Text, message: Text, headingLevel: Int, footnote: Text? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.headingLevel = headingLevel
        self.footnote = footnote
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: QeetrixSpace.gapSm) {
            // `.qx-empty-state-icon`: 24 px, `margin-block-end: space.gap.xs`.
            QeetrixIcon(icon, size: .lg, shape: .sharp)
                .foregroundStyle(QeetrixColor.iconSubtle)
                .padding(.bottom, QeetrixSpace.gapXs)
            QeetrixHeading(title, level: headingLevel, size: .titleMd, align: .center)
            message
                .qeetrixTextStyle(.bodyMd)
                .foregroundStyle(QeetrixColor.textSubtle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let actions {
                // `.qx-empty-state-actions { margin-block-start: space.gap.sm; gap: space.gap.sm }`.
                VStack(spacing: QeetrixSpace.gapSm) { actions }
                    .padding(.top, QeetrixSpace.gapSm)
            }
            if let footnote {
                // `.qx-empty-state-footer`: body.sm, color.text.subtle.
                footnote
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, QeetrixSpace.layoutLg)
        .padding(.horizontal, QeetrixSpace.insetLg)
        .frame(maxWidth: Self.maxWidth)
        .frame(maxWidth: .infinity)
    }
}

extension QeetrixPermissionPrimerLayout where Actions == EmptyView {
    /// The column without actions.
    init(icon: QeetrixIconName, title: Text, message: Text, headingLevel: Int) {
        self.icon = icon
        self.title = title
        self.message = message
        self.headingLevel = headingLevel
        self.footnote = nil
        self.actions = nil
    }
}

/// The primer's built-in strings, `qeetrix.permission-primer.*` in `Resources/Localization`, with their
/// English defaults beside them.
enum QeetrixPermissionPrimerStrings {
    /// "Continue" — Apple's word for a button before the system's alert, never "Allow".
    static let continueTitle = LocalizedStringResource("qeetrix.permission-primer.continue", defaultValue: "Continue", bundle: bundle)
    /// "Not now".
    static let notNow = LocalizedStringResource("qeetrix.permission-primer.not-now", defaultValue: "Not now", bundle: bundle)
    /// "Open Settings", the name of the Settings app.
    static let openSettings = LocalizedStringResource(
        "qeetrix.permission-primer.open-settings", defaultValue: "Open Settings", bundle: bundle)

    /// The package's own bundle, for a resource resolved where it's displayed.
    static let bundle = LocalizedStringResource.BundleDescription.atURL(Bundle.module.bundleURL)
}
