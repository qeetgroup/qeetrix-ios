import SwiftUI
import UniformTypeIdentifiers

/// The checks a ``QeetrixFileUpload`` runs on every file chosen or dropped, and the web's words for
/// them — `@qeetrix/react` FileUpload's `accept`, `maxSize` and `multiple`, and its `fileUpload`
/// messages: "PDF or PNG, up to 10 MB", "Only PDF or PNG files can be used here", "Larger than 10 MB".
///
/// ```swift
/// let limits = QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)
/// limits.hint(locale: locale)                      // "PDF or PNG, up to 10 MB"
/// limits.problem(for: file, locale: locale)        // nil, or why the file can't be used
/// ```
///
/// Use it to check a file the app gets another way — from a share extension, say — with the same words.
public struct QeetrixFileLimits: Hashable, Sendable {
    /// The types allowed, as `fileImporter` takes them: a file passes when its type conforms to one.
    /// Empty allows any file.
    public var allowedContentTypes: [UTType]
    /// The largest file allowed, in bytes.
    public var maxSize: Int64?
    /// Whether one choice can bring several files; otherwise each file after the first is refused.
    public var allowsMultiple: Bool

    /// Limits on type, size and number.
    public init(allowedContentTypes: [UTType] = [], maxSize: Int64? = nil, allowsMultiple: Bool = false) {
        self.allowedContentTypes = allowedContentTypes
        self.maxSize = maxSize
        self.allowsMultiple = allowsMultiple
    }

    /// The allowed types in words, as people name them — `[.xml, .json]` is "XML or JSON" — or `nil`.
    /// A family with no file extension of its own (`.image`) is left out, as the web leaves out
    /// "image/*".
    public func typeNames(locale: Locale = .current) -> String? {
        var names: [String] = []
        for type in allowedContentTypes {
            guard let name = type.preferredFilenameExtension?.uppercased(), !names.contains(name) else { continue }
            names.append(name)
        }
        return names.isEmpty ? nil : names.formatted(.list(type: .or).locale(locale))
    }

    /// The line under the picker: "XML, up to 1 MB" (`fileUpload.hint`), "Up to 1 MB" (`hintSize`), the
    /// types alone, or `nil` without limits.
    public func hint(locale: Locale = .current) -> String? {
        let types = typeNames(locale: locale)
        guard let maxSize else { return types }
        let size = QeetrixFormat.fileSize(maxSize, locale: locale)
        if let types { return QeetrixFileUploadStrings.hint(types: types, size: size, locale: locale) }
        return QeetrixFileUploadStrings.hintSize(size, locale: locale)
    }

    /// Whether a file of this name and type passes the type check: its type, or the type its extension
    /// names, conforms to an allowed one.
    public func accepts(name: String, contentType: UTType?) -> Bool {
        guard !allowedContentTypes.isEmpty else { return true }
        let extensionType = UTType(filenameExtension: (name as NSString).pathExtension)
        return [contentType, extensionType].compactMap { $0 }.contains { type in
            allowedContentTypes.contains { type.conforms(to: $0) }
        }
    }

    /// Why `file` can't be used — "Only PDF or PNG files can be used here" (`fileUpload.wrongType`),
    /// "This kind of file can't be used here" (`notAllowed`, when no type has a name), "Larger than
    /// 10 MB" (`tooBig`) — or `nil` when it can.
    public func problem(for file: QeetrixFileUploadItem, locale: Locale = .current) -> String? {
        if !accepts(name: file.name, contentType: file.contentType) {
            return typeNames(locale: locale).map { QeetrixFileUploadStrings.wrongType($0, locale: locale) }
                ?? QeetrixFileUploadStrings.notAllowed
        }
        if let maxSize, file.size > maxSize {
            return QeetrixFileUploadStrings.tooBig(QeetrixFormat.fileSize(maxSize, locale: locale), locale: locale)
        }
        return nil
    }

    /// The reason for each of the files one choice brought, in order: as ``problem(for:locale:)``, and
    /// "Choose one file at a time" (`fileUpload.tooMany`) for every file after the first unless
    /// `allowsMultiple`.
    public func problems(for files: [QeetrixFileUploadItem], locale: Locale = .current) -> [String?] {
        files.enumerated().map { index, file in
            !allowsMultiple && index > 0 ? QeetrixFileUploadStrings.tooMany : problem(for: file, locale: locale)
        }
    }

    // MARK: What the pickers offer

    /// Whether a photo from the camera — a JPEG — can pass.
    var acceptsPhotos: Bool { accepts(type: .jpeg) }

    /// What the photo library offers: images, videos, both, or nothing when neither can pass.
    var libraryKinds: (images: Bool, videos: Bool) {
        (accepts(family: .image), accepts(family: .movie))
    }

    /// The types `fileImporter` offers.
    var importableTypes: [UTType] {
        allowedContentTypes.isEmpty ? [.item] : allowedContentTypes
    }

    private func accepts(type: UTType) -> Bool {
        allowedContentTypes.isEmpty || allowedContentTypes.contains { type.conforms(to: $0) }
    }

    /// Whether any allowed type is in `family`, or contains it: `.png` and `.image` both admit photos.
    private func accepts(family: UTType) -> Bool {
        allowedContentTypes.isEmpty || allowedContentTypes.contains { $0.conforms(to: family) || family.conforms(to: $0) }
    }
}

/// A file's icon (file-upload.tsx `iconFor`): by its name's extension, as the web reads it, then — for
/// a file whose name says nothing, such as a photo — by its type.
enum QeetrixFileUploadIcon {
    static let images: Set<String> = ["png", "jpg", "jpeg", "gif", "svg", "webp", "avif", "ico"]
    static let spreadsheets: Set<String> = ["csv", "tsv", "xls", "xlsx", "ods"]
    static let code: Set<String> = [
        "xml", "json", "yml", "yaml", "htm", "html", "js", "jsx", "ts", "tsx", "css", "pem", "crt", "cer", "key",
    ]
    static let archives: Set<String> = ["zip", "gz", "tgz", "tar", "7z", "rar"]

    static func name(for file: QeetrixFileUploadItem) -> QeetrixIconName {
        let pathExtension = (file.name as NSString).pathExtension.lowercased()
        if images.contains(pathExtension) { return .fileImage }
        if spreadsheets.contains(pathExtension) { return .fileSpreadsheet }
        if code.contains(pathExtension) { return .fileCode }
        if archives.contains(pathExtension) { return .fileArchive }
        guard let type = file.contentType ?? UTType(filenameExtension: pathExtension) else { return .fileText }
        if type.conforms(to: .image) { return .fileImage }
        if type.conforms(to: .spreadsheet) || type.conforms(to: .commaSeparatedText) { return .fileSpreadsheet }
        if type.conforms(to: .sourceCode) || type.conforms(to: .xml) || type.conforms(to: .json) { return .fileCode }
        if type.conforms(to: .archive) { return .fileArchive }
        return .fileText
    }
}

/// The file upload's built-in strings: `@qeetrix/react`'s `fileUpload` messages, and the pickers' names
/// (qeetrix-android's `qx_attach_*`).
enum QeetrixFileUploadStrings {
    static var photos: Text { Text("qeetrix.file-upload.photos", bundle: .module) }
    static var camera: Text { Text("qeetrix.file-upload.camera", bundle: .module) }
    static var files: Text { Text("qeetrix.file-upload.files", bundle: .module) }
    /// "Drop to upload" — `fileUpload.drop`.
    static var drop: Text { Text("qeetrix.file-upload.drop", bundle: .module) }

    /// "Uploaded" — `fileUpload.uploaded`.
    static var uploaded: String {
        String(localized: "qeetrix.file-upload.uploaded", defaultValue: "Uploaded", bundle: .module)
    }

    /// "Not uploaded" — `fileUpload.failed`.
    static var failed: String {
        String(localized: "qeetrix.file-upload.failed", defaultValue: "Not uploaded", bundle: .module)
    }

    /// "Uploading {name}" — `fileUpload.uploading`, the progress bar's name.
    static func uploading(_ name: String) -> String {
        String(localized: "qeetrix.file-upload.uploading", defaultValue: "Uploading \(name)", bundle: .module)
    }

    /// "Remove {name}" — `fileUpload.remove`.
    static func remove(_ name: String) -> String {
        String(localized: "qeetrix.file-upload.remove", defaultValue: "Remove \(name)", bundle: .module)
    }

    /// "{types}, up to {size}" — `fileUpload.hint`.
    static func hint(types: String, size: String, locale: Locale) -> String {
        String(localized: "qeetrix.file-upload.hint", defaultValue: "\(types), up to \(size)", bundle: .module, locale: locale)
    }

    /// "Up to {size}" — `fileUpload.hintSize`.
    static func hintSize(_ size: String, locale: Locale) -> String {
        String(localized: "qeetrix.file-upload.hint-size", defaultValue: "Up to \(size)", bundle: .module, locale: locale)
    }

    /// "Only {types} files can be used here" — `fileUpload.wrongType`.
    static func wrongType(_ types: String, locale: Locale) -> String {
        String(
            localized: "qeetrix.file-upload.wrong-type", defaultValue: "Only \(types) files can be used here", bundle: .module,
            locale: locale)
    }

    /// "This kind of file can't be used here" — `fileUpload.notAllowed`.
    static var notAllowed: String {
        String(localized: "qeetrix.file-upload.not-allowed", defaultValue: "This kind of file can't be used here", bundle: .module)
    }

    /// "Larger than {size}" — `fileUpload.tooBig`.
    static func tooBig(_ size: String, locale: Locale) -> String {
        String(localized: "qeetrix.file-upload.too-big", defaultValue: "Larger than \(size)", bundle: .module, locale: locale)
    }

    /// "Choose one file at a time" — `fileUpload.tooMany`.
    static var tooMany: String {
        String(localized: "qeetrix.file-upload.too-many", defaultValue: "Choose one file at a time", bundle: .module)
    }
}
