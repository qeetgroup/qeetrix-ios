import Foundation

/// `qeetrix-gen resources`: the package's hand-maintained resources are consistent.
///
/// - Every built-in string (`qeetrix.*`) used in the library is defined in every localisation, and every
///   defined one is used. Each `.strings` table parses.
/// - Where snapshot baselines have been recorded (they are local, never committed), every snapshot test has
///   its four and every baseline belongs to a test.
///
/// Fonts, icons and generated metadata are covered by `verify`, which holds them to the lock.
public struct ResourceCheck {
    public let root: URL
    static let localizationPath = "Sources/Qeetrix/Resources/Localization"
    static let snapshotTestsPath = "Tests/QeetrixSnapshotTests"
    static let snapshotConfigurations = ["light", "dark", "ax3", "rtl"]

    public init(root: URL) {
        self.root = root
    }

    public func problems() throws -> [String] {
        try strings() + snapshots()
    }

    func strings() throws -> [String] {
        var problems: [String] = []
        let used = try keysUsed()
        let localizations = try FileManager.default.contentsOfDirectory(atPath: url(Self.localizationPath).path)
            .filter { $0.hasSuffix(".lproj") }.sorted()
        if localizations.isEmpty { problems.append("No .lproj folders in \(Self.localizationPath).") }
        for localization in localizations {
            let path = "\(Self.localizationPath)/\(localization)/Localizable.strings"
            guard let data = FileManager.default.contents(atPath: url(path).path) else {
                problems.append("\(path) is missing.")
                continue
            }
            guard let table = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
                problems.append("\(path) does not parse as a strings table.")
                continue
            }
            for key in used.subtracting(table.keys).sorted() {
                problems.append("\(key) is used in Sources/Qeetrix but not defined in \(path).")
            }
            for key in Set(table.keys).subtracting(used).sorted() {
                problems.append("\(key) is defined in \(path) but never used.")
            }
        }
        return problems
    }

    /// The `qeetrix.*` keys the library looks up in its own bundle.
    func keysUsed() throws -> Set<String> {
        var keys: Set<String> = []
        let regex = try NSRegularExpression(pattern: #""(qeetrix\.[a-z0-9.-]+)",\s*bundle:\s*\.module"#)
        for file in try swiftFiles(under: "Sources/Qeetrix") {
            let text = try String(contentsOf: file, encoding: .utf8)
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                keys.insert(String(text[Range(match.range(at: 1), in: text)!]))
            }
        }
        return keys
    }

    func snapshots() throws -> [String] {
        var problems: [String] = []
        var expected: Set<String> = []
        let testRegex = try NSRegularExpression(pattern: #"@Test\([^\n]*\)\s*\n\s*func\s+([A-Za-z0-9_]+)\s*\("#)
        for file in try swiftFiles(under: Self.snapshotTestsPath) where !file.path.contains("/Support/") {
            let text = try String(contentsOf: file, encoding: .utf8)
            guard text.contains("assertSpecimen(") else { continue }
            let family = file.deletingLastPathComponent().lastPathComponent
            let suite = file.deletingPathExtension().lastPathComponent
            for match in testRegex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                let test = String(text[Range(match.range(at: 1), in: text)!])
                for configuration in Self.snapshotConfigurations {
                    expected.insert("\(Self.snapshotTestsPath)/__Snapshots__/\(family)/\(suite)/\(test).\(configuration).png")
                }
            }
        }
        var recorded: Set<String> = []
        let baselines = url("\(Self.snapshotTestsPath)/__Snapshots__")
        if let enumerator = FileManager.default.enumerator(at: baselines, includingPropertiesForKeys: nil) {
            let base = root.resolvingSymlinksInPath().path
            for case let file as URL in enumerator where file.pathExtension == "png" {
                recorded.insert(String(file.resolvingSymlinksInPath().path.dropFirst(base.count + 1)))
            }
        }
        // Baselines are recorded locally and never committed (screenshots stay out of git): a fresh clone
        // has none, and that is not an error. Once any are recorded, the set must be complete.
        if recorded.isEmpty { return [] }
        for missing in expected.subtracting(recorded).sorted() {
            problems.append("\(missing) is missing: record it (SNAPSHOT_TESTING_RECORD=all, ADR 0009).")
        }
        for orphan in recorded.subtracting(expected).sorted() {
            problems.append("\(orphan) belongs to no snapshot test: delete it.")
        }
        return problems
    }

    func swiftFiles(under path: String) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: url(path), includingPropertiesForKeys: nil) else { return [] }
        return enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }.sorted { $0.path < $1.path }
    }

    func url(_ path: String) -> URL {
        root.appendingPathComponent(path)
    }
}
