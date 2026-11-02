import SwiftUI

/// One file — `@qeetrix/react` FileUpload's row (file-upload.css `.qx-file-upload-item`): its type's
/// icon, its name over its size or the reason it failed, its state, and Remove.
///
/// ```swift
/// QeetrixFileRow(invoice) { remove(invoice) }
/// ```
///
/// ``QeetrixFileUpload`` lists its files in these rows; use one on its own for a file shown elsewhere,
/// such as a message's attachment.
///
/// - **The icon**: a sharp 20 pt `file-image`, `file-spreadsheet`, `file-code`, `file-archive` or
///   `file-text` in `color.icon.subtle`, by the name's extension as on the web, then by the file's type.
/// - **The name** in `label.md`, wrapping; under it the size (``QeetrixFormat/fileSize(_:locale:)``) or,
///   for a file that failed, the reason, in `body.sm` and `color.text.subtle`.
/// - **The state**, under them: a ``QeetrixProgress`` while it uploads ("Uploading invoice.pdf" to
///   VoiceOver); a sharp `circle-check` and "Uploaded" in `color.text.success`; a sharp `circle-alert`
///   and "Not uploaded" in `color.text.danger`. Nothing while it is only chosen.
/// - **Remove**, with `onRemove`: a neutral `sm` ``QeetrixIconButton`` with a sharp `x`, named "Remove
///   invoice.pdf".
///
/// At least the density's `size.row` and 44 pt tall, `space.gap.xs` above and below, `space.inset.sm`
/// before the icon and `space.gap.xs` after Remove. VoiceOver reads the name, the size or reason and
/// the state as one element, then the progress bar and Remove.
public struct QeetrixFileRow: View {
    let item: QeetrixFileUploadItem
    let messages: QeetrixFileUploadMessages
    let onRemove: (@MainActor () -> Void)?
    @Environment(\.locale) private var locale
    @Environment(\.qeetrixDensity) private var density

    /// A row for `item`; `onRemove` adds its Remove button.
    public init(
        _ item: QeetrixFileUploadItem, messages: QeetrixFileUploadMessages = QeetrixFileUploadMessages(),
        onRemove: (@MainActor () -> Void)? = nil
    ) {
        self.item = item
        self.messages = messages
        self.onRemove = onRemove
    }

    public var body: some View {
        // .qx-file-upload-item: gap.sm between the parts, centred on the row.
        HStack(spacing: QeetrixSpace.gapSm) {
            QeetrixIcon(QeetrixFileUploadIcon.name(for: item), size: .md, shape: .sharp)
                .foregroundStyle(QeetrixColor.iconSubtle)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: item.name)
                        .qeetrixTextStyle(.labelMd)
                        .foregroundStyle(QeetrixColor.textDefault)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(verbatim: meta)
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .fixedSize(horizontal: false, vertical: true)
                    if let outcome = QeetrixFileRowOutcome(item.status) {
                        outcomeLabel(outcome)
                            .padding(.top, QeetrixSpace.gapXs)
                    }
                }
                .accessibilityElement(children: .combine)
                if case let .uploading(progress) = item.status {
                    QeetrixProgress(label: nil, value: progress.map { min(max($0, 0), 1) })
                        .accessibilityLabel(Text(verbatim: QeetrixFileUploadStrings.uploading(item.name)))
                        .padding(.top, QeetrixSpace.gapXs)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let onRemove {
                QeetrixIconButton(
                    .x, label: Text(verbatim: QeetrixFileUploadStrings.remove(item.name)), tone: .neutral, size: .sm, action: onRemove)
            }
        }
        .padding(.vertical, QeetrixSpace.gapXs)
        // padding-inline: inset.sm gap.xs.
        .padding(.leading, QeetrixSpace.insetSm)
        .padding(.trailing, QeetrixSpace.gapXs)
        .frame(maxWidth: .infinity, minHeight: QeetrixListItemMetrics.minimumHeight(density), alignment: .leading)
    }

    /// The line under the name: the reason a failed file failed, or its size.
    var meta: String {
        if case let .error(reason) = item.status, !reason.isEmpty { return reason }
        return QeetrixFormat.fileSize(item.size, locale: locale)
    }

    private func outcomeLabel(_ outcome: QeetrixFileRowOutcome) -> some View {
        // .qx-file-upload-status: label.sm, gap.xs after a 16 pt sharp icon, in the state's colour. The
        // icon is the line's height, so it tops the text as a field error's icon does.
        let text =
            switch outcome {
            case .done: messages.uploaded ?? QeetrixFileUploadStrings.uploaded
            case .failed: messages.failed ?? QeetrixFileUploadStrings.failed
            }
        return HStack(alignment: .top, spacing: QeetrixSpace.gapXs) {
            QeetrixIcon(outcome.icon, size: .sm, shape: .sharp, relativeTo: .footnote)
            Text(verbatim: text)
                .qeetrixTextStyle(.labelSm)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(outcome.color)
    }
}

/// How a file's upload ended, as its row shows it.
enum QeetrixFileRowOutcome: Equatable {
    case done
    case failed

    init?(_ status: QeetrixFileUploadStatus) {
        switch status {
        case .done: self = .done
        case .error: self = .failed
        case .chosen, .uploading: return nil
        }
    }

    var icon: QeetrixIconName {
        self == .done ? .circleCheck : .circleAlert
    }

    /// `[data-status="done"]`: `text.success`; `[data-status="error"]`: `text.danger`.
    var color: QeetrixColor {
        self == .done ? .textSuccess : .textDanger
    }
}
