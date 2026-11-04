import SwiftUI

/// A dialog's intent, as `@qeetrix/react`'s Dialog `intent`: the 3 pt line across its top.
public enum QeetrixDialogIntent: String, CaseIterable, Sendable {
    /// Ember (`color.border.brand`).
    case standard
    /// A destructive confirmation (`color.border.danger`).
    case danger
    /// A warning (`color.icon.warning`).
    case warning

    var color: QeetrixColor {
        switch self {
        case .standard: .borderBrand
        case .danger: .borderDanger
        case .warning: .iconWarning
        }
    }
}

extension View {
    /// Presents a Qeetrix sheet while `isPresented` is true — the system sheet, with the drawer's
    /// overlay surface (`color.surface.overlay`) and 4 pt corners. Put a ``QeetrixSheetContent`` in it.
    ///
    /// On iOS the sheet stands in for both `@qeetrix/react`'s Drawer and its Dialog (ADR 0014): it
    /// keeps the system's presentation, swipe to dismiss, detents and VoiceOver focus handling.
    /// `isDismissDisabled` turns off the swipe, as the web's `dismissible={false}` turns off Escape and
    /// an outside click; pair it with `isDismissible: false` on the content, which then has no close
    /// button.
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

    /// Presents a Qeetrix sheet for `item` while it is not `nil`.
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

struct QeetrixSheetPresentation: ViewModifier {
    let detents: Set<PresentationDetent>
    let isDismissDisabled: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(QeetrixColor.textDefault)
            .presentationDetents(detents)
            .presentationDragIndicator(detents.count > 1 ? .visible : .hidden)
            .presentationBackground(QeetrixColor.surfaceOverlay)
            .presentationCornerRadius(QeetrixRadius.modal)
            .interactiveDismissDisabled(isDismissDisabled)
    }
}

/// A sheet's layout, as `@qeetrix/react`'s Drawer: a ruled header with the title (`title.md`), an
/// optional description and the close button at its end; the body, which scrolls; and a ruled footer
/// with the actions, end-aligned, tertiary first.
///
/// ```swift
/// .qeetrixSheet(isPresented: $isEditing) {
///     QeetrixSheetContent("Edit address", description: Text("Used on every invoice.")) {
///         QeetrixTextField("Street", text: $street)
///     } actions: {
///         QeetrixButton("Cancel", variant: .ghost, size: .lg) { isEditing = false }
///         QeetrixButton("Save", size: .lg) { save() }
///     }
/// }
/// ```
///
/// 24 pt padding (`space.inset.xl`) and 1 pt `color.border.subtle` rules; the header and footer stay
/// put while the body scrolls. Where the sheet is the web's Dialog — a decision that interrupts — give
/// it an `intent`, which draws the Dialog's 3 pt line across its top: Ember for a standard dialog, red
/// for a destructive one, amber for a warning. The close button is a neutral ghost ``QeetrixIconButton``
/// named "Close"; it calls `onClose`, or dismisses the sheet. With `isDismissible: false` there is no
/// close button, as for an unsaved form: only the actions close it.
public struct QeetrixSheetContent<Content: View, Actions: View>: View {
    let title: Text
    let description: Text?
    let intent: QeetrixDialogIntent?
    let isDismissible: Bool
    let onClose: (@MainActor () -> Void)?
    let content: Content
    let actions: Actions
    @Environment(\.dismiss) private var dismiss

    public init(
        _ titleKey: LocalizedStringKey, description: Text? = nil, intent: QeetrixDialogIntent? = nil, isDismissible: Bool = true,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: Text(titleKey), description: description, intent: intent, isDismissible: isDismissible, onClose: onClose,
            content: content, actions: actions)
    }

    public init<S: StringProtocol>(
        _ title: S, description: Text? = nil, intent: QeetrixDialogIntent? = nil, isDismissible: Bool = true,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: Text(title), description: description, intent: intent, isDismissible: isDismissible, onClose: onClose,
            content: content, actions: actions)
    }

    public init(
        title: Text, description: Text? = nil, intent: QeetrixDialogIntent? = nil, isDismissible: Bool = true,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.description = description
        self.intent = intent
        self.isDismissible = isDismissible
        self.onClose = onClose
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        let padding = QeetrixSpace.insetXl
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
        }
        .scrollBounceBehavior(.basedOnSize)
        // The header and footer stay put; the body scrolls beneath them, so they carry the surface.
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                if let intent {
                    Rectangle().fill(intent.color).frame(height: QeetrixBorderWidth.accent).accessibilityHidden(true)
                }
                header.padding(padding)
                QeetrixSheetRule()
            }
            .background(QeetrixColor.surfaceOverlay)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                QeetrixSheetRule()
                QeetrixFormActions { actions }
                    .padding(.horizontal, padding)
                    .padding(.vertical, QeetrixSpace.insetLg)
            }
            .background(QeetrixColor.surfaceOverlay)
        }
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: QeetrixSpace.gapSm) {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                title
                    .qeetrixTextStyle(.titleMd)
                    .foregroundStyle(QeetrixColor.textDefault)
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .qeetrixTextStyle(.bodyMd)
                        .foregroundStyle(QeetrixColor.textSubtle)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            if isDismissible {
                QeetrixIconButton(.x, label: QeetrixStrings.close, tone: .neutral, size: .sm) {
                    if let onClose { onClose() } else { dismiss() }
                }
                .padding(.top, -4)
            }
        }
    }
}

/// A drawer section's 1 pt `color.border.subtle` rule.
struct QeetrixSheetRule: View {
    var body: some View {
        Rectangle().fill(QeetrixColor.borderSubtle).frame(height: QeetrixBorderWidth.default).accessibilityHidden(true)
    }
}
