// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Qeetrix",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        // Development host only: lets `swift build` and `swift test` run on a Mac. iOS is the
        // supported product platform; see README.md.
        .macOS(.v14),
    ],
    products: [
        .library(name: "Qeetrix", targets: ["Qeetrix"])
    ],
    dependencies: [
        // Test-only: used by QeetrixSnapshotTests and nothing else, so an app that depends on Qeetrix
        // never resolves it (ADR 0009). Exact, so a baseline image never changes under a dependency bump.
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.19.6")
    ],
    targets: [
        .target(
            name: "Qeetrix",
            resources: [
                // Copied as folders so the bundle keeps each font beside its licence.
                .copy("Resources/Fonts"),
                // Notices that must travel with the library: the icon artwork's (the fonts' are in Fonts).
                .copy("Resources/Licenses"),
                .copy("Resources/Metadata"),
                .process("Resources/Localization"),
            ]
        ),
        .testTarget(
            name: "QeetrixTests",
            dependencies: ["Qeetrix"]
        ),
        .testTarget(
            name: "QeetrixSnapshotTests",
            dependencies: [
                "Qeetrix",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"]
        ),
    ]
)
