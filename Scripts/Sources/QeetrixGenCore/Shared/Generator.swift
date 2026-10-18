import Foundation

/// Generates everything derived from the upstream snapshot, and checks that what is committed is
/// exactly what the snapshot produces.
public struct Generator {
    public let root: URL

    /// Directories the generator owns: any file in them that it did not produce is stale.
    public static let ownedDirectories = [
        TokenEmitter.directory,
        "Sources/Qeetrix/Icons/Generated",
        "Sources/Qeetrix/Resources/Metadata",
    ]
    public static let coveragePath = "Documentation/Foundations/TOKEN_COVERAGE.md"
    public static let provenancePath = "Sources/Qeetrix/Resources/Metadata/token-provenance.json"

    public init(root: URL) {
        self.root = root
    }

    func read(_ path: String) throws -> Data {
        guard let data = try? Data(contentsOf: root.appendingPathComponent(path)) else {
            throw GeneratorError("\(path) is missing.")
        }
        return data
    }

    /// Every generated file, computed in memory from the snapshot. Fails if the snapshot does not
    /// match the lock.
    public func outputs() throws -> [GeneratedFile] {
        let provenance = try Lock.read(root: root)
        let problems = Lock.check(provenance, root: root)
        guard problems.isEmpty else { throw GeneratorError(problems.joined(separator: "\n")) }

        let source = try TokenSource(
            tokensJSON: try read("Scripts/Upstream/qeetrix-ui/tokens.json"),
            tokensCSS: String(decoding: try read("Scripts/Upstream/qeetrix-ui/tokens.css"), as: UTF8.self),
            indexCSS: String(decoding: try read("Scripts/Upstream/qeetrix-ui/index.css"), as: UTF8.self))
        let model = try TokenModel(source: source)

        let fonts = try provenance.fonts.map { font in
            FontSpec(
                family: font.family, webFamily: font.webFamily, repository: font.repository, tag: font.tag,
                resourceName: URL(fileURLWithPath: font.destination).deletingPathExtension().lastPathComponent,
                info: try FontInspector.inspect(try read(font.destination), context: font.destination))
        }
        let icons = try IconCatalog.load(
            manifest: try read("Scripts/Upstream/qeetrix-icons/icons.json"),
            svgDirectory: root.appendingPathComponent("Scripts/Upstream/qeetrix-icons/svg"))

        return try TokenEmitter(model: model, provenance: provenance, fonts: fonts).files()
            + [
                try IconEmitter(icons: icons, provenance: provenance).file(),
                GeneratedFile(path: Self.provenancePath, contents: Self.provenanceJSON(provenance, model: model, fonts: fonts)),
                GeneratedFile(path: Self.coveragePath, contents: CoverageReport(model: model, provenance: provenance).markdown()),
            ]
    }

    /// Writes the outputs, removing stale files from the owned directories. Returns the changed paths.
    public func write() throws -> [String] {
        let files = try outputs()
        var changed: [String] = []
        for file in files {
            let url = root.appendingPathComponent(file.path)
            let data = Data(file.contents.utf8)
            if (try? Data(contentsOf: url)) == data { continue }
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            changed.append(file.path)
        }
        for stale in try staleFiles(keeping: files) {
            try FileManager.default.removeItem(at: root.appendingPathComponent(stale))
            changed.append("\(stale) (removed)")
        }
        return changed
    }

    /// Problems with the committed outputs: stale, missing, edited by hand or left over.
    public func drift() throws -> [String] {
        let files = try outputs()
        var problems: [String] = []
        for file in files {
            guard let data = try? Data(contentsOf: root.appendingPathComponent(file.path)) else {
                problems.append("\(file.path) is missing.")
                continue
            }
            if data != Data(file.contents.utf8) {
                problems.append("\(file.path) differs from what the snapshot generates (edited by hand, or not regenerated).")
            }
        }
        problems += try staleFiles(keeping: files).map { "\($0) is not produced by the generator." }
        return problems
    }

    func staleFiles(keeping files: [GeneratedFile]) throws -> [String] {
        let produced = Set(files.map(\.path))
        var stale: [String] = []
        for directory in Self.ownedDirectories {
            let url = root.appendingPathComponent(directory)
            let names = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? []
            for name in names.sorted() where !name.hasPrefix(".") {
                let path = "\(directory)/\(name)"
                if !produced.contains(path) { stale.append(path) }
            }
        }
        return stale
    }

    /// The provenance record bundled with the library (`Resources/Metadata/token-provenance.json`).
    static func provenanceJSON(_ provenance: Provenance, model: TokenModel, fonts: [FontSpec]) -> String {
        OrderedJSON.object([
            (
                "$comment",
                .string("Generated by qeetrix-gen from Scripts/Upstream/upstream.lock.json — do not edit.")
            ),
            (
                "tokens",
                .object([
                    ("package", .string(provenance.qeetrixUIPackage)),
                    ("version", .string(provenance.qeetrixUIVersion)),
                    ("gitHead", .string(provenance.qeetrixUIGitHead)),
                    ("integrity", .string(provenance.qeetrixUIIntegrity)),
                    ("themes", .array(model.themes.map(OrderedJSON.string))),
                    ("generatedTokens", .number(String(model.included.count))),
                    ("excludedTokens", .number(String(model.excluded.count))),
                ])
            ),
            (
                "icons",
                .object([
                    ("package", .string(provenance.iconsPackage)),
                    ("version", .string(provenance.iconsVersion)),
                    ("repository", .string(provenance.iconsRepository)),
                    ("commit", .string(provenance.iconsCommit)),
                ])
            ),
            (
                "fonts",
                .array(
                    zip(provenance.fonts, fonts).map { locked, spec in
                        .object([
                            ("family", .string(locked.family)),
                            ("webFamily", .string(locked.webFamily)),
                            ("postScriptName", .string(spec.info.postScriptName)),
                            ("version", .string(spec.info.version)),
                            ("repository", .string(locked.repository)),
                            ("tag", .string(locked.tag)),
                            ("sha256", .string(locked.ttfSHA256)),
                        ])
                    })
            ),
            ("inputs", .object(provenance.files.map { ($0.path, .string($0.sha256)) })),
        ]).serialized()
    }
}
