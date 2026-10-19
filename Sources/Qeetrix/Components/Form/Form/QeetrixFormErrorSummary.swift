import SwiftUI

/// A summary of a form's errors after a failed submit — the web's `FormErrorSummary`.
///
/// ```swift
/// @FocusState private var focus: Field?
///
/// QeetrixFormErrorSummary(errors: [
///     .init(id: "email", message: "Enter a valid email address.") { focus = .email },
///     .init(id: "password", message: "Enter a password.") { focus = .password },
/// ])
/// ```
///
/// Each error is a link: tapping it runs its action, which should move focus to the field it is about.
/// The summary draws nothing while there are no errors. When errors appear or change, VoiceOver announces
/// the heading and the errors, as the web's `role="alert"` does. Each field should still show its own
/// message; the summary adds the overview, it does not replace them. What counts as an error is the app's.
public struct QeetrixFormErrorSummary: View {
    /// One error in the summary.
    public struct Item: Identifiable {
        public let id: String
        /// The error, already localised.
        public let message: String
        let action: @MainActor () -> Void

        /// - Parameters:
        ///   - id: Identifies the error, usually by the field it is about.
        ///   - message: The error, already localised.
        ///   - action: Runs when the error is tapped — typically moving focus to its field.
        public init(id: String, message: String, action: @escaping @MainActor () -> Void) {
            self.id = id
            self.message = message
            self.action = action
        }
    }

    let title: String?
    let errors: [Item]

    /// - Parameters:
    ///   - title: The heading, already localised; "There is a problem" when `nil`.
    ///   - errors: The errors, in the order of the fields they are about.
    public init(title: String? = nil, errors: [Item]) {
        self.title = title
        self.errors = errors
    }

    public var body: some View {
        if !errors.isEmpty {
            let shape = RoundedRectangle(cornerRadius: QeetrixCorner.control)  // rounded-lg
            HStack(alignment: .top, spacing: QeetrixWebScale.spacing(2.5)) {  // gap-2.5
                QeetrixIcon(.circleAlert, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // size-4
                    .foregroundStyle(QeetrixColor.textDanger)
                    .padding(.top, QeetrixWebScale.spacing(0.5))  // mt-0.5
                VStack(alignment: .leading, spacing: 0) {  // mt-2, within the first 44 pt row
                    (title.map { Text(verbatim: $0) } ?? QeetrixStrings.errorSummaryTitle)
                        .qeetrixType(QeetrixFormMetrics.titleType)
                        .foregroundStyle(QeetrixColor.textDanger)
                        .accessibilityAddTraits(.isHeader)
                    VStack(alignment: .leading, spacing: 0) {  // space-y-1, within the 44 pt rows
                        ForEach(errors) { error in
                            QeetrixFormErrorLink(error: error)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(QeetrixWebScale.spacing(4))  // p-4
            .background(QeetrixColor.feedbackErrorSubtle, in: shape)  // bg-destructive-subtle
            .overlay { shape.strokeBorder(QeetrixColor.borderDanger, lineWidth: QeetrixStroke.hairline) }
            .accessibilityElement(children: .contain)
            .onAppear { announce() }
            .onChange(of: errors.map(\.id)) { _, _ in announce() }
        }
    }

    private func announce() {
        let heading = title ?? QeetrixStrings.errorSummaryTitleString
        AccessibilityNotification.Announcement(([heading] + errors.map(\.message)).joined(separator: ". ")).post()
    }
}

/// An error as a link-styled button: a bullet, then the message, medium and underlined in the danger text
/// colour.
private struct QeetrixFormErrorLink: View {
    let error: QeetrixFormErrorSummary.Item

    var body: some View {
        Button(action: error.action) {
            HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(2)) {
                Text(verbatim: "•").accessibilityHidden(true)  // list-disc, marker:text-destructive-text
                Text(verbatim: error.message)
                    .underline()
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .qeetrixType(QeetrixFormMetrics.linkType)
            .foregroundStyle(QeetrixColor.textDanger)
            .padding(.leading, QeetrixWebScale.spacing(1))
            // A full 44 pt row rather than an extended hit area: the links sit 4 pt apart, and extended
            // targets would overlap, sending a tap to the neighbouring error.
            .frame(maxWidth: .infinity, minHeight: QeetrixAccessibility.minimumTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .fixedSize(horizontal: false, vertical: true)
    }
}

enum QeetrixFormMetrics {
    /// `text-sm font-semibold`.
    static let titleType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .semibold, scalesLike: .subheadline)
    /// `text-sm font-medium`.
    static let linkType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
}
