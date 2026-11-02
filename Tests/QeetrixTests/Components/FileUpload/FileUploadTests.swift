import Foundation
import SwiftUI
import Testing
import UniformTypeIdentifiers

@testable import Qeetrix

@MainActor
@Suite("File upload")
struct FileUploadTests {
    static let english = Locale(identifier: "en_IN")

    static func file(
        _ name: String, size: Int64 = 1_000, type: UTType? = nil, status: QeetrixFileUploadStatus = .chosen
    )
        -> QeetrixFileUploadItem
    {
        QeetrixFileUploadItem(id: name, name: name, size: size, contentType: type, status: status)
    }

    @Test("The types are named as people name them, joined with \"or\", families left out")
    func typeNames() {
        #expect(QeetrixFileLimits(allowedContentTypes: [.pdf, .png]).typeNames(locale: Self.english) == "PDF or PNG")
        #expect(QeetrixFileLimits(allowedContentTypes: [.xml]).typeNames(locale: Self.english) == "XML")
        #expect(
            QeetrixFileLimits(allowedContentTypes: [.pdf, .image, .commaSeparatedText, .pdf]).typeNames(locale: Self.english)
                == "PDF or CSV",
            "image/* is left out, as on the web, and PDF named once")
        #expect(QeetrixFileLimits(allowedContentTypes: [.image]).typeNames(locale: Self.english) == nil)
        #expect(QeetrixFileLimits().typeNames(locale: Self.english) == nil)
    }

    @Test("The hint is fileUpload.hint, hintSize, the types alone, or nothing")
    func hint() {
        #expect(
            QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000).hint(locale: Self.english)
                == "PDF or PNG, up to 10 MB")
        #expect(QeetrixFileLimits(allowedContentTypes: [.xml], maxSize: 1_000_000).hint(locale: Self.english) == "XML, up to 1 MB")
        #expect(QeetrixFileLimits(maxSize: 1_500_000).hint(locale: Self.english) == "Up to 1.5 MB")
        #expect(QeetrixFileLimits(allowedContentTypes: [.json]).hint(locale: Self.english) == "JSON")
        #expect(QeetrixFileLimits().hint(locale: Self.english) == nil)
    }

    @Test("A file passes by its type, or the type its extension names, conforming to an allowed one")
    func accepts() {
        let images = QeetrixFileLimits(allowedContentTypes: [.image])
        #expect(images.accepts(name: "IMG_0001.HEIC", contentType: nil))
        #expect(images.accepts(name: "photo", contentType: .jpeg), "A photo's type, whatever its name")
        #expect(!images.accepts(name: "invoice.pdf", contentType: .pdf))
        let documents = QeetrixFileLimits(allowedContentTypes: [.pdf, .commaSeparatedText])
        #expect(documents.accepts(name: "users.CSV", contentType: nil))
        #expect(!documents.accepts(name: "notes", contentType: nil), "No extension and no type: unknown")
        #expect(QeetrixFileLimits().accepts(name: "anything.bin", contentType: nil))
    }

    @Test("Refused files get the web's reasons: wrong type, not allowed, too big, too many")
    func problems() {
        let limits = QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)
        #expect(limits.problem(for: Self.file("notes.txt"), locale: Self.english) == "Only PDF or PNG files can be used here")
        #expect(limits.problem(for: Self.file("scan.pdf", size: 12_000_000), locale: Self.english) == "Larger than 10 MB")
        #expect(limits.problem(for: Self.file("scan.pdf", size: 10_000_000), locale: Self.english) == nil, "Up to the limit")
        #expect(
            QeetrixFileLimits(allowedContentTypes: [.image]).problem(for: Self.file("scan.pdf"), locale: Self.english)
                == "This kind of file can't be used here", "No type has a name to list")
        let one = QeetrixFileLimits(allowedContentTypes: [.pdf])
        #expect(
            one.problems(for: [Self.file("a.pdf"), Self.file("b.pdf"), Self.file("c.txt")], locale: Self.english) == [
                nil, "Choose one file at a time", "Choose one file at a time",
            ])
        let several = QeetrixFileLimits(allowedContentTypes: [.pdf], allowsMultiple: true)
        #expect(
            several.problems(for: [Self.file("a.pdf"), Self.file("c.txt")], locale: Self.english) == [
                nil, "Only PDF files can be used here",
            ])
    }

    @Test("A choice's files are sorted: the passing ones join, the others carry their reason")
    func intake() {
        let intake = QeetrixFileUploadIntake(limits: QeetrixFileLimits(maxSize: 5_000, allowsMultiple: true), locale: Self.english)
        let sorted = intake.sort([Self.file("a.pdf"), Self.file("big.mov", size: 9_000), Self.file("b.png")])
        #expect(sorted.accepted.map(\.name) == ["a.pdf", "b.png"])
        #expect(sorted.accepted.allSatisfy { $0.status == .chosen })
        #expect(sorted.refused.map(\.status) == [.error("Larger than 5 kB")])
    }

    @Test("Each picker is offered only where its files can pass")
    func offers() {
        #expect(QeetrixFileLimits().libraryKinds == (true, true))
        #expect(QeetrixFileLimits(allowedContentTypes: [.png]).libraryKinds == (true, false), "A PNG may be in the library")
        #expect(QeetrixFileLimits(allowedContentTypes: [.movie]).libraryKinds == (false, true))
        #expect(QeetrixFileLimits(allowedContentTypes: [.pdf, .xml]).libraryKinds == (false, false))
        #expect(QeetrixFileLimits().acceptsPhotos && QeetrixFileLimits(allowedContentTypes: [.image]).acceptsPhotos)
        #expect(!QeetrixFileLimits(allowedContentTypes: [.png]).acceptsPhotos, "The camera's JPEG can't pass")
        #expect(QeetrixFileLimits().importableTypes == [.item])
        #expect(QeetrixFileLimits(allowedContentTypes: [.pdf]).importableTypes == [.pdf])

        let documents = QeetrixFileUpload("Metadata", files: .constant([]), allowedContentTypes: [.xml])
        #expect(documents.offered == [.files] && documents.libraryFilter == nil)
        let anything = QeetrixFileUpload("Receipts", files: .constant([]))
        #expect(anything.offered.first == .photos && anything.offered.last == .files)
        #expect(!QeetrixFileUploadCameraAvailability.isAvailable || anything.offered.contains(.camera))
        #expect(QeetrixFileUpload("Receipts", files: .constant([]), sources: .files).offered == [.files])
        #expect(QeetrixFileUploadSources.all == [.photos, .camera, .files])
    }

    @Test("Each file's icon is the web's, by extension, then by type")
    func icons() {
        #expect(QeetrixFileUploadIcon.name(for: Self.file("logo.svg")) == .fileImage)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("users.xlsx")) == .fileSpreadsheet)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("idp-metadata.xml")) == .fileCode)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("backup.tgz")) == .fileArchive)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("contract.pdf")) == .fileText)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("IMG_0001.HEIC")) == .fileImage, "A photo's type: image")
        #expect(QeetrixFileUploadIcon.name(for: Self.file("export", type: .commaSeparatedText)) == .fileSpreadsheet)
        #expect(QeetrixFileUploadIcon.name(for: Self.file("README")) == .fileText)
    }

    @Test("A row shows the size, or a failed file's reason, and how the upload ended")
    func row() {
        let failed = QeetrixFileRow(Self.file("a.pdf", status: .error("The connection was lost")))
        #expect(failed.meta == "The connection was lost")
        #expect(QeetrixFileRowOutcome(.done) == .done && QeetrixFileRowOutcome(.error("x")) == .failed)
        #expect(QeetrixFileRowOutcome(.chosen) == nil && QeetrixFileRowOutcome(.uploading(progress: 0.4)) == nil)
        #expect(QeetrixFileRowOutcome.done.color == .textSuccess && QeetrixFileRowOutcome.failed.color == .textDanger)
        #expect(QeetrixFileRowOutcome.done.icon == .circleCheck && QeetrixFileRowOutcome.failed.icon == .circleAlert)
    }

    @Test("The built-in words are react's fileUpload messages")
    func strings() {
        #expect(QeetrixFileUploadStrings.uploading("invoice.pdf") == "Uploading invoice.pdf")
        #expect(QeetrixFileUploadStrings.remove("invoice.pdf") == "Remove invoice.pdf")
        #expect(QeetrixFileUploadStrings.uploaded == "Uploaded")
        #expect(QeetrixFileUploadStrings.failed == "Not uploaded")
        #expect(QeetrixFileUploadStrings.tooMany == "Choose one file at a time")
        #expect(QeetrixFileUpload.summary(name: "a.pdf", outcome: "Uploaded") == "a.pdf, Uploaded")
    }

    @Test("The zone: the neutral fill in a dashed strong edge; Ember while dragged over; danger when invalid")
    func zone() {
        let resting = QeetrixFileUploadZoneColors(isEnabled: true, isTargeted: false, isInvalid: false)
        #expect(resting.background == .bgNeutralSubtle && resting.border == .borderStrong && resting.icon == .iconSubtle)
        let dragged = QeetrixFileUploadZoneColors(isEnabled: true, isTargeted: true, isInvalid: true)
        #expect(dragged.background == .bgSelected && dragged.border == .borderBrand && dragged.icon == .iconBrand)
        #expect(QeetrixFileUploadZoneColors(isEnabled: true, isTargeted: false, isInvalid: true).border == .borderDanger)
        let disabled = QeetrixFileUploadZoneColors(isEnabled: false, isTargeted: false, isInvalid: true)
        #expect(disabled.background == .bgDisabled && disabled.border == .borderDisabled && disabled.text == .textDisabled)
        #expect(
            QeetrixFileUploadZoneColors.dashes.lineWidth == QeetrixBorderWidth.default && !QeetrixFileUploadZoneColors.dashes.dash.isEmpty)
    }

    @Test("The zone and the rows keep their contrast, in both schemes")
    func contrast() {
        // (foreground, background, minimum): the dashed edge on the page and on a card (3:1), the danger
        // and Ember edges, the icon, the ghost buttons' text and the hint on the zone's fill, "Drop to
        // upload" and the Ember icon on the dragged fill, and the rows' states on the page and a card.
        let pairs: [(QeetrixColor, QeetrixColor, Double)] = [
            (.borderStrong, .surfaceCanvas, 3), (.borderStrong, .surfaceRaised, 3), (.borderDanger, .surfaceCanvas, 3),
            (.borderBrand, .surfaceCanvas, 3), (.iconSubtle, .bgNeutralSubtle, 3), (.textBrand, .bgNeutralSubtle, 4.5),
            (.textBrand, .bgBrandSubtlePressed, 4.5), (.textSubtle, .bgNeutralSubtle, 4.5), (.textDefault, .bgSelected, 4.5),
            (.iconBrand, .bgSelected, 3), (.iconSubtle, .surfaceCanvas, 3), (.textSubtle, .surfaceCanvas, 4.5),
            (.textSuccess, .surfaceCanvas, 4.5), (.textDanger, .surfaceCanvas, 4.5), (.textSuccess, .surfaceRaised, 4.5),
            (.textDanger, .surfaceRaised, 4.5),
        ]
        for theme in [QeetrixTheme.light, .dark] {
            for (foreground, background, minimum) in pairs {
                let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(foreground), on: theme.resolve(background))
                #expect(ratio >= minimum, "\(foreground) on \(background), \(theme.colorScheme): \(ratio)")
            }
        }
    }

    @Test("Chosen files are copied into a folder each, read for their size and type, and a refused copy is deleted")
    func storage() throws {
        let source = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-test-\(UUID().uuidString).pdf")
        try Data(repeating: 7, count: 2_048).write(to: source)
        defer { try? FileManager.default.removeItem(at: source) }
        let first = try QeetrixFileUploadStorage.keep(source)
        let second = try QeetrixFileUploadStorage.keep(source)
        #expect(first != second && first.lastPathComponent == source.lastPathComponent, "Same name, own folders")
        #expect(first.path.hasPrefix(QeetrixFileUploadStorage.folder.path))
        let item = QeetrixFileUploadStorage.item(at: first)
        #expect(item.name == source.lastPathComponent && item.size == 2_048 && item.contentType == .pdf && item.status == .chosen)
        QeetrixFileUploadStorage.discard(first)
        QeetrixFileUploadStorage.discard(second)
        #expect(!FileManager.default.fileExists(atPath: first.path) && !FileManager.default.fileExists(atPath: second.path))
        QeetrixFileUploadStorage.discard(source)
        #expect(FileManager.default.fileExists(atPath: source.path), "Only Qeetrix's own copies are deleted")
    }

    @Test("A photo is named as a camera names one")
    func photoName() throws {
        let date = try #require(
            Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 30, hour: 14, minute: 15, second: 2)))
        let url = try QeetrixFileUploadStorage.keepPhoto(Data([0xFF, 0xD8, 0xFF]), takenAt: date)
        defer { QeetrixFileUploadStorage.discard(url) }
        #expect(url.lastPathComponent == "IMG_20261030_141502.jpg")
        #expect(QeetrixFileUploadStorage.item(at: url).contentType == .jpeg)
    }

    @Test("Every state renders, light and dark: empty, files in each state, refused, invalid and disabled")
    func renders() {
        let files = [
            Self.file("invoice-october.pdf", size: 248_000, type: .pdf),
            Self.file("receipt.png", size: 1_400_000, type: .png, status: .uploading(progress: 0.42)),
            Self.file("statement.csv", size: 12_000, status: .uploading(progress: nil)),
            Self.file("users.xlsx", size: 88_000, status: .done),
            Self.file("backup.zip", size: 4_000_000, status: .error("The connection was lost. Try again.")),
        ]
        for scheme in [ColorScheme.light, .dark] {
            let views: [AnyView] = [
                AnyView(QeetrixFileUpload("Receipts", files: .constant([]), allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)),
                AnyView(QeetrixFileUpload("Receipts", files: .constant(files), allowsMultiple: true) { _ in }),
                AnyView(QeetrixFileUpload("Logo", files: .constant([]), error: "Add your logo", isRequired: true)),
                AnyView(QeetrixFileUpload("Logo", files: .constant(files), isOptional: true).disabled(true)),
                AnyView(VStack { ForEach(files) { QeetrixFileRow($0) {} } }),
            ]
            for view in views {
                #expect(ImageRenderer(content: view.frame(width: 390).environment(\.colorScheme, scheme)).cgImage != nil)
            }
        }
    }
}
