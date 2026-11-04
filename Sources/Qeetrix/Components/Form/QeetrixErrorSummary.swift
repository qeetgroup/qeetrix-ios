import Accessibility
import SwiftUI

/// What to fix before a form can be submitted, as `@qeetrix/react`'s ErrorSummary (GOV.UK's error
/// summary): the danger ``QeetrixAlert`` at the top of the form, titled "Fix these to continue", with one
/// link per problem, worded exactly as the field's own error.
///
/// ```swift
/// QeetrixErrorSummary(items: [
///     .init(id: "email", message: "Enter a work email") { focus = .email },
///     .init(id: "pan", message: "Enter the PAN as 10 characters") { focus = .pan },
/// ])
/// ```
///
/// Show it after a submit that fails validation, or when server errors arrive, and remove it once a
/// submit succeeds. Each link's action should scroll to its field and focus it. The look is the
/// danger Alert (alert.css): `color.bg.danger.subtle` with a 3 pt `color.icon.danger` edge on the
/// start side, a sharp 16 pt alert icon, the title in `label.md` at 600 and the links in
/// `color.text.link`, underlined. Each link is a full 44 pt row, so neighbouring targets never
/// overlap. When it appears or changes, VoiceOver announces the title and every problem, as the
/// web's `role="alert"` does; `headingLevel` sets the title's heading level (2 by default).
public struct QeetrixErrorSummary: View {
    /// One problem: the field it belongs to, its message, and what following the link does.
    public struct Item: Identifiable {
        public let id: String
        public let message: String
        let action: @MainActor () -> Void

        public init(id: String, message: String, action: @escaping @MainActor () -> Void) {
            self.id = id
            self.message = message
            self.action = action
        }
    }

    let title: String?
    let headingLevel: Int
    let items: [Item]

    public init(title: String? = nil, headingLevel: Int = 2, items: [Item]) {
        self.title = title
        self.headingLevel = headingLevel
        self.items = items
    }

    public var body: some View {
        if !items.isEmpty {
            QeetrixAlertSurface(tone: .danger) {
                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    (title.map { Text(verbatim: $0) } ?? QeetrixStrings.errorSummaryTitle)
                        .qeetrixType(QeetrixAlertSurface<EmptyView>.titleType)
                        .foregroundStyle(QeetrixColor.textDefault)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(QeetrixHeading.accessibilityLevel(headingLevel))
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(items) { item in
                            QeetrixErrorSummaryLink(item: item)
                        }
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .onAppear { announce() }
            .onChange(of: items.map(\.id)) { _, _ in announce() }
        }
    }

    private func announce() {
        let heading = title ?? QeetrixStrings.errorSummaryTitleString
        AccessibilityNotification.Announcement(([heading] + items.map(\.message)).joined(separator: ". ")).post()
    }
}

private struct QeetrixErrorSummaryLink: View {
    let item: QeetrixErrorSummary.Item

    var body: some View {
        Button(action: item.action) {
            Text(verbatim: item.message)
                .underline()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .qeetrixTextStyle(.bodyMd)
                .foregroundStyle(QeetrixColor.textLink)
                // A full 44 pt row rather than an extended hit area: the links sit 4 pt apart, and
                // extended targets would overlap, sending a tap to the neighbouring error.
                .frame(maxWidth: .infinity, minHeight: QeetrixAccessibility.minimumTouchTarget, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .fixedSize(horizontal: false, vertical: true)
    }
}
