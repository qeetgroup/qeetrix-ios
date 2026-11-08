import Qeetrix
import SwiftUI

/// A sign-in approval's number match: two square slots that open focused on the number pad,
/// with no one-time-code AutoFill, under the screen's own label.
struct NumberMatchPage: View {
    // Synthetic numbers only.
    @State private var number = ""
    @State private var isFocused = true

    var body: some View {
        ComponentPage(
            title: "Number match",
            summary: "Square slots at the leading edge, focused on appear, with no code offered over the number pad."
        ) {
            DemoSection("Approve a sign-in") {
                QeetrixText("Enter the number shown on your other device", size: .sm, tone: .subtle)
                QeetrixOTPInput(code: $number, accessibilityLabel: Text("Number on your other device"), length: 2)
                    .qeetrixOTPSlotWidth(.square)
                    .qeetrixOTPAutoFill(false)
                    .qeetrixOTPFocus($isFocused)
                QeetrixText(number.isEmpty ? "Nothing entered" : "Entered \(number)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("number-status")
            }
        }
    }
}

#Preview {
    NavigationStack { NumberMatchPage() }
}
