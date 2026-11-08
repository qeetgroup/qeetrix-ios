import Foundation

/// Generates everything derived from the upstream snapshot, and checks that what is committed is
/// exactly what the snapshot produces.
public struct Generator {
    public let root: URL

    /// Directories the generator owns: any file in them that it did not produce is stale.
    public static let ownedDirectories = [
        TokenEmitter.directory,
        "Sources/Qeetrix/Icons/Generated",
        IconEmitter.extendedDirectory,
        "Sources/Qeetrix/Resources/Metadata",
    ]
    public static let coveragePath = "docs/tokens.md"
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

    public static let tokensDirectory = "Upstream/qeetrix-tokens"

    /// The DTCG build, resolved as its resolver says, checked against the package's pre-resolved
    /// schemes and against tokens.css.
    public func tokenModel() throws -> (TokenModel, Stylesheet) {
        let source = try DTCGSource(resolver: "dtcg/qeetrix.resolver.json") { path in
            try read("\(Self.tokensDirectory)/\(path)")
        }
        var problems: [String] = []
        for scheme in source.colorSchemes {
            let name = "\(scheme).tokens.json"
            let file = try OrderedJSON.parse(try read("\(Self.tokensDirectory)/dtcg/\(name)"), context: name)
            problems += try source.disagreements(
                with: file, context: TokenContext(colorScheme: scheme, density: source.densities[0]), name: name)
        }
        guard problems.isEmpty else {
            throw GeneratorError(
                "The resolver's result and the package's resolved files disagree:\n  " + problems.prefix(20).joined(separator: "\n  "))
        }
        let model = try TokenModel(source: source)
        let stylesheet = try Stylesheet(String(decoding: try read("\(Self.tokensDirectory)/tokens.css"), as: UTF8.self))
        let disagreements = try stylesheet.disagreements(with: model)
        guard disagreements.isEmpty else {
            throw GeneratorError("tokens.css and the DTCG build disagree:\n  " + disagreements.prefix(20).joined(separator: "\n  "))
        }
        return (model, stylesheet)
    }

    /// Every generated file, computed in memory from the snapshot. Fails if the snapshot does not
    /// match the lock.
    public func outputs() throws -> [GeneratedFile] {
        let provenance = try Lock.read(root: root)
        let problems = Lock.check(provenance, root: root)
        guard problems.isEmpty else { throw GeneratorError(problems.joined(separator: "\n")) }

        let (model, stylesheet) = try tokenModel()
        let fonts = try provenance.fonts.map { font in
            FontSpec(
                family: font.family, webFamily: font.webFamily, package: font.package, source: font.source,
                resourceName: URL(fileURLWithPath: font.destination).deletingPathExtension().lastPathComponent,
                info: try FontInspector.inspect(try read(font.destination), context: font.destination))
        }
        let icons = try IconCatalog.load(
            manifest: try read("Upstream/qeetrix-icons/icons.json"),
            svgDirectory: root.appendingPathComponent("Upstream/qeetrix-icons/svg"))
        // The core icons are the pins; with `extended`, the snapshot holds every icon and the rest go to
        // QeetrixIconsExtended.
        let pins = try OrderedJSON.parse(try read(Lock.pinsPath), context: Lock.pinsPath)
        guard let pinned = pins["icons"]?["icons"]?.arrayValue?.compactMap(\.stringValue) else {
            throw GeneratorError("\(Lock.pinsPath): icons needs an icons list.")
        }
        let extendedCatalogue = pins["icons"]?["extended"] == .bool(true)
        let core = icons.filter { pinned.contains($0.name) }.sorted { $0.name < $1.name }
        let missing = Set(pinned).subtracting(core.map(\.name))
        guard missing.isEmpty else {
            throw GeneratorError("Upstream/qeetrix-icons/icons.json has no \(missing.sorted()) — run Scripts/sync-upstream.sh.")
        }
        let extended = extendedCatalogue ? icons.filter { !pinned.contains($0.name) }.sorted { $0.name < $1.name } : []

        return try TokenEmitter(model: model, stylesheet: stylesheet, provenance: provenance, fonts: fonts).files()
            + IconEmitter(core: core, extended: extended, provenance: provenance).files()
            + [
                GeneratedFile(path: Self.provenancePath, contents: try Self.provenanceJSON(provenance, model: model, fonts: fonts)),
                GeneratedFile(
                    path: Self.coveragePath,
                    contents: try CoverageReport(model: model, stylesheet: stylesheet, provenance: provenance).markdown()),
                GeneratedFile(path: TokenValuesReport.path, contents: try TokenValuesReport(model: model, provenance: provenance).json()),
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
    static func provenanceJSON(_ provenance: Provenance, model: TokenModel, fonts: [FontSpec]) throws -> String {
        func package(_ name: String) throws -> OrderedJSON {
            let package = try provenance.package(name)
            return .object([
                ("package", .string(package.name)),
                ("version", .string(package.version)),
                ("gitHead", .string(package.gitHead)),
                ("integrity", .string(package.integrity)),
            ])
        }
        var tokens = try package(Provenance.tokensPackage)
        if case var .object(pairs) = tokens {
            pairs += [
                ("colorSchemes", .array(model.source.colorSchemes.map(OrderedJSON.string))),
                ("densities", .array(model.source.densities.map(OrderedJSON.string))),
                ("generatedTokens", .number(String(model.included.count))),
                ("excludedTokens", .number(String(model.excluded.count))),
            ]
            tokens = .object(pairs)
        }
        return OrderedJSON.object([
            ("$comment", .string("Generated by qeetrix-gen from Upstream/upstream.lock.json — do not edit.")),
            ("tokens", tokens),
            ("icons", try package(Provenance.iconsPackage)),
            ("components", try package(Provenance.reactPackage)),
            (
                "fonts",
                .array(
                    zip(provenance.fonts, fonts).map { locked, spec in
                        .object([
                            ("family", .string(locked.family)),
                            ("webFamily", .string(locked.webFamily)),
                            ("postScriptName", .string(spec.info.postScriptName)),
                            ("version", .string(spec.info.version)),
                            ("package", .string(locked.package)),
                            ("source", .string(locked.source)),
                            ("woff2SHA256", .string(locked.woff2SHA256)),
                            ("sha256", .string(locked.ttfSHA256)),
                        ])
                    })
            ),
            ("inputs", .object(provenance.files.map { ($0.path, .string($0.sha256)) })),
        ]).serialized()
    }
}
