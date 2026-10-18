import CryptoKit
import Foundation

/// Where every input came from, read from `Scripts/Upstream/upstream.lock.json`.
public struct Provenance: Equatable, Sendable {
    public struct Font: Equatable, Sendable {
        public let family: String
        public let webFamily: String
        public let repository: String
        public let tag: String
        public let destination: String
        public let ttfSHA256: String
        public let woff2SHA256: String
        public let webFile: String
    }

    public let qeetrixUIPackage: String
    public let qeetrixUIVersion: String
    public let qeetrixUIGitHead: String
    public let qeetrixUIIntegrity: String
    public let iconsRepository: String
    public let iconsPackage: String
    public let iconsVersion: String
    public let iconsCommit: String
    public let fonts: [Font]
    /// Repository-relative path → sha256 of every pinned input the snapshot holds.
    public let files: [(path: String, sha256: String)]

    public static func == (lhs: Provenance, rhs: Provenance) -> Bool {
        lhs.qeetrixUIPackage == rhs.qeetrixUIPackage && lhs.qeetrixUIVersion == rhs.qeetrixUIVersion
            && lhs.qeetrixUIGitHead == rhs.qeetrixUIGitHead && lhs.qeetrixUIIntegrity == rhs.qeetrixUIIntegrity
            && lhs.iconsRepository == rhs.iconsRepository && lhs.iconsCommit == rhs.iconsCommit
            && lhs.iconsVersion == rhs.iconsVersion && lhs.iconsPackage == rhs.iconsPackage && lhs.fonts == rhs.fonts
            && lhs.files.map(\.path) == rhs.files.map(\.path) && lhs.files.map(\.sha256) == rhs.files.map(\.sha256)
    }
}

public enum Lock {
    public static let path = "Scripts/Upstream/upstream.lock.json"
    public static let pinsPath = "Scripts/Upstream/pins.json"

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
        let ui = json["qeetrixUI"]
        let icons = json["qeetrixIcons"]
        let fonts = try (json["fonts"]?.arrayValue ?? []).map { font in
            Provenance.Font(
                family: try string(font, "family"), webFamily: try string(font, "webFamily"),
                repository: try string(font, "repository"), tag: try string(font, "tag"),
                destination: try string(font, "destination"), ttfSHA256: try string(font, "ttfSHA256"),
                woff2SHA256: try string(font, "woff2SHA256"), webFile: try string(font, "webFile"))
        }
        guard case let .object(filePairs)? = json["files"] else { throw GeneratorError("\(path): missing files.") }
        let files = try filePairs.map { pair -> (path: String, sha256: String) in
            guard let hash = pair.1.stringValue else { throw GeneratorError("\(path): \(pair.0) has no hash.") }
            return (pair.0, hash)
        }
        return Provenance(
            qeetrixUIPackage: try string(ui, "package"), qeetrixUIVersion: try string(ui, "version"),
            qeetrixUIGitHead: try string(ui, "gitHead"), qeetrixUIIntegrity: try string(ui, "integrity"),
            iconsRepository: try string(icons, "repository"), iconsPackage: try string(icons, "package"),
            iconsVersion: try string(icons, "version"), iconsCommit: try string(icons, "commit"),
            fonts: fonts, files: files)
    }

    public static func json(_ provenance: Provenance) -> OrderedJSON {
        .object([
            (
                "$comment",
                .string(
                    "Written by Scripts/sync-upstream.sh — do not edit. Records exactly which upstream artifacts this package is built from and the sha256 of every file taken from them; Scripts/verify.sh fails if any of those files changes without a sync."
                )
            ),
            (
                "qeetrixUI",
                .object([
                    ("package", .string(provenance.qeetrixUIPackage)),
                    ("version", .string(provenance.qeetrixUIVersion)),
                    ("gitHead", .string(provenance.qeetrixUIGitHead)),
                    ("integrity", .string(provenance.qeetrixUIIntegrity)),
                ])
            ),
            (
                "qeetrixIcons",
                .object([
                    ("repository", .string(provenance.iconsRepository)),
                    ("package", .string(provenance.iconsPackage)),
                    ("version", .string(provenance.iconsVersion)),
                    ("commit", .string(provenance.iconsCommit)),
                ])
            ),
            (
                "fonts",
                .array(
                    provenance.fonts.map { font in
                        .object([
                            ("family", .string(font.family)),
                            ("webFamily", .string(font.webFamily)),
                            ("repository", .string(font.repository)),
                            ("tag", .string(font.tag)),
                            ("destination", .string(font.destination)),
                            ("ttfSHA256", .string(font.ttfSHA256)),
                            ("woff2SHA256", .string(font.woff2SHA256)),
                            ("webFile", .string(font.webFile)),
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
