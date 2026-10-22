import SwiftUI

/// A failed load, as a ``QeetrixDataState`` shows it: a message for the person and, optionally, a way to
/// try again.
public struct QeetrixDataFailure {
    /// What happened, already localised and written for the person — never a raw error, a status code or
    /// a stack trace. `nil` shows "Something went wrong while loading this data."
    public let message: String?
    let retry: (@MainActor () -> Void)?

    /// - Parameters:
    ///   - message: What happened, for the person. `nil` for the default message.
    ///   - retry: Runs when the person taps "Try again". Without it, no button is shown. Loading again,
    ///     and whether to, is your app's decision.
    public init(_ message: String? = nil, retry: (@MainActor () -> Void)? = nil) {
        self.message = message
        self.retry = retry
    }
}

/// The loading, failure and empty branches of a surface that shows loaded data, in one place, so none is
/// forgotten — the web's `DataState`.
///
/// ```swift
/// QeetrixDataState(isLoading: model.isLoading, isEmpty: model.invoices.isEmpty, failure: model.failure) {
///     List(model.invoices) { invoice in InvoiceRow(invoice) }
/// } empty: {
///     QeetrixEmptyState("No invoices yet", description: Text("Invoices appear here once you bill a customer."))
/// }
/// ```
///
/// One branch shows at a time, in the web's order: loading, then a failure, then empty, then the content.
///
/// - **Loading** shows six skeleton rows unless you pass your own `loading` view. VoiceOver finds one
///   element, "Loading", instead of a placeholder per row; nothing is announced while it waits.
/// - **A failure** shows an error ``QeetrixEmptyState`` with your message and, when you give it a retry
///   action, a "Try again" button. VoiceOver announces the message when the failure appears.
/// - **Empty** shows the `empty` view you pass.
///
/// The state is yours: this view fetches, retries and caches nothing. Keep the content visible while you
/// refresh it — `refreshable(action:)`, or a toolbar spinner — and set `isLoading` only when there is
/// nothing to show yet. A branch that comes back is built again, so state inside the content is kept in
/// your model rather than in the content's views.
public struct QeetrixDataState<Content: View, Loading: View, Empty: View>: View {
    let isLoading: Bool
    let isEmpty: Bool
    let failure: QeetrixDataFailure?
    let content: Content
    let loading: Loading
    let empty: Empty
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isLoading: Nothing to show yet: the loading branch.
    ///   - isEmpty: Loaded, with nothing in it: the empty branch.
    ///   - failure: The load failed: the failure branch.
    ///   - content: The data.
    ///   - loading: What shows while loading — skeletons in the shape of the content.
    ///   - empty: What shows when there is nothing — usually a ``QeetrixEmptyState``.
    public init(
        isLoading: Bool, isEmpty: Bool, failure: QeetrixDataFailure? = nil, @ViewBuilder content: () -> Content,
        @ViewBuilder loading: () -> Loading, @ViewBuilder empty: () -> Empty
    ) {
        self.isLoading = isLoading
        self.isEmpty = isEmpty
        self.failure = failure
        self.content = content()
        self.loading = loading()
        self.empty = empty()
    }

    public var body: some View {
        let phase = QeetrixDataPhase(isLoading: isLoading, isFailed: failure != nil, isEmpty: isEmpty)
        ZStack {
            switch phase {
            case .loading:
                loading
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(QeetrixStrings.loading)
                    .transition(.opacity)
            case .failed:
                QeetrixDataFailureView(failure: failure ?? QeetrixDataFailure())
                    .transition(.opacity)
            case .empty:
                empty.transition(.opacity)
            case .content:
                content.transition(.opacity)
            }
        }
        .animation(QeetrixMotion.animation(.standard, .fast, reduceMotion: reduceMotion), value: phase)
    }
}

extension QeetrixDataState where Loading == QeetrixDataLoadingRows {
    /// A data state that shows six skeleton rows while loading.
    public init(
        isLoading: Bool, isEmpty: Bool, failure: QeetrixDataFailure? = nil, @ViewBuilder content: () -> Content,
        @ViewBuilder empty: () -> Empty
    ) {
        self.init(
            isLoading: isLoading, isEmpty: isEmpty, failure: failure, content: content, loading: { QeetrixDataLoadingRows() }, empty: empty)
    }
}

/// The default loading branch of a ``QeetrixDataState``: full-width skeleton rows, 40 pt tall and 12 pt
/// apart, in a 16 pt inset — the web's `space-y-3 p-4` of six `h-10` skeletons.
public struct QeetrixDataLoadingRows: View {
    let rows: Int

    /// - Parameter rows: How many rows. At least one is drawn.
    public init(rows: Int = 6) {
        self.rows = max(1, rows)
    }

    public var body: some View {
        VStack(spacing: QeetrixWebScale.spacing(3)) {  // space-y-3
            ForEach(0..<rows, id: \.self) { _ in
                QeetrixSkeleton().frame(height: QeetrixWebScale.spacing(10))  // h-10 w-full
            }
        }
        .padding(QeetrixWebScale.spacing(4))  // p-4
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

/// Which branch a data state shows.
enum QeetrixDataPhase: Hashable {
    case loading, failed, empty, content

    init(isLoading: Bool, isFailed: Bool, isEmpty: Bool) {
        if isLoading {
            self = .loading
        } else if isFailed {
            self = .failed
        } else if isEmpty {
            self = .empty
        } else {
            self = .content
        }
    }
}

/// The failure branch: a small error empty state with the message, and "Try again" when the app can.
struct QeetrixDataFailureView: View {
    let failure: QeetrixDataFailure

    var body: some View {
        let message = failure.message.map { Text(verbatim: $0) } ?? QeetrixStrings.dataStateError
        QeetrixEmptyState(title: nil, description: message, variant: .error, size: .sm) {
            if let retry = failure.retry {
                QeetrixButton(title: QeetrixStrings.retry, leadingIcon: .refreshCw, variant: .outline, size: .sm, action: retry)
            }
        }
        .onAppear {
            // role="alert": the failure is announced, at high priority, when it replaces the content.
            var announcement = AttributedString(failure.message ?? QeetrixStrings.dataStateErrorString)
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}
