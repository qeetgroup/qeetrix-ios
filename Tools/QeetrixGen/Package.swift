// swift-tools-version: 6.0
// The Qeetrix iOS build tool. It lives in its own package so that apps depending on Qeetrix never
// resolve or build it.
import PackageDescription

let package = Package(
    name: "QeetrixGen",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "qeetrix-gen", targets: ["qeetrix-gen"])
    ],
    targets: [
        .target(name: "QeetrixGenCore"),
        .executableTarget(name: "qeetrix-gen", dependencies: ["QeetrixGenCore"]),
        .testTarget(name: "QeetrixGenCoreTests", dependencies: ["QeetrixGenCore"]),
    ]
)
