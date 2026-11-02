import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Haptics.md, Components/Format.md and
// Components/RelativeTime.md, copied verbatim inside views that supply the names they use. If the API
// changes in a way that breaks an example, this file stops compiling, and the page must be updated
// with it.

private struct Invoice {
    let number = "INV-2026-0042"
    let sentAt = Date(timeIntervalSince1970: 1_792_918_800)
}

private struct Device {
    let lastSeen = Date(timeIntervalSince1970: 1_792_900_000)
}

private enum Submission: Equatable {
    case sent, rejected
}

/// Haptics.md.
private struct HapticsExamples: View {
    let invoiceNumber = "INV-2026-0042"
    @State private var copies = 0
    @State private var isPastThreshold = false
    @State private var submission: Submission?

    var body: some View {
        VStack {
            Button("Copy invoice number") {
                copy(invoiceNumber)
                copies += 1
            }
            .qeetrixFeedback(.lightImpact, trigger: copies)

            Color.clear
                .qeetrixFeedback(.lightImpact, trigger: isPastThreshold) { _, isPast in isPast }
                .qeetrixFeedback(trigger: submission) { _, result in
                    switch result {
                    case .sent: .success
                    case .rejected: .error
                    case nil: nil
                    }
                }

            Button("Play") {
                QeetrixFeedback.error.play()
            }
        }
    }

    func copy(_ text: String) {}
}

/// Format.md.
private struct InvoiceTotal: View {
    let total: Decimal
    @Environment(\.locale) private var locale

    var body: some View {
        QeetrixText(QeetrixFormat.currency(total, code: "INR", locale: locale))
            .monospacedDigit()
    }
}

/// RelativeTime.md.
private struct RelativeTimeExamples: View {
    let invoice = Invoice()
    let device = Device()
    let previewNow = Date(timeIntervalSince1970: 1_792_920_600)

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                QeetrixRelativeTime(invoice.sentAt)
                QeetrixRelativeTime(device.lastSeen, size: .sm, tone: .subtle)
            }
            QeetrixRelativeTime(invoice.sentAt, threshold: .seconds(7 * 86_400), now: previewNow)
        }
    }
}

@Suite("Foundations documentation examples")
struct FoundationsDocumentationExamplesTests {
    @Test("Every Haptics, Format and RelativeTime example compiles against the public API and renders")
    @MainActor
    func examplesRender() {
        #expect(ImageRenderer(content: HapticsExamples().frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: InvoiceTotal(total: 124_500).environment(\.locale, Locale(identifier: "en-IN"))).cgImage != nil)
        #expect(ImageRenderer(content: RelativeTimeExamples().frame(width: 390)).cgImage != nil)
    }

    @Test("Format.md — what each example says it writes")
    func formatExamples() {
        let sentAt = Date(timeIntervalSince1970: 1_792_918_800)  // 2026-10-25T09:00:00Z
        let now = sentAt.addingTimeInterval(120)

        let india = Locale(identifier: "en-IN")
        let kolkata = TimeZone(identifier: "Asia/Kolkata")!

        #expect(QeetrixFormat.number(1_234_567, locale: india) == "12,34,567")
        #expect(QeetrixFormat.currency(124_500, code: "INR", locale: india) == "₹1,24,500.00")
        #expect(QeetrixFormat.date("2026-10-25", locale: india) == "25 Oct 2026")
        #expect(QeetrixFormat.dateTime(sentAt, locale: india, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.relativeTime(sentAt, now: now, locale: india) == "2 minutes ago")

        #expect(QeetrixFormat.fileSize(1_500_000, locale: india) == "1.5 MB")
        #expect(QeetrixFormat.duration(.seconds(7_500), style: .long, locale: india) == "2 hours, 5 minutes")
    }

    @Test("Format.md — the date table")
    func dateTable() {
        let india = Locale(identifier: "en-IN")
        let kolkata = TimeZone(identifier: "Asia/Kolkata")!
        let moment = "2026-10-25T09:00:00Z"
        #expect(
            QeetrixFormatDateStyle.allCases.map { QeetrixFormat.date("2026-10-25", style: $0, locale: india) } == [
                "25/10/26", "25 Oct 2026", "25 October 2026",
            ])
        #expect(
            QeetrixFormatDateStyle.allCases.map { QeetrixFormat.dateTime(moment, dateStyle: $0, locale: india, timeZone: kolkata) } == [
                "25/10/26, 2:30 pm", "25 Oct 2026, 2:30 pm", "25 October 2026 at 2:30 pm",
            ])
        #expect(
            QeetrixFormatDateStyle.allCases.map { QeetrixFormat.date("2026-10-25", style: $0, locale: Locale(identifier: "en-US")) } == [
                "10/25/26", "Oct 25, 2026", "October 25, 2026",
            ])
    }
}
