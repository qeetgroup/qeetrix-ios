import Foundation

/// A CycloneDX 1.5 software bill of materials for a release of the Qeetrix library.
///
/// It lists what the library carries — the bundled fonts, the icon artwork and the design tokens it was
/// generated from — and, scoped `excluded`, the test-only packages that never reach an app. It is built
/// only from `Upstream/pins.json`, `Upstream/upstream.lock.json`, `Package.resolved` and the dependency
/// allowlist, so it can't list anything that isn't pinned. It has no timestamp and no random serial
/// number: the same inputs give the same file.
public enum SBOM {
    public static func render(root: URL, version: String) throws -> String {
        let lock = try Lock.read(root: root)
        let pins = try OrderedJSON.parse(Data(contentsOf: root.appendingPathComponent(Lock.pinsPath)), context: Lock.pinsPath)
        func licence(_ entry: OrderedJSON?, _ name: String) throws -> [[String: Any]] {
            guard let value = entry?["licence"]?.stringValue else {
                throw GeneratorError("\(Lock.pinsPath): \(name) has no reviewed licence.")
            }
            // npm's UNLICENSED is a statement, not an SPDX licence: keep it verbatim as a name.
            return value == "UNLICENSED" ? [["license": ["name": value]]] : [["expression": value]]
        }

        var components: [[String: Any]] = []
        let pinnedFonts = pins["fonts"]?.arrayValue ?? []
        for font in lock.fonts {
            let pin = pinnedFonts.first { $0["family"]?.stringValue == font.family }
            components.append([
                "bom-ref": "font-\(font.family)",
                "type": "file",
                "name": (font.destination as NSString).lastPathComponent,
                "version": font.tag,
                "description": "\(font.webFamily): bundled unmodified in the Qeetrix resource bundle, with its licence.",
                "scope": "required",
                "purl": "pkg:github/\(font.repository)@\(font.tag)",
                "hashes": [["alg": "SHA-256", "content": font.ttfSHA256]],
                "licenses": try licence(pin, "the \(font.family) font"),
                "externalReferences": [["type": "vcs", "url": "https://github.com/\(font.repository)"]],
            ])
        }
        components.append([
            "bom-ref": "qeetrix-icons",
            "type": "data",
            "name": lock.iconsPackage,
            "version": lock.iconsVersion,
            "description":
                "Icon artwork, converted to Swift path data (Sources/Qeetrix/Icons/Generated); includes Lucide (ISC) and Feather (MIT) drawings. The notice is bundled in Licenses/.",
            "scope": "required",
            "purl": "pkg:github/\(lock.iconsRepository)@\(lock.iconsCommit)",
            "licenses": try licence(pins["qeetrixIcons"], "qeetrixIcons"),
            "externalReferences": [["type": "vcs", "url": "https://github.com/\(lock.iconsRepository)"]],
        ])
        var tokens: [String: Any] = [
            "bom-ref": "qeetrix-ui",
            "type": "data",
            "name": lock.qeetrixUIPackage,
            "version": lock.qeetrixUIVersion,
            "description": "Design tokens, generated into Swift (Sources/Qeetrix/Tokens/Generated) from the published package.",
            "scope": "required",
            "purl": "pkg:npm/\(lock.qeetrixUIPackage.replacingOccurrences(of: "@", with: "%40"))@\(lock.qeetrixUIVersion)",
            "licenses": try licence(pins["qeetrixUI"], "qeetrixUI"),
        ]
        if let digest = Self.hex(fromIntegrity: lock.qeetrixUIIntegrity) {
            tokens["hashes"] = [["alg": "SHA-512", "content": digest]]
        }
        components.append(tokens)

        let allowlist = try JSONDecoder().decode(
            DependencyReview.Allowlist.self, from: Data(contentsOf: root.appendingPathComponent(DependencyReview.allowlistPath)))
        let resolved = try? Data(contentsOf: root.appendingPathComponent(DependencyReview.resolvedPath))
        let packages = try resolved.map { try JSONDecoder().decode(DependencyReview.Resolved.self, from: $0).pins } ?? []
        for package in packages.sorted(by: { $0.identity < $1.identity }) {
            guard let reviewed = allowlist.packages.first(where: { $0.identity == package.identity }) else {
                throw GeneratorError("Package.resolved pins \(package.identity), which the allowlist doesn't review.")
            }
            let host = DependencyReview.normalised(package.location).replacingOccurrences(of: "https://", with: "")
            components.append([
                "bom-ref": package.identity,
                "type": "library",
                "name": package.identity,
                "version": package.state.version ?? package.state.revision ?? "",
                "description":
                    "Test-only: \(reviewed.reason ?? "reviewed in Tools/dependency-allowlist.json"). Never linked into Qeetrix, and not resolved by an app.",
                "scope": "excluded",
                "purl": "pkg:swift/\(host)@\(package.state.version ?? "")",
                "licenses": [["expression": reviewed.licence]],
                "externalReferences": [["type": "vcs", "url": package.location]],
            ])
        }

        let bom: [String: Any] = [
            "bomFormat": "CycloneDX",
            "specVersion": "1.5",
            "version": 1,
            "metadata": [
                "component": [
                    "bom-ref": "qeetrix",
                    "type": "library",
                    "name": "Qeetrix",
                    "version": version,
                    "description": "The Qeetrix design system for SwiftUI (iOS, iPadOS). Distributed as a Swift package, from source.",
                    "purl": "pkg:swift/github.com/qeetgroup/qeetrix-ios@\(version)",
                    // No licence has been chosen for the package's own code (Documentation/Releases/LICENSE_COMPLIANCE.md).
                    "licenses": [["license": ["name": "No licence chosen (Qeet Group)"]]],
                ]
            ],
            "components": components,
            "dependencies": [
                ["ref": "qeetrix", "dependsOn": components.filter { $0["scope"] as? String == "required" }.compactMap { $0["bom-ref"] }]
            ],
        ]
        let data = try JSONSerialization.data(withJSONObject: bom, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        return String(decoding: data, as: UTF8.self) + "\n"
    }

    /// An npm integrity value (`sha512-<base64>`) as the hex digest CycloneDX expects.
    static func hex(fromIntegrity integrity: String) -> String? {
        guard integrity.hasPrefix("sha512-"), let digest = Data(base64Encoded: String(integrity.dropFirst("sha512-".count))) else {
            return nil
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
