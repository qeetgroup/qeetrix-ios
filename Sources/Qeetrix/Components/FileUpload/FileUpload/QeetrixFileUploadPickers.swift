import CoreTransferable
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import os

#if os(iOS)
    import UIKit
#endif

/// A file handed over by the photo library or a drop. The system's copy lasts only while it is being
/// received, so it is copied at once into the upload's own folder (``QeetrixFileUploadStorage``).
struct QeetrixFileUploadTransfer: Transferable, Sendable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        // Most specific first: a photo arrives as an image, a video as a movie, anything else as an item.
        FileRepresentation(importedContentType: .image) { received in Self(url: try QeetrixFileUploadStorage.keep(received.file)) }
        FileRepresentation(importedContentType: .movie) { received in Self(url: try QeetrixFileUploadStorage.keep(received.file)) }
        FileRepresentation(importedContentType: .item) { received in Self(url: try QeetrixFileUploadStorage.keep(received.file)) }
    }
}

/// Where chosen files are kept for the app: a folder of their own under the app's temporary directory,
/// one per file so two files of the same name never meet. The app reads, uploads and deletes them;
/// iOS clears the temporary directory in time.
enum QeetrixFileUploadStorage {
    static let log = Logger(subsystem: "in.qeet.qeetrix", category: "file-upload")

    static var folder: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("QeetrixFileUpload", isDirectory: true)
    }

    /// A fresh place for a file called `name`.
    static func place(for name: String) throws -> URL {
        let directory = folder.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent(name.isEmpty ? "File" : name)
    }

    /// Copies `file` into its own place.
    static func keep(_ file: URL) throws -> URL {
        let copy = try place(for: file.lastPathComponent)
        try FileManager.default.copyItem(at: file, to: copy)
        return copy
    }

    /// Copies files chosen in Files, which are only lent to the app (security-scoped), off the main
    /// thread. A file that can't be read is left out, and logged.
    static func keepImported(_ urls: [URL]) async -> [URL] {
        await Task.detached(priority: .userInitiated) {
            urls.compactMap { url -> URL? in
                let isScoped = url.startAccessingSecurityScopedResource()
                defer { if isScoped { url.stopAccessingSecurityScopedResource() } }
                do {
                    return try keep(url)
                } catch {
                    log.error("A chosen file couldn't be copied: \(error.localizedDescription, privacy: .public)")
                    return nil
                }
            }
        }.value
    }

    /// Copies what was chosen in the photo library. An item iOS can't hand over — a photo still in
    /// iCloud while offline — is left out, and logged.
    static func keepLibraryItems(_ items: [PhotosPickerItem]) async -> [URL] {
        var kept: [URL] = []
        for item in items {
            do {
                if let file = try await item.loadTransferable(type: QeetrixFileUploadTransfer.self) { kept.append(file.url) }
            } catch {
                log.error("A photo couldn't be loaded: \(error.localizedDescription, privacy: .public)")
            }
        }
        return kept
    }

    /// Writes the camera's photos off the main thread.
    static func keepPhotos(_ photos: [Data]) async -> [URL] {
        await Task.detached(priority: .userInitiated) {
            photos.compactMap { data -> URL? in
                do {
                    return try keepPhoto(data)
                } catch {
                    log.error("A photo couldn't be saved: \(error.localizedDescription, privacy: .public)")
                    return nil
                }
            }
        }.value
    }

    /// Writes a photo's JPEG data to a file named as a camera names one: `IMG_20261030_141502.jpg`, in
    /// the device's time zone. A file name, not text to read, so it isn't localised.
    static func keepPhoto(_ data: Data, takenAt date: Date = .now) throws -> URL {
        let parts = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let name = String(
            format: "IMG_%04d%02d%02d_%02d%02d%02d.jpg", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0, parts.hour ?? 0,
            parts.minute ?? 0, parts.second ?? 0)
        let url = try place(for: name)
        try data.write(to: url, options: .atomic)
        return url
    }

    /// Removes a copy the app never got: a refused file's.
    static func discard(_ url: URL?) {
        guard let url, url.path.hasPrefix(folder.path) else { return }
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    /// The upload item for a kept file: its name, size and type.
    static func item(at url: URL) -> QeetrixFileUploadItem {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
        return QeetrixFileUploadItem(
            name: url.lastPathComponent, size: Int64(values?.fileSize ?? 0),
            contentType: values?.contentType ?? UTType(filenameExtension: url.pathExtension), url: url)
    }
}

/// Whether the camera can be offered: the device has one and the app has said why it wants it
/// (`NSCameraUsageDescription`), without which iOS would end the app when the camera opens.
enum QeetrixFileUploadCameraAvailability {
    @MainActor static var isAvailable: Bool {
        #if os(iOS)
            UIImagePickerController.isSourceTypeAvailable(.camera)
                && Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil
        #else
            false
        #endif
    }
}

#if os(iOS)
    /// The system camera, `UIImagePickerController`: SwiftUI has no camera picker of its own. It takes
    /// one photo and hands back its image; the system draws all of it.
    struct QeetrixFileUploadCamera: UIViewControllerRepresentable {
        let onCapture: @MainActor (UIImage) -> Void
        let onFinish: @MainActor () -> Void

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [UTType.image.identifier]
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(onCapture: onCapture, onFinish: onFinish)
        }

        @MainActor
        final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let onCapture: @MainActor (UIImage) -> Void
            let onFinish: @MainActor () -> Void

            init(onCapture: @escaping @MainActor (UIImage) -> Void, onFinish: @escaping @MainActor () -> Void) {
                self.onCapture = onCapture
                self.onFinish = onFinish
            }

            func imagePickerController(
                _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
            ) {
                if let image = info[.originalImage] as? UIImage { onCapture(image) }
                onFinish()
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                onFinish()
            }
        }
    }
#endif
