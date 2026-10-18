import CryptoKit
import Foundation

/// Fetches the artifacts pinned in `Scripts/Upstream/pins.json` and refreshes the snapshot and lock.
///
/// - `@qeetrix/ui` comes from the npm registry: the published tarball, checked against its registry
///   integrity, is the output of qeetrix-ui's own Style Dictionary build.
/// - Fonts come from their projects' releases as TTF. Each is accepted only if the same release's
///   WOFF2 is byte-identical to the WOFF2 inside the pinned `@qeetrix/ui` tarball — proof that iOS
///   bundles the exact font the web ships, in its native format.
/// - Icons come from the pinned qeetrix-icons commit: the manifest entries and SVGs for the pinned names.
///
/// With `check: true` nothing is written; the fetched bytes are compared with the lock instead.
public struct UpstreamSync {
    let root: URL
    let log: @Sendable (String) -> Void

    public init(root: URL, log: @escaping @Sendable (String) -> Void) {
        self.root = root
        self.log = log
    }

    public func run(check: Bool) async throws {
        let pins = try OrderedJSON.parse(Data(contentsOf: root.appendingPathComponent(Lock.pinsPath)), context: Lock.pinsPath)
        let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-sync-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: scratch) }

        var staged: [(path: String, data: Data)] = []

        // @qeetrix/ui
        guard let ui = pins["qeetrixUI"], let package = ui["package"]?.stringValue, let version = ui["version"]?.stringValue,
            case let .object(fileMap)? = ui["files"]
        else { throw GeneratorError("pins.json: qeetrixUI needs package, version and files.") }
        let registry = "https://registry.npmjs.org/\(package.replacingOccurrences(of: "/", with: "%2F"))/\(version)"
        let metadata = try OrderedJSON.parse(try await fetch(registry), context: registry)
        guard let tarball = metadata["dist"]?["tarball"]?.stringValue,
            let integrity = metadata["dist"]?["integrity"]?.stringValue,
            let gitHead = metadata["gitHead"]?.stringValue
        else { throw GeneratorError("\(registry): missing dist.tarball, dist.integrity or gitHead.") }
        let archive = try await fetch(tarball)
        let digest = "sha512-" + Data(SHA512.hash(data: archive)).base64EncodedString()
        guard digest == integrity else {
            throw GeneratorError("\(tarball): integrity mismatch — registry says \(integrity), download is \(digest).")
        }
        log("✓ \(package)@\(version) (\(gitHead.prefix(7))) — integrity verified")
        let unpacked = scratch.appendingPathComponent("ui")
        try FileManager.default.createDirectory(at: unpacked, withIntermediateDirectories: true)
        let archiveURL = scratch.appendingPathComponent("ui.tgz")
        try archive.write(to: archiveURL)
        try run("/usr/bin/tar", ["-xzf", archiveURL.path, "-C", unpacked.path])
        func packageFile(_ path: String) throws -> Data {
            guard let data = try? Data(contentsOf: unpacked.appendingPathComponent(path)) else {
                throw GeneratorError("\(package)@\(version) has no \(path).")
            }
            return data
        }
        for (source, destination) in fileMap {
            guard let destination = destination.stringValue else { continue }
            staged.append((destination, try packageFile(source)))
        }

        // Fonts
        var fonts: [Provenance.Font] = []
        for font in pins["fonts"]?.arrayValue ?? [] {
            func field(_ key: String) throws -> String {
                guard let value = font[key]?.stringValue else { throw GeneratorError("pins.json: a font is missing \(key).") }
                return value
            }
            let repository = try field("repository")
            let tag = try field("tag")
            let webFile = try field("webFile")
            let ttf: Data
            let woff2: Data
            if let asset = font["releaseAsset"]?.stringValue {
                let zip = scratch.appendingPathComponent(asset)
                try await fetch("https://github.com/\(repository)/releases/download/\(tag)/\(asset)").write(to: zip)
                ttf = try run("/usr/bin/unzip", ["-p", zip.path, try field("ttf")])
                woff2 = try run("/usr/bin/unzip", ["-p", zip.path, try field("woff2")])
            } else {
                ttf = try await fetch(Self.raw(repository, tag, try field("ttf")))
                woff2 = try await fetch(Self.raw(repository, tag, try field("woff2")))
            }
            let web = try packageFile(webFile)
            guard woff2 == web else {
                throw GeneratorError(
                    "\(repository) \(tag): \(try field("woff2")) is not byte-identical to \(webFile) in \(package)@\(version). The TTF would not be the font the web ships; pin the release the web uses."
                )
            }
            log("✓ \(repository) \(tag) — WOFF2 matches \(webFile); taking the TTF")
            let license = try await fetch(Self.raw(repository, tag, try field("license")))
            staged.append((try field("destination"), ttf))
            staged.append((try field("licenseDestination"), license))
            fonts.append(
                Provenance.Font(
                    family: try field("family"), webFamily: try field("webFamily"), repository: repository, tag: tag,
                    destination: try field("destination"), ttfSHA256: Lock.sha256(ttf), woff2SHA256: Lock.sha256(woff2),
                    webFile: webFile))
        }

        // Icons
        guard let icons = pins["qeetrixIcons"], let iconRepository = icons["repository"]?.stringValue,
            let commit = icons["commit"]?.stringValue, let iconPackage = icons["package"]?.stringValue,
            let iconVersion = icons["version"]?.stringValue,
            let names = icons["icons"]?.arrayValue?.compactMap(\.stringValue)
        else { throw GeneratorError("pins.json: qeetrixIcons needs repository, commit, package, version and icons.") }
        let manifestURL = Self.raw(iconRepository, commit, "icon-manifest.json")
        let manifest = try OrderedJSON.parse(try await fetch(manifestURL), context: manifestURL)
        let entries = manifest["icons"]?.arrayValue ?? []
        var selected: [OrderedJSON] = []
        for name in names {
            guard let entry = entries.first(where: { $0["name"]?.stringValue == name }),
                let category = entry["category"]?.stringValue,
                let shapes = entry["shapes"]?.arrayValue?.compactMap(\.stringValue),
                let variants = entry["variants"]?.arrayValue?.compactMap(\.stringValue)
            else { throw GeneratorError("\(iconRepository)@\(commit.prefix(7)) has no icon named \"\(name)\".") }
            selected.append(entry)
            for shape in shapes {
                for variant in variants {
                    let source = "icons/\(shape)-\(variant)/\(category)/\(name).svg"
                    staged.append(
                        (
                            "Scripts/Upstream/qeetrix-icons/svg/\(shape)-\(variant)/\(name).svg",
                            try await fetch(Self.raw(iconRepository, commit, source))
                        ))
                }
            }
        }
        staged.append(("Scripts/Upstream/qeetrix-icons/icons.json", Data(OrderedJSON.array(selected).serialized().utf8)))
        staged.append(("Scripts/Upstream/qeetrix-icons/LICENSE", try await fetch(Self.raw(iconRepository, commit, "LICENSE"))))
        log("✓ \(iconRepository)@\(commit.prefix(7)) — \(names.count) icons")

        staged.sort { $0.path < $1.path }
        let provenance = Provenance(
            qeetrixUIPackage: package, qeetrixUIVersion: version, qeetrixUIGitHead: gitHead, qeetrixUIIntegrity: integrity,
            iconsRepository: iconRepository, iconsPackage: iconPackage, iconsVersion: iconVersion, iconsCommit: commit,
            fonts: fonts, files: staged.map { ($0.path, Lock.sha256($0.data)) })

        if check {
            let locked = try Lock.read(root: root)
            guard locked == provenance else {
                let lockedFiles = Dictionary(uniqueKeysWithValues: locked.files.map { ($0.path, $0.sha256) })
                let drift = provenance.files.filter { lockedFiles[$0.path] != $0.sha256 }.map(\.path)
                throw GeneratorError(
                    "The pinned upstream artifacts no longer match the lock. Differing files: \(drift.isEmpty ? "none (metadata changed)" : drift.joined(separator: ", "))."
                )
            }
            log("✓ Upstream matches \(Lock.path)")
            return
        }

        let svgRoot = root.appendingPathComponent("Scripts/Upstream/qeetrix-icons/svg")
        try? FileManager.default.removeItem(at: svgRoot)  // drop drawings of icons no longer pinned
        for (path, data) in staged {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
        }
        try Data(Lock.json(provenance).serialized().utf8).write(to: root.appendingPathComponent(Lock.path))
        log("✓ Wrote \(staged.count) files and \(Lock.path)")
    }

    static func raw(_ repository: String, _ ref: String, _ path: String) -> String {
        "https://raw.githubusercontent.com/\(repository)/\(ref)/\(path)"
    }

    func fetch(_ address: String) async throws -> Data {
        guard let url = URL(string: address) else { throw GeneratorError("Bad URL \(address).") }
        var request = URLRequest(url: url)
        request.timeoutInterval = 120
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GeneratorError("GET \(address) failed (\((response as? HTTPURLResponse)?.statusCode ?? 0)).")
        }
        return data
    }

    @discardableResult
    func run(_ executable: String, _ arguments: [String]) throws -> Data {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw GeneratorError("\(executable) \(arguments.joined(separator: " ")) failed (\(process.terminationStatus)).")
        }
        return data
    }
}
