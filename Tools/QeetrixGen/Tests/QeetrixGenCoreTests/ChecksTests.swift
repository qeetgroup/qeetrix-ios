import Foundation
import Testing

@testable import QeetrixGenCore

@Suite("Dependency review")
struct DependencyReviewTests {
    let allowlist = Data(
        """
        {"packages": [{"identity": "swift-snapshot-testing", "location": "https://github.com/pointfreeco/swift-snapshot-testing",
          "version": "1.19.6", "licence": "MIT", "licenceFile": "LICENSE", "licenceText": "MIT License"}]}
        """.utf8)

    func resolved(_ identity: String = "swift-snapshot-testing", version: String = "1.19.6", location: String? = nil) -> Data {
        Data(
            """
            {"pins": [{"identity": "\(identity)", "location": "\(location ?? "https://github.com/pointfreeco/\(identity).git")",
              "state": {"version": "\(version)", "revision": "28e5de0"}}], "version": 3}
            """.utf8)
    }

    func manifest(libraryUsesProduct: Bool = false) -> Data {
        let library = libraryUsesProduct ? #"[{"product": ["SnapshotTesting", "swift-snapshot-testing", null, null]}]"# : "[]"
        return Data(
            """
            {"targets": [{"name": "Qeetrix", "type": "regular", "dependencies": \(library)},
              {"name": "QeetrixSnapshotTests", "type": "test", "dependencies": [{"product": ["SnapshotTesting", "swift-snapshot-testing", null, null]}]}]}
            """.utf8)
    }

    func checkouts(licence: String = "MIT License\n\nCopyright (c) 2019 Point-Free, Inc.") throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-checkouts-\(UUID().uuidString)")
        let package = directory.appendingPathComponent("swift-snapshot-testing")
        try FileManager.default.createDirectory(at: package, withIntermediateDirectories: true)
        try Data(licence.utf8).write(to: package.appendingPathComponent("LICENSE"))
        return directory
    }

    @Test("A reviewed, test-only dependency passes")
    func passes() throws {
        let problems = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved(), manifest: manifest(), checkouts: try checkouts())
        #expect(problems.isEmpty)
    }

    @Test("An unreviewed package, version, source or licence fails")
    func fails() throws {
        let checkouts = try checkouts()
        let unknown = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved("left-pad"), manifest: manifest(), checkouts: checkouts)
        #expect(unknown.contains { $0.contains("left-pad is pinned but not on") })
        #expect(unknown.contains { $0.contains("swift-snapshot-testing is on") && $0.contains("no longer pinned") })
        let bumped = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved(version: "1.20.0"), manifest: manifest(), checkouts: checkouts)
        #expect(bumped.contains { $0.contains("1.20.0, not the reviewed 1.19.6") })
        let fork = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved(location: "https://github.com/someone/swift-snapshot-testing"), manifest: manifest(),
            checkouts: checkouts)
        #expect(fork.contains { $0.contains("not the reviewed https://github.com/pointfreeco") })
        let relicensed = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved(), manifest: manifest(),
            checkouts: try self.checkouts(licence: "Business Source License"))
        #expect(relicensed.contains { $0.contains("no longer reads as MIT") })
    }

    @Test("A library target that depends on a package fails")
    func libraryDependency() throws {
        let problems = try DependencyReview.problems(
            allowlist: allowlist, resolved: resolved(), manifest: manifest(libraryUsesProduct: true), checkouts: try checkouts())
        #expect(problems == ["The Qeetrix target depends on a package product; Qeetrix must not ship a dependency to apps."])
    }
}

@Suite("Resource check")
struct ResourceCheckTests {
    struct Fixture {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-resources-\(UUID().uuidString)")

        func write(_ path: String, _ text: String) throws {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(text.utf8).write(to: url)
        }

        /// A library using one string, a table defining it, and one snapshot test with its four baselines.
        static func complete() throws -> Fixture {
            let fixture = Fixture()
            try fixture.write("Sources/Qeetrix/Strings.swift", #"let loading = Text("qeetrix.spinner.label", bundle: .module)"#)
            try fixture.write(
                "Sources/Qeetrix/Resources/Localization/en.lproj/Localizable.strings", #""qeetrix.spinner.label" = "Loading";"#)
            try fixture.write(
                "Tests/QeetrixSnapshotTests/Spinner/SpinnerSnapshotTests.swift",
                "@Test(\"Sizes\")\nfunc sizes() {\n    assertSpecimen(QeetrixSpinner())\n}\n")
            for configuration in ResourceCheck.snapshotConfigurations {
                try fixture.write("Tests/QeetrixSnapshotTests/__Snapshots__/Spinner/SpinnerSnapshotTests/sizes.\(configuration).png", "png")
            }
            return fixture
        }
    }

    @Test("Complete strings and baselines pass")
    func passes() throws {
        let fixture = try Fixture.complete()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        #expect(try ResourceCheck(root: fixture.root).problems().isEmpty)
    }

    @Test("A fresh clone, with no baselines recorded, passes — they are local, never committed")
    func noBaselines() throws {
        let fixture = try Fixture.complete()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try FileManager.default.removeItem(at: fixture.root.appendingPathComponent("Tests/QeetrixSnapshotTests/__Snapshots__"))
        #expect(try ResourceCheck(root: fixture.root).problems().isEmpty)
    }

    @Test("A missing or unused string, an unparseable table, a missing or orphaned baseline all fail")
    func fails() throws {
        let fixture = try Fixture.complete()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try fixture.write("Sources/Qeetrix/More.swift", #"let required = Text("qeetrix.field.required", bundle: .module)"#)
        try fixture.write("Sources/Qeetrix/Resources/Localization/fr.lproj/Localizable.strings", #""qeetrix.spinner.label" = "Chargement""#)
        try FileManager.default.removeItem(
            at: fixture.root.appendingPathComponent("Tests/QeetrixSnapshotTests/__Snapshots__/Spinner/SpinnerSnapshotTests/sizes.rtl.png"))
        try fixture.write("Tests/QeetrixSnapshotTests/__Snapshots__/Spinner/SpinnerSnapshotTests/old.light.png", "png")
        let problems = try ResourceCheck(root: fixture.root).problems()
        #expect(problems.contains { $0.hasPrefix("qeetrix.field.required is used") && $0.contains("en.lproj") })
        #expect(problems.contains { $0.contains("fr.lproj/Localizable.strings does not parse") })
        #expect(problems.contains { $0.contains("sizes.rtl.png is missing") })
        #expect(problems.contains { $0.contains("old.light.png belongs to no snapshot test") })

        try fixture.write("Sources/Qeetrix/More.swift", "")
        try fixture.write(
            "Sources/Qeetrix/Resources/Localization/fr.lproj/Localizable.strings",
            #""qeetrix.spinner.label" = "Chargement"; "qeetrix.unused" = "x";"#)
        #expect(
            try ResourceCheck(root: fixture.root).strings() == [
                "qeetrix.unused is defined in Sources/Qeetrix/Resources/Localization/fr.lproj/Localizable.strings but never used."
            ])
    }
}
