# Installing and updating

Add Qeetrix by version, take its fixes, and know what each version promises.

## Overview

Qeetrix is a Swift package, distributed from source through its public repository
`github.com/qeetgroup/qeetrix-ios`. Its releases are Git tags in Semantic Versioning form, the bare
version with no `v` (`0.3.0`).

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/qeetgroup/qeetrix-ios.git`, choose **Up to Next Minor Version** from the version
you want, and add the `Qeetrix` library to your app target. In a package manifest:

```swift
dependencies: [
    .package(url: "https://github.com/qeetgroup/qeetrix-ios.git", .upToNextMinor(from: "0.3.0"))
],
targets: [
    .target(name: "App", dependencies: [.product(name: "Qeetrix", package: "qeetrix-ios")])
]
```

To try a release candidate, pin it exactly — `exact: "0.4.0-rc.1"`, say — since SwiftPM never picks a
pre-release on its own.

The repository is public: no account, token or credential is needed, in Xcode or in CI.

### Requirements

- iOS or iPadOS 17 or later.
- Xcode with Swift 6. The pinned, tested toolchain is Xcode 27.1.
- Nothing else: Qeetrix has no dependencies, and needs no Node.js, web packages or generator to build.
  Its fonts, licences and metadata come in its resource bundle.

### What versions promise

Before 1.0, a minor version (0.3 to 0.4) may break source, always with a migration note; a patch
(0.3.0 to 0.3.1) never does. That is why the rule above is **up to next minor**: `from: "0.3.0"` alone
would accept 0.4 and its breaks. From 1.0, standard Semantic Versioning applies.

Only source compatibility is promised; the package isn't distributed as a binary.

### Updating

Read the release notes before moving to a new minor version. Breaking changes and their migrations come
first. <doc:Migrating> collects them.
