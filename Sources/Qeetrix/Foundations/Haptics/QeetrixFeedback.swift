import SwiftUI

#if canImport(UIKit) && os(iOS)
    import UIKit
#endif

/// Qeetrix's feedback roles: what a moment means, played as the platform's haptic for it.
///
/// ```swift
/// Button("Copy invoice number") {
///     UIPasteboard.general.string = invoice.number
///     copies += 1
/// }
/// .qeetrixFeedback(.lightImpact, trigger: copies)
/// ```
///
/// Choose a role by what happened, not by how it should feel, so every Qeetrix app taps the same way
/// for the same moment:
///
/// - ``selection`` — a choice changed: a switch, checkbox or radio, a tab, a picker's value.
///   Qeetrix's switch, checkbox and radio group play it when a person changes them.
/// - ``success`` — a task finished as asked: saved, sent, refreshed.
/// - ``warning`` — a task finished but needs attention: saved offline, a limit nearly reached.
/// - ``error`` — a task failed: a rejected code, a declined payment, a form that can't be sent.
/// - ``lightImpact`` — a small, physical confirmation: a copy; a swipe or a pull crossing the point
///   where letting go acts; a drag snapping into place.
///
/// The system plays nothing when the person has turned System Haptics off (Settings › Sounds &
/// Haptics), or on a device without a Taptic Engine, such as an iPad. Qeetrix adds no setting of its
/// own: never make feedback the only sign that something happened. See <doc:Haptics>.
public enum QeetrixFeedback: String, CaseIterable, Sendable {
    /// A choice changed: the lightest tick.
    case selection
    /// A task finished as asked.
    case success
    /// A task finished but needs attention.
    case warning
    /// A task failed.
    case error
    /// A physical moment with no outcome: a light tap.
    case lightImpact = "light-impact"

    /// The SwiftUI feedback this role plays, for `sensoryFeedback(_:trigger:)` and the APIs that take
    /// one.
    public var sensoryFeedback: SensoryFeedback {
        switch self {
        case .selection: .selection
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .lightImpact: .impact(weight: .light)
        }
    }

    /// Plays the feedback now, for code that runs outside a view's state: a completion handler, a
    /// UIKit delegate. In a view, prefer `.qeetrixFeedback(_:trigger:)`, which plays when a value
    /// changes. Nothing plays on the Mac.
    @MainActor
    public func play() {
        #if canImport(UIKit) && os(iOS)
            switch generator {
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .notification(let kind):
                UINotificationFeedbackGenerator().notificationOccurred(kind.type)
            case .impact(.light):
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        #endif
    }

    /// The UIKit generator ``play()`` uses — the same haptics `sensoryFeedback` plays.
    var generator: QeetrixFeedbackGenerator {
        switch self {
        case .selection: .selection
        case .success: .notification(.success)
        case .warning: .notification(.warning)
        case .error: .notification(.error)
        case .lightImpact: .impact(.light)
        }
    }
}

extension QeetrixFeedback {
    /// A toggle's binding that counts each change made through it towards a feedback trigger: the
    /// binding of a toggle's accessibility element, which VoiceOver, Switch Control and Full Keyboard
    /// Access change, so they get the feedback a tap gets.
    static func counting(_ isOn: Binding<Bool>, in changes: Binding<Int>) -> Binding<Bool> {
        Binding {
            isOn.wrappedValue
        } set: { newValue in
            if newValue != isOn.wrappedValue { changes.wrappedValue += 1 }
            isOn.wrappedValue = newValue
        }
    }
}

/// A UIKit feedback generator and its argument, named apart from UIKit so the mapping is the same on
/// the Mac, where there is no UIKit to play it.
enum QeetrixFeedbackGenerator: Equatable, Sendable {
    /// `UISelectionFeedbackGenerator.selectionChanged()`.
    case selection
    /// `UINotificationFeedbackGenerator.notificationOccurred(_:)`.
    case notification(Notification)
    /// `UIImpactFeedbackGenerator(style:).impactOccurred()`.
    case impact(Impact)

    enum Notification: Equatable, Sendable {
        case success, warning, error

        #if canImport(UIKit) && os(iOS)
            var type: UINotificationFeedbackGenerator.FeedbackType {
                switch self {
                case .success: .success
                case .warning: .warning
                case .error: .error
                }
            }
        #endif
    }

    enum Impact: Equatable, Sendable {
        case light
    }
}

extension View {
    /// Plays a feedback role each time `trigger` changes.
    ///
    /// ```swift
    /// Button("Copy", action: copy)
    ///     .qeetrixFeedback(.lightImpact, trigger: copyCount)
    /// ```
    ///
    /// Built on `sensoryFeedback(_:trigger:)`, so the system decides whether to play: not at all when
    /// System Haptics is off. Change the trigger only for the person's own actions; a value the app sets
    /// itself — loading saved settings, a sync — shouldn't tap.
    public func qeetrixFeedback<Trigger: Equatable>(_ feedback: QeetrixFeedback, trigger: Trigger) -> some View {
        sensoryFeedback(feedback.sensoryFeedback, trigger: trigger)
    }

    /// Plays a feedback role when `trigger` changes and `condition` holds for its old and new values.
    ///
    /// ```swift
    /// List { rows }
    ///     .qeetrixFeedback(.lightImpact, trigger: isPastThreshold) { _, isPast in isPast }
    /// ```
    public func qeetrixFeedback<Trigger: Equatable>(
        _ feedback: QeetrixFeedback, trigger: Trigger, condition: @escaping (_ oldValue: Trigger, _ newValue: Trigger) -> Bool
    ) -> some View {
        sensoryFeedback(feedback.sensoryFeedback, trigger: trigger, condition: condition)
    }

    /// Plays the role `feedback` chooses from `trigger`'s old and new values, or nothing when it
    /// returns `nil` — for an outcome that can go either way.
    ///
    /// ```swift
    /// Form { fields }
    ///     .qeetrixFeedback(trigger: submission) { _, result in
    ///         switch result {
    ///         case .sent: .success
    ///         case .rejected: .error
    ///         case nil: nil
    ///         }
    ///     }
    /// ```
    public func qeetrixFeedback<Trigger: Equatable>(
        trigger: Trigger, _ feedback: @escaping (_ oldValue: Trigger, _ newValue: Trigger) -> QeetrixFeedback?
    ) -> some View {
        sensoryFeedback(trigger: trigger) { oldValue, newValue in feedback(oldValue, newValue)?.sensoryFeedback }
    }
}
