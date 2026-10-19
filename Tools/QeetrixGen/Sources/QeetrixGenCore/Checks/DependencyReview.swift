import Foundation

/// `qeetrix-gen dependencies`: the dependency and licence gate. Every pin in `Package.resolved` must be
/// on `Tools/dependency-allowlist.json` at the same location and version, its licence file must say
/// what the allowlist says, nothing allowlisted may be left unused, and no library target — only test
/// targets — may depend on a package.
public struct DependencyReview {
    public static let allowlistPath = "Tools/dependency-allowlist.json"
    public static let resolvedPath = "Package.resolved"

    struct Allowed: Decodable {
        let identity: String
        let location: String
        let version: String
        let licence: String
        let licenceFile: String
        let licenceText: String
    }

    struct Allowlist: Decodable {
        let packages: [Allowed]
    }

    struct Resolved: Decodable {
        struct Pin: Decodable {
            struct State: Decodable {
                let version: String?
                let revision: String?
            }

            let identity: String
            let location: String
            let state: State
        }

        let pins: [Pin]
    }

    /// The problems found; empty when the gate passes.
    ///
    /// - Parameters:
    ///   - manifest: `swift package dump-package` output.
    ///   - checkouts: SwiftPM's checkouts directory, where each package's licence file is read.
    public static func problems(allowlist: Data, resolved: Data?, manifest: Data, checkouts: URL) throws -> [String] {
        let allowed = try JSONDecoder().decode(Allowlist.self, from: allowlist).packages
        let pins = try resolved.map { try JSONDecoder().decode(Resolved.self, from: $0).pins } ?? []
        var problems: [String] = []

        for pin in pins {
            guard let entry = allowed.first(where: { $0.identity == pin.identity }) else {
                problems.append("\(pin.identity) is pinned but not on \(allowlistPath).")
                continue
            }
            if normalised(pin.location) != normalised(entry.location) {
                problems.append("\(pin.identity) comes from \(pin.location), not the reviewed \(entry.location).")
            }
            if pin.state.version != entry.version {
                problems.append(
                    "\(pin.identity) is pinned at \(pin.state.version ?? pin.state.revision ?? "?"), not the reviewed \(entry.version).")
            }
            let licence = checkouts.appendingPathComponent(pin.identity).appendingPathComponent(entry.licenceFile)
            if let text = try? String(contentsOf: licence, encoding: .utf8) {
                if !text.contains(entry.licenceText) {
                    problems.append("\(pin.identity)'s \(entry.licenceFile) no longer reads as \(entry.licence).")
                }
            } else {
                problems.append("\(pin.identity): no \(entry.licenceFile) in \(checkouts.path); run swift package resolve first.")
            }
        }
        for entry in allowed where !pins.contains(where: { $0.identity == entry.identity }) {
            problems.append("\(entry.identity) is on \(allowlistPath) but no longer pinned; remove it, and its notice.")
        }

        let package = try JSONSerialization.jsonObject(with: manifest) as? [String: Any] ?? [:]
        for target in package["targets"] as? [[String: Any]] ?? [] where target["type"] as? String != "test" {
            let name = target["name"] as? String ?? "?"
            for dependency in target["dependencies"] as? [[String: Any]] ?? [] where dependency["product"] != nil {
                problems.append("The \(name) target depends on a package product; Qeetrix must not ship a dependency to apps.")
            }
        }
        return problems
    }

    static func normalised(_ location: String) -> String {
        var value = location.lowercased()
        if value.hasSuffix(".git") { value.removeLast(4) }
        if value.hasSuffix("/") { value.removeLast() }
        return value
    }
}
