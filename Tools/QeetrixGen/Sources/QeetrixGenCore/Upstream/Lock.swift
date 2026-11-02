import CryptoKit
import Foundation

/// Where every input came from, read from `Upstream/upstream.lock.json`.
public struct Provenance: Equatable, Sendable {
    /// One npm package, exactly as the registry published it.
    public struct Package: Equatable, Sendable {
        /// `@qeetrix/tokens`, `@qeetrix/icons`, `@qeetrix/react`.
        public let name: String
        public let version: String
        /// The commit the package was published from (the registry's `gitHead`).
        public let gitHead: String
        /// The tarball's Subresource Integrity hash, as the registry states it and the sync verified it.
        public let integrity: String

        public init(name: String, version: String, gitHead: String, integrity: String) {
            self.name = name
            self.version = version
            self.gitHead = gitHead
            self.integrity = integrity
        }
    }

    /// A bundled font: the TTF the tokens package ships for native platforms.
    public struct Font: Equatable, Sendable {
        /// The `QeetrixFontFamily` case, e.g. `sans`.
        public let family: String
        /// The family name the web's CSS uses, e.g. `Qeet Sans`.
        public let webFamily: String
        /// The package and the TTF's path in it.
        public let package: String
        public let source: String
        /// The package's full WOFF2, which it made the TTF from (the web loads per-script subsets of it).
        public let woff2SHA256: String
        /// The bundled TTF, repository-relative.
        public let destination: String
        public let ttfSHA256: String
        /// How the package made the TTF, from its `native.json`.
        public let madeWith: String

        public init(
            family: String, webFamily: String, package: String, source: String, woff2SHA256: String, destination: String,
            ttfSHA256: String, madeWith: String
        ) {
            self.family = family
            self.webFamily = webFamily
            self.package = package
            self.source = source
            self.woff2SHA256 = woff2SHA256
            self.destination = destination
            self.ttfSHA256 = ttfSHA256
            self.madeWith = madeWith
        }
    }

    public let packages: [Package]
    public let fonts: [Font]
    /// Repository-relative path → sha256 of every pinned input the snapshot holds.
    public let files: [(path: String, sha256: String)]

    public init(packages: [Package], fonts: [Font], files: [(path: String, sha256: String)]) {
        self.packages = packages
        self.fonts = fonts
        self.files = files
    }

    public static func == (lhs: Provenance, rhs: Provenance) -> Bool {
        lhs.packages == rhs.packages && lhs.fonts == rhs.fonts && lhs.files.map(\.path) == rhs.files.map(\.path)
            && lhs.files.map(\.sha256) == rhs.files.map(\.sha256)
    }

    public static let tokensPackage = "@qeetrix/tokens"
    public static let iconsPackage = "@qeetrix/icons"
    public static let reactPackage = "@qeetrix/react"

    /// The locked package of that name.
    public func package(_ name: String) throws -> Package {
        guard let package = packages.first(where: { $0.name == name }) else {
            throw GeneratorError("\(Lock.path) has no \(name); run Scripts/sync-upstream.sh.")
        }
        return package
    }
}

public enum Lock {
    public static let path = "Upstream/upstream.lock.json"
    public static let pinsPath = "Upstream/pins.json"

    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func read(root: URL) throws -> Provenance {
        let url = root.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else {
            throw GeneratorError("\(path) is missing — run Scripts/sync-upstream.sh first.")
        }
        let json = try OrderedJSON.parse(data, context: path)
        func string(_ value: OrderedJSON?, _ key: String) throws -> String {
            guard let text = value?[key]?.stringValue else { throw GeneratorError("\(path): missing \(key).") }
            return text
        }
        let packages = try (json["packages"]?.arrayValue ?? []).map { package in
            Provenance.Package(
                name: try string(package, "package"), version: try string(package, "version"),
                gitHead: try string(package, "gitHead"), integrity: try string(package, "integrity"))
        }
        let fonts = try (json["fonts"]?.arrayValue ?? []).map { font in
            Provenance.Font(
                family: try string(font, "family"), webFamily: try string(font, "webFamily"), package: try string(font, "package"),
                source: try string(font, "source"), woff2SHA256: try string(font, "woff2SHA256"),
                destination: try string(font, "destination"), ttfSHA256: try string(font, "ttfSHA256"),
                madeWith: try string(font, "madeWith"))
        }
        guard case let .object(filePairs)? = json["files"] else { throw GeneratorError("\(path): missing files.") }
        let files = try filePairs.map { pair -> (path: String, sha256: String) in
            guard let hash = pair.1.stringValue else { throw GeneratorError("\(path): \(pair.0) has no hash.") }
            return (pair.0, hash)
        }
        return Provenance(packages: packages, fonts: fonts, files: files)
    }

    public static func json(_ provenance: Provenance) -> OrderedJSON {
        .object([
            (
                "$comment",
                .string(
                    "Written by Scripts/sync-upstream.sh — do not edit. Records exactly which npm packages this package is built from (each tarball verified against the registry's integrity hash), where the fonts came from, and the sha256 of every file taken from them; Scripts/verify.sh fails if any of those files changes without a sync."
                )
            ),
            (
                "packages",
                .array(
                    provenance.packages.map { package in
                        .object([
                            ("package", .string(package.name)),
                            ("version", .string(package.version)),
                            ("gitHead", .string(package.gitHead)),
                            ("integrity", .string(package.integrity)),
                        ])
                    })
            ),
            (
                "fonts",
                .array(
                    provenance.fonts.map { font in
                        .object([
                            ("family", .string(font.family)),
                            ("webFamily", .string(font.webFamily)),
                            ("package", .string(font.package)),
                            ("source", .string(font.source)),
                            ("woff2SHA256", .string(font.woff2SHA256)),
                            ("destination", .string(font.destination)),
                            ("ttfSHA256", .string(font.ttfSHA256)),
                            ("madeWith", .string(font.madeWith)),
                        ])
                    })
            ),
            ("files", .object(provenance.files.map { ($0.path, .string($0.sha256)) })),
        ])
    }

    /// Every locked file, re-hashed. Returns one message per mismatch; empty means the snapshot is intact.
    public static func check(_ provenance: Provenance, root: URL) -> [String] {
        provenance.files.compactMap { file in
            guard let data = try? Data(contentsOf: root.appendingPathComponent(file.path)) else {
                return "\(file.path) is missing."
            }
            let actual = sha256(data)
            return actual == file.sha256
                ? nil
                : "\(file.path) changed (sha256 \(actual.prefix(12))…, locked \(file.sha256.prefix(12))…). Upstream inputs only change through Scripts/sync-upstream.sh."
        }
    }
}
