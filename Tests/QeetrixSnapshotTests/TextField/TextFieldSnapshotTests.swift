#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Text field snapshots")
    struct TextFieldSnapshotTests {
        @Test("Prompt, value, icon, affixes, error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixTextField("Trade name", text: .constant(""), prompt: Text("e.g. Acme Pvt Ltd"), isOptional: true)
                    QeetrixTextField("Work email", text: .constant("priya@kaveri.in"), description: Text("We send receipts here."))
                    QeetrixTextField("Search", text: .constant(""), prompt: Text("Invoices, people"), icon: .search, isLabelHidden: true)
                    QeetrixTextField("Amount", text: .constant("1,20,000"), startAdornment: Text("₹"), endAdornment: Text("per year"))
                    QeetrixTextField("GSTIN", text: .constant("29ABCDE1234"), error: "Enter the GSTIN as 15 characters")
                    QeetrixTextField("Client ID", text: .constant("qid_live_7Yf2"), isReadOnly: true)
                    QeetrixTextField("Organisation", text: .constant("Kaveri Foods"), description: Text("Only an owner can change it."))
                        .disabled(true)
                }
            )
        }

        @Test("Large: the prompt at body size, a value with an affix, an error, read-only, disabled and compact")
        func large() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixTextField(
                        "Phone number", text: .constant(""), prompt: Text("10-digit mobile number"), startAdornment: Text("+91"), size: .lg)
                    QeetrixTextField("Phone number", text: .constant("98765 43210"), startAdornment: Text("+91"), size: .lg)
                    QeetrixTextField("Your name", text: .constant("Meera"), error: "Enter the name your contacts know", size: .lg)
                    QeetrixTextField(
                        "Phone number", text: .constant("98765 43210"), startAdornment: Text("+91"), size: .lg, isReadOnly: true)
                    QeetrixTextField("Your name", text: .constant("Meera"), size: .lg).disabled(true)
                    QeetrixTextField("Your name", text: .constant(""), prompt: Text("As your contacts know you"), size: .lg)
                        .qeetrixDensity(.compact)
                }
            )
        }

        @Test("The input box in every state: rest, hover, focus, invalid, focused and invalid, read-only, disabled")
        func surfaces() {
            let states: [(String, QeetrixInputState)] = [
                ("Rest", .init(isEnabled: true, isReadOnly: false, isFocused: false, isHovered: false, isInvalid: false)),
                ("Hover", .init(isEnabled: true, isReadOnly: false, isFocused: false, isHovered: true, isInvalid: false)),
                ("Focus", .init(isEnabled: true, isReadOnly: false, isFocused: true, isHovered: false, isInvalid: false)),
                ("Invalid", .init(isEnabled: true, isReadOnly: false, isFocused: false, isHovered: false, isInvalid: true)),
                ("Focus, invalid", .init(isEnabled: true, isReadOnly: false, isFocused: true, isHovered: false, isInvalid: true)),
                ("Read-only", .init(isEnabled: true, isReadOnly: true, isFocused: false, isHovered: false, isInvalid: false)),
                ("Disabled", .init(isEnabled: false, isReadOnly: false, isFocused: false, isHovered: false, isInvalid: false)),
            ]
            assertSpecimen(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(states, id: \.0) { label, state in
                        Text(label)
                            .qeetrixTextStyle(.bodyMd)
                            .padding(.horizontal, QeetrixInputMetrics.padding)
                            .frame(maxWidth: .infinity, minHeight: QeetrixDensity.default.sizeControlLg, alignment: .leading)
                            .qeetrixInputSurface(state)
                    }
                }
            )
        }
    }
#endif
