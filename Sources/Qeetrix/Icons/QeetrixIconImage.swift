import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

extension Image {
    /// A Qeetrix icon as a template `Image`, for the places SwiftUI accepts only an image: tab items,
    /// toolbar buttons, menu items and `Label`s inside system chrome. It takes its colour from the
    /// surrounding tint or foreground style, as an SF Symbol does.
    ///
    /// ```swift
    /// HomeView()
    ///     .tabItem { Label { Text("Home") } icon: { Image(qeetrix: .house) } }
    ///
    /// Button { share() } label: { Label { Text("Share") } icon: { Image(qeetrix: .share2) } }
    /// ```
    ///
    /// Inside your own views, prefer ``QeetrixIcon``, which scales with Dynamic Type and mirrors in
    /// right-to-left layouts; system chrome sizes this image itself. The image is decorative: label the
    /// control it sits in.
    @MainActor
    public init(
        qeetrix name: QeetrixIconName,
        size: QeetrixIconSize = .md,
        shape: QeetrixIconShape = .round,
        variant: QeetrixIconVariant = .outline,
        stroke: QeetrixIconStroke = .regular
    ) {
        let key = QeetrixIconImageCache.Key(name: name, size: size, shape: shape, variant: variant, stroke: stroke)
        if let image = QeetrixIconImageCache.images[key] {
            self = Image(qeetrixTemplate: image)
            return
        }
        let renderer = ImageRenderer(
            content: QeetrixIcon(name, size: size, stroke: stroke, shape: shape, variant: variant, relativeTo: nil)
                .foregroundStyle(Color.black))
        renderer.scale = QeetrixIconImageCache.scale
        if let image = renderer.cgImage {
            QeetrixIconImageCache.store(image, for: key)
            self = Image(qeetrixTemplate: image)
        } else {
            self = Image(decorative: QeetrixIconImageCache.empty, scale: 1)
        }
    }
}

extension Image {
    /// A rendered icon as a template image. On UIKit it goes through `UIImage`: a system menu bridges an
    /// item's image through UIKit, and an item whose image is a bare `CGImage` loses its accessibility —
    /// VoiceOver and UI tests find the row without its title.
    @MainActor
    init(qeetrixTemplate image: CGImage) {
        #if canImport(UIKit)
            self = Image(
                uiImage: UIImage(cgImage: image, scale: QeetrixIconImageCache.scale, orientation: .up).withRenderingMode(.alwaysTemplate)
            )
            .renderingMode(.template)
        #else
            self = Image(decorative: image, scale: QeetrixIconImageCache.scale).renderingMode(.template)
        #endif
    }
}

/// Rendered icons, so an icon is drawn once per size and style however often chrome asks for it.
@MainActor
enum QeetrixIconImageCache {
    struct Key: Hashable {
        let name: QeetrixIconName
        let size: QeetrixIconSize
        let shape: QeetrixIconShape
        let variant: QeetrixIconVariant
        let stroke: QeetrixIconStroke
    }

    /// The highest display scale of the supported devices, so the image is sharp everywhere.
    static let scale: CGFloat = 3
    /// Far more than an app's chrome uses; reaching it empties the cache, so custom sizes can't grow it
    /// without bound.
    static let capacity = 256
    private(set) static var images: [Key: CGImage] = [:]

    static func store(_ image: CGImage, for key: Key) {
        if images.count >= capacity { images.removeAll() }
        images[key] = image
    }
    static let empty: CGImage = {
        let context = CGContext(
            data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        return context.makeImage()!
    }()
}
