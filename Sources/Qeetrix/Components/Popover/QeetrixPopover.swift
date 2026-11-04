import SwiftUI

extension View {
    /// Presents contextual content anchored to this view while `isPresented` is true — `@qeetrix/react`'s
    /// Popover, as the system popover (ADR 0014).
    ///
    /// ```swift
    /// QeetrixIconButton(.info, label: "About roles", tone: .neutral) { showsHelp = true }
    ///     .qeetrixPopover(isPresented: $showsHelp, title: Text("Roles"), description: Text("Who can do what.")) {
    ///         QeetrixText("Admins can invite members and manage billing.")
    ///     }
    /// ```
    ///
    /// The content sits on `color.surface.overlay` with 16 pt padding (`space.inset.lg`) and 12 pt
    /// between its parts, at most 360 pt wide, under an optional title (`title.sm`) and description
    /// (`body.md`, `color.text.subtle`, 4 pt under it) — the title names it for VoiceOver. In a
    /// regular-width window — iPad, or an iPhone in landscape where it has the room — it is the system
    /// popover, whose arrow and frame iOS draws (the web's popover has neither arrow nor pointer). In
    /// compact width — a portrait iPhone — iOS shows it as a sheet, the native form for contextual content
    /// on a small screen; pass `compactAdaptation: .popover` to keep a small popover there too. In compact
    /// height — any iPhone in landscape — it stays a popover. A tap outside or Escape
    /// dismisses it. Don't put urgent warnings or destructive confirmations in a popover: use a
    /// ``QeetrixAlertDialog`` or a ``QeetrixConfirmationDialog``.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the popover is shown; set back to `false` when it is dismissed.
    ///   - title: Names the popover.
    ///   - description: A line under the title.
    ///   - arrowEdge: The edge of this view the system's arrow points at, where there is room.
    ///   - compactAdaptation: How it is shown in compact width (portrait iPhone): `.automatic` (a sheet)
    ///     or `.popover`.
    ///   - content: The popover's content.
    public func qeetrixPopover<Content: View>(
        isPresented: Binding<Bool>,
        title: Text? = nil,
        description: Text? = nil,
        arrowEdge: Edge = .top,
        compactAdaptation: PresentationAdaptation = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            QeetrixPopoverSurface(title: title, description: description, compactAdaptation: compactAdaptation) { content() }
        }
    }
}

/// The popover's content (popover.css).
struct QeetrixPopoverSurface<Content: View>: View {
    let title: Text?
    let description: Text?
    let compactAdaptation: PresentationAdaptation
    let content: Content

    /// `max-inline-size: min(360px, …)`.
    static var maximumWidth: CGFloat { 360 }

    init(title: Text? = nil, description: Text? = nil, compactAdaptation: PresentationAdaptation, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.compactAdaptation = compactAdaptation
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            if title != nil || description != nil {
                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    if let title {
                        title
                            .qeetrixTextStyle(.titleSm)
                            .foregroundStyle(QeetrixColor.textDefault)
                            .accessibilityAddTraits(.isHeader)
                    }
                    if let description {
                        description
                            .qeetrixTextStyle(.bodyMd)
                            .foregroundStyle(QeetrixColor.textSubtle)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            content
        }
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
        .foregroundStyle(QeetrixColor.textDefault)
        .padding(QeetrixSpace.insetLg)
        // Ideal and maximum 360 pt, so text wraps there instead of laying out on one line.
        .frame(idealWidth: Self.maximumWidth, maxWidth: Self.maximumWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        // Shown as a sheet (compact width), the content starts at the top, as a sheet's does.
        .frame(maxHeight: .infinity, alignment: .top)
        // In compact height (an iPhone in landscape) `.automatic` covers the screen, with no grabber
        // and nothing outside to tap: there it stays a popover.
        .presentationCompactAdaptation(horizontal: compactAdaptation, vertical: .popover)
        .presentationBackground(QeetrixColor.surfaceOverlay)
        .presentationDetents([.medium, .large])  // when shown as a sheet
    }
}
