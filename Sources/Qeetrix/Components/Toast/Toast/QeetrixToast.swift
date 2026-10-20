import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// What a ``QeetrixToast`` reports, as the web toast's types.
public enum QeetrixToastType: String, CaseIterable, Sendable {
    /// A neutral message.
    case info
    /// Something finished as intended.
    case success
    /// Something finished, with something to look at.
    case warning
    /// Something failed. Announced with high priority. A failure the person must resolve belongs next to
    /// what failed, not in a toast.
    case error
}

/// Brief, non-blocking feedback about an outcome — "Saved", "Link copied" — the web's `Toast`.
///
/// ```swift
/// @State private var toast: QeetrixToast?
///
/// SettingsForm()
///     .qeetrixToast($toast)
///
/// toast = .success("Settings saved")
/// toast = QeetrixToast(.info, title: "Message archived", action: .init("Undo") { unarchive() })
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
    public let type: QeetrixToastType
    public let title: String
    public let description: String?
    public let action: Action?
    /// How long the toast stays: `nil` for the default of its type, `.zero` to stay until dismissed.
    public let duration: Duration?

    /// - Parameters:
    ///   - type: What it reports.
    ///   - title: The message, already localised.
    ///   - description: A second line, already localised.
    ///   - action: An optional button.
    ///   - duration: `nil` for the default — 5 s, or 10 s for warnings, errors and toasts with an action —
    ///     or `.zero` to stay until dismissed.
    public init(_ type: QeetrixToastType, title: String, description: String? = nil, action: Action? = nil, duration: Duration? = nil) {
        self.type = type
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
    public static func error(_ title: LocalizedStringResource) -> QeetrixToast {
        QeetrixToast(.error, title: String(localized: title))
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
    /// - **Timing.** 5 s, or 10 s for warnings, errors and toasts with an action, as on the web. While
    ///   VoiceOver is running a toast with an action stays until it is used or closed. A toast whose time
    ///   runs out while VoiceOver's focus or a pointer is on it leaves when they move off.
    /// - **Leaving.** The Close button, the action, the timer or setting `toast` to `nil`. The timer stops
    ///   when this view disappears.
    /// - **Placement.** At the bottom, above the safe area, the full width on iPhone and 384 pt at the
    ///   trailing edge on iPad. Only the toast itself takes touches.
    /// - **Announcement.** VoiceOver announces each new toast once — errors with high priority.
    public func qeetrixToast(_ toast: Binding<QeetrixToast?>) -> some View {
        modifier(QeetrixToastHost(toast: toast))
    }
}

/// The lifecycle rules, apart from the view, so they can be tested.
enum QeetrixToastPolicy {
    /// The web's `TOAST_EXTENDED_TIMEOUT` and default timeout.
    static let standardDuration = Duration.seconds(5)
    static let extendedDuration = Duration.seconds(10)

    /// How long `toast` stays before leaving by itself; `nil` when it stays until dismissed.
    static func duration(for toast: QeetrixToast, voiceOverRunning: Bool) -> Duration? {
        if let duration = toast.duration {
            return duration == .zero ? nil : duration
        }
        if toast.action != nil && voiceOverRunning { return nil }
        let needsTime = toast.type == .error || toast.type == .warning || toast.action != nil
        return needsTime ? extendedDuration : standardDuration
    }

    /// Whether `new` is a repeat of `current`: then it is not announced again, only re-timed.
    static func isRepeat(_ new: QeetrixToast, of current: QeetrixToast?) -> Bool {
        guard let current else { return false }
        return new.type == current.type && new.title == current.title && new.description == current.description
            && (new.action == nil) == (current.action == nil)
    }

    /// The announcement for `toast`: its title and description, high priority for an error.
    static func announcement(for toast: QeetrixToast) -> AttributedString {
        var text = AttributedString([toast.title, toast.description].compactMap { $0 }.joined(separator: ". "))
        text.accessibilitySpeechAnnouncementPriority = toast.type == .error ? .high : .default
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
                        .padding(QeetrixWebScale.spacing(4))  // bottom-4 end-4
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                        .id(shown.id)
                }
            }
            .animation(QeetrixMotion.animation(.enter, .slow, reduceMotion: reduceMotion), value: state.shown?.id)
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

/// The toast: the status icon, the title and description, the optional action, and Close — on the
/// overlay surface with the status accent on the inline-start edge.
struct QeetrixToastView: View {
    let toast: QeetrixToast
    let focus: AccessibilityFocusState<QeetrixToastFocus?>.Binding
    let close: @MainActor () -> Void
    let act: @MainActor () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCorner.overlay)  // rounded-(--qx-corner-overlay)
        HStack(alignment: .top, spacing: QeetrixWebScale.spacing(3)) {  // gap-3
            QeetrixIcon(
                QeetrixToastMetrics.icon(toast.type), size: QeetrixIconSize(QeetrixWebScale.spacing(4)),
                variant: toast.type == .info ? .outline : .filled
            )
            .foregroundStyle(QeetrixToastMetrics.iconColor(toast.type))
            .padding(.top, QeetrixWebScale.spacing(0.5))  // mt-0.5
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // gap-0.5
                VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {
                    Text(verbatim: toast.title)
                        .qeetrixType(QeetrixToastMetrics.titleType)
                        .foregroundStyle(QeetrixToastMetrics.titleColor(toast.type))
                    if let description = toast.description {
                        Text(verbatim: description)
                            .qeetrixType(QeetrixSheetMetrics.bodyType)
                            .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityFocused(focus, equals: .message)
                if let action = toast.action {
                    Button(action: act) { Text(verbatim: action.title) }
                        .buttonStyle(QeetrixToastActionStyle())
                        .padding(.top, QeetrixWebScale.spacing(2))  // mt-2
                        .accessibilityFocused(focus, equals: .action)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, QeetrixWebScale.spacing(3))  // py-3
        .padding(.leading, QeetrixWebScale.spacing(3.5))  // ps-3.5
        .padding(.trailing, QeetrixWebScale.spacing(10))  // pe-10, the close button's lane
        .overlay(alignment: .topTrailing) {
            QeetrixIconButton(.x, label: QeetrixStrings.close, variant: .ghost, size: .sm, action: close)
                .padding(QeetrixWebScale.spacing(2))  // inset-e-2 top-2
                .accessibilityFocused(focus, equals: .close)
        }
        .overlay(alignment: .leading) {
            if let accent = QeetrixToastMetrics.accent(toast.type) {
                Rectangle().fill(accent).frame(width: QeetrixToastMetrics.accentWidth)  // border-s-[3px]
            }
        }
        .clipShape(shape)
        .qeetrixElevation(.overlay, fill: .surfaceOverlay, in: shape)  // bg-popover shadow-popover
        .overlay { shape.strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixStroke.hairline) }  // border border-border
        .accessibilityElement(children: .contain)
    }
}

/// `inline-flex h-7 px-2.5 rounded-md border bg-transparent text-xs font-medium`, the toast's action.
struct QeetrixToastActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixToastActionBody(configuration: configuration)
    }
}

private struct QeetrixToastActionBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCorner.chip)  // rounded-md
        configuration.label
            .qeetrixType(QeetrixComponentType.ui(QeetrixWebScale.textXS, .medium, scalesLike: .caption))
            .foregroundStyle(QeetrixColor.textPrimary)
            .padding(.horizontal, QeetrixWebScale.spacing(2.5))
            .frame(minHeight: QeetrixWebScale.spacing(7))  // h-7
            .background {
                if configuration.isPressed || isHovered { shape.fill(QeetrixColor.surfaceInteractive) }  // hover:bg-surface-interactive
            }
            .overlay {
                shape.strokeBorder(
                    colorScheme == .dark ? QeetrixColor.borderStrong : QeetrixColor.borderDefault, lineWidth: QeetrixStroke.hairline)
            }
            .contentShape(shape)
            .qeetrixHitArea()
            .onHover { isHovered = $0 }
    }
}

enum QeetrixToastMetrics {
    /// `max-w-sm`.
    static let maximumWidth = QeetrixWebScale.containerSM
    static let accentWidth: CGFloat = 3
    /// `font-heading text-sm font-medium`.
    static let titleType = QeetrixComponentType.heading(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)

    static func icon(_ type: QeetrixToastType) -> QeetrixIconName {
        switch type {
        case .info: .info
        case .success: .circleCheck
        case .warning: .triangleAlert
        case .error: .circleX
        }
    }

    static func iconColor(_ type: QeetrixToastType) -> QeetrixColor {
        switch type {
        case .info: .textInfo
        case .success: .textSuccess
        case .warning: .textWarning
        case .error: .textDanger
        }
    }

    static func titleColor(_ type: QeetrixToastType) -> QeetrixColor {
        type == .info ? .textPrimary : iconColor(type)
    }

    /// `border-s-success`, `-warning`, `-destructive`: the bridge's feedback colours. Info has none.
    static func accent(_ type: QeetrixToastType) -> QeetrixColor? {
        switch type {
        case .info: nil
        case .success: .feedbackSuccess
        case .warning: .feedbackWarning
        case .error: .feedbackError
        }
    }
}
