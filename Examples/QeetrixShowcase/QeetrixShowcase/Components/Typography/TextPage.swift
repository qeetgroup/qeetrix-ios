import Qeetrix
import SwiftUI

struct TextPage: View {
    var body: some View {
        ComponentPage(
            title: "Text",
            summary: "Copy in the web Typography variants. Headings are VoiceOver headings, and every variant scales with Dynamic Type."
        ) {
            DemoSection("Headings") {
                QeetrixText("Account settings", variant: .h1)
                QeetrixText("Security", variant: .h2)
                QeetrixText("Passkeys", variant: .h3)
                QeetrixText("This device", variant: .h4)
            }
            DemoSection("Copy") {
                QeetrixText("Sign in without a password, on any device you trust.", variant: .lead)
                QeetrixText("Passkeys are stored in your password manager and synced across your devices.")
                QeetrixText("Last used 2 days ago", variant: .muted)
                QeetrixText("Recommended", variant: .large)
                QeetrixText("Device name", variant: .small)
                QeetrixText("“The simplest sign-in we have shipped.”", variant: .blockquote)
                QeetrixText("navigator.credentials.create()", variant: .inlineCode)
            }
        }
    }
}

#Preview {
    NavigationStack { TextPage() }
}
