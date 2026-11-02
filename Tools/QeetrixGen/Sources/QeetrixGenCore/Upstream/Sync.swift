import CryptoKit
import Foundation

/// Fetches the artifacts pinned in `Upstream/pins.json` and refreshes the snapshot and lock.
///
/// Everything comes from the npm registry, as published:
///
/// - `@qeetrix/tokens`: the DTCG build (`dist/dtcg/`, resolver and resolved schemes), `tokens.css`,
///   and the fonts: the TTFs the package ships for native platforms, each checked against the sha256
///   and size `fonts/native.json` gives it, and against the full WOFF2 it was made from (the web
///   loads per-script subsets of that WOFF2).
/// - `@qeetrix/icons`: the pinned icons' entries from its JSON manifest (`dist/manifest.json`) and
///   the SVG file of every drawing each entry lists (`dist/svg/<shape>-<variant>/<id>.svg`), verbatim.
/// - `@qeetrix/react`: its component manifest (`dist/manifest.json`) and the compiled CSS of every
///   family iOS implements — the reference for each component's parts, metrics and states.
///
/// Each tarball is checked against the registry's integrity hash. With `check: true` nothing is
/// written; the fetched bytes are compared with the lock instead.
public struct UpstreamSync {
    let root: URL
    let log: @Sendable (String) -> Void

    public init(root: URL, log: @escaping @Sendable (String) -> Void) {
        self.root = root
        self.log = log
    }

    /// The directories the sync owns: anything in them it did not stage is removed.
    static let ownedDirectories = [
        "Upstream/qeetrix-tokens", "Upstream/qeetrix-icons", "Upstream/qeetrix-react", "Sources/Qeetrix/Resources/Fonts",
    ]

    struct Unpacked {
        let package: Provenance.Package
        let directory: URL

        func file(_ path: String) throws -> Data {
            guard let data = try? Data(contentsOf: directory.appendingPathComponent(path)) else {
                throw GeneratorError("\(package.name)@\(package.version) has no \(path).")
            }
            return data
        }
    }

    public func run(check: Bool) async throws {
        let pins = try OrderedJSON.parse(Data(contentsOf: root.appendingPathComponent(Lock.pinsPath)), context: Lock.pinsPath)
        let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-sync-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: scratch) }

        var staged: [(path: String, data: Data)] = []
        func pin(_ key: String) throws -> (OrderedJSON, String, String) {
            guard let entry = pins[key], let package = entry["package"]?.stringValue, let version = entry["version"]?.stringValue else {
                throw GeneratorError("pins.json: \(key) needs package and version.")
            }
            return (entry, package, version)
        }

        // @qeetrix/tokens
        let (tokensPin, tokensName, tokensVersion) = try pin("tokens")
        let tokens = try await fetchPackage(tokensName, tokensVersion, into: scratch)
        guard case let .object(fileMap)? = tokensPin["files"] else { throw GeneratorError("pins.json: tokens needs files.") }
        for (source, destination) in fileMap {
            guard let destination = destination.stringValue else { continue }
            if source.hasSuffix("/") {
                let files = try Self.files(under: tokens.directory.appendingPathComponent(source))
                guard !files.isEmpty else { throw GeneratorError("\(tokensName)@\(tokensVersion) has nothing under \(source).") }
                for file in files { staged.append((destination + file, try tokens.file(source + file))) }
            } else {
                staged.append((destination, try tokens.file(source)))
            }
        }

        // Fonts: the TTFs the tokens package ships for native platforms, as fonts/native.json describes them.
        guard let fontPins = pins["fonts"], let manifestPath = fontPins["manifest"]?.stringValue,
            let faces = fontPins["faces"]?.arrayValue
        else { throw GeneratorError("pins.json: fonts needs manifest and faces.") }
        let native = try OrderedJSON.parse(try tokens.file(manifestPath), context: manifestPath)
        let fontDirectory = manifestPath.split(separator: "/").dropLast().joined(separator: "/")
        guard let madeWith = native["fontTools"]?.stringValue, let described = native["fonts"]?.arrayValue else {
            throw GeneratorError("\(manifestPath): needs fontTools and fonts.")
        }
        var fonts: [Provenance.Font] = []
        for face in faces {
            func field(_ key: String) throws -> String {
                guard let value = face[key]?.stringValue else { throw GeneratorError("pins.json: a font face is missing \(key).") }
                return value
            }
            let file = try field("ttf")
            guard let entry = described.first(where: { $0["file"]?.stringValue == file }),
                let sha256 = entry["sha256"]?.stringValue, let bytes = entry["bytes"]?.doubleValue,
                let licence = entry["licence"]?.stringValue, let woff2File = entry["from"]?["file"]?.stringValue,
                let woff2SHA256 = entry["from"]?["sha256"]?.stringValue
            else { throw GeneratorError("\(manifestPath) doesn't describe \(file) (file, bytes, sha256, licence, from).") }
            let source = "\(fontDirectory)/\(file)"
            let ttf = try tokens.file(source)
            guard Lock.sha256(ttf) == sha256, Double(ttf.count) == bytes else {
                throw GeneratorError(
                    "\(source) is \(ttf.count) bytes with sha256 \(Lock.sha256(ttf)), but \(manifestPath) says \(swiftNumber(bytes)) bytes, \(sha256)."
                )
            }
            let woff2 = try tokens.file("\(fontDirectory)/\(woff2File)")
            guard Lock.sha256(woff2) == woff2SHA256 else {
                throw GeneratorError(
                    "\(fontDirectory)/\(woff2File) doesn't match the sha256 \(manifestPath) gives the WOFF2 \(file) was made from.")
            }
            let destination = try field("destination")
            log("✓ \(source) → \(destination) (sha256 and size match \(manifestPath))")
            staged.append((destination, ttf))
            staged.append((try field("licenseDestination"), try tokens.file("\(fontDirectory)/\(licence)")))
            fonts.append(
                Provenance.Font(
                    family: try field("family"), webFamily: try field("webFamily"), package: tokensName, source: source,
                    woff2SHA256: woff2SHA256, destination: destination, ttfSHA256: sha256,
                    madeWith: "fontTools \(madeWith), from \(fontDirectory)/\(woff2File)"))
        }

        // @qeetrix/icons
        let (iconsPin, iconsName, iconsVersion) = try pin("icons")
        let icons = try await fetchPackage(iconsName, iconsVersion, into: scratch)
        guard let names = iconsPin["icons"]?.arrayValue?.compactMap(\.stringValue) else {
            throw GeneratorError("pins.json: icons needs an icons list.")
        }
        let iconManifestPath = "package/dist/manifest.json"
        let manifest = try OrderedJSON.parse(try icons.file(iconManifestPath), context: iconManifestPath)
        guard let entries = manifest["icons"]?.arrayValue else { throw GeneratorError("\(iconManifestPath): no icons array.") }
        var selected: [OrderedJSON] = []
        for name in names {
            guard let entry = entries.first(where: { $0["name"]?.stringValue == name }) else {
                if let renamed = entries.first(where: { $0["aliases"]?.arrayValue?.contains(.string(name)) == true })?["name"]?.stringValue
                {
                    throw GeneratorError("\(iconsName)@\(iconsVersion) renamed \"\(name)\" to \"\(renamed)\": update Upstream/pins.json.")
                }
                throw GeneratorError("\(iconsName)@\(iconsVersion) has no icon named \"\(name)\".")
            }
            guard let id = entry["id"]?.stringValue, let shapes = entry["shapes"]?.arrayValue?.compactMap(\.stringValue),
                let variants = entry["variants"]?.arrayValue?.compactMap(\.stringValue)
            else { throw GeneratorError("\(iconManifestPath): \(name) needs id, shapes and variants.") }
            selected.append(entry)
            // The files follow the manifest: one per listed shape and variant, and none it doesn't list.
            for shape in IconCatalog.shapes {
                for variant in IconCatalog.variants {
                    let drawing = "\(shape)-\(variant)"
                    let source = "package/dist/svg/\(drawing)/\(id).svg"
                    let listed = shapes.contains(shape) && variants.contains(variant)
                    let exists = FileManager.default.fileExists(atPath: icons.directory.appendingPathComponent(source).path)
                    guard listed == exists else {
                        throw GeneratorError(
                            "\(iconsName)@\(iconsVersion): \(name) \(listed ? "lists \(drawing) but has no \(source)" : "has \(source), which its manifest entry doesn't list")."
                        )
                    }
                    if listed { staged.append(("Upstream/qeetrix-icons/svg/\(drawing)/\(name).svg", try icons.file(source))) }
                }
            }
        }
        staged.append(("Upstream/qeetrix-icons/icons.json", Data(OrderedJSON.array(selected).serialized().utf8)))
        staged.append(("Upstream/qeetrix-icons/LICENSE", try icons.file("package/LICENSE")))
        log("✓ \(iconsName)@\(iconsVersion) — \(names.count) icons")

        // @qeetrix/react
        let (reactPin, reactName, reactVersion) = try pin("react")
        let react = try await fetchPackage(reactName, reactVersion, into: scratch)
        let componentsPath = "package/dist/manifest.json"
        let componentsData = try react.file(componentsPath)
        let components = try OrderedJSON.parse(componentsData, context: componentsPath)
        staged.append(("Upstream/qeetrix-react/component-manifest.json", componentsData))
        guard let families = components.arrayValue else { throw GeneratorError("\(componentsPath): expected an array of families.") }
        let familyNames = Set(families.compactMap { $0["name"]?.stringValue })
        for family in reactPin["families"]?.arrayValue?.compactMap(\.stringValue) ?? [] {
            let name = family.split(separator: "/").last.map(String.init) ?? family
            guard familyNames.contains(name) else {
                throw GeneratorError("\(reactName)@\(reactVersion) has no family \"\(name)\" in its manifest.")
            }
            staged.append(("Upstream/qeetrix-react/css/\(family).css", try react.file("package/dist/css/\(family).css")))
        }
        log("✓ \(reactName)@\(reactVersion) — component manifest and \(reactPin["families"]?.arrayValue?.count ?? 0) families' CSS")

        staged.sort { $0.path < $1.path }
        let provenance = Provenance(
            packages: [tokens.package, icons.package, react.package], fonts: fonts,
            files: staged.map { ($0.path, Lock.sha256($0.data)) })

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

        let produced = Set(staged.map(\.path))
        for directory in Self.ownedDirectories {
            for file in try Self.files(under: root.appendingPathComponent(directory)) where !produced.contains("\(directory)/\(file)") {
                try FileManager.default.removeItem(at: root.appendingPathComponent("\(directory)/\(file)"))
                log("✓ removed \(directory)/\(file)")
            }
        }
        for (path, data) in staged {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
        }
        try Data(Lock.json(provenance).serialized().utf8).write(to: root.appendingPathComponent(Lock.path))
        log("✓ Wrote \(staged.count) files and \(Lock.path)")
    }

    // MARK: npm

    /// Downloads a package version from the npm registry, verifies the tarball against the registry's
    /// integrity hash and unpacks it.
    func fetchPackage(_ name: String, _ version: String, into scratch: URL) async throws -> Unpacked {
        let registry = "https://registry.npmjs.org/\(name.replacingOccurrences(of: "/", with: "%2F"))/\(version)"
        let metadata = try OrderedJSON.parse(try await fetch(registry), context: registry)
        guard let tarball = metadata["dist"]?["tarball"]?.stringValue,
            let integrity = metadata["dist"]?["integrity"]?.stringValue,
            let gitHead = metadata["gitHead"]?.stringValue
        else { throw GeneratorError("\(registry): missing dist.tarball, dist.integrity or gitHead.") }
        guard integrity.hasPrefix("sha512-") else { throw GeneratorError("\(registry): integrity is not sha512.") }
        let archive = try await fetch(tarball)
        let digest = "sha512-" + Data(SHA512.hash(data: archive)).base64EncodedString()
        guard digest == integrity else {
            throw GeneratorError("\(tarball): integrity mismatch — registry says \(integrity), download is \(digest).")
        }
        log("✓ \(name)@\(version) (\(gitHead.prefix(7))) — integrity verified")
        let folder = scratch.appendingPathComponent(name.replacingOccurrences(of: "/", with: "-"))
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let archiveURL = scratch.appendingPathComponent("\(folder.lastPathComponent).tgz")
        try archive.write(to: archiveURL)
        try run("/usr/bin/tar", ["-xzf", archiveURL.path, "-C", folder.path])
        return Unpacked(
            package: Provenance.Package(name: name, version: version, gitHead: gitHead, integrity: integrity), directory: folder)
    }

    // MARK: Helpers

    /// Every regular file under `directory`, as sorted relative paths. Empty when it doesn't exist.
    static func files(under directory: URL) throws -> [String] {
        let base = directory.resolvingSymlinksInPath().path
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return []
        }
        var files: [String] = []
        for case let url as URL in enumerator where (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true {
            let path = url.resolvingSymlinksInPath().path
            guard path.hasPrefix(base + "/") else { continue }
            let relative = String(path.dropFirst(base.count + 1))
            if !relative.split(separator: "/").contains(where: { $0.hasPrefix(".") }) { files.append(relative) }
        }
        return files.sorted()
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
        let errors = Pipe()
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        let message = errors.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw GeneratorError(
                "\(executable) \(arguments.joined(separator: " ")) failed (\(process.terminationStatus)): \(String(decoding: message, as: UTF8.self))"
            )
        }
        return data
    }
}
