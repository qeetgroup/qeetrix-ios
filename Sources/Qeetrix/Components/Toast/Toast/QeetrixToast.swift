import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// What a ``QeetrixToast`` reports, as `@qeetrix/react`'s `ToastTone`.
public enum QeetrixToastTone: String, CaseIterable, Sendable {
    /// A neutral message, the default.
    case info
    /// Something finished as intended.
    case success
    /// Something finished, with something to look at.
    case warning
    /// Something failed. It stays until dismissed and is announced with high priority. A failure the
    /// person must resolve belongs next to what failed, not in a toast.
    case danger
}

/// Brief, non-blocking feedback about an outcome — "Saved", "Link copied" — `@qeetrix/react`'s toast.
///
/// ```swift
/// @State private var toast: QeetrixToast?
///
/// SettingsForm()
///     .qeetrixToast($toast)
///
/// toast = .success("Settings saved")
/// toast = QeetrixToast(.info, title: "Message archived", action: .init("Undo") { unarchive() })
/// toast = QeetrixToast(.danger, title: "Couldn't send the invoice", description: "Check the address and try again.")
/// ```
///
/// A toast never blocks: the screen stays usable underneath, and it leaves by itself. For something the
/// person must decide, use a ``QeetrixAlertDialog``. The title and description are plain strings,
/// already localised, because they are also announced. Never put secrets — passwords, codes, tokens — in
/// a toast.
public struct QeetrixToast: Identifiable {
    /// A button in a toast — "Undo", "Retry", "View".
    public struct Action {
        public let title: String
        let perform: @MainActor () -> Void

        /// - Parameters:
        ///   - title: The button's title, already localised.
        ///   - action: Runs once when the button is tapped; the toast is dismissed first.
        public init(_ title: String, action: @escaping @MainActor () -> Void) {
            self.title = title
            perform = action
        }
    }

    public let id = UUID()
    public let tone: QeetrixToastTone
    public let title: String
    public let description: String?
    public let action: Action?
    /// How long the toast stays: `nil` for the default, 5 s, or `.zero` to stay until dismissed. A
    /// `danger` toast stays until dismissed whatever its duration.
    public let duration: Duration?

    /// - Parameters:
    ///   - tone: What it reports.
    ///   - title: The message, already localised.
    ///   - description: A second line, already localised.
    ///   - action: An optional button.
    ///   - duration: `nil` for the default, 5 s, or `.zero` to stay until dismissed. A `danger` toast
    ///     stays until dismissed whatever its duration.
    public init(_ tone: QeetrixToastTone, title: String, description: String? = nil, action: Action? = nil, duration: Duration? = nil) {
        self.tone = tone
        self.title = title
        self.description = description
        self.action = action
        self.duration = duration
    }

    /// An info toast, localised from the main bundle.
    public static func info(_ title: LocalizedStringResource) -> QeetrixToast {
        QeetrixToast(.info, title: String(localized: title))
    }

    /// A success toast, localised from the main bundle.
    public static func success(_ title: LocalizedStringResource) -> QeetrixToast {
        QeetrixToast(.success, title: String(localized: title))
    }

    /// A warning toast, localised from the main bundle.
    public static func warning(_ title: LocalizedStringResource) -> QeetrixToast {
        QeetrixToast(.warning, title: String(localized: title))
    }

    /// An error toast, localised from the main bundle.
    public static func danger(_ title: LocalizedStringResource) -> QeetrixToast {
        QeetrixToast(.danger, title: String(localized: title))
    }
}

extension View {
    /// Shows `toast` over this view while it is not `nil`, and sets it back to `nil` when it leaves.
    ///
    /// Put it on the view whose area the feedback is about — usually a screen's root. There is no global
    /// toast service: each modifier hosts its own, so two windows each show their own toasts.
    ///
    /// - **One at a time.** Setting a new toast replaces the one on screen at once; nothing queues. A
    ///   repeat of the toast on screen — the same type, title and description — keeps it and restarts its
    ///   timer, without announcing it again.
    /// - **Timing.** 5 s, as on the web; a `danger` toast stays until it is dismissed. While VoiceOver is
    ///   running a toast with an action stays until it is used or closed. A toast whose time runs out
    ///   while VoiceOver's focus or a pointer is on it leaves when they move off.
    /// - **Leaving.** The Close button, the action, the timer or setting `toast` to `nil`. The timer stops
    ///   when this view disappears.
    /// - **Placement.** At the bottom, 16 pt from the edges, above the safe area: the full width on iPhone
    ///   and 360 pt at the trailing edge on iPad. Only the toast itself takes touches.
    /// - **Announcement.** VoiceOver announces each new toast once — `danger` ones with high priority.
    public func qeetrixToast(_ toast: Binding<QeetrixToast?>) -> some View {
        modifier(QeetrixToastHost(toast: toast))
    }
}

/// The lifecycle rules, apart from the view, so they can be tested.
enum QeetrixToastPolicy {
    /// `ToastProvider`'s `timeout`, 5000 ms.
    static let standardDuration = Duration.seconds(5)

    /// How long `toast` stays before leaving by itself; `nil` when it stays until dismissed.
    static func duration(for toast: QeetrixToast, voiceOverRunning: Bool) -> Duration? {
        // A danger toast stays until dismissed, whatever its duration (toast.tsx: `timeout = 0`).
        if toast.tone == .danger { return nil }
        if let duration = toast.duration {
            return duration == .zero ? nil : duration
        }
        if toast.action != nil && voiceOverRunning { return nil }
        return standardDuration
    }

    /// Whether `new` is a repeat of `current`: then it is not announced again, only re-timed.
    static func isRepeat(_ new: QeetrixToast, of current: QeetrixToast?) -> Bool {
        guard let current else { return false }
        return new.tone == current.tone && new.title == current.title && new.description == current.description
            && (new.action == nil) == (current.action == nil)
    }

    /// The announcement for `toast`: its title and description, high priority for an error.
    static func announcement(for toast: QeetrixToast) -> AttributedString {
        var text = AttributedString([toast.title, toast.description].compactMap { $0 }.joined(separator: ". "))
        text.accessibilitySpeechAnnouncementPriority = toast.tone == .danger ? .high : .default
        return text
    }
}

/// Which part of the toast VoiceOver's focus is on.
enum QeetrixToastFocus: Hashable {
    case message, action, close
}

/// The host's lifecycle as a value: which toast is on screen, its timer round, and whether it is overdue.
/// The view feeds it events and does what it answers, so the rules are tested without a view.
struct QeetrixToastState {
    /// The toast on screen. A repeat leaves it in place while the binding moves on to the repeat.
    private(set) var shown: QeetrixToast?
    /// Bumped by a repeat, which restarts the timer.
    private(set) var round = 0
    /// The timer ran out while the toast was held; it leaves when released.
    private(set) var isOverdue = false

    /// The binding changed to `new`. Returns the toast to announce — a new one, not a repeat.
    mutating func present(_ new: QeetrixToast?) -> QeetrixToast? {
        isOverdue = false
        guard let new else {
            shown = nil
            return nil
        }
        if QeetrixToastPolicy.isRepeat(new, of: shown) {
            round += 1
            return nil
        }
        shown = new
        return new
    }

    /// Removes toast `id` if it is the one on screen. Returns whether it was.
    mutating func dismiss(_ id: UUID) -> Bool {
        guard shown?.id == id else { return false }
        shown = nil
        isOverdue = false
        return true
    }

    /// The timer of toast `id` ran out. A held toast waits for release. Returns whether it left.
    mutating func expire(_ id: UUID, isHeld: Bool) -> Bool {
        guard shown?.id == id else { return false }
        guard !isHeld else {
            isOverdue = true
            return false
        }
        return dismiss(id)
    }

    /// Nothing holds the toast any more. Returns whether an overdue toast left.
    mutating func release() -> Bool {
        guard isOverdue, let id = shown?.id else { return false }
        return dismiss(id)
    }

    /// Dismisses toast `id` and hands over its action — once: a second tap while it leaves finds it gone.
    mutating func takeAction(_ id: UUID) -> QeetrixToast.Action? {
        guard shown?.id == id, let action = shown?.action else { return nil }
        _ = dismiss(id)
        return action
    }
}

struct QeetrixToastHost: ViewModifier {
    @Binding var toast: QeetrixToast?
    @State private var state = QeetrixToastState()
    @State private var isHovered = false
    @AccessibilityFocusState private var focus: QeetrixToastFocus?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// VoiceOver's focus or a pointer is on the toast.
    private var isHeld: Bool { focus != nil || isHovered }

    func body(content: Content) -> some View {
        let isCompact = horizontalSizeClass != .regular
        content
            .overlay(alignment: isCompact ? .bottom : .bottomTrailing) {
                if let shown = state.shown {
                    QeetrixToastView(toast: shown, focus: $focus, close: { dismiss(shown.id) }, act: { act(on: shown.id) })
                        .frame(maxWidth: isCompact ? .infinity : QeetrixToastMetrics.maximumWidth)
                        .onHover { isHovered = $0 }
                        .padding(QeetrixSpace.insetLg)
                        .transition(reduceMotion ? .opacity : .offset(y: 4).combined(with: .opacity))
                        .id(shown.id)
                }
            }
            // toast.css: in over `normal` with `enter`, a fade and a 4 pt rise.
            .animation(QeetrixMotion.animation(.enter, .normal, reduceMotion: reduceMotion), value: state.shown?.id)
            .onAppear { present(toast) }
            .onChange(of: toast?.id) { present(toast) }
            .onChange(of: isHeld) { _, held in
                if !held && state.release() { left() }
            }
            .task(id: TimerKey(id: state.shown?.id, round: state.round)) {
                guard let current = state.shown,
                    let duration = QeetrixToastPolicy.duration(for: current, voiceOverRunning: Self.isVoiceOverRunning)
                else { return }
                try? await Task.sleep(for: duration)
                guard !Task.isCancelled else { return }
                if state.expire(current.id, isHeld: isHeld) { left() }
            }
    }

    private struct TimerKey: Hashable {
        let id: UUID?
        let round: Int
    }

    private func present(_ new: QeetrixToast?) {
        if let announced = state.present(new) {
            AccessibilityNotification.Announcement(QeetrixToastPolicy.announcement(for: announced)).post()
        }
    }

    private func dismiss(_ id: UUID) {
        if state.dismiss(id) { left() }
    }

    private func act(on id: UUID) {
        guard let action = state.takeAction(id) else { return }
        left()
        action.perform()
    }

    /// The toast left: clear the binding, and the hover that went with it.
    private func left() {
        isHovered = false
        toast = nil
    }

    static var isVoiceOverRunning: Bool {
        #if canImport(UIKit)
            UIAccessibility.isVoiceOverRunning
        #else
            false
        #endif
    }
}

/// The toast (toast.css): the overlay surface, 4 pt corners and `shadow.overlay`, a 3 pt status edge on
/// the start side, the sharp 16 pt status icon, the title (`title.sm`) and description (`body.sm`,
/// `color.text.subtle`), then the action — a ghost `sm` button — and Close, a neutral `sm` icon button.
struct QeetrixToastView: View {
    let toast: QeetrixToast
    let focus: AccessibilityFocusState<QeetrixToastFocus?>.Binding
    let close: @MainActor () -> Void
    let act: @MainActor () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.overlay)
        HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
            QeetrixIcon(QeetrixToastMetrics.icon(toast.tone), size: .sm, shape: .sharp)
                .foregroundStyle(QeetrixToastMetrics.accent(toast.tone))
                .padding(.top, 4)  // centred on the 24 pt title line
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: toast.title)
                    .qeetrixTextStyle(.titleSm)
                    .foregroundStyle(QeetrixColor.textDefault)
                if let description = toast.description {
                    Text(verbatim: description)
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityFocused(focus, equals: .message)
            if let action = toast.action {
                QeetrixButton(action.title, variant: .ghost, size: .sm, action: act)
                    .padding(.vertical, -2)
                    .accessibilityFocused(focus, equals: .action)
            }
            QeetrixIconButton(.x, label: QeetrixStrings.dismiss, tone: .neutral, size: .sm, action: close)
                .accessibilityFocused(focus, equals: .close)
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .overlay(alignment: .leading) {
            Rectangle().fill(QeetrixToastMetrics.accent(toast.tone)).frame(width: QeetrixBorderWidth.accent).accessibilityHidden(true)
        }
        .clipShape(shape)
        .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: shape)
        .accessibilityElement(children: .contain)
    }
}

enum QeetrixToastMetrics {
    /// The viewport's width: `min(360px, 100vw - 32px)`.
    static let maximumWidth: CGFloat = 360

    /// Each tone's own icon, so status is never colour alone.
    static func icon(_ tone: QeetrixToastTone) -> QeetrixIconName {
        switch tone {
        case .info: .info
        case .success: .circleCheck
        case .warning: .triangleAlert
        case .danger: .circleAlert
        }
    }

    /// The status edge and the icon: `color.icon.info`, `-success`, `-warning`, `-danger`.
    static func accent(_ tone: QeetrixToastTone) -> QeetrixColor {
        switch tone {
        case .info: .iconInfo
        case .success: .iconSuccess
        case .warning: .iconWarning
        case .danger: .iconDanger
        }
    }
}
