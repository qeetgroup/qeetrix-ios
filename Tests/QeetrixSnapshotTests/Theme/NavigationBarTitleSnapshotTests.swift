#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Large and collapsing title snapshots")
    struct NavigationBarTitleSnapshotTests {
        /// The bar is the system's; the specimen shows what Qeetrix sets on it — the titles' type and
        /// colour, the tint — at the scroll edge, large and inline.
        @Test("A large title and an inline title in Qeet Sans, on the automatic and the canvas background")
        func titles() {
            assertSpecimen(
                VStack(spacing: 16) {
                    NavigationStack {
                        List(["Asha Rao", "Ravi Kumar"], id: \.self) { Text($0) }
                            .navigationTitle("Accounts")
                            .navigationBarTitleDisplayMode(.large)
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button {
                                    } label: {
                                        Label {
                                            Text("Add account")
                                        } icon: {
                                            Image(qeetrix: .plus)
                                        }
                                    }
                                }
                            }
                            .qeetrixNavigationBar(title: .qeetrix)
                    }
                    .frame(height: 240)
                    NavigationStack {
                        Text("Invoice INV-2041")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .navigationTitle("Invoice")
                            .navigationBarTitleDisplayMode(.inline)
                            .qeetrixNavigationBar(background: .canvas, title: .qeetrix)
                    }
                    .frame(height: 140)
                }
                .padding(.horizontal, -16)
            )
        }
    }
#endif
