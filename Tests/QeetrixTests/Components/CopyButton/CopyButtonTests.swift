import SwiftUI
import Testing

@testable import Qeetrix

/// A writer that records what it is given instead of touching the pasteboard. Every value is synthetic.
@MainActor
final class CopyRecorder {
    var entries: [QeetrixCopyEntry] = []
    var accepts = true

    var writer: QeetrixCopyWriter {
        QeetrixCopyWriter { [self] entry in
            entries.append(entry)
            return accepts
        }
    }
}

@MainActor
@Suite("Copy button")
struct CopyButtonTests {
    let copiedAt = Date(timeIntervalSinceReferenceDate: 800_000_000)

    @Test("A plain copy stays until replaced; a sensitive one is local only and removed 60 seconds later")
    func entries() {
        let plain = QeetrixCopyEntry("acme-user-0042", isSensitive: false, copiedAt: copiedAt)
        #expect(plain.text == "acme-user-0042")
        #expect(!plain.isLocalOnly && plain.expiresAt == nil)
        let secret = QeetrixCopyEntry("482913", isSensitive: true, copiedAt: copiedAt)
        #expect(secret.isLocalOnly)
        #expect(secret.expiresAt == copiedAt.addingTimeInterval(60))
        #expect(QeetrixCopyEntry.sensitiveLifetime == .seconds(60))
        #expect(QeetrixCopyEntry.seconds(.milliseconds(1_500)) == 1.5)
    }

    #if canImport(UIKit)
        @Test("On iOS a copy is one UTF-8 plain-text item; a secret's options are local only and its expiry")
        func pasteboardOptions() throws {
            let plain = QeetrixCopyEntry("acme-user-0042", isSensitive: false, copiedAt: copiedAt)
            #expect(plain.pasteboardOptions.isEmpty)
            #expect(plain.pasteboardItems.count == 1)
            #expect(plain.pasteboardItems.first?["public.utf8-plain-text"] as? String == "acme-user-0042")
            let options = QeetrixCopyEntry("482913", isSensitive: true, copiedAt: copiedAt).pasteboardOptions
            #expect(options[.localOnly] as? Bool == true)
            #expect(options[.expirationDate] as? Date == copiedAt.addingTimeInterval(60))
        }
    #else
        @Test("The Mac host has no UIKit pasteboard, so the system writer refuses every copy")
        func hostWriter() {
            #expect(!QeetrixCopyWriter.system.write(QeetrixCopyEntry("acme", isSensitive: false, copiedAt: copiedAt)))
        }
    #endif

    @Test("A copy reads the value when tapped and writes it through the writer it is given")
    func copies() async {
        let recorder = CopyRecorder()
        let copied = await QeetrixCopy.copy({ "482913" }, isSensitive: true, writer: recorder.writer, now: { copiedAt })
        #expect(copied == "482913")
        #expect(recorder.entries == [QeetrixCopyEntry("482913", isSensitive: true, copiedAt: copiedAt)])
        var reads = 0
        let fresh = await QeetrixCopy.copy(
            {
                reads += 1
                return "token-\(reads)"
            }, isSensitive: false, writer: recorder.writer)
        #expect(fresh == "token-1" && reads == 1, "Read at the moment of the copy")
    }

    struct Unavailable: Error {}

    @Test("A value that throws copies nothing; a writer that refuses fails the copy")
    func failures() async {
        let recorder = CopyRecorder()
        let thrown = await QeetrixCopy.copy({ throw Unavailable() }, isSensitive: false, writer: recorder.writer)
        #expect(thrown == nil)
        #expect(recorder.entries.isEmpty, "Nothing reaches the pasteboard")
        recorder.accepts = false
        let refused = await QeetrixCopy.copy({ "acme" }, isSensitive: false, writer: recorder.writer)
        #expect(refused == nil)
        #expect(recorder.entries.count == 1)
    }

    @Test("Each tap is a round: copied or failed, idle again after the reset; a newer tap replaces an older round")
    func rounds() {
        var session = QeetrixCopySession()
        #expect(session.state == .idle && session.round == 0 && session.outcome == nil)
        session.begin()
        let first = session.round
        let finished = session.finish(first, copied: true)
        #expect(finished && session.state == .copied)
        session.reset(first)
        #expect(session.state == .idle)

        session.begin()
        let second = session.round
        session.begin()  // tapped again before the copy finished
        let replaced = session.finish(second, copied: true)
        #expect(!replaced && session.state == .idle, "A replaced round shows nothing")
        let failed = session.finish(session.round, copied: false)
        #expect(failed && session.state == .failed)
        session.reset(second)
        #expect(session.state == .failed, "A stale reset leaves the newer round alone")
        session.begin()
        #expect(session.state == .idle, "A tap starts idle, as copy-button.tsx does")
    }

    @Test("A light haptic for a copy and the error haptic for a failure, for every copy, even two alike")
    func haptics() {
        var session = QeetrixCopySession()
        session.begin()
        _ = session.finish(session.round, copied: true)
        let first = session.outcome
        session.begin()
        _ = session.finish(session.round, copied: true)
        #expect(first != session.outcome, "Two copies are two triggers")
        #expect(QeetrixCopy.feedback(for: session.outcome) == .lightImpact)
        #expect(QeetrixCopy.feedback(for: .init(round: 3, state: .failed)) == .error)
        #expect(QeetrixCopy.feedback(for: nil) == nil)
    }

    @Test("With the screen's toast a copy shows Copied — for a secret, when it leaves; without one it is announced")
    func confirmation() {
        let english = Locale(identifier: "en_US")
        var shown: QeetrixToast?
        let binding = Binding(get: { shown }, set: { shown = $0 })
        #expect(QeetrixCopy.confirm(copied: "acme", isSensitive: false, toast: binding, locale: english) == nil)
        #expect(shown?.tone == .success && shown?.title == "Copied" && shown?.description == nil)
        #expect(QeetrixCopy.confirm(copied: "482913", isSensitive: true, toast: binding, locale: english) == nil)
        #expect(shown?.description == "Clears from the clipboard after 1 minute")
        #expect(QeetrixCopy.confirm(copied: "acme", isSensitive: false, toast: nil, locale: english) == "Copied")
        shown = nil
        #expect(QeetrixCopy.confirm(copied: nil, isSensitive: false, toast: binding, locale: english) == "Couldn't copy")
        #expect(shown == nil, "A failure is announced, never toasted")
    }

    @Test("copy, then check or circle-alert; on ghost buttons in icon.success or icon.danger (copy-button.css)")
    func icons() {
        #expect(QeetrixCopyState.allCases.map(\.rawValue) == ["idle", "copied", "failed"])
        #expect(QeetrixCopyState.allCases.map(QeetrixCopy.icon) == [.copy, .check, .circleAlert])
        #expect(QeetrixCopy.iconTint(.idle, variant: .ghost) == nil)
        #expect(QeetrixCopy.iconTint(.copied, variant: .ghost) == .iconSuccess)
        #expect(QeetrixCopy.iconTint(.failed, variant: .ghost) == .iconDanger)
        for variant in [QeetrixButtonVariant.solid, .soft] {
            for state in QeetrixCopyState.allCases {
                #expect(QeetrixCopy.iconTint(state, variant: variant) == nil, "\(variant) keeps its own icon colour")
            }
        }
        #expect(QeetrixCopy.status(.idle) == nil)
        #expect(QeetrixCopy.status(.copied) == "Copied")
        #expect(QeetrixCopy.status(.failed) == "Couldn't copy")
    }

    @Test("Defaults are CopyButton's: ghost, neutral, md, named Copy, reset after 2 seconds")
    func defaults() {
        let button = QeetrixCopyButton(value: "acme")
        #expect(button.variant == .ghost && button.tone == .neutral && button.size == .md)
        #expect(button.resetAfter == .seconds(2) && QeetrixCopy.resetAfter == .seconds(2))
        #expect(button.label == nil && button.title == nil && !button.isSensitive && button.toast == nil)
        let titled = QeetrixCopyButton("Copy link", value: "https://qeet.in/i/7Hq2", isSensitive: true)
        #expect(titled.title != nil && titled.label == nil && titled.isSensitive)
        #expect(QeetrixCopyStrings.copy("ACS URL") == "Copy ACS URL")
    }

    @Test("The copied and failed icons keep 3:1 on the surfaces and the ghost button's hover tint, in both schemes")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for background in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceRaised, .bgNeutralSubtle] {
                for icon in [QeetrixColor.iconSuccess, .iconDanger] {
                    let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(icon), on: theme.resolve(background))
                    #expect(ratio >= 3, "\(icon) on \(background), \(theme.colorScheme): \(ratio)")
                }
            }
        }
        // Pressed again while it shows the check, a ghost copy button draws icon.success on the pressed
        // tint: 2.85:1 in light, as on the web (copy-button.css over button.css). Reported upstream.
        let light = QeetrixTheme.light
        #expect(QeetrixAccessibility.contrastRatio(light.resolve(.iconSuccess), on: light.resolve(.bgNeutralSubtlePressed)) < 3)
        #expect(QeetrixAccessibility.contrastRatio(light.resolve(.iconDanger), on: light.resolve(.bgNeutralSubtlePressed)) >= 3)
    }

    @Test("It renders: icon-only and titled, every variant and state, and every public form")
    func renders() {
        for state in QeetrixCopyState.allCases {
            for variant in QeetrixButtonVariant.allCases {
                for title in [nil, Text("Copy link")] {
                    let face = QeetrixCopyButtonFace(
                        state: state, label: Text("Copy user ID"), title: title, variant: variant, tone: .neutral, size: .md, action: {})
                    #expect(ImageRenderer(content: face).cgImage != nil)
                }
            }
        }
        #expect(ImageRenderer(content: QeetrixCopyButton(value: "acme", size: .sm)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCopyButton(label: Text("Copy API key"), isSensitive: true) { "qk_test_0000" }).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCopyButton(title: Text("Copy"), value: "acme", variant: .soft, size: .lg)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCopyButton(String("Copy ID"), value: "acme").disabled(true)).cgImage != nil)
    }
}
