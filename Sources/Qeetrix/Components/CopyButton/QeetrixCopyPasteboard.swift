import SwiftUI

#if canImport(UIKit)
    import UIKit
    import UniformTypeIdentifiers
#endif

/// What a Qeetrix copy puts on the pasteboard: plain text and, for a secret — a one-time code, a key
/// shown once — the two limits that keep it from spreading:
///
/// - **Local only**: it stays on this device and is never offered to the universal clipboard, so Handoff
///   doesn't carry it to the person's Mac or iPad.
/// - **Expiring**: the system removes it ``sensitiveLifetime`` after the copy, if nothing has replaced it.
///
/// The text is never logged or described.
struct QeetrixCopyEntry: Equatable, Sendable {
    let text: String
    let isSensitive: Bool
    /// When the system removes a sensitive entry; `nil` for a plain one, which stays until replaced.
    let expiresAt: Date?

    init(_ text: String, isSensitive: Bool, copiedAt now: Date) {
        self.text = text
        self.isSensitive = isSensitive
        expiresAt = isSensitive ? now.addingTimeInterval(Self.seconds(Self.sensitiveLifetime)) : nil
    }

    /// Kept off the universal clipboard.
    var isLocalOnly: Bool { isSensitive }

    /// How long a sensitive entry stays: 60 seconds. Long enough to switch apps and paste — a person
    /// pastes within seconds — and long enough for a code: a 30-second code's own window plus the one
    /// step of clock drift servers usually accept (RFC 6238 §5.2), and the whole of a 60-second one.
    /// Short enough that a secret isn't still there for whatever is pasted next. `@qeetrix/react` has
    /// no expiry: a browser can't set one.
    static let sensitiveLifetime = Duration.seconds(60)

    static func seconds(_ duration: Duration) -> TimeInterval {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }
}

#if canImport(UIKit)
    extension QeetrixCopyEntry {
        /// The entry as one pasteboard item: UTF-8 plain text.
        var pasteboardItems: [[String: Any]] {
            [[UTType.utf8PlainText.identifier: text]]
        }

        /// `UIPasteboard.setItems(_:options:)`'s options: none for plain text; for a secret, local only and
        /// the expiry.
        var pasteboardOptions: [UIPasteboard.OptionsKey: Any] {
            guard isSensitive, let expiresAt else { return [:] }
            return [.localOnly: true, .expirationDate: expiresAt]
        }
    }
#endif

/// Writes a ``QeetrixCopyEntry`` and says whether it was taken: the system pasteboard in an app, a
/// recorder in tests (through the environment's `qeetrixCopyWriter`).
struct QeetrixCopyWriter: Sendable {
    let write: @MainActor @Sendable (QeetrixCopyEntry) -> Bool

    /// `UIPasteboard.general`. The Mac development host has no UIKit pasteboard, so there every copy
    /// fails — visibly, as on a web page without clipboard access.
    static let system = QeetrixCopyWriter { entry in
        #if canImport(UIKit)
            UIPasteboard.general.setItems(entry.pasteboardItems, options: entry.pasteboardOptions)
            return true
        #else
            return false
        #endif
    }
}

private struct QeetrixCopyWriterKey: EnvironmentKey {
    static let defaultValue = QeetrixCopyWriter.system
}

extension EnvironmentValues {
    /// Where Qeetrix copies go: the system pasteboard, unless a test injects its own writer.
    var qeetrixCopyWriter: QeetrixCopyWriter {
        get { self[QeetrixCopyWriterKey.self] }
        set { self[QeetrixCopyWriterKey.self] = newValue }
    }
}

/// Where a copy stands, as `@qeetrix/react`'s `CopyButtonState`.
enum QeetrixCopyState: String, CaseIterable, Sendable {
    /// Ready to copy.
    case idle
    /// Just copied, until the reset.
    case copied
    /// The value couldn't be read or the pasteboard refused it, until the reset.
    case failed
}

/// One copy control's lifecycle as a value: each tap starts a round, a round finishes as copied or
/// failed, and `resetAfter` later goes back to idle — unless a newer tap has started another round, which
/// replaces it (copy-button.tsx clears its timer on every click).
struct QeetrixCopySession: Equatable {
    /// Bumped by each tap; the task that copies is keyed on it, so a new tap cancels the last one.
    private(set) var round = 0
    private(set) var state = QeetrixCopyState.idle
    /// The last finished round, for the haptic: it changes with every copy, even two that end alike.
    private(set) var outcome: Outcome?

    struct Outcome: Equatable {
        let round: Int
        let state: QeetrixCopyState
    }

    /// A tap: a new round, idle while it copies (copy-button.tsx: `setState("idle")` first).
    mutating func begin() {
        round += 1
        state = .idle
    }

    /// Round `round` finished. Returns `false` for a round a newer tap replaced, which shows nothing.
    mutating func finish(_ round: Int, copied: Bool) -> Bool {
        guard round == self.round else { return false }
        state = copied ? .copied : .failed
        outcome = Outcome(round: round, state: state)
        return true
    }

    /// `resetAfter` has passed since round `round` finished.
    mutating func reset(_ round: Int) {
        guard round == self.round else { return }
        state = .idle
    }
}

/// Qeetrix's copy, for a trigger that isn't a Qeetrix control: a menu item, a swipe action, a keyboard
/// shortcut. ``QeetrixCopyButton``, ``QeetrixCopyField`` and ``QeetrixOTPCode`` follow the same rules.
///
/// ```swift
/// Button("Copy code") { QeetrixCopy.copy(account.code, isSensitive: true, toast: $toast) }
/// ```
public enum QeetrixCopy {
    /// copy-button.tsx `resetAfter`: "Copied" (or the failure) shows for 2000 ms.
    static let resetAfter = Duration.seconds(2)

    /// Copies `text` as Qeetrix's copy controls do:
    ///
    /// - **The clipboard.** A secret (`isSensitive`: a one-time code, a key shown once) stays on this
    ///   device, never on the universal clipboard, and the system removes it after 60 seconds. Plain text
    ///   stays until something replaces it.
    /// - **The haptic.** A light tap when it copied; the error haptic when the clipboard refused it.
    /// - **The confirmation.** With the screen's toast binding, the "Copied" toast — for a secret with
    ///   "Clears from the clipboard after 1 minute" — in Qeetrix's localised strings. Without one,
    ///   VoiceOver announces "Copied". A failure is announced ("Couldn't copy"), never toasted.
    ///
    /// The text is never logged, announced or put in the toast.
    ///
    /// - Parameters:
    ///   - text: What to copy.
    ///   - isSensitive: Keeps a secret local to this device and removes it after 60 seconds.
    ///   - toast: The binding the screen's `qeetrixToast(_:)` hosts, to confirm the copy with a toast.
    ///   - locale: The locale of the toast's expiry line: the screen's, from `@Environment(\.locale)`.
    /// - Returns: Whether the text is on the clipboard.
    @MainActor
    @discardableResult
    public static func copy(
        _ text: String, isSensitive: Bool = false, toast: Binding<QeetrixToast?>? = nil, locale: Locale = .autoupdatingCurrent
    ) -> Bool {
        copy(
            text, isSensitive: isSensitive, toast: toast, locale: locale, writer: .system, now: Date(), feedback: { $0.play() },
            announce: { AccessibilityNotification.Announcement($0).post() })
    }

    /// The public copy with its effects given, for tests.
    @MainActor
    static func copy(
        _ text: String, isSensitive: Bool, toast: Binding<QeetrixToast?>?, locale: Locale, writer: QeetrixCopyWriter, now: Date,
        feedback: (QeetrixFeedback) -> Void, announce: (String) -> Void
    ) -> Bool {
        let copied = writer.write(QeetrixCopyEntry(text, isSensitive: isSensitive, copiedAt: now))
        feedback(copied ? .lightImpact : .error)
        if let announcement = confirm(copied: copied ? text : nil, isSensitive: isSensitive, toast: toast, locale: locale) {
            announce(announcement)
        }
        return copied
    }

    /// Reads the value and writes it. Returns the text that was copied, or `nil` when reading threw or
    /// the writer refused it.
    @MainActor
    static func copy(
        _ value: @MainActor () async throws -> String, isSensitive: Bool, writer: QeetrixCopyWriter, now: () -> Date = { Date() }
    ) async -> String? {
        guard let text = try? await value() else { return nil }
        return writer.write(QeetrixCopyEntry(text, isSensitive: isSensitive, copiedAt: now())) ? text : nil
    }

    /// The haptic for a finished copy: a light tap when it copied, the error when it failed.
    static func feedback(for outcome: QeetrixCopySession.Outcome?) -> QeetrixFeedback? {
        switch outcome?.state {
        case .copied: .lightImpact
        case .failed: .error
        case .idle, nil: nil
        }
    }

    /// Confirms a finished copy: with the screen's toast binding, the "Copied" toast, which announces
    /// itself; without one, "Copied" to announce. A failure is always announced, never toasted: a danger
    /// toast stays until dismissed, and the control already shows it. Returns what to announce.
    @MainActor
    static func confirm(copied text: String?, isSensitive: Bool, toast: Binding<QeetrixToast?>?, locale: Locale) -> String? {
        guard text != nil else { return QeetrixCopyStrings.failed }
        guard let toast else { return QeetrixCopyStrings.copied }
        toast.wrappedValue = Self.toast(isSensitive: isSensitive, locale: locale)
        return nil
    }

    /// The toast that confirms a copy: "Copied", and for a secret when it leaves the clipboard.
    static func toast(isSensitive: Bool, locale: Locale) -> QeetrixToast {
        QeetrixToast(.success, title: QeetrixCopyStrings.copied, description: isSensitive ? QeetrixCopyStrings.expiry(locale: locale) : nil)
    }

    /// The icon a copy button shows: `copy`, a `check` once copied, a `circle-alert` if it failed.
    static func icon(_ state: QeetrixCopyState) -> QeetrixIconName {
        switch state {
        case .idle: .copy
        case .copied: .check
        case .failed: .circleAlert
        }
    }

    /// The icon's colour after a copy, on a ghost button only (copy-button.css
    /// `.qx-copy-button[data-variant="ghost"][data-state]`); `nil` keeps the button's own.
    static func iconTint(_ state: QeetrixCopyState, variant: QeetrixButtonVariant) -> QeetrixColor? {
        guard variant == .ghost else { return nil }
        switch state {
        case .idle: return nil
        case .copied: return .iconSuccess
        case .failed: return .iconDanger
        }
    }

    /// What VoiceOver hears and the tooltip says after a copy: "Copied", "Couldn't copy".
    static func status(_ state: QeetrixCopyState) -> String? {
        switch state {
        case .idle: nil
        case .copied: QeetrixCopyStrings.copied
        case .failed: QeetrixCopyStrings.failed
        }
    }
}

/// Runs the copies of the control it wraps, which draws itself from the state it is handed and calls
/// `copy` when tapped. One per control: its session, the task that copies (cancelled when the control
/// disappears or is tapped again), the haptic, and the confirmation (``QeetrixCopy/confirm(copied:isSensitive:toast:locale:)``).
struct QeetrixCopyControl<Content: View>: View {
    let value: @MainActor () async throws -> String
    let isSensitive: Bool
    let resetAfter: Duration
    let toast: Binding<QeetrixToast?>?
    let onCopied: (@MainActor (String) -> Void)?
    let content: (QeetrixCopyState, @escaping @MainActor () -> Void) -> Content
    @State private var session = QeetrixCopySession()
    @Environment(\.qeetrixCopyWriter) private var writer
    @Environment(\.locale) private var locale

    init(
        value: @escaping @MainActor () async throws -> String, isSensitive: Bool, resetAfter: Duration, toast: Binding<QeetrixToast?>?,
        onCopied: (@MainActor (String) -> Void)?,
        @ViewBuilder content: @escaping (QeetrixCopyState, @escaping @MainActor () -> Void) -> Content
    ) {
        self.value = value
        self.isSensitive = isSensitive
        self.resetAfter = resetAfter
        self.toast = toast
        self.onCopied = onCopied
        self.content = content
    }

    var body: some View {
        content(session.state) { session.begin() }
            .qeetrixFeedback(trigger: session.outcome) { _, outcome in QeetrixCopy.feedback(for: outcome) }
            .task(id: session.round) { await run(session.round) }
    }

    private func run(_ round: Int) async {
        guard round > 0 else { return }
        let text = await QeetrixCopy.copy(value, isSensitive: isSensitive, writer: writer)
        guard !Task.isCancelled, session.finish(round, copied: text != nil) else { return }
        if let announcement = QeetrixCopy.confirm(copied: text, isSensitive: isSensitive, toast: toast, locale: locale) {
            AccessibilityNotification.Announcement(announcement).post()
        }
        if let text { onCopied?(text) }
        try? await Task.sleep(for: resetAfter)
        guard !Task.isCancelled else { return }
        session.reset(round)
    }
}

/// The copy strings, with their English text as the default until a translation has them.
enum QeetrixCopyStrings {
    /// "Copy" — `copyButton.copy`, a copy button's name when it has no label.
    static var copy: Text { Text("qeetrix.copy-button.copy", bundle: .module) }

    /// "Copied" — `copyButton.copied`: the tooltip, the announcement and the toast's title.
    static var copied: String { String(localized: "qeetrix.copy-button.copied", bundle: .module) }

    /// "Couldn't copy" — `copyButton.failed`.
    static var failed: String { String(localized: "qeetrix.copy-button.failed", bundle: .module) }

    /// "Clears from the clipboard after 1 minute": the toast's second line for a secret.
    static func expiry(locale: Locale) -> String {
        let lifetime = QeetrixFormat.duration(QeetrixCopyEntry.sensitiveLifetime, style: .long, locale: locale)
        return String(localized: "qeetrix.copy-button.expiry", defaultValue: "Clears from the clipboard after \(lifetime)", bundle: .module)
    }

    /// "Copy {label}" — `copyField.copy`.
    static func copy(_ label: String) -> String {
        String(localized: "qeetrix.copy-field.copy", defaultValue: "Copy \(label)", bundle: .module)
    }

    /// "Copy {label}" round a label that is a `Text`: the sentence is localised with a stand-in for the
    /// label, then the label takes the stand-in's place, so word order follows the language.
    static func copy(_ label: Text) -> Text {
        let placeholder = "\u{FFFC}"
        let sentence = copy(placeholder)
        guard let range = sentence.range(of: placeholder) else { return Text(verbatim: sentence) }
        let before = Text(verbatim: String(sentence[..<range.lowerBound]))
        let after = Text(verbatim: String(sentence[range.upperBound...]))
        return Text("\(before)\(label)\(after)")
    }
}
