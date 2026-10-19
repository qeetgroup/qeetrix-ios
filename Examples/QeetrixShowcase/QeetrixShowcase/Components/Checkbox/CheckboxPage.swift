import Qeetrix
import SwiftUI

struct Channel: Identifiable {
    let id: String
    var isOn: Bool
}

struct CheckboxPage: View {
    @State private var terms = false
    @State private var channels = [Channel(id: "Email", isOn: true), Channel(id: "Push", isOn: false), Channel(id: "SMS", isOn: false)]
    @State private var remember = true

    var body: some View {
        ComponentPage(
            title: "Checkbox",
            summary: "On, off or mixed. The glyph carries the state; the whole row is the target."
        ) {
            DemoSection("Single") {
                QeetrixCheckbox("Accept the terms", isOn: $terms, description: Text("You can read them at any time."))
                QeetrixCheckbox("Managed by your organisation", isOn: .constant(true)).disabled(true)
            }
            DemoSection("A group with a mixed parent") {
                QeetrixFieldSet(
                    "Notifications", description: Text("Choose how we reach you."),
                    message: channels.allSatisfy { !$0.isOn } ? .error("Choose at least one channel.") : nil
                ) {
                    QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
                    ForEach($channels) { $channel in
                        QeetrixCheckbox(channel.id, isOn: $channel.isOn)
                    }
                }
                QeetrixText("On: \(channels.filter(\.isOn).map(\.id).joined(separator: ", "))", variant: .muted)
                    .accessibilityIdentifier("channels-on")
            }
            DemoSection("The style on a native Toggle") {
                Toggle("Remember this device", isOn: $remember)
                    .toggleStyle(.qeetrixCheckbox)
            }
        }
    }
}

#Preview {
    NavigationStack { CheckboxPage() }
}
