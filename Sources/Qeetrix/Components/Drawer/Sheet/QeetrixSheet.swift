import SwiftUI

extension View {
    /// Presents a sheet while `isPresented` is true — the web's `Drawer` and `Dialog`, as the system sheet.
    ///
    /// ```swift
    /// .qeetrixSheet(isPresented: $isEditing, detents: [.medium, .large], isDismissDisabled: hasChanges) {
    ///     QeetrixSheetContent("Edit profile", description: Text("Your team sees these details.")) {
    ///         QeetrixTextField("Display name", text: $name)
    ///     } actions: {
    ///         QeetrixButton("Cancel", variant: .outline) { isEditing = false }
    ///         QeetrixButton("Save") { save() }
    ///     }
    /// }
    /// ```
    ///
    /// On iPhone the sheet rises from the bottom, to the heights in `detents`, with a grab handle when there
    /// is more than one; on iPad, in a regular-width window, it is the centred form sheet — the web Dialog's
    /// shape. It draws the dialog surface and corner from the design tokens; motion, dimming and the
    /// gestures are the system's.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is shown; set back to `false` however it is dismissed.
    ///   - detents: The heights it can rest at. `[.large]` by default, the web drawer's full height.
    ///   - isDismissDisabled: Stops a swipe or a tap outside from dismissing it — while a form has unsaved
    ///     changes, say. Your own buttons still dismiss it. The decision is yours.
    ///   - onDismiss: Runs once after the sheet is dismissed, however that happened.
    ///   - content: The sheet's content, typically a ``QeetrixSheetContent``.
    public func qeetrixSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.large],
        isDismissDisabled: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content().modifier(QeetrixSheetPresentation(detents: detents, isDismissDisabled: isDismissDisabled))
        }
    }

    /// Presents a sheet for `item` while it is not `nil` — for a sheet about one thing, such as the row
    /// that was tapped.
    public func qeetrixSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.large],
        isDismissDisabled: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        sheet(item: item, onDismiss: onDismiss) { presented in
            content(presented).modifier(QeetrixSheetPresentation(detents: detents, isDismissDisabled: isDismissDisabled))
        }
    }
}

/// The Qeetrix sheet surface: the dialog background and corner from `component.dialog.*`, the detents,
/// and a grab handle when there is more than one detent to move between.
struct QeetrixSheetPresentation: ViewModifier {
    let detents: Set<PresentationDetent>
    let isDismissDisabled: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(QeetrixDialogTokens.foreground)
            .presentationDetents(detents)
            .presentationDragIndicator(detents.count > 1 ? .visible : .hidden)
            .presentationBackground(QeetrixDialogTokens.background)
            .presentationCornerRadius(QeetrixDialogTokens.corner)
            .interactiveDismissDisabled(isDismissDisabled)
    }
}

/// The layout of a sheet — the web `Dialog`'s parts: a header with the title, an optional description and
/// a Close button; the content, which scrolls; and the actions, pinned below it.
///
/// The title is a heading and names the sheet for VoiceOver. Close dismisses the sheet with the
/// environment's `dismiss` — or, when you pass `onClose`, runs that instead, so a sheet with unsaved
/// changes can ask before discarding them. The actions are placed as ``QeetrixFormActions`` places them —
/// stacked full-width with the primary on top on iPhone, a trailing row on iPad — and stay above the
/// keyboard while a field is focused, so the primary action never scrolls out of reach.
public struct QeetrixSheetContent<Content: View, Actions: View>: View {
    let title: Text
    let description: Text?
    let onClose: (@MainActor () -> Void)?
    let content: Content
    let actions: Actions
    @Environment(\.dismiss) private var dismiss

    /// A sheet layout with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, description: Text? = nil, onClose: (@MainActor () -> Void)? = nil,
        @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.init(title: Text(titleKey), description: description, onClose: onClose, content: content, actions: actions)
    }

    /// A sheet layout with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, description: Text? = nil, onClose: (@MainActor () -> Void)? = nil,
        @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.init(title: Text(title), description: description, onClose: onClose, content: content, actions: actions)
    }

    /// A sheet layout with a `Text` title.
    ///
    /// - Parameters:
    ///   - title: The heading, which names the sheet for VoiceOver.
    ///   - description: A line under the title.
    ///   - onClose: What Close does instead of dismissing — to confirm discarding changes, say.
    ///   - content: The body; it scrolls when taller than the sheet.
    ///   - actions: The buttons, in reading order, primary last.
    public init(
        title: Text, description: Text? = nil, onClose: (@MainActor () -> Void)? = nil,
        @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.description = description
        self.onClose = onClose
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        let padding = QeetrixWebScale.spacing(6)  // p-6
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(4)) {  // gap-4
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, padding)
            .padding(.bottom, padding)
        }
        .scrollBounceBehavior(.basedOnSize)
        // The header and actions stay put; the content scrolls beneath them, so they carry the surface.
        .safeAreaInset(edge: .top, spacing: 0) {
            header.padding(padding).background(QeetrixDialogTokens.background)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            QeetrixFormActions { actions }
                .padding(.horizontal, padding)
                .padding(.bottom, padding)
                .background(QeetrixDialogTokens.background)
        }
        .qeetrixType(QeetrixSheetMetrics.bodyType)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: QeetrixWebScale.spacing(2)) {
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
                title
                    .qeetrixType(QeetrixSheetMetrics.titleType)
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .qeetrixType(QeetrixSheetMetrics.bodyType)
                        .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            QeetrixIconButton(.x, label: QeetrixStrings.close, variant: .ghost, size: .sm) {
                if let onClose { onClose() } else { dismiss() }
            }
        }
    }
}

enum QeetrixSheetMetrics {
    /// `font-heading text-heading font-semibold`: the heading role.
    static let titleType = QeetrixTypeSpec(.heading)
    /// `text-sm`.
    static let bodyType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .body)
}
