import Qeetrix
import SwiftUI

struct SwitchPage: View {
    @State private var email = true
    @State private var push = false
    @State private var twoStep = true
    @State private var wifi = false
    @State private var faceID = true

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
            DemoSection("At the end of a row") {
                // The row lays out its own title and note; the switch is the track alone, named for VoiceOver.
                HStack(spacing: QeetrixSpace.gapMd) {
                    VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                        Text("Unlock with Face ID")
                            .qeetrixTextStyle(.bodyMd)
                            .foregroundStyle(QeetrixColor.textDefault)
                        Text("Asks for your face before it shows a code.")
                            .qeetrixTextStyle(.bodySm)
                            .foregroundStyle(QeetrixColor.textSubtle)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    QeetrixSwitch(isOn: $faceID, accessibilityLabel: Text("Unlock with Face ID"))
                }
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
