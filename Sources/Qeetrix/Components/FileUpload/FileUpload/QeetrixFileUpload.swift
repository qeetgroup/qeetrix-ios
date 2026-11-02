import Accessibility
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
    import UIKit
#endif

/// Where a file stands — `@qeetrix/react`'s `FileUploadItem` `status`, `progress` and `error`.
public enum QeetrixFileUploadStatus: Hashable, Sendable {
    /// Chosen, not sent yet: the web's item without a status. New files start here.
    case chosen
    /// On its way: `progress` from 0 to 1, or `nil` while it isn't known.
    case uploading(progress: Double?)
    /// Uploaded.
    case done
    /// Not uploaded, with why, already localised: "The connection was lost. Try again."
    case error(String)
}

/// A file the app is handling — `@qeetrix/react`'s `FileUploadItem`: what it's called, how big it is,
/// where its copy is, and where its upload stands. The app owns the array and the uploads.
public struct QeetrixFileUploadItem: Identifiable, Hashable, Sendable {
    /// Stable for the file's life: a server's ID for a file already uploaded, or a new one.
    public var id: String
    /// The file's name, shown as given: "invoice.pdf".
    public var name: String
    /// In bytes.
    public var size: Int64
    /// Its type, when known; otherwise its name's extension says.
    public var contentType: UTType?
    /// The file, for a file just chosen: Qeetrix's copy in the app's temporary directory, the app's to
    /// read, upload and delete.
    public var url: URL?
    /// Where its upload stands.
    public var status: QeetrixFileUploadStatus

    /// A file the app is handling.
    public init(
        id: String = UUID().uuidString, name: String, size: Int64, contentType: UTType? = nil, url: URL? = nil,
        status: QeetrixFileUploadStatus = .chosen
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.contentType = contentType
        self.url = url
        self.status = status
    }
}

/// The system pickers a ``QeetrixFileUpload`` offers.
public struct QeetrixFileUploadSources: OptionSet, Hashable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The photo library, through the system's Photos picker (`PhotosPicker`).
    public static let photos = QeetrixFileUploadSources(rawValue: 1 << 0)
    /// A new photo, through the system camera (`UIImagePickerController`).
    public static let camera = QeetrixFileUploadSources(rawValue: 1 << 1)
    /// Any file, through the Files browser (`fileImporter`).
    public static let files = QeetrixFileUploadSources(rawValue: 1 << 2)
    /// All three: each still only where it can work.
    public static let all: QeetrixFileUploadSources = [.photos, .camera, .files]
}

/// The words a ``QeetrixFileUpload`` and its ``QeetrixFileRow``s show, to replace their built-in ones —
/// `@qeetrix/react`'s `messages` for `fileUpload`. Any left `nil` keep their default.
public struct QeetrixFileUploadMessages {
    /// "Photos".
    public var photos: Text?
    /// "Camera".
    public var camera: Text?
    /// "Files".
    public var files: Text?
    /// While a file is dragged over the picker: "Drop to upload".
    public var drop: Text?
    /// "Uploaded". Announced, so it's a `String`.
    public var uploaded: String?
    /// "Not uploaded". Announced.
    public var failed: String?

    /// The words to replace.
    public init(
        photos: Text? = nil, camera: Text? = nil, files: Text? = nil, drop: Text? = nil, uploaded: String? = nil, failed: String? = nil
    ) {
        self.photos = photos
        self.camera = camera
        self.files = files
        self.drop = drop
        self.uploaded = uploaded
        self.failed = failed
    }
}

/// Attach files on a phone — `@qeetrix/react`'s FileUpload: the system's pickers for photos, the
/// camera and files, the limits in words, and a row for each file with its state. Qeetrix never
/// uploads: the files are the app's, in `files`, and so are the uploads.
///
/// ```swift
/// QeetrixFileUpload(
///     "Receipts", files: $receipts, allowedContentTypes: [.pdf, .jpeg, .png], maxSize: 10_000_000, allowsMultiple: true
/// ) { chosen in
///     for file in chosen { upload(file) }
/// }
/// ```
///
/// - **The picker** is the web's zone — `color.bg.neutral.subtle` inside a 1 pt dashed
///   `color.border.strong` edge with 4 pt corners, a sharp 24 pt `cloud-upload` — holding a ghost
///   button, in Ember as the web's "browse" link, for each source that can work: **Photos** for images
///   or videos the types allow, **Camera** where the device has one, the app declares
///   `NSCameraUsageDescription` and a JPEG is allowed, and **Files**. Under them the limits: "PDF, JPEG
///   or PNG, up to 10 MB".
/// - **Each file it brings** is checked — its type, its size, one at a time unless `allowsMultiple` —
///   and copied into the app's temporary directory. Files that pass join `files` as `.chosen`, with
///   their `url`, and `onSelect` gets them; start their uploads there and report each one's `status`
///   in `files`. Files that don't are listed with the reason, worded as the web's ("Larger than
///   10 MB"), until the next choice or Remove.
/// - **Rows** are ``QeetrixFileRow``s in a ruled box; Remove takes the file out of `files` and calls
///   `onRemove`, where an upload is cancelled and its copy deleted.
/// - **On iPad** a file dragged over the picker turns it Ember (`color.border.brand`, `color.bg.selected`)
///   with "Drop to upload", and dropping it runs the same checks.
///
/// The pickers themselves — Photos, the camera and Files — are drawn by iOS.
public struct QeetrixFileUpload: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let files: Binding<[QeetrixFileUploadItem]>
    let sources: QeetrixFileUploadSources
    let limits: QeetrixFileLimits
    let hint: Text?
    let messages: QeetrixFileUploadMessages
    let onRemove: (@MainActor (QeetrixFileUploadItem) -> Void)?
    let onSelect: (@MainActor ([QeetrixFileUploadItem]) -> Void)?
    @State private var refused: [QeetrixFileUploadItem] = []
    @State private var isTargeted = false
    @State private var isReceiving = false
    @State private var isChoosingPhotos = false
    @State private var photoSelection: [PhotosPickerItem] = []
    @State private var isTakingPhoto = false
    @State private var isImporting = false
    @AccessibilityFocusState private var focusedPicker: QeetrixFileUploadPicker?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.locale) private var locale

    init(
        label: Text, files: Binding<[QeetrixFileUploadItem]>, sources: QeetrixFileUploadSources, limits: QeetrixFileLimits, hint: Text?,
        description: Text?, error: String?, isRequired: Bool, isOptional: Bool, messages: QeetrixFileUploadMessages,
        onSelect: (@MainActor ([QeetrixFileUploadItem]) -> Void)?, onRemove: (@MainActor (QeetrixFileUploadItem) -> Void)?
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.files = files
        self.sources = sources
        self.limits = limits
        self.hint = hint
        self.messages = messages
        self.onRemove = onRemove
        self.onSelect = onSelect
    }

    /// A file upload with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, files: Binding<[QeetrixFileUploadItem]>, sources: QeetrixFileUploadSources = .all,
        allowedContentTypes: [UTType] = [], maxSize: Int64? = nil, allowsMultiple: Bool = false, hint: Text? = nil,
        description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        messages: QeetrixFileUploadMessages = QeetrixFileUploadMessages(), onSelect: (@MainActor ([QeetrixFileUploadItem]) -> Void)? = nil,
        onRemove: (@MainActor (QeetrixFileUploadItem) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), files: files, sources: sources,
            limits: QeetrixFileLimits(allowedContentTypes: allowedContentTypes, maxSize: maxSize, allowsMultiple: allowsMultiple),
            hint: hint, description: description, error: error, isRequired: isRequired, isOptional: isOptional, messages: messages,
            onSelect: onSelect, onRemove: onRemove)
    }

    /// A file upload with a label shown as given.
    public init<S: StringProtocol>(
        _ title: S, files: Binding<[QeetrixFileUploadItem]>, sources: QeetrixFileUploadSources = .all, allowedContentTypes: [UTType] = [],
        maxSize: Int64? = nil, allowsMultiple: Bool = false, hint: Text? = nil, description: Text? = nil, error: String? = nil,
        isRequired: Bool = false, isOptional: Bool = false, messages: QeetrixFileUploadMessages = QeetrixFileUploadMessages(),
        onSelect: (@MainActor ([QeetrixFileUploadItem]) -> Void)? = nil, onRemove: (@MainActor (QeetrixFileUploadItem) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), files: files, sources: sources,
            limits: QeetrixFileLimits(allowedContentTypes: allowedContentTypes, maxSize: maxSize, allowsMultiple: allowsMultiple),
            hint: hint, description: description, error: error, isRequired: isRequired, isOptional: isOptional, messages: messages,
            onSelect: onSelect, onRemove: onRemove)
    }

    /// A file upload with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the picker for VoiceOver.
    ///   - files: The app's files, with their states. New files are appended as `.chosen`.
    ///   - sources: The pickers to offer, each only where it can work.
    ///   - allowedContentTypes: The types allowed (`[.pdf, .png]`, or a family such as `.image`); empty
    ///     allows any file.
    ///   - maxSize: The largest file allowed, in bytes.
    ///   - allowsMultiple: Lets one choice bring several files.
    ///   - hint: Replaces the line under the pickers, written from the types and size by default.
    ///   - description: Help under the field.
    ///   - error: What to fix, already localised: it marks the picker invalid and replaces the
    ///     description.
    ///   - isRequired: Tells VoiceOver the field is required.
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - messages: Replaces the built-in words.
    ///   - onSelect: The files that passed the checks, just appended to `files`: upload them.
    ///   - onRemove: After Remove has taken a file out of `files`: cancel its upload, delete its copy.
    public init(
        label: Text, files: Binding<[QeetrixFileUploadItem]>, sources: QeetrixFileUploadSources = .all, allowedContentTypes: [UTType] = [],
        maxSize: Int64? = nil, allowsMultiple: Bool = false, hint: Text? = nil, description: Text? = nil, error: String? = nil,
        isRequired: Bool = false, isOptional: Bool = false, messages: QeetrixFileUploadMessages = QeetrixFileUploadMessages(),
        onSelect: (@MainActor ([QeetrixFileUploadItem]) -> Void)? = nil, onRemove: (@MainActor (QeetrixFileUploadItem) -> Void)? = nil
    ) {
        self.init(
            label: label, files: files, sources: sources,
            limits: QeetrixFileLimits(allowedContentTypes: allowedContentTypes, maxSize: maxSize, allowsMultiple: allowsMultiple),
            hint: hint, description: description, error: error, isRequired: isRequired, isOptional: isOptional, messages: messages,
            onSelect: onSelect, onRemove: onRemove)
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            // .qx-file-upload: the zone, then the list, gap.sm apart.
            VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                zone
                if !entries.isEmpty { list }
            }
        }
        .photosPicker(
            isPresented: $isChoosingPhotos, selection: $photoSelection, maxSelectionCount: limits.allowsMultiple ? nil : 1,
            selectionBehavior: .ordered, matching: libraryFilter, preferredItemEncoding: .compatible
        )
        .fileImporter(
            isPresented: $isImporting, allowedContentTypes: limits.importableTypes, allowsMultipleSelection: limits.allowsMultiple
        ) { result in
            switch result {
            case let .success(urls):
                receive { await QeetrixFileUploadStorage.keepImported(urls) }
            case let .failure(error):
                QeetrixFileUploadStorage.log.error("Files didn't open: \(error.localizedDescription, privacy: .public)")
            }
        }
        .modifier(
            QeetrixFileUploadCameraCover(isPresented: $isTakingPhoto) { data in
                receive { await QeetrixFileUploadStorage.keepPhotos([data]) }
            }
        )
        .onChange(of: photoSelection) { _, chosen in
            guard !chosen.isEmpty else { return }
            photoSelection = []
            receive { await QeetrixFileUploadStorage.keepLibraryItems(chosen) }
        }
        // The web's list is a polite live region: a finished or failed upload is announced.
        .onChange(of: outcomes) { old, new in
            let changed = files.wrappedValue.compactMap { file in new[file.id].flatMap { old[file.id] == $0 ? nil : (file, $0) } }
            announce(changed.map { file, outcome in Self.summary(name: file.name, outcome: outcomeText(outcome)) })
        }
    }

    // MARK: The picker

    /// The files listed: the app's, then the ones the last choice refused.
    var entries: [QeetrixFileUploadItem] { files.wrappedValue + refused }

    /// The sources on offer, in order, each only where it can work.
    var offered: [QeetrixFileUploadPicker] {
        QeetrixFileUploadPicker.allCases.filter { picker in
            switch picker {
            case .photos: sources.contains(.photos) && libraryFilter != nil
            case .camera: sources.contains(.camera) && limits.acceptsPhotos && QeetrixFileUploadCameraAvailability.isAvailable
            case .files: sources.contains(.files)
            }
        }
    }

    /// What the photo library offers: the images and videos the types allow.
    var libraryFilter: PHPickerFilter? {
        switch limits.libraryKinds {
        case (true, true): .any(of: [.images, .videos])
        case (true, false): .images
        case (false, true): .videos
        case (false, false): nil
        }
    }

    private var zone: some View {
        let drop = messages.drop ?? QeetrixFileUploadStrings.drop
        return QeetrixFileUploadZone(
            isTargeted: isTargeted, isReceiving: isReceiving, isInvalid: context.invalid, drop: drop, hint: shownHint
        ) {
            ForEach(offered, id: \.self) { picker in
                pickerButton(picker)
                    .accessibilityFocused($focusedPicker, equals: picker)
            }
        }
        // The picker is named by the field, so VoiceOver says what the files are for as it reaches it.
        .accessibilityElement(children: .contain)
        .accessibilityLabel(context.accessibilityLabel)
        .dropDestination(for: QeetrixFileUploadTransfer.self) { dropped, _ in
            guard isEnabled, !dropped.isEmpty else { return false }
            take(dropped.map(\.url))
            return true
        } isTargeted: { targeted in
            isTargeted = targeted && isEnabled
        }
    }

    private func pickerButton(_ picker: QeetrixFileUploadPicker) -> some View {
        // Ghost, as design rules §7 make every button past one solid and one soft, and Ember, as the web's
        // "browse" link is.
        QeetrixButton(title: title(of: picker), icon: picker.icon, variant: .ghost) {
            switch picker {
            case .photos: isChoosingPhotos = true
            case .camera: isTakingPhoto = true
            case .files: isImporting = true
            }
        }
        .disabled(isReceiving)
    }

    private func title(of picker: QeetrixFileUploadPicker) -> Text {
        switch picker {
        case .photos: messages.photos ?? QeetrixFileUploadStrings.photos
        case .camera: messages.camera ?? QeetrixFileUploadStrings.camera
        case .files: messages.files ?? QeetrixFileUploadStrings.files
        }
    }

    /// The hint shown: yours, or the limits in words.
    private var shownHint: Text? {
        hint ?? limits.hint(locale: locale).map { Text(verbatim: $0) }
    }

    // MARK: The files

    private var list: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        // .qx-file-upload-list: a 1 pt border.subtle box with 4 pt corners, rows ruled in border.subtle.
        return VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, item in
                if index > 0 { QeetrixSeparator() }
                QeetrixFileRow(item, messages: messages) { remove(item) }
            }
        }
        .overlay { shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixBorderWidth.default).accessibilityHidden(true) }
    }

    /// Takes a file out — out of `files`, or out of the refused ones — and returns VoiceOver to the
    /// picker, as the web returns focus to its input.
    private func remove(_ item: QeetrixFileUploadItem) {
        if refused.contains(where: { $0.id == item.id }) {
            refused.removeAll { $0.id == item.id }
        } else {
            files.wrappedValue.removeAll { $0.id == item.id }
            onRemove?(item)
        }
        focusedPicker = offered.first
    }

    /// Runs `copy` — the system's files into the app's temporary directory — with the zone busy, then
    /// takes what it kept.
    private func receive(_ copy: @escaping @MainActor () async -> [URL]) {
        isReceiving = true
        Task {
            let kept = await copy()
            take(kept)
            isReceiving = false
        }
    }

    /// Checks the kept files: the ones that pass join `files` and go to `onSelect`; the others are
    /// listed with the reason, and their copies deleted.
    func take(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        let sorted = QeetrixFileUploadIntake(limits: limits, locale: locale).sort(urls.map(QeetrixFileUploadStorage.item(at:)))
        // The app never sees a refused file, so its copy goes at once.
        let turnedAway = sorted.refused.map { file in
            QeetrixFileUploadStorage.discard(file.url)
            var file = file
            file.url = nil
            return file
        }
        refused = turnedAway
        if !sorted.accepted.isEmpty {
            files.wrappedValue.append(contentsOf: sorted.accepted)
            onSelect?(sorted.accepted)
        }
        // The web's list is a live region: each new row is read.
        announce(
            sorted.accepted.map { Self.summary(name: $0.name, outcome: QeetrixFormat.fileSize($0.size, locale: locale)) }
                + turnedAway.map { file in
                    guard case let .error(reason) = file.status else { return file.name }
                    return Self.summary(name: file.name, outcome: reason + ", " + outcomeText(.failed))
                })
    }

    /// The files whose upload has finished, either way, by ID.
    private var outcomes: [String: QeetrixFileRowOutcome] {
        Dictionary(files.wrappedValue.compactMap { file in QeetrixFileRowOutcome(file.status).map { (file.id, $0) } }) { first, _ in first }
    }

    private func outcomeText(_ outcome: QeetrixFileRowOutcome) -> String {
        outcome == .done ? messages.uploaded ?? QeetrixFileUploadStrings.uploaded : messages.failed ?? QeetrixFileUploadStrings.failed
    }

    static func summary(name: String, outcome: String) -> String {
        name + ", " + outcome
    }

    private func announce(_ lines: [String]) {
        guard !lines.isEmpty else { return }
        AccessibilityNotification.Announcement(lines.joined(separator: ". ")).post()
    }
}

/// One of the system pickers, with its button's icon.
enum QeetrixFileUploadPicker: CaseIterable, Hashable {
    case photos
    case camera
    case files

    var icon: QeetrixIconName {
        switch self {
        case .photos: .image
        case .camera: .camera
        case .files: .folder
        }
    }
}

/// The checks applied to one choice's files, apart from the view: which join the app's files, and which
/// are refused with their reason.
struct QeetrixFileUploadIntake {
    let limits: QeetrixFileLimits
    let locale: Locale

    func sort(_ candidates: [QeetrixFileUploadItem]) -> (accepted: [QeetrixFileUploadItem], refused: [QeetrixFileUploadItem]) {
        var accepted: [QeetrixFileUploadItem] = []
        var refused: [QeetrixFileUploadItem] = []
        for (file, problem) in zip(candidates, limits.problems(for: candidates, locale: locale)) {
            if let problem {
                var file = file
                file.status = .error(problem)
                refused.append(file)
            } else {
                accepted.append(file)
            }
        }
        return (accepted, refused)
    }
}

/// The web's drop zone, holding the pickers (file-upload.css `.qx-file-upload-zone`): a centred column,
/// `space.gap.xs` apart, `space.inset.xl` above and below and `space.inset.md` at the sides — the sharp
/// 24 pt `cloud-upload`, the pickers' buttons in a centred row that wraps, then the hint in `body.sm`
/// and `color.text.subtle`. While a file is dragged over it, "Drop to upload" takes the buttons' place;
/// while chosen files are being copied, a spinner takes the icon's.
struct QeetrixFileUploadZone<Pickers: View>: View {
    let isTargeted: Bool
    let isReceiving: Bool
    let isInvalid: Bool
    let drop: Text
    let hint: Text?
    let pickers: Pickers
    @Environment(\.isEnabled) private var isEnabled

    init(isTargeted: Bool, isReceiving: Bool, isInvalid: Bool, drop: Text, hint: Text?, @ViewBuilder pickers: () -> Pickers) {
        self.isTargeted = isTargeted
        self.isReceiving = isReceiving
        self.isInvalid = isInvalid
        self.drop = drop
        self.hint = hint
        self.pickers = pickers()
    }

    var body: some View {
        let colors = QeetrixFileUploadZoneColors(isEnabled: isEnabled, isTargeted: isTargeted, isInvalid: isInvalid)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        VStack(spacing: QeetrixSpace.gapXs) {
            if isReceiving {
                // A long video can take a moment to copy.
                QeetrixSpinner(size: .xl)
            } else {
                QeetrixIcon(.cloudUpload, size: .lg, shape: .sharp)
                    .foregroundStyle(colors.icon)
            }
            if isTargeted {
                drop
                    .qeetrixTextStyle(.bodyMd)
                    .foregroundStyle(colors.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                QeetrixFeedbackActionsLayout(spacing: QeetrixSpace.gapSm, alignment: .center) { pickers }
                    .padding(.vertical, QeetrixSpace.gapXs)
            }
            if let hint {
                hint
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, QeetrixSpace.insetXl)
        .padding(.horizontal, QeetrixSpace.insetMd)
        .background(colors.background, in: shape)
        .overlay {
            shape.strokeBorder(colors.border, style: QeetrixFileUploadZoneColors.dashes)
                .accessibilityHidden(true)
        }
        .qeetrixAnimation(.standard, .fast, value: colors)
    }
}

/// The zone's colours (file-upload.css `.qx-file-upload-zone`): the neutral fill inside a dashed strong
/// edge; Ember while a file is dragged over it; a danger edge when the field is invalid; the disabled
/// fill and edge when disabled.
struct QeetrixFileUploadZoneColors: Hashable {
    let isEnabled: Bool
    let isTargeted: Bool
    let isInvalid: Bool

    /// `border: border.width.default dashed`, drawn as a browser draws a 1 px dashed border: dashes and
    /// gaps of about three times its width.
    static let dashes = StrokeStyle(lineWidth: QeetrixBorderWidth.default, dash: [3, 3])

    var background: QeetrixColor {
        if !isEnabled { return .bgDisabled }
        return isTargeted ? .bgSelected : .bgNeutralSubtle
    }

    var border: QeetrixColor {
        if !isEnabled { return .borderDisabled }
        if isTargeted { return .borderBrand }
        return isInvalid ? .borderDanger : .borderStrong
    }

    /// `.qx-file-upload-icon`: `icon.subtle`, `icon.brand` while dragging.
    var icon: QeetrixColor {
        if !isEnabled { return .iconDisabled }
        return isTargeted ? .iconBrand : .iconSubtle
    }

    var text: QeetrixColor {
        isEnabled ? .textDefault : .textDisabled
    }
}

/// The system camera in a full-screen cover, on iOS; on the Mac host, nothing.
struct QeetrixFileUploadCameraCover: ViewModifier {
    @Binding var isPresented: Bool
    /// The photo, as JPEG data.
    let onPhoto: @MainActor (Data) -> Void

    func body(content: Content) -> some View {
        #if os(iOS)
            content.fullScreenCover(isPresented: $isPresented) {
                QeetrixFileUploadCamera { image in
                    if let data = image.jpegData(compressionQuality: 0.9) { onPhoto(data) }
                } onFinish: {
                    isPresented = false
                }
                .ignoresSafeArea()
            }
        #else
            content
        #endif
    }
}
