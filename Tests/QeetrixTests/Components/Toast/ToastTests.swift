import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Toast")
struct ToastTests {
    @Test("Durations follow ToastProvider: 5 s; a danger toast stays until dismissed")
    func durations() {
        let action = QeetrixToast.Action("Undo") {}
        func duration(_ toast: QeetrixToast, voiceOver: Bool = false) -> Duration? {
            QeetrixToastPolicy.duration(for: toast, voiceOverRunning: voiceOver)
        }
        #expect(QeetrixToastTone.allCases.map(\.rawValue) == ["info", "success", "warning", "danger"])
        #expect(duration(QeetrixToast(.info, title: "Archived")) == .seconds(5))
        #expect(duration(QeetrixToast(.success, title: "Saved")) == .seconds(5))
        #expect(duration(QeetrixToast(.warning, title: "Saved offline")) == .seconds(5))
        #expect(duration(QeetrixToast(.info, title: "Archived", action: action)) == .seconds(5))
        #expect(duration(QeetrixToast(.danger, title: "Not saved")) == nil)
        #expect(duration(QeetrixToast(.danger, title: "Not saved", duration: .seconds(3))) == nil, "Danger ignores a duration")
        #expect(duration(QeetrixToast(.success, title: "Saved", duration: .seconds(3))) == .seconds(3))
        #expect(duration(QeetrixToast(.success, title: "Saved", duration: .zero)) == nil, "Zero stays until dismissed")
    }

    @Test("With VoiceOver running, a toast with an action stays until used or closed")
    func voiceOverKeepsActions() {
        let undo = QeetrixToast(.info, title: "Archived", action: .init("Undo") {})
        #expect(QeetrixToastPolicy.duration(for: undo, voiceOverRunning: true) == nil)
        #expect(QeetrixToastPolicy.duration(for: QeetrixToast(.info, title: "Archived"), voiceOverRunning: true) == .seconds(5))
    }

    @Test("A repeat is the same tone, title, description and presence of an action")
    func repeats() {
        let saved = QeetrixToast(.success, title: "Saved")
        #expect(QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(saved, of: nil))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.info, title: "Saved"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved", description: "2 files"), of: saved))
        #expect(!QeetrixToastPolicy.isRepeat(QeetrixToast(.success, title: "Saved", action: .init("View") {}), of: saved))
    }

    @Test("The announcement reads the title and description; danger is high priority")
    func announcement() {
        let error = QeetrixToastPolicy.announcement(for: QeetrixToast(.danger, title: "Not saved", description: "Try again."))
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
        let second = QeetrixToast(.danger, title: "Not sent")
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

    @Test("toast.css: each tone's own sharp icon, its status edge, a 360 pt viewport")
    func metrics() {
        #expect(QeetrixToastTone.allCases.map(QeetrixToastMetrics.icon) == [.info, .circleCheck, .triangleAlert, .circleAlert])
        #expect(QeetrixToastTone.allCases.map(QeetrixToastMetrics.accent) == [.iconInfo, .iconSuccess, .iconWarning, .iconDanger])
        #expect(QeetrixToastMetrics.maximumWidth == 360)
    }

    @Test("Every tone renders, light and dark, with and without an action")
    func renders() {
        @AccessibilityFocusState var focus: QeetrixToastFocus?
        for tone in QeetrixToastTone.allCases {
            for scheme in [ColorScheme.light, .dark] {
                let toast = QeetrixToast(tone, title: "Title", description: "Description", action: .init("Undo") {})
                let view = QeetrixToastView(toast: toast, focus: $focus, close: {}, act: {})
                    .frame(width: 358).environment(\.colorScheme, scheme)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
    }

    @Test("A toast is the overlay surface with the tone's 3 pt edge on its start side")
    func drawn() throws {
        @AccessibilityFocusState var focus: QeetrixToastFocus?
        let view = QeetrixToastView(toast: QeetrixToast(.danger, title: "Not saved"), focus: $focus, close: {}, act: {})
            .frame(width: 300).padding(20).background(Color.white).environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let middle = image.height / 2
        #expect(close(QeetrixTheme.light.resolve(.iconDanger).bytes, image.pixel(21, middle)))
        #expect(close(QeetrixTheme.light.resolve(.surfaceOverlay).bytes, image.pixel(150, 22)))
    }

    @Test("The info, success, warning and danger shortcuts")
    func shortcuts() {
        #expect(QeetrixToast.info("Archived").tone == .info)
        #expect(QeetrixToast.success("Saved").title == "Saved")
        #expect(QeetrixToast.warning("Saved offline").tone == .warning)
        #expect(QeetrixToast.danger("Not saved").tone == .danger)
        #expect(QeetrixToast.success("Saved").id != QeetrixToast.success("Saved").id)
    }
}
