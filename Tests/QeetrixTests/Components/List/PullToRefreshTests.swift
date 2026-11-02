import SwiftUI
import Testing

@testable import Qeetrix

#if os(iOS)
    import UIKit
#endif

@MainActor
@Suite("Pull to refresh")
struct PullToRefreshTests {
    @Test("Updated: \"Updated\" or the app's words, politely, with the success haptic")
    func updated() throws {
        #expect(QeetrixRefreshResult.updated.announcement == "Updated")
        #expect(QeetrixRefreshResult.updated.feedback == .success)
        let words = QeetrixRefreshResult.updated("2 new requests")
        #expect(words.announcement == "2 new requests")
        #expect(words.feedback == .success)
        for result in [QeetrixRefreshResult.updated, words] {
            let spoken = try #require(result.spokenAnnouncement)
            // Queued after what VoiceOver is saying: the web's role="status".
            #expect(spoken.accessibilitySpeechAnnouncementPriority == .low)
        }
    }

    @Test("Failed: nothing said when the app shows the failure, or its words at once; the error haptic")
    func failed() throws {
        #expect(QeetrixRefreshResult.failed.announcement == nil)
        #expect(QeetrixRefreshResult.failed.spokenAnnouncement == nil)
        #expect(QeetrixRefreshResult.failed.feedback == .error)
        let words = QeetrixRefreshResult.failed("Couldn't refresh your approvals")
        #expect(words.feedback == .error)
        let spoken = try #require(words.spokenAnnouncement)
        #expect(String(spoken.characters) == "Couldn't refresh your approvals")
        #expect(spoken.accessibilitySpeechAnnouncementPriority == .high)
        #expect(QeetrixRefreshResult.updated("").spokenAnnouncement == nil, "An empty announcement isn't posted")
    }

    @Test("The result comes once the refresh has returned, and not at all if it was cancelled")
    func finishes() async {
        final class Log {
            var events: [String] = []
        }
        let log = Log()
        await QeetrixRefreshableModifier.refresh({
            log.events.append("refreshed")
            return .updated("Fresh")
        }) { log.events.append("finished: \($0.announcement ?? "")") }
        #expect(log.events == ["refreshed", "finished: Fresh"])

        // Cancelled while it runs — the screen went away — in a task of its own, not the test's.
        let cancelled = Log()
        let refresh = Task { @MainActor in
            await QeetrixRefreshableModifier.refresh({
                withUnsafeCurrentTask { $0?.cancel() }
                cancelled.events.append("refreshed")
                return .updated
            }) { _ in cancelled.events.append("finished") }
        }
        await refresh.value
        #expect(cancelled.events == ["refreshed"])
    }

    @Test("The plain form says \"Updated\", or the announcement it is given")
    func plainForm() async throws {
        func result(of view: some View) async throws -> QeetrixRefreshResult {
            let modified = try #require(view as Any as? ModifiedContent<Text, QeetrixRefreshableModifier>)
            return await modified.modifier.action()
        }
        #expect(try await result(of: Text("Approvals").qeetrixRefreshable {}) == .updated)
        let announced = try await result(of: Text("Approvals").qeetrixRefreshable(announcement: "Approvals updated") {})
        #expect(announced == .updated("Approvals updated"))
        #expect(try await result(of: Text("Approvals").qeetrixRefreshable { .failed }) == .failed)
    }

    @Test("The content gets the system's refresh action, which runs the app's")
    func installsTheSystemRefresh() async throws {
        final class Capture {
            var refresh: RefreshAction?
            var runs = 0
        }
        struct Probe: View {
            let capture: Capture
            @Environment(\.refresh) private var refresh

            var body: some View {
                let _ = capture.refresh = refresh
                Text("Approvals")
            }
        }
        let capture = Capture()
        let view = Probe(capture: capture).qeetrixRefreshable { capture.runs += 1 }
        #expect(ImageRenderer(content: view).cgImage != nil)
        let refresh = try #require(capture.refresh)
        await refresh()
        #expect(capture.runs == 1)
    }

    @Test("A refreshable list renders as before, in both schemes")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let list = List {
                QeetrixListItem("Qeet Pay console", description: Text("Bengaluru"))
                QeetrixListItem("Qeet People", description: Text("Pune"))
            }
            .qeetrixListStyle()
            .qeetrixRefreshable {}
            #expect(ImageRenderer(content: list.frame(width: 390, height: 120).environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }

    #if os(iOS)
        @Test("SwiftUI gives the system refresh control no tint: tint(_:) doesn't reach it, so it keeps its own grey")
        func systemControlIsUntinted() async throws {
            // What PullToRefresh.md says about tinting rests on this. If it fails, iOS now lets SwiftUI
            // tint the control: give it a neutral token (design rules §4 keep Ember off a wait) and update
            // the page.
            let root = List { Text("Row") }
                .qeetrixRefreshable {}
                .tint(QeetrixColor.iconBrand)
            let host = UIHostingController(rootView: root)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = host
            window.isHidden = false
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(200))
            func refreshControl(in view: UIView) -> UIRefreshControl? {
                if let control = (view as? UIScrollView)?.refreshControl { return control }
                return view.subviews.lazy.compactMap(refreshControl(in:)).first
            }
            let control = try #require(refreshControl(in: window), "The list has the system's refresh control")
            #expect(control.tintColor == nil, "No tint reached the control: \(String(describing: control.tintColor))")
        }
    #endif
}
