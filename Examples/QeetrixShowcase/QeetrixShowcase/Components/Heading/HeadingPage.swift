import Qeetrix
import SwiftUI

struct HeadingPage: View {
    var body: some View {
        ComponentPage(
            title: "Heading",
            summary: "A section heading: the level sets the outline VoiceOver reads, the size sets the look. Base letters; Geo for display."
        ) {
            DemoSection("Default size by level") {
                QeetrixHeading("Account settings", level: 1)
                QeetrixHeading("Security", level: 2)
                QeetrixHeading("Passkeys", level: 3)
                QeetrixHeading("This device", level: 4)
                QeetrixHeading("Recovery", level: 5)
                QeetrixHeading("Backup codes", level: 6)
            }
            DemoSection("Display, for welcoming pages") {
                QeetrixHeading("Sign in to Qeet", level: 1, size: .displaySm)
            }
            DemoSection("Tones") {
                QeetrixHeading("Subtle", level: 3, size: .titleMd, tone: .subtle)
                QeetrixHeading("Inverse", level: 3, size: .titleMd, tone: .inverse)
                    .padding(QeetrixSpace.insetSm)
                    .background(QeetrixColor.surfaceInverse)
            }
        }
    }
}

#Preview {
    NavigationStack { HeadingPage() }
}
