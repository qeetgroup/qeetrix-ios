import Qeetrix
import SwiftUI

struct SkeletonPage: View {
    var body: some View {
        ComponentPage(
            title: "Skeleton",
            summary: "Placeholders in the shape of what is loading. Hidden from VoiceOver; the container says it is loading."
        ) {
            DemoSection("Shapes") {
                HStack(spacing: QeetrixSpacing.m) {
                    QeetrixSkeleton(.circle).frame(width: 40, height: 40)
                    QeetrixSkeleton().frame(width: 64, height: 40)
                    QeetrixSkeleton(.capsule).frame(width: 72, height: 24)
                }
            }
            DemoSection("Text") {
                QeetrixSkeletonText(lines: 3)
            }
            DemoSection("A row, composed") {
                QeetrixCard {
                    VStack(spacing: QeetrixSpacing.l) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: QeetrixSpacing.m) {
                                QeetrixSkeleton(.circle).frame(width: 32, height: 32)
                                QeetrixSkeletonText(lines: 2, role: .label)
                            }
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("Loading members"))
                }
            }
        }
    }
}

#Preview {
    NavigationStack { SkeletonPage() }
}
