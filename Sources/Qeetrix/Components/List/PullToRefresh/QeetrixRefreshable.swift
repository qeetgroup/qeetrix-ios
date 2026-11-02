import Accessibility
import SwiftUI

/// How a pull to refresh ended: what VoiceOver hears once it has, and the haptic that plays.
///
/// ```swift
/// List(approvals) { ApprovalRow($0) }
///     .qeetrixRefreshable {
///         do {
///             let added = try await model.reload()
///             return added == 0 ? .updated : .updated("\(added) new requests")
///         } catch {
///             toast = .danger("Couldn't refresh your approvals")
///             return .failed
///         }
///     }
/// ```
///
/// The announcement is a plain, already-localised string, because it is spoken; never put a secret
/// in it.
public struct QeetrixRefreshResult: Equatable, Sendable {
    /// Whether the refresh did what it was asked: the content is up to date, or it isn't.
    enum Outcome: Equatable, Sendable {
        case updated, failed
    }

    let outcome: Outcome
    /// What VoiceOver hears once the refresh has ended; `nil` for nothing.
    public let announcement: String?

    init(outcome: Outcome, announcement: String?) {
        self.outcome = outcome
        self.announcement = announcement
    }

    /// The content is up to date: "Updated", read once VoiceOver has finished what it is saying, and the
    /// success haptic.
    public static var updated: QeetrixRefreshResult {
        QeetrixRefreshResult(outcome: .updated, announcement: standardAnnouncement)
    }

    /// The content is up to date, said in the app's words — "2 new requests" — read once VoiceOver has
    /// finished what it is saying, with the success haptic.
    public static func updated(_ announcement: LocalizedStringResource) -> QeetrixRefreshResult {
        QeetrixRefreshResult(outcome: .updated, announcement: String(localized: announcement))
    }

    /// The refresh failed, and the app shows it — a danger ``QeetrixToast`` or a ``QeetrixAlert``,
    /// which announce themselves — so nothing more is said. The error haptic plays.
    public static var failed: QeetrixRefreshResult {
        QeetrixRefreshResult(outcome: .failed, announcement: nil)
    }

    /// The refresh failed: the app's words, read at once, interrupting, with the error haptic. Show
    /// the failure on the screen too; an announcement is gone once it has been said.
    public static func failed(_ announcement: LocalizedStringResource) -> QeetrixRefreshResult {
        QeetrixRefreshResult(outcome: .failed, announcement: String(localized: announcement))
    }

    /// "Updated" — iOS's own, as qeetrix-android's `qx_refresh_finished`.
    static var standardAnnouncement: String {
        String(localized: "qeetrix.refresh.updated", defaultValue: "Updated", bundle: .module)
    }

    /// The haptic for the outcome. The system taps as a pull starts the refresh and plays nothing when
    /// it ends, so this is the only one at the end.
    var feedback: QeetrixFeedback {
        outcome == .updated ? .success : .error
    }

    /// The announcement as posted: an update politely, once current speech has finished (the web's
    /// `role="status"`); a failure urgently, interrupting (`role="alert"`). `nil` when there is nothing
    /// to say.
    var spokenAnnouncement: AttributedString? {
        guard let announcement, !announcement.isEmpty else { return nil }
        var text = AttributedString(announcement)
        text.accessibilitySpeechAnnouncementPriority = outcome == .updated ? .low : .high
        return text
    }

    /// Says how the refresh ended, and plays its haptic.
    @MainActor
    func post() {
        if let spokenAnnouncement {
            AccessibilityNotification.Announcement(spokenAnnouncement).post()
        }
        feedback.play()
    }
}

extension View {
    /// Makes a `List` or `ScrollView` refreshable with the system's pull to refresh, and says when the
    /// refresh has finished: "Updated", or your words, once VoiceOver has finished what it is saying,
    /// with the success haptic.
    ///
    /// ```swift
    /// List(approvals) { approval in
    ///     QeetrixListItem(approval.app, description: Text(approval.place))
    /// }
    /// .qeetrixListStyle()
    /// .qeetrixRefreshable { await model.reload() }
    /// ```
    ///
    /// The control is `refreshable(action:)`'s: iOS draws its indicator, in its own grey — SwiftUI
    /// gives it no tint — taps as the pull starts the refresh, and keeps the indicator showing until
    /// `action` returns. Qeetrix adds no motion; the announcement and the haptic come once `action` has
    /// returned, and not at all if the refresh was cancelled. For a refresh that can fail, use
    /// `qeetrixRefreshable(action:)` returning a ``QeetrixRefreshResult``.
    ///
    /// - Parameters:
    ///   - announcement: What VoiceOver hears when the refresh has finished; "Updated" by default.
    ///   - action: The refresh. Keep the content showing while it runs.
    public func qeetrixRefreshable(
        announcement: LocalizedStringResource? = nil, action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        let result: QeetrixRefreshResult = announcement.map { .updated($0) } ?? .updated
        return modifier(
            QeetrixRefreshableModifier {
                await action()
                return result
            })
    }

    /// Makes a `List` or `ScrollView` refreshable with the system's pull to refresh; `action` says how
    /// the refresh ended — up to date, in the standard words or yours, or failed — and Qeetrix says so
    /// to VoiceOver at the right priority, with the success or error haptic.
    ///
    /// ```swift
    /// List(approvals) { ApprovalRow($0) }
    ///     .qeetrixRefreshable {
    ///         do {
    ///             try await model.reload()
    ///             return .updated
    ///         } catch {
    ///             toast = .danger("Couldn't refresh your approvals")
    ///             return .failed
    ///         }
    ///     }
    /// ```
    public func qeetrixRefreshable(action: @escaping @MainActor @Sendable () async -> QeetrixRefreshResult) -> some View {
        modifier(QeetrixRefreshableModifier(action: action))
    }
}

/// The system's refresh, then the announcement and the haptic for how it ended.
struct QeetrixRefreshableModifier: ViewModifier {
    let action: @MainActor @Sendable () async -> QeetrixRefreshResult

    func body(content: Content) -> some View {
        content.refreshable {
            await Self.refresh(action) { $0.post() }
        }
    }

    /// Runs the refresh, then `finish` with its result — unless the refresh was cancelled (the screen
    /// went away, or SwiftUI replaced the refresh), when nothing is said or played.
    @MainActor
    static func refresh(
        _ action: @MainActor @Sendable () async -> QeetrixRefreshResult, finish: @MainActor (QeetrixRefreshResult) -> Void
    ) async {
        let result = await action()
        guard !Task.isCancelled else { return }
        finish(result)
    }
}
