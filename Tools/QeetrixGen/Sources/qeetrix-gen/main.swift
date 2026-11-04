import Foundation
import QeetrixGenCore

let usage = """
    usage: qeetrix-gen <command> [--root <repository>]

      generate      Regenerate Swift, provenance and the coverage report from Upstream/.
      verify        Fail if the snapshot does not match its lock or the generated files are stale.
      sync          Fetch the artifacts pinned in Upstream/pins.json and rewrite the lock.
      sync --check  Fetch the pinned artifacts and compare them with the lock; change nothing.
      api --symbol-graphs <dir> [--update]
                    Compare the public API in the symbol graphs with api/ (or rewrite it).
      dependencies --manifest <dump-package.json> [--checkouts <dir>]
                    Check Package.resolved against Tools/dependency-allowlist.json, with licences.
      resources     Check the built-in strings and the snapshot baselines.
      sbom --version <version> [--output <file>]
                    Write the release's CycloneDX bill of materials from the pins, lock and Package.resolved.
    """

/// The value after `flag`, if present.
func option(_ flag: String, in arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
    return arguments[index + 1]
}

/// The repository root: --root, or the nearest ancestor of the working directory holding the pins.
func repositoryRoot(_ arguments: [String]) throws -> URL {
    if let index = arguments.firstIndex(of: "--root"), index + 1 < arguments.count {
        return URL(fileURLWithPath: arguments[index + 1]).standardizedFileURL
    }
    var url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).standardizedFileURL
    while true {
        if FileManager.default.fileExists(atPath: url.appendingPathComponent(Lock.pinsPath).path) { return url }
        let parent = url.deletingLastPathComponent()
        if parent.path == url.path {
            throw GeneratorError("No \(Lock.pinsPath) above \(FileManager.default.currentDirectoryPath); pass --root.")
        }
        url = parent
    }
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("✗ \(message)\n".utf8))
    exit(1)
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard let command = arguments.first else {
    print(usage)
    exit(2)
}

do {
    let root = try repositoryRoot(arguments)
    switch command {
    case "generate":
        let changed = try Generator(root: root).write()
        print(changed.isEmpty ? "✓ Generated files are up to date." : changed.map { "✓ wrote \($0)" }.joined(separator: "\n"))
    case "verify":
        let problems = try Generator(root: root).drift()
        if !problems.isEmpty {
            fail("Generated files are out of date:\n  " + problems.joined(separator: "\n  ") + "\nRun Scripts/generate.sh.")
        }
        print("✓ Snapshot matches its lock and every generated file is current.")
    case "sync":
        try await UpstreamSync(root: root, log: { print($0) }).run(check: arguments.contains("--check"))
    case "api":
        guard let index = arguments.firstIndex(of: "--symbol-graphs"), index + 1 < arguments.count else {
            fail("api needs --symbol-graphs <directory>.")
        }
        let snapshot = try APISnapshot.render(
            symbolGraphs: try APISnapshot.graphs(in: URL(fileURLWithPath: arguments[index + 1])))
        let url = root.appendingPathComponent(APISnapshot.path)
        if arguments.contains("--update") {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(snapshot.utf8).write(to: url)
            print("✓ wrote \(APISnapshot.path)")
        } else {
            let committed = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            guard committed == snapshot else {
                let old = Set(committed.split(separator: "\n")), new = Set(snapshot.split(separator: "\n"))
                let added = new.subtracting(old).sorted().map { "  + \($0)" }
                let removed = old.subtracting(new).sorted().map { "  - \($0)" }
                fail(
                    "The public API changed:\n" + (removed + added).joined(separator: "\n")
                        + "\nIf intended, run Scripts/api-check.sh --update and note it in CHANGELOG.md.")
            }
            print("✓ Public API matches \(APISnapshot.path).")
        }
    case "dependencies":
        guard let manifest = option("--manifest", in: arguments) else {
            fail("dependencies needs --manifest <file with swift package dump-package output>.")
        }
        let problems = try DependencyReview.problems(
            allowlist: try Data(contentsOf: root.appendingPathComponent(DependencyReview.allowlistPath)),
            resolved: FileManager.default.contents(atPath: root.appendingPathComponent(DependencyReview.resolvedPath).path),
            manifest: try Data(contentsOf: URL(fileURLWithPath: manifest)),
            checkouts: URL(fileURLWithPath: option("--checkouts", in: arguments) ?? root.appendingPathComponent(".build/checkouts").path))
        if !problems.isEmpty {
            fail("Dependency review failed:\n  " + problems.joined(separator: "\n  "))
        }
        print("✓ Every dependency is test-only, allowlisted at its reviewed version, with the reviewed licence.")
    case "resources":
        let problems = try ResourceCheck(root: root).problems()
        if !problems.isEmpty {
            fail("Resource check failed:\n  " + problems.joined(separator: "\n  "))
        }
        print("✓ Built-in strings and snapshot baselines are complete and consistent.")
    case "sbom":
        guard let version = option("--version", in: arguments) else { fail("sbom needs --version <version>.") }
        let sbom = try SBOM.render(root: root, version: version)
        if let output = option("--output", in: arguments) {
            try Data(sbom.utf8).write(to: URL(fileURLWithPath: output))
            print("✓ wrote \(output)")
        } else {
            print(sbom, terminator: "")
        }
    default:
        print(usage)
        exit(2)
    }
} catch let error as GeneratorError {
    fail(error.message)
} catch {
    fail("\(error)")
}
