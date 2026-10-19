import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Toast")
struct ToastTests {
    @Test("Durations follow the web: 5 s, 10 s for warnings, errors and actions")
    func durations() {
        let action = QeetrixToast.Action("Undo") {}
        func duration(_ toast: QeetrixToast, voiceOver: Bool = false) -> Duration? {
            QeetrixToastPolicy.duration(for: toast, voiceOverRunning: voiceOver)
        }
        #expect(duration(QeetrixToast(.info, title: "Archived")) == .seconds(5))
        #expect(duration(QeetrixToast(.success, title: "Saved")) == .seconds(5))
        #expect(duration(QeetrixToast(.warning, title: "Saved offline")) == .seconds(10))
        #expect(duration(QeetrixToast(.error, title: "Not saved")) == .seconds(10))
        #expect(duration(QeetrixToast(.info, title: "Archived", action: action)) == .seconds(10))
        #expect(duration(QeetrixToast(.success, title: "Saved", duration: .seconds(3))) == .seconds(3))
        #expect(duration(QeetrixToast(.success, title: "Saved", duration: .zero)) == nil, "Zero stays until dismissed")
    }

    @Test("With VoiceOver running, a toast with an action stays until used or closed")
    func voiceOverKeepsActions() {
        let undo = QeetrixToast(.info, title: "Archived", action: .init("Undo") {})
        #expect(QeetrixToastPolicy.duration(for: undo, voiceOverRunning: true) == nil)
        #expect(QeetrixToastPolicy.duration(for: QeetrixToast(.info, title: "Archived"), voiceOverRunning: true) == .seconds(5))
    }

    @Test("A repeat is the same type, title, description and presence of an action")
    func repeats() {
        let saved = QeetrixToast(.success, title: "Saved")
        #expect(QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(saved, of: nil))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.info, title: "Saved"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved", description: "2 files"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved", action: .init("View") {}), of: saved))
    }

    @Test("The announcement reads the title and description; errors are high priority")
    func announcement() {
        let error = QeetrixToastPolicy.announcement(for: QeetrixToast(.error, title: "Not saved", description: "Try again."))
        #expect(String(error.characters) == "Not saved. Try again.")
        #expect(error.accessibilitySpeechAnnouncementPriority == .high)
        let success = QeetrixToastPolicy.announcement(for: QeetrixToast(.success, title: "Saved"))
        #expect(String(success.characters) == "Saved")
        #expect(success.accessibilitySpeechAnnouncementPriority == .default)
    }

    @Test("A new toast replaces the one on screen and is announced; nothing queues")
    func replaces() {
        var state = QeetrixToastState()
        let first = QeetrixToast(.success, title: "Saved")
        let second = QeetrixToast(.error, title: "Not sent")
        let announcedFirst = state.present(first)
        let announcedSecond = state.present(second)
        #expect(announcedFirst?.id == first.id)
        #expect(announcedSecond?.id == second.id)
        #expect(state.shown?.id == second.id)
        let dismissedReplaced = state.dismiss(first.id)
        #expect(!dismissedReplaced, "The replaced toast is gone; dismissing it does nothing")
        #expect(state.shown?.id == second.id)
    }

    @Test("A repeat keeps the toast, restarts its timer and is not announced again")
    func coalesces() {
        var state = QeetrixToastState()
        let first = QeetrixToast(.success, title: "Copied")
        _ = state.present(first)
        let announced = state.present(QeetrixToast(.success, title: "Copied"))
        #expect(announced == nil)
        #expect(state.shown?.id == first.id)
        #expect(state.round == 1)
    }

    @Test("The timer dismisses; a stale timer does nothing")
    func expires() {
        var state = QeetrixToastState()
        let first = QeetrixToast(.info, title: "Archived")
        let second = QeetrixToast(.info, title: "Restored")
        _ = state.present(first)
        _ = state.present(second)
        let staleLeft = state.expire(first.id, isHeld: false)
        #expect(!staleLeft, "The first toast's timer outlived it")
        #expect(state.shown?.id == second.id)
        let left = state.expire(second.id, isHeld: false)
        #expect(left)
        #expect(state.shown == nil)
    }

    @Test("A held toast outlives its timer and leaves when released")
    func holds() {
        var state = QeetrixToastState()
        let toast = QeetrixToast(.info, title: "Archived")
        _ = state.present(toast)
        let earlyRelease = state.release()
        #expect(!earlyRelease, "Releasing before the timer runs out keeps it")
        let leftWhileHeld = state.expire(toast.id, isHeld: true)
        #expect(!leftWhileHeld)
        #expect(state.isOverdue)
        #expect(state.shown?.id == toast.id)
        let leftOnRelease = state.release()
        #expect(leftOnRelease)
        #expect(state.shown == nil)
        #expect(!state.isOverdue)
    }

    @Test("The action is taken once and dismisses the toast")
    func actsOnce() {
        var state = QeetrixToastState()
        var runs = 0
        let toast = QeetrixToast(.info, title: "Archived", action: .init("Undo") { runs += 1 })
        _ = state.present(toast)
        state.takeAction(toast.id)?.perform()
        state.takeAction(toast.id)?.perform()
        #expect(runs == 1)
        #expect(state.shown == nil)
        let plain = QeetrixToast(.info, title: "No action")
        _ = state.present(plain)
        let none = state.takeAction(plain.id)
        #expect(none == nil)
        #expect(state.shown?.id == plain.id, "A toast without an action is not dismissed by asking for one")
    }

    @Test("Setting nil clears it")
    func clears() {
        var state = QeetrixToastState()
        _ = state.present(QeetrixToast(.warning, title: "Saved offline"))
        let announced = state.present(nil)
        #expect(announced == nil)
        #expect(state.shown == nil)
    }

    @Test("Status icons, colours and accents per type")
    func metrics() {
        #expect(QeetrixToastMetrics.icon(.info) == .info)
        #expect(QeetrixToastMetrics.icon(.success) == .circleCheck)
        #expect(QeetrixToastMetrics.icon(.warning) == .triangleAlert)
        #expect(QeetrixToastMetrics.icon(.error) == .circleX)
        #expect(QeetrixToastMetrics.accent(.info) == nil)
        #expect(QeetrixToastMetrics.accent(.error) == .feedbackError)
        #expect(QeetrixToastMetrics.titleColor(.info) == .textPrimary)
        #expect(QeetrixToastMetrics.titleColor(.success) == .textSuccess)
        #expect(QeetrixToastMetrics.maximumWidth == 384)
        #expect(QeetrixToastMetrics.titleType.tokens.size == 14)
    }

    @Test("Every type renders, light and dark, with and without an action")
    func renders() {
        @AccessibilityFocusState var focus: QeetrixToastFocus?
        for type in QeetrixToastType.allCases {
            for scheme in [ColorScheme.light, .dark] {
                let toast = QeetrixToast(type, title: "Title", description: "Description", action: .init("Undo") {})
                let view = QeetrixToastView(toast: toast, focus: $focus, close: {}, act: {})
                    .frame(width: 358).environment(\.colorScheme, scheme)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
    }

    @Test("The info, success, warning and error shortcuts")
    func shortcuts() {
        #expect(QeetrixToast.info("Archived").type == .info)
        #expect(QeetrixToast.success("Saved").title == "Saved")
        #expect(QeetrixToast.warning("Saved offline").type == .warning)
        #expect(QeetrixToast.error("Not saved").type == .error)
        #expect(QeetrixToast.success("Saved").id != QeetrixToast.success("Saved").id)
    }
}
