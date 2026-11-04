import Qeetrix
import SwiftUI

/// This page's own bar shows the large title in Qeet Sans; scroll to collapse it into the inline bar.
/// The canvas variant is one level down.
struct LargeTitlePage: View {
    @State private var isQeetrix = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.layoutMd) {
                QeetrixText(
                    "The system's large title in Qeet Sans: heading.lg, collapsing into title.md in the bar as the page scrolls, with a rule once content is under it.",
                    size: .lg, tone: .subtle)
                DemoSection("Typeface") {
                    QeetrixSwitch("Qeet Sans titles", isOn: $isQeetrix, description: Text("Off: the system's font."))
                }
                DemoSection("On the canvas") {
                    NavigationLink {
                        LargeTitleCanvasDetail()
                    } label: {
                        QeetrixText("Open a page with the canvas bar")
                    }
                }
                DemoSection("Scroll to collapse the title") {
                    ForEach(1...20, id: \.self) { row in
                        QeetrixText("Account \(row)")
                    }
                }
            }
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Large title")
        .navigationBarTitleDisplayMode(.large)
        .qeetrixNavigationBar(title: isQeetrix ? .qeetrix : .system)
    }
}

/// A pushed page on the canvas background, its large title in Qeet Sans.
private struct LargeTitleCanvasDetail: View {
    var body: some View {
        List(1...30, id: \.self) { row in
            Text("Invoice INV-20\(row)")
                .qeetrixTextStyle(.bodyMd)
                .listRowBackground(Rectangle().fill(QeetrixColor.surfaceRaised))
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Invoices")
        .navigationBarTitleDisplayMode(.large)
        .qeetrixNavigationBar(background: .canvas, title: .qeetrix)
    }
}

#Preview {
    NavigationStack { LargeTitlePage() }
}
