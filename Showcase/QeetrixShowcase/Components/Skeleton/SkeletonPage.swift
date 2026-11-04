import Qeetrix
import SwiftUI

struct SkeletonPage: View {
    @State private var isLoading = true

    var body: some View {
        ComponentPage(
            title: "Skeleton",
            summary: "Placeholders shaped like the content on its way, pulsing to 45% and back; still under Reduce Motion."
        ) {
            DemoSection("Accounts loading") {
                QeetrixSwitch("Loading", isOn: $isLoading)
                if isLoading {
                    VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: QeetrixSpace.gapMd) {
                                QeetrixSkeleton(.circle, size: .lg)
                                QeetrixSkeleton(lines: 2)
                            }
                        }
                    }
                    .qeetrixSkeletonGroup(label: Text("Loading accounts"))
                } else {
                    VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
                        ForEach(["Qeet ID", "Qeet Pay", "Qeet People"], id: \.self) { product in
                            HStack(spacing: QeetrixSpace.gapMd) {
                                QeetrixAvatar(name: "Priya Sharma", size: .lg)
                                VStack(alignment: .leading, spacing: 0) {
                                    QeetrixText("Priya Sharma")
                                    QeetrixText(product, tone: .subtle)
                                }
                            }
                        }
                    }
                }
            }
            DemoSection("Variants") {
                QeetrixSkeleton()
                QeetrixSkeleton().frame(width: 160)
                QeetrixSkeleton(.block)
                QeetrixSkeleton(.block, height: 120)
            }
            DemoSection("Circles, the avatar's sizes") {
                HStack(spacing: QeetrixSpace.gapMd) {
                    ForEach(QeetrixSkeletonSize.allCases, id: \.self) { size in
                        QeetrixSkeleton(.circle, size: size)
                    }
                }
                .qeetrixSkeletonGroup()
            }
            DemoSection("A paragraph") {
                QeetrixSkeleton(lines: 3)
                QeetrixSkeleton(lines: 2, role: .bodySm)
            }
        }
    }
}

#Preview {
    NavigationStack { SkeletonPage() }
}
