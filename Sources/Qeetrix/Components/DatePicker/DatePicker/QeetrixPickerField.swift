import SwiftUI

/// The field every Qeetrix date and time picker opens from, as `@qeetrix/react`'s PickerField: the
/// Input box with the value or the placeholder, its trailing icon in an icon button's place, and the
/// picker in a popover under it. On iOS the whole box is one button: there is nothing to type.
struct QeetrixPickerField<Panel: View>: View {
    /// What the field shows: "25/10/2026".
    let text: String?
    /// What VoiceOver reads as the value: "25 October 2026".
    let spokenText: String?
    let placeholder: Text?
    let icon: QeetrixIconName
    /// The pointer's tooltip: "Choose date".
    let tooltip: Text
    let isReadOnly: Bool
    let isPresented: Binding<Bool>
    let panel: Panel
    @State private var isHovered = false
    @State private var fieldWidth: CGFloat = 0
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 100

    init(
        text: String?, spokenText: String?, placeholder: Text?, icon: QeetrixIconName, tooltip: Text, isReadOnly: Bool,
        isPresented: Binding<Bool>, @ViewBuilder panel: () -> Panel
    ) {
        self.text = text
        self.spokenText = spokenText
        self.placeholder = placeholder
        self.icon = icon
        self.tooltip = tooltip
        self.isReadOnly = isReadOnly
        self.isPresented = isPresented
        self.panel = panel()
    }

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered && !isReadOnly,
            isInvalid: context?.invalid ?? false)
        let presentation = QeetrixPickerPresentation(
            horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass, dynamicTypeSize: dynamicTypeSize)
        Button {
            isPresented.wrappedValue = true
        } label: {
            HStack(spacing: QeetrixInputMetrics.gap) {
                ZStack(alignment: .leading) {
                    // A hidden line keeps an empty field one line tall at every text size.
                    Text(verbatim: "X").hidden()
                    if let text {
                        Text(verbatim: text)
                            .foregroundStyle(state.foreground)
                            .monospacedDigit()
                            .fixedSize(horizontal: false, vertical: true)
                    } else if let placeholder {
                        placeholder.foregroundStyle(QeetrixInputMetrics.placeholder)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                // The web's ghost neutral icon button at the field's end (`size: "sm"`, `color.text.subtle`).
                QeetrixIcon(icon, size: .sm, shape: .sharp)
                    .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled)
                    .frame(width: density.sizeControlSm * Swift.max(1, scale / 100))
            }
            .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
            .padding(.leading, QeetrixInputMetrics.padding)
            // date-picker.css: `.qx-date-picker { padding-inline-end: var(--qx-space-gap-xs) }`.
            .padding(.trailing, QeetrixSpace.gapXs)
            .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: QeetrixInputMetrics.textType)
            .qeetrixInputSurface(state)
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .disabled(isReadOnly)
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .help(tooltip)
        .qeetrixFieldControlAccessibility()
        .accessibilityValue(spokenText.map { Text(verbatim: $0) } ?? placeholder ?? Text(verbatim: ""))
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { fieldWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, width in fieldWidth = width }
            }
        }
        .popover(isPresented: isPresented, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
            QeetrixPickerPopover(presentation: presentation, width: Swift.max(fieldWidth, QeetrixPickerPopover<Panel>.minimumWidth)) {
                panel
            }
        }
    }
}

/// How a picker is presented in the window it's in.
struct QeetrixPickerPresentation: Hashable {
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?
    let dynamicTypeSize: DynamicTypeSize

    /// A sheet where a popover wouldn't fit: on a phone at the accessibility text sizes, where a month no
    /// longer fits beside the screen's edges, and in a phone's landscape, which is too short for one.
    /// Elsewhere a popover under the field, as the system's compact date picker opens.
    var isSheet: Bool {
        (horizontalSizeClass == .compact && dynamicTypeSize.isAccessibilitySize) || verticalSizeClass == .compact
    }
}

/// The picker's popover (date-picker.css `.qx-date-picker-popup`): the overlay surface, 12 pt in, as
/// wide as the field and never narrower than a month; a sheet, scrolling, where a popover wouldn't fit.
struct QeetrixPickerPopover<Content: View>: View {
    let presentation: QeetrixPickerPresentation
    let width: CGFloat
    let content: Content

    /// Room for the system's calendar and wheel, 320 pt wide, and for seven 44 pt days, inside the 12 pt
    /// padding. The web's `min-inline-size: calc(7 * (control.md + 2px) + 2 * inset.md)`, 262 px, would
    /// bring a day's target under 44 pt.
    static var minimumWidth: CGFloat { 320 + 2 * QeetrixSpace.insetMd }

    init(presentation: QeetrixPickerPresentation, width: CGFloat, @ViewBuilder content: () -> Content) {
        self.presentation = presentation
        self.width = width
        self.content = content()
    }

    var body: some View {
        Group {
            if presentation.isSheet {
                ScrollView {
                    content.padding(QeetrixSpace.insetMd)
                }
            } else {
                content
                    .padding(QeetrixSpace.insetMd)
                    .frame(width: width)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(QeetrixColor.textDefault)
        // The field's label and error belong to the field, not to the controls inside its picker.
        .environment(\.qeetrixFieldContext, nil)
        .presentationCompactAdaptation(horizontal: presentation.isSheet ? .sheet : .popover, vertical: .sheet)
        .presentationBackground(QeetrixColor.surfaceOverlay)
        .presentationDetents([.large])
    }
}

/// The picker's actions at the foot of its popover: "Clear" when the value can be emptied, and "Done"
/// where the system's picker needs one to commit.
struct QeetrixPickerActions: View {
    let clear: (@MainActor () -> Void)?
    let done: (@MainActor () -> Void)?

    var body: some View {
        if clear != nil || done != nil {
            HStack(spacing: QeetrixSpace.gapSm) {
                Spacer(minLength: 0)
                if let clear {
                    QeetrixButton(title: QeetrixPickerStrings.clear, variant: .ghost, tone: .neutral, size: .sm, action: clear)
                }
                if let done {
                    QeetrixButton(title: QeetrixPickerStrings.done, size: .sm, action: done)
                }
            }
        }
    }
}

/// The pickers' own words. iOS only: the web's field is typed into and cleared like any input, and its
/// calendar commits a day as soon as it is chosen.
enum QeetrixPickerStrings {
    /// "Done".
    static var done: Text { Text("qeetrix.date-picker.done", bundle: .module) }
    /// "Clear".
    static var clear: Text { Text("qeetrix.date-picker.clear", bundle: .module) }
}
