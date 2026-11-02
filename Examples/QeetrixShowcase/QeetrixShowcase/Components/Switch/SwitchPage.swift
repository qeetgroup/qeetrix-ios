import Qeetrix
import SwiftUI

struct SwitchPage: View {
    @State private var email = true
    @State private var push = false
    @State private var twoStep = true
    @State private var wifi = false

    var body: some View {
        ComponentPage(
            title: "Switch",
            summary: "A setting that applies at once: a square 32 × 18 pt track, Ember when on, the thumb on the end side."
        ) {
            DemoSection("Settings") {
                VStack(spacing: 0) {
                    QeetrixSwitch("Email notifications", isOn: $email)
                    QeetrixSwitch("Push notifications", isOn: $push)
                }
            }
            DemoSection("With a description") {
                QeetrixSwitch("Two-step sign-in", isOn: $twoStep, description: Text("A code by SMS at each sign-in."))
            }
            DemoSection("Disabled") {
                QeetrixSwitch("Managed by your organisation", isOn: .constant(true)).disabled(true)
            }
            DemoSection("The style on a native Toggle") {
                Toggle("Wi-Fi", isOn: $wifi)
                    .toggleStyle(.qeetrixSwitch)
            }
        }
    }
}

#Preview {
    NavigationStack { SwitchPage() }
}
