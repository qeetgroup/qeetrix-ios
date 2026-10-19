import SwiftUI

extension View {
    /// Presents contextual content anchored to this view while `isPresented` is true — the web's `Popover`,
    /// as the system popover.
    ///
    /// ```swift
    /// QeetrixIconButton(.info, label: "About roles") { showsHelp = true }
    ///     .qeetrixPopover(isPresented: $showsHelp) {
    ///         QeetrixText("Admins can invite members and manage billing.")
    ///     }
    /// ```
    ///
    /// In a regular-width window — iPad, or an iPhone in landscape where it has the room — it is a
    /// popover with an arrow to this view. In compact width iOS shows it as a sheet, the native form for
    /// contextual content on a small screen; pass `compactAdaptation: .popover` to keep a small popover
    /// there too. A tap outside or Escape dismisses it.
    ///
    /// The content sits on the popover surface from `component.popover.*`, with 16 pt padding and the
    /// web's 288 pt width as its ideal. Don't put urgent warnings or destructive confirmations in a
    /// popover: use a ``QeetrixAlertDialog`` or a ``QeetrixConfirmationDialog``.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the popover is shown; set back to `false` when it is dismissed.
    ///   - arrowEdge: The edge of this view the arrow points at, where there is room.
    ///   - compactAdaptation: How it is shown in compact width: `.automatic` (a sheet) or `.popover`.
    ///   - content: The popover's content.
    public func qeetrixPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .top,
        compactAdaptation: PresentationAdaptation = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            QeetrixPopoverSurface(compactAdaptation: compactAdaptation) { content() }
        }
    }
}

struct QeetrixPopoverSurface<Content: View>: View {
    let compactAdaptation: PresentationAdaptation
    let content: Content

    init(compactAdaptation: PresentationAdaptation, @ViewBuilder content: () -> Content) {
        self.compactAdaptation = compactAdaptation
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(2)) {
            content
        }
        .qeetrixType(QeetrixSheetMetrics.bodyType)  // text-sm
        .foregroundStyle(QeetrixPopoverTokens.foreground)
        .padding(QeetrixWebScale.spacing(4))  // p-4
        .frame(idealWidth: QeetrixWebScale.spacing(72), alignment: .leading)  // w-72
        .fixedSize(horizontal: false, vertical: true)
        .presentationCompactAdaptation(compactAdaptation)
        .presentationBackground(QeetrixPopoverTokens.background)
        .presentationDetents([.medium, .large])  // when shown as a sheet
    }
}
