// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Qeetrix",
    platforms: [
        .iOS(.v17),
        // Development host only: lets `swift build` and `swift test` run on a Mac. iOS is the
        // supported product platform; see README.md.
        .macOS(.v14),
    ],
    products: [
        .library(name: "Qeetrix", targets: ["Qeetrix"])
    ],
    targets: [
        .target(
            name: "Qeetrix",
            resources: [
                // Copied as folders so the bundle keeps each font beside its licence.
                .copy("Resources/Fonts"),
                .copy("Resources/Metadata"),
            ]
        ),
        .testTarget(
            name: "QeetrixTests",
            dependencies: ["Qeetrix"]
        ),
    ]
)
