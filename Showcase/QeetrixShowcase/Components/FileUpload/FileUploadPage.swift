import Qeetrix
import SwiftUI
import UniformTypeIdentifiers

/// Receipts chosen from Photos, the camera or Files and "uploaded" with progress, a single metadata file
/// with type and size limits, the rows in every state, and the disabled picker.
struct FileUploadPage: View {
    @State private var receipts: [QeetrixFileUploadItem] = []
    @State private var metadata: [QeetrixFileUploadItem] = []
    @State private var uploads: [String: Task<Void, Never>] = [:]

    private static let rows = [
        QeetrixFileUploadItem(id: "1", name: "invoice-october-2026.pdf", size: 248_000, contentType: .pdf),
        QeetrixFileUploadItem(id: "2", name: "receipt.png", size: 1_400_000, status: .uploading(progress: 0.42)),
        QeetrixFileUploadItem(id: "3", name: "users.csv", size: 12_000, status: .uploading(progress: nil)),
        QeetrixFileUploadItem(id: "4", name: "idp-metadata.xml", size: 8_200, status: .done),
        QeetrixFileUploadItem(id: "5", name: "backup.zip", size: 4_000_000, status: .error("The connection was lost. Try again.")),
    ]

    var body: some View {
        ComponentPage(
            title: "File upload",
            summary:
                "Files from Photos, the camera or Files, checked against the type and size limits, each in a row with its upload's state."
        ) {
            DemoSection("Several, uploaded") {
                QeetrixFileUpload(
                    "Receipts", files: $receipts, allowedContentTypes: [.pdf, .jpeg, .png, .heic], maxSize: 10_000_000,
                    allowsMultiple: true,
                    description: Text("One for each expense.")
                ) { chosen in
                    for file in chosen { upload(file) }
                } onRemove: { file in
                    cancel(file)
                }
                QeetrixText("Files: \(receipts.count)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("file-upload-count")
            }
            DemoSection("One file, with limits") {
                QeetrixFileUpload(
                    "Identity provider metadata", files: $metadata, sources: .files, allowedContentTypes: [.xml], maxSize: 1_000_000,
                    error: metadata.isEmpty ? "Add the metadata file your identity provider gave you." : nil, isRequired: true)
            }
            DemoSection("Rows") {
                VStack(spacing: 0) {
                    ForEach(Self.rows) { file in
                        QeetrixFileRow(file) {}
                        QeetrixSeparator()
                    }
                    QeetrixFileRow(QeetrixFileUploadItem(name: "contract-signed-by-both-parties-final-version.pdf", size: 980_000))
                }
            }
            DemoSection("Disabled") {
                QeetrixFileUpload("Logo", files: .constant([]), allowedContentTypes: [.png, .svg], maxSize: 2_000_000)
                    .disabled(true)
            }
        }
    }

    /// Pretends to send `file`: its progress climbs over two seconds, then it's uploaded — or, for a file
    /// over 5 MB, it fails, to show the error.
    private func upload(_ file: QeetrixFileUploadItem) {
        uploads[file.id] = Task {
            for step in 1...10 {
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else { return }
                update(file.id, to: .uploading(progress: Double(step) / 10))
            }
            update(file.id, to: file.size > 5_000_000 ? .error("The server didn't answer. Try again.") : .done)
            uploads[file.id] = nil
        }
    }

    private func update(_ id: String, to status: QeetrixFileUploadStatus) {
        guard let index = receipts.firstIndex(where: { $0.id == id }) else { return }
        receipts[index].status = status
    }

    /// Stops a removed file's upload and deletes its copy.
    private func cancel(_ file: QeetrixFileUploadItem) {
        uploads[file.id]?.cancel()
        uploads[file.id] = nil
        if let url = file.url { try? FileManager.default.removeItem(at: url) }
    }
}

#Preview {
    NavigationStack { FileUploadPage() }
}

#Preview("Large text, dark") {
    NavigationStack { FileUploadPage() }
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}
