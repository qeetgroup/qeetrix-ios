import Accessibility
import SwiftUI

/// What an alert reports, as `@qeetrix/react`'s `AlertTone`. Each tone has its own icon and a word
/// VoiceOver reads before the title, so the status is never colour alone.
public enum QeetrixAlertTone: String, CaseIterable, Sendable {
    /// Something to know, the default.
    case info
    /// Something finished as intended.
    case success
    /// Something to check before it becomes a problem.
    case warning
    /// Something failed or blocks the task.
    case danger

    /// The tint (alert.css `background`): `color.bg.<tone>.subtle`.
    var background: QeetrixColor {
        switch self {
        case .info: .bgInfoSubtle
        case .success: .bgSuccessSubtle
        case .warning: .bgWarningSubtle
        case .danger: .bgDangerSubtle
        }
    }

    /// The status edge and icon colour: `color.icon.<tone>`.
    var accent: QeetrixColor {
        switch self {
        case .info: .iconInfo
        case .success: .iconSuccess
        case .warning: .iconWarning
        case .danger: .iconDanger
        }
    }

    /// Each tone's own icon, so status is never colour alone.
    var icon: QeetrixIconName {
        switch self {
        case .info: .info
        case .success: .circleCheck
        case .warning: .triangleAlert
        case .danger: .circleAlert
        }
    }

    /// The word VoiceOver reads before the title — the web's hidden "Warning: " (`alert.info`, …).
    var spokenName: String {
        switch self {
        case .info: String(localized: "qeetrix.alert.info", defaultValue: "Information", bundle: .module)
        case .success: String(localized: "qeetrix.alert.success", defaultValue: "Success", bundle: .module)
        case .warning: String(localized: "qeetrix.alert.warning", defaultValue: "Warning", bundle: .module)
        case .danger: String(localized: "qeetrix.alert.danger", defaultValue: "Error", bundle: .module)
        }
    }
}

/// How an alert that appears after something happens is announced, as `@qeetrix/react`'s Alert
/// `announce`.
public enum QeetrixAlertAnnouncement: String, CaseIterable, Sendable {
    /// Waits for VoiceOver to finish what it is saying — the web's `role="status"`.
    case polite
    /// Interrupts, for an error that blocks the task — the web's `role="alert"`.
    case urgent
}

/// A message in the page — above a form, inside a card, at the top of a screen — as `@qeetrix/react`'s
/// Alert: the tone's tint with a 3 pt status edge on the start side, the tone's sharp 16 pt icon, a
/// title, a line of description, and optional actions and Dismiss.
///
/// ```swift
/// QeetrixAlert("Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning) {
///     QeetrixButton("Open Settings", size: .sm) { openSettings() }
/// }
/// QeetrixAlert("You're offline", description: "Approvals arrive when you reconnect.", onDismiss: { isOfflineShown = false })
/// ```
///
/// It never takes focus and never leaves by itself: the app removes it, and decides whether a
/// dismissed alert comes back. The title says what happened in a few words; the description, why and
/// what to do. Put at most one primary action in `actions`. VoiceOver reads the tone's word before the
/// title ("Warning: Push notifications are off"); an alert that appears after something happens can
/// also be announced with `announce`. The title and description are plain strings, because they are
/// also announced; never put secrets in them. For feedback about an outcome that leaves by itself, use
/// ``QeetrixToast``.
public struct QeetrixAlert<Actions: View>: View {
    let title: String
    let description: String?
    let tone: QeetrixAlertTone
    let icon: QeetrixIconName?
    let announce: QeetrixAlertAnnouncement?
    let onDismiss: (@MainActor () -> Void)?
    let actions: Actions?

    /// An alert with a localised title and description, and actions.
    ///
    /// - Parameters:
    ///   - title: What happened, in a few words, localised from the main bundle.
    ///   - description: One or two sentences: why, and what to do.
    ///   - tone: The status, `info` by default.
    ///   - icon: An icon in place of the tone's, such as an eye for "viewing as". The tone is still read.
    ///   - announce: How VoiceOver announces the alert when it appears or changes; `nil`, the default,
    ///     for an alert that is there when the screen opens.
    ///   - onDismiss: Adds Dismiss, which calls it. The app removes the alert.
    ///   - actions: Buttons under the text, wrapping onto more rows: at most one primary.
    public init(
        _ title: LocalizedStringResource, description: LocalizedStringResource? = nil, tone: QeetrixAlertTone = .info,
        icon: QeetrixIconName? = nil, announce: QeetrixAlertAnnouncement? = nil, onDismiss: (@MainActor () -> Void)? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: String(localized: title), description: description.map { String(localized: $0) }, tone: tone, icon: icon,
            announce: announce, onDismiss: onDismiss, actions: actions())
    }

    /// An alert with a title and description shown as given, and actions.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, tone: QeetrixAlertTone = .info, icon: QeetrixIconName? = nil,
        announce: QeetrixAlertAnnouncement? = nil, onDismiss: (@MainActor () -> Void)? = nil, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: String(title), description: description, tone: tone, icon: icon, announce: announce, onDismiss: onDismiss,
            actions: actions())
    }

    init(
        title: String, description: String?, tone: QeetrixAlertTone, icon: QeetrixIconName?, announce: QeetrixAlertAnnouncement?,
        onDismiss: (@MainActor () -> Void)?, actions: Actions?
    ) {
        self.title = title
        self.description = description
        self.tone = tone
        self.icon = icon
        self.announce = announce
        self.onDismiss = onDismiss
        self.actions = actions
    }

    public var body: some View {
        QeetrixAlertSurface(tone: tone, icon: icon, dismiss: onDismiss) {
            // .qx-alert-body: the text over its actions, 2 pt apart.
            VStack(alignment: .leading, spacing: 2) {
                // .qx-alert-text: the title over the description, 2 pt apart.
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: title)
                        .qeetrixType(QeetrixAlertSurface<EmptyView>.titleType)
                        .foregroundStyle(QeetrixColor.textDefault)
                    if let description {
                        Text(verbatim: description)
                            .qeetrixTextStyle(.bodyMd)
                            .foregroundStyle(QeetrixColor.textSubtle)
                    }
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: spokenText))
                if let actions {
                    // .qx-alert-actions: wrapping, 8 pt apart, 8 pt under the text.
                    QeetrixFeedbackActionsLayout(spacing: QeetrixSpace.gapSm, alignment: .leading) { actions }
                        .padding(.top, QeetrixSpace.gapSm)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .onAppear { post() }
        .onChange(of: spokenText) { post() }
    }

    /// The text as VoiceOver reads it: the tone's word, then the title and the description.
    var spokenText: String {
        Self.spokenText(tone: tone, title: title, description: description)
    }

    static func spokenText(tone: QeetrixAlertTone, title: String, description: String?) -> String {
        ["\(tone.spokenName): \(title)", description].compactMap { $0 }.joined(separator: ", ")
    }

    /// The announcement for `announce`: the spoken text at its priority; `nil` without `announce`.
    var announcement: AttributedString? {
        guard let announce else { return nil }
        var text = AttributedString(spokenText)
        // polite waits for the speech before it; urgent interrupts, and isn't interrupted.
        text.accessibilitySpeechAnnouncementPriority = announce == .urgent ? .high : .low
        return text
    }

    private func post() {
        if let announcement {
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}

extension QeetrixAlert where Actions == EmptyView {
    /// An alert with a localised title and description, without actions.
    public init(
        _ title: LocalizedStringResource, description: LocalizedStringResource? = nil, tone: QeetrixAlertTone = .info,
        icon: QeetrixIconName? = nil, announce: QeetrixAlertAnnouncement? = nil, onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.init(
            title: String(localized: title), description: description.map { String(localized: $0) }, tone: tone, icon: icon,
            announce: announce, onDismiss: onDismiss, actions: nil)
    }

    /// An alert with a title and description shown as given, without actions.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, tone: QeetrixAlertTone = .info, icon: QeetrixIconName? = nil,
        announce: QeetrixAlertAnnouncement? = nil, onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.init(
            title: String(title), description: description, tone: tone, icon: icon, announce: announce, onDismiss: onDismiss,
            actions: nil)
    }
}

/// The in-page Alert surface (alert.css): the tone's tint, a 3 pt status edge on the start side, the
/// tone's sharp 16 pt icon and, with `dismiss`, a neutral `sm` Dismiss button at the end; no shadow.
/// ``QeetrixAlert`` and ``QeetrixErrorSummary`` are built on it.
struct QeetrixAlertSurface<Content: View>: View {
    let tone: QeetrixAlertTone
    let icon: QeetrixIconName?
    let dismiss: (@MainActor () -> Void)?
    let content: Content

    init(
        tone: QeetrixAlertTone, icon: QeetrixIconName? = nil, dismiss: (@MainActor () -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.tone = tone
        self.icon = icon
        self.dismiss = dismiss
        self.content = content()
    }

    /// The title: `label.md` at `title.sm`'s weight (600).
    static var titleType: QeetrixTypeSpec { QeetrixComponentType.role(.labelMd, QeetrixTextRole.titleSm.tokens.weight) }

    var body: some View {
        // .qx-alert: a row 12 pt apart (gap-md) of the icon, the body and Dismiss.
        HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
            QeetrixIcon(icon ?? tone.icon, size: .sm, shape: .sharp)
                .foregroundStyle(tone.accent)
                .padding(.top, 2)  // .qx-alert-icon: margin-block-start 2px, centred on the 20 pt line
            content
                .padding(.trailing, QeetrixSpace.gapXs)  // .qx-alert-body: padding-inline-end gap-xs
                .frame(maxWidth: .infinity, alignment: .leading)
            if let dismiss {
                QeetrixIconButton(.x, label: QeetrixStrings.dismiss, tone: .neutral, size: .sm, action: dismiss)
                    .padding(.vertical, -2)  // .qx-alert-dismiss: margin-block -2px
            }
        }
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
        .foregroundStyle(QeetrixColor.textDefault)
        // padding: inset-md inset-sm inset-md inset-md
        .padding(.vertical, QeetrixSpace.insetMd)
        .padding(.leading, QeetrixSpace.insetMd)
        .padding(.trailing, QeetrixSpace.insetSm)
        .background(tone.background)
        .overlay(alignment: .leading) {
            // border-inline-start: border-width-accent solid color-icon-<tone>
            Rectangle().fill(tone.accent).frame(width: QeetrixBorderWidth.accent).accessibilityHidden(true)
        }
    }
}
