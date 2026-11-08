// swift-tools-version: 6.0
import PackageDescription

// The extended icons' size budget (docs/icons.md): the same program built twice in release, both linking
// QeetrixIconsExtended — one names no extended icon, the other twenty — measured by Scripts/icon-budget.sh.
// Built on the Mac host, which links with dead stripping as an app's release build does. Never shipped.
let package = Package(
    name: "IconBudget",
    platforms: [.macOS(.v14)],
    dependencies: [.package(name: "qeetrix-ios", path: "../..")],
    targets: [
        .executableTarget(
            name: "NoExtendedIcons",
            dependencies: [
                .product(name: "Qeetrix", package: "qeetrix-ios"),
                .product(name: "QeetrixIconsExtended", package: "qeetrix-ios"),
            ]),
        .executableTarget(
            name: "TwentyExtendedIcons",
            dependencies: [
                .product(name: "Qeetrix", package: "qeetrix-ios"),
                .product(name: "QeetrixIconsExtended", package: "qeetrix-ios"),
            ]),
    ]
)
