#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Check list snapshots")
    struct CheckListSnapshotTests {
        @Test("Every status, with details, and a footer")
        func statuses() {
            assertSpecimen(
                QeetrixCheckList {
                    QeetrixCheckItem("The certificate is in date", detail: Text("Until 23 Aug 2030"), status: .passed)
                    QeetrixCheckItem("The signing key matches", detail: Text("Expected SHA-256 4F:2A…, found 9C:11…"), status: .failed)
                    QeetrixCheckItem("The metadata URL answers", status: .running)
                    QeetrixCheckItem("Users can sign in", status: .pending)
                } footer: {
                    Text("Started just now")
                    QeetrixButton("Run again", variant: .ghost, size: .sm) {}
                }
            )
        }

        @Test("A new password's rules, part met")
        func passwordRules() {
            assertSpecimen(
                QeetrixCheckList {
                    QeetrixCheckItem("At least 12 characters", status: .passed)
                    QeetrixCheckItem("A number or a symbol", status: .pending)
                    QeetrixCheckItem("Not a password you've used before", status: .passed)
                }
            )
        }
    }
#endif
