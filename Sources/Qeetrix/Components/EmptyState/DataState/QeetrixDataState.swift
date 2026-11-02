import Accessibility
import SwiftUI

/// What a ``QeetrixDataState`` says when its load fails: `@qeetrix/react`'s `dataState` messages, and
/// the icon that goes with them.
///
/// ```swift
/// let offline = QeetrixDataStateFailure(
///     title: "You're offline", description: "Connect to the internet to see your accounts.", icon: .wifiOff)
/// ```
///
/// Say what couldn't load and what the person can do — never the raw error, a status code or a server
/// message, which may hold internals. The strings are plain and already localised, because they are
/// also announced.
public struct QeetrixDataStateFailure: Equatable, Sendable {
    /// What couldn't load: "Couldn't load your accounts".
    public var title: String
    /// What to do, in a sentence.
    public var description: String?
    /// A 24 pt icon, drawn sharp in `color.icon.danger`: `circle-alert` by default, `wifi-off` when offline.
    public var icon: QeetrixIconName
    /// The retry button's title.
    public var retryLabel: String

    /// - Parameters:
    ///   - title: What couldn't load, already localised.
    ///   - description: What to do, already localised.
    ///   - icon: The icon; `circle-alert` by default.
    ///   - retryLabel: The retry button's title; "Try again" by default (`dataState.retry`).
    public init(title: String, description: String? = nil, icon: QeetrixIconName = .circleAlert, retryLabel: String? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.retryLabel = retryLabel ?? Self.standardRetryLabel
    }

    /// The web's words: "Couldn't load this" and "Try again, or check your connection."
    /// (`dataState.errorTitle`, `dataState.errorDescription`), with `circle-alert`.
    public static var standard: QeetrixDataStateFailure {
        QeetrixDataStateFailure(
            title: String(localized: "qeetrix.data-state.error-title", defaultValue: "Couldn't load this", bundle: .module),
            description: String(
                localized: "qeetrix.data-state.error-description", defaultValue: "Try again, or check your connection.", bundle: .module))
    }

    /// "Try again" — `dataState.retry`.
    static var standardRetryLabel: String {
        String(localized: "qeetrix.data-state.retry", defaultValue: "Try again", bundle: .module)
    }

    /// The announcement when the failure appears: its title and description, at high priority, as the
    /// web's `role="alert"`.
    var announcement: AttributedString {
        var text = AttributedString([title, description].compactMap { $0 }.joined(separator: ". "))
        text.accessibilitySpeechAnnouncementPriority = .high
        return text
    }
}

/// Which of its four states a ``QeetrixDataState`` shows.
enum QeetrixDataStatePhase: Equatable {
    case loading, failed, empty, content

    /// `@qeetrix/react`'s order: loading wins, then the error, then empty, then the content.
    init(isLoading: Bool, isFailed: Bool, isEmpty: Bool) {
        self = isLoading ? .loading : isFailed ? .failed : isEmpty ? .empty : .content
    }
}

/// The four states of loaded content in one place, as `@qeetrix/react`'s DataState: loading, then a
/// failure, then empty, then the content — in that order, so none is forgotten.
///
/// ```swift
/// QeetrixDataState(isLoading: model.isLoading, error: model.error, isEmpty: model.accounts.isEmpty, onRetry: model.reload) {
///     AccountList(accounts: model.accounts)
/// } emptyState: {
///     QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus)
/// }
/// ```
///
/// - **Loading** shows an `lg` ``QeetrixSpinner`` ("Loading"), centred over the failure state, which is
///   laid out but not drawn, so the screen doesn't jump when a load fails. VoiceOver finds one element,
///   "Loading".
/// - **A failure** — any `error` — shows a `section` ``QeetrixEmptyState`` in the danger tone with
///   `failure`'s icon, title and description and, with `onRetry`, a soft Try again button. VoiceOver
///   announces it as it appears. The error itself is never shown: log it in the app.
/// - **Empty** shows `emptyState`, usually a ``QeetrixEmptyState`` with your words.
/// - **The content** is shown as it is, with no wrapper.
///
/// The state is the app's: this view loads, retries and caches nothing. Keep showing the content while
/// you refresh it, and set `isLoading` only when there is nothing to show yet; for pull to refresh, put
/// `qeetrixRefreshable(announcement:action:)` on the content.
public struct QeetrixDataState<Content: View, EmptyContent: View>: View {
    let phase: QeetrixDataStatePhase
    let failure: QeetrixDataStateFailure
    let onRetry: (@MainActor () -> Void)?
    let content: Content
    let emptyState: EmptyContent

    /// - Parameters:
    ///   - isLoading: The content is loading. It wins over every other state.
    ///   - error: Any error shows the failure state. It is never shown.
    ///   - isEmpty: The content loaded, and there is nothing in it.
    ///   - failure: What the failure state says; the web's words by default. Pass the app's own, such as
    ///     an offline message with `wifi-off`.
    ///   - onRetry: Adds a soft Try again button to the failure state, which calls it.
    ///   - content: The content, shown as it is when it has loaded and isn't empty.
    ///   - emptyState: What to show when the content is empty.
    public init(
        isLoading: Bool, error: (any Error)? = nil, isEmpty: Bool = false, failure: QeetrixDataStateFailure = .standard,
        onRetry: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content, @ViewBuilder emptyState: () -> EmptyContent
    ) {
        phase = QeetrixDataStatePhase(isLoading: isLoading, isFailed: error != nil, isEmpty: isEmpty)
        self.failure = failure
        self.onRetry = onRetry
        self.content = content()
        self.emptyState = emptyState()
    }

    public var body: some View {
        switch phase {
        case .loading:
            // [data-state="loading"]: the spinner centred over the failure, which holds the height but is
            // unseen, unreachable and silent (.qx-data-state-reserve: visibility hidden, inert, aria-hidden).
            ZStack {
                QeetrixDataStateFailureView(failure: failure, hasRetry: onRetry != nil, retry: {})
                    .hidden()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                QeetrixSpinner(size: .lg)
            }
            .frame(maxWidth: .infinity)
        case .failed:
            QeetrixDataStateFailureView(failure: failure, hasRetry: onRetry != nil, retry: { onRetry?() })
                .onAppear { announce() }
                .onChange(of: failure) { announce() }
        case .empty:
            emptyState
        case .content:
            content
        }
    }

    private func announce() {
        AccessibilityNotification.Announcement(failure.announcement).post()
    }
}

extension QeetrixDataState where EmptyContent == EmptyView {
    /// A data state whose content is never empty, or that shows nothing when it is.
    public init(
        isLoading: Bool, error: (any Error)? = nil, failure: QeetrixDataStateFailure = .standard,
        onRetry: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content
    ) {
        self.init(isLoading: isLoading, error: error, isEmpty: false, failure: failure, onRetry: onRetry, content: content) {
            EmptyView()
        }
    }
}

/// data-state.tsx `failure`: a `section`, danger-toned empty state with the failure's icon, title and
/// description, and with a retry a soft button (`<Button variant="soft">`).
struct QeetrixDataStateFailureView: View {
    let failure: QeetrixDataStateFailure
    let hasRetry: Bool
    let retry: @MainActor () -> Void

    var body: some View {
        if hasRetry {
            QeetrixEmptyState(
                failure.title, description: failure.description, icon: failure.icon, size: .section, tone: .danger
            ) {
                QeetrixButton(failure.retryLabel, variant: .soft, action: retry)
            }
        } else {
            QeetrixEmptyState(failure.title, description: failure.description, icon: failure.icon, size: .section, tone: .danger)
        }
    }
}
