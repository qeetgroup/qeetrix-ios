import Qeetrix
import SwiftUI

struct SwitchPage: View {
    @State private var email = true
    @State private var push = false
    @State private var digest = true
    @State private var wifi = false

    var body: some View {
        ComponentPage(
            title: "Switch",
            summary: "An on/off control. The thumb's position and lightness carry the state, never colour alone."
        ) {
            DemoSection("Default") {
                VStack(spacing: 0) {
                    QeetrixSwitch("Email notifications", isOn: $email)
                    QeetrixSwitch("Push notifications", isOn: $push)
                }
            }
            DemoSection("Small") {
                QeetrixSwitch("Weekly digest", isOn: $digest, size: .sm)
            }
            DemoSection("Disabled") {
                QeetrixSwitch("Managed by your organisation", isOn: .constant(true)).disabled(true)
            }
            DemoSection("The style on a native Toggle") {
                Toggle("Wi-Fi", isOn: $wifi)
                    .toggleStyle(.qeetrixSwitch())
            }
        }
    }
}

#Preview {
    NavigationStack { SwitchPage() }
}
