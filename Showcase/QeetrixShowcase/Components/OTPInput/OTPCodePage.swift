import Qeetrix
import SwiftUI

/// Qeet Auth's main screen, in miniature: a list of accounts and their codes. Every code is synthetic,
/// derived from the time step with no secret: Qeetrix doesn't compute TOTP, the app does.
struct OTPCodePage: View {
    @State private var toast: QeetrixToast?
    @State private var fills = 0

    var body: some View {
        ComponentPage(
            title: "OTP code",
            summary:
                "A one-time code and the time it has left. Tap to copy: the code stays on this device and leaves the clipboard after a minute. Touch and hold an account for its Copy code menu."
        ) {
            DemoSection("Qeet Auth") {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    VStack(spacing: 0) {
                        ForEach(OTPDemoAccount.all) { account in
                            OTPDemoRow(account: account, date: context.date, toast: $toast)
                            QeetrixSeparator()
                        }
                    }
                }
            }
            DemoSection("On its own screen") {
                OTPDemoCode(account: OTPDemoAccount.all[0], size: .lg, toast: $toast)
            }
            DemoSection("Eight digits, 60 seconds") {
                OTPDemoCode(account: OTPDemoAccount.longCode, size: .lg, toast: $toast)
            }
            DemoSection("Hidden until tapped") {
                OTPDemoCode(account: OTPDemoAccount.hidden, size: .lg, isHidden: true, toast: $toast)
                QeetrixText("The first tap shows the code, the next copies it; the next code is hidden again.", size: .sm, tone: .subtle)
            }
            DemoSection("Fills instead of copying") {
                OTPDemoFillCode(account: OTPDemoAccount.autoFill) { _ in fills += 1 }
                QeetrixText(fills == 0 ? "Nothing filled" : "Filled \(fills) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("otp-fill-status")
                QeetrixText(
                    "In an AutoFill picker a tap fills the code: no clipboard, no toast. Hidden here, so the first tap shows it.",
                    size: .sm, tone: .subtle)
            }
            DemoSection("Disabled") {
                OTPDemoCode(account: OTPDemoAccount.all[1], size: .md, toast: $toast).disabled(true)
            }
        }
        .qeetrixToast($toast)
    }
}

/// An account's issuer and name, the code's length and its period.
struct OTPDemoAccount: Identifiable {
    let issuer: String
    let name: String
    let digits: Int
    let period: Int

    var id: String { issuer + name }

    static let all = [
        OTPDemoAccount(issuer: "Acme", name: "priya@acme.in", digits: 6, period: 30),
        OTPDemoAccount(issuer: "Qeet ID", name: "priya.sharma", digits: 6, period: 30),
        OTPDemoAccount(issuer: "Qeet Logs", name: "ops@acme.in", digits: 8, period: 30),
        OTPDemoAccount(issuer: "Registrar", name: "acme.in", digits: 6, period: 60),
    ]
    static let longCode = OTPDemoAccount(issuer: "Qeet Pay", name: "finance@acme.in", digits: 8, period: 60)
    static let hidden = OTPDemoAccount(issuer: "Bank", name: "Savings", digits: 6, period: 30)
    static let autoFill = OTPDemoAccount(issuer: "GitHub", name: "priya-sharma", digits: 6, period: 30)

    /// The time step `date` is in: its start, as TOTP counts from the Unix epoch.
    func periodStart(at date: Date) -> Date {
        let step = (date.timeIntervalSince1970 / Double(period)).rounded(.down)
        return Date(timeIntervalSince1970: step * Double(period))
    }

    /// A stand-in for the app's TOTP: digits that change each step, from no secret at all.
    func code(at date: Date) -> String {
        let step = UInt64(periodStart(at: date).timeIntervalSince1970) / UInt64(period)
        var value = step &* 6_364_136_223_846_793_005 &+ UInt64(truncatingIfNeeded: id.utf8.reduce(0) { $0 &* 31 &+ Int($1) })
        value ^= value >> 29
        var modulus: UInt64 = 1
        for _ in 0..<digits { modulus *= 10 }
        let number = String(value % modulus)
        return String(repeating: "0", count: digits - number.count) + number
    }
}

/// One account in the list: its issuer, its name and the code. VoiceOver reads the row as the code's
/// button, which the issuer and name label. Touch and hold for "Copy code", Qeetrix's copy from a menu.
private struct OTPDemoRow: View {
    let account: OTPDemoAccount
    let date: Date
    let toast: Binding<QeetrixToast?>

    var body: some View {
        HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
            QeetrixAvatar(name: account.issuer, size: .lg, shape: .square, isDecorative: true)
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixText(account.issuer, weight: .medium)
                    QeetrixText(account.name, size: .sm, tone: .subtle)
                }
                .accessibilityHidden(true)
                QeetrixOTPCode(
                    account.code(at: date), periodStart: account.periodStart(at: date), period: .seconds(account.period),
                    label: Text("\(account.issuer), \(account.name)"), size: .md, toast: toast)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, QeetrixSpace.gapMd)
        .contextMenu {
            Button("Copy code") { QeetrixCopy.copy(account.code(at: date), isSensitive: true, toast: toast) }
        }
    }
}

/// One code that follows the clock.
private struct OTPDemoCode: View {
    let account: OTPDemoAccount
    let size: QeetrixOTPCodeSize
    var isHidden = false
    let toast: Binding<QeetrixToast?>

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            QeetrixOTPCode(
                account.code(at: context.date), periodStart: account.periodStart(at: context.date), period: .seconds(account.period),
                label: Text("\(account.issuer), \(account.name)"), size: size, isHidden: isHidden, toast: toast)
        }
    }
}

/// A code that runs the app's action instead of copying, as an AutoFill credential provider's picker does.
private struct OTPDemoFillCode: View {
    let account: OTPDemoAccount
    let fill: @MainActor (String) -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            QeetrixOTPCode(
                account.code(at: context.date), periodStart: account.periodStart(at: context.date), period: .seconds(account.period),
                label: Text("\(account.issuer), \(account.name)"), size: .md, isHidden: true, actionHint: Text("Fills the code"),
                action: fill)
        }
    }
}

#Preview {
    NavigationStack { OTPCodePage() }
}
