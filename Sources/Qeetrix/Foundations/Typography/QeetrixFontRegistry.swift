import CoreText
import Foundation

/// Registers the bundled fonts with CoreText and creates fonts with Qeetrix's variation settings.
///
/// Fonts are built from the descriptor CoreText reads out of the bundled file itself, never looked
/// up by name: a variable font's named instances can make a PostScript-name lookup land on a
/// synthesised instance, or on another installed font of the same name. Registration runs once per
/// process, on first use, and is safe from any thread. Every failure is recorded and logged — a
/// missing font never silently becomes the system font. Call ``register()`` early (for example at
/// app launch) to surface problems before the first frame.
public enum QeetrixFontRegistry {
    /// The outcome of registering one bundled family.
    public struct Registration: Hashable, Sendable {
        public let family: QeetrixFontFamily
        /// Whether the bundled file loaded and CoreText draws the family from it.
        public let isAvailable: Bool
        /// Why the family is unavailable, when it is.
        public let failure: String?
    }

    /// Registers every bundled family (once) and returns the outcome per family.
    @discardableResult
    public static func register() -> [Registration] {
        loaded.map(\.registration)
    }

    /// Whether a family registered and resolves to its bundled file.
    public static func isAvailable(_ family: QeetrixFontFamily) -> Bool {
        loaded.first { $0.registration.family == family }?.registration.isAvailable ?? false
    }

    /// The bundled file a family is drawn from, when it loaded.
    static func url(of family: QeetrixFontFamily) -> URL? {
        loaded.first { $0.registration.family == family }?.url
    }

    /// A CoreText font from a bundled family, or `nil` when the family is unavailable.
    ///
    /// Variation axes are set the way the web sets them: `wght` from the weight, `GEOM` from the
    /// geometry (Qeet Sans), `opsz` from the point size (the web's `font-optical-sizing: auto`, CSS px
    /// being points), and `ital` 0. Values outside an axis's range are clamped to it; other axes keep
    /// the font's defaults, as on the web.
    public static func font(
        _ family: QeetrixFontFamily, size: CGFloat, weight: QeetrixFontWeight, geometry: QeetrixFontGeometry? = nil
    ) -> CTFont? {
        guard let entry = loaded.first(where: { $0.registration.family == family }), let base = entry.descriptor?.value else {
            return nil
        }
        var variations: [NSNumber: NSNumber] = [:]
        for axis in family.face.axes {
            let value: Double?
            switch axis.tag {
            case "wght": value = weight.value
            case "opsz": value = Double(size)
            case "GEOM": value = geometry?.value
            case "ital": value = 0
            default: value = nil
            }
            if let value {
                variations[NSNumber(value: fourCharCode(axis.tag))] = NSNumber(value: axis.clamped(value))
            }
        }
        let attributes = [kCTFontVariationAttribute: variations] as CFDictionary
        return CTFontCreateWithFontDescriptor(CTFontDescriptorCreateCopyWithAttributes(base, attributes), size, nil)
    }

    /// The variation-axis values a CoreText font actually carries, keyed by tag.
    static func variations(of font: CTFont) -> [String: Double] {
        guard let raw = CTFontCopyVariation(font) as? [NSNumber: NSNumber] else { return [:] }
        return Dictionary(uniqueKeysWithValues: raw.map { (tagString($0.key.uint32Value), $0.value.doubleValue) })
    }

    // MARK: Loading

    /// A font descriptor. CoreText descriptors are immutable and documented as thread-safe, which is
    /// what makes sharing one across concurrency domains sound.
    struct Descriptor: @unchecked Sendable {
        let value: CTFontDescriptor
    }

    struct Loaded: Sendable {
        let registration: Registration
        let url: URL?
        let descriptor: Descriptor?
    }

    private static let loaded: [Loaded] = QeetrixFontFamily.allCases.map(load)

    private static func load(_ family: QeetrixFontFamily) -> Loaded {
        let face = family.face
        func failed(_ reason: String, url: URL? = nil) -> Loaded {
            QeetrixLog.fonts.error("Qeetrix font \(family.rawValue, privacy: .public) unavailable: \(reason, privacy: .public)")
            return Loaded(registration: Registration(family: family, isAvailable: false, failure: reason), url: url, descriptor: nil)
        }
        guard let url = Bundle.module.url(forResource: face.resourceName, withExtension: "ttf", subdirectory: "Fonts") else {
            return failed("Fonts/\(face.resourceName).ttf is not in the package bundle.")
        }
        // Process-scoped registration, so text that names the family (attributed strings, web views)
        // finds it too. Already registered — by an earlier call or by the host app — is fine.
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            let cfError = error?.takeRetainedValue()
            if cfError.map(CFErrorGetCode) != CTFontManagerError.alreadyRegistered.rawValue {
                return failed(cfError.map { CFErrorCopyDescription($0) as String } ?? "CoreText refused the font.", url: url)
            }
        }
        let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor] ?? []
        let named = descriptors.first {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String == face.postScriptName
        }
        guard let descriptor = named ?? descriptors.first else {
            return failed("CoreText found no font in \(url.lastPathComponent).", url: url)
        }
        let font = CTFontCreateWithFontDescriptor(descriptor, 12, nil)
        let familyName = CTFontCopyFamilyName(font) as String
        guard familyName == face.familyName else {
            return failed("\(url.lastPathComponent) reads as family \(familyName), expected \(face.familyName).", url: url)
        }
        return Loaded(
            registration: Registration(family: family, isAvailable: true, failure: nil), url: url,
            descriptor: Descriptor(value: descriptor))
    }

    static func fourCharCode(_ tag: String) -> UInt32 {
        tag.utf8.reduce(0) { $0 << 8 | UInt32($1) }
    }

    static func tagString(_ code: UInt32) -> String {
        String(decoding: [24, 16, 8, 0].map { UInt8((code >> $0) & 0xFF) }, as: UTF8.self)
    }
}
