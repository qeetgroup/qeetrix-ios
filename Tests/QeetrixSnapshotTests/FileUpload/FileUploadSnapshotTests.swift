#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("File upload snapshots")
    struct FileUploadSnapshotTests {
        static let files = [
            QeetrixFileUploadItem(id: "1", name: "invoice-october-2026.pdf", size: 248_000, contentType: .pdf),
            QeetrixFileUploadItem(id: "2", name: "receipt.png", size: 1_400_000, status: .uploading(progress: 0.42)),
            QeetrixFileUploadItem(id: "3", name: "users.csv", size: 12_000, status: .uploading(progress: nil)),
            QeetrixFileUploadItem(id: "4", name: "idp-metadata.xml", size: 8_200, status: .done),
            QeetrixFileUploadItem(id: "5", name: "backup.zip", size: 4_000_000, status: .error("The connection was lost. Try again.")),
        ]

        @Test("The picker: with the limits' hint, invalid, disabled, a file dragged over it, and copying")
        func picker() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixFileUpload(
                        "Receipts", files: .constant([]), sources: [.photos, .files], allowedContentTypes: [.pdf, .jpeg, .png],
                        maxSize: 10_000_000, allowsMultiple: true, description: Text("Add one for each expense."))
                    QeetrixFileUpload(
                        "Identity provider metadata", files: .constant([]), allowedContentTypes: [.xml], maxSize: 1_000_000,
                        error: "Add the metadata file your identity provider gave you")
                    QeetrixFileUpload("Logo", files: .constant([]), sources: .files, maxSize: 2_000_000).disabled(true)
                    QeetrixFileUploadZone(
                        isTargeted: true, isReceiving: false, isInvalid: false, drop: QeetrixFileUploadStrings.drop,
                        hint: Text(verbatim: "PDF or PNG, up to 10 MB")
                    ) {}
                    QeetrixFileUploadZone(
                        isTargeted: false, isReceiving: true, isInvalid: false, drop: QeetrixFileUploadStrings.drop, hint: nil
                    ) {
                        QeetrixButton(title: QeetrixFileUploadStrings.files, icon: .folder, variant: .ghost) {}
                            .disabled(true)
                    }
                }
            )
        }

        @Test("Rows: chosen, uploading, uploading without a known progress, uploaded, failed, and without Remove")
        func rows() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Self.files) { file in
                        QeetrixFileRow(file) {}
                        QeetrixSeparator()
                    }
                    QeetrixFileRow(QeetrixFileUploadItem(name: "contract-signed-by-both-parties-final-version.pdf", size: 980_000))
                }
            )
        }

        @Test("A field with its files, one in each state")
        func field() {
            assertSpecimen(
                QeetrixFileUpload(
                    "Receipts", files: .constant(Self.files), sources: .files,
                    allowedContentTypes: [.pdf, .png, .xml, .commaSeparatedText],
                    maxSize: 10_000_000, allowsMultiple: true)
            )
        }
    }
#endif
