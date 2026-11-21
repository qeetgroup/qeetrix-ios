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
    @State private var alsoReport = true

    var body: some View {
        ComponentPage(
            title: "Checkbox",
            summary:
                "A 16 pt square: Ember with a white tick when on, a dash when mixed. The label follows it and the whole row is the target."
        ) {
            DemoSection("Single") {
                QeetrixCheckbox("Accept the terms", isOn: $terms, description: Text("You can read them at any time."))
                QeetrixCheckbox("Managed by your organisation", isOn: .constant(true)).disabled(true)
                QeetrixCheckbox("Not available on your plan", isOn: .constant(false)).disabled(true)
            }
            DemoSection("A question with a mixed parent") {
                QeetrixField(
                    "Notifications", description: Text("Choose how we reach you."),
                    error: channels.allSatisfy { !$0.isOn } ? "Choose at least one channel." : nil
                ) {
                    VStack(alignment: .leading, spacing: 0) {
                        QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
                        ForEach($channels) { $channel in
                            QeetrixCheckbox(channel.id, isOn: $channel.isOn)
                        }
                    }
                }
                QeetrixText("On: \(channels.filter(\.isOn).map(\.id).joined(separator: ", "))", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("channels-on")
            }
            DemoSection("Beside the screen's own words") {
                // The card lays out its own title and note; the checkbox is the box alone, named for VoiceOver.
                HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
                    QeetrixCheckbox(isOn: $alsoReport, accessibilityLabel: Text("Also report Meera"))
                    VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                        Text("Also report Meera")
                            .qeetrixTextStyle(.bodyMd, weight: .medium)
                            .foregroundStyle(QeetrixColor.textDefault)
                        Text("We'll look at the last 20 messages.")
                            .qeetrixTextStyle(.bodySm)
                            .foregroundStyle(QeetrixColor.textSubtle)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(QeetrixSpace.insetMd)
                .background(QeetrixColor.surfaceRaised, in: RoundedRectangle(cornerRadius: QeetrixRadius.surface))
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
