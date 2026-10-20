# Installing and updating

Add Qeetrix by version, take its fixes, and know what each version promises.

## Overview

Qeetrix is a Swift package, distributed from source through the private repository
`github.com/qeetgroup/qeetrix-ios`. Its releases are Git tags in Semantic Versioning form.

> Note: No version has been tagged yet. The first candidate, 0.1.0-rc.1, is prepared but unreleased.
> Until it is tagged, the package can only be added by branch or revision, for evaluation.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/qeetgroup/qeetrix-ios.git`, choose **Up to Next Minor Version** from the version
you want, and add the `Qeetrix` library to your app target. In a package manifest:

```swift
dependencies: [
    .package(url: "https://github.com/qeetgroup/qeetrix-ios.git", .upToNextMinor(from: "0.1.0"))
],
targets: [
    .target(name: "App", dependencies: [.product(name: "Qeetrix", package: "qeetrix-ios")])
]
```

To try a release candidate, pin it exactly — `exact: "0.1.0-rc.1"` — since SwiftPM never picks a
pre-release on its own.

Your account, and any CI that builds the app, needs read access to the repository.

### Requirements

- iOS or iPadOS 17 or later.
- Xcode with Swift 6. The pinned, tested toolchain is Xcode 27.1.
- Nothing else: Qeetrix has no dependencies, and needs no Node.js, web packages or generator to build.
  Its fonts, licences and metadata come in its resource bundle.

### What versions promise

Before 1.0, a minor version (0.1 to 0.2) may break source, always with a migration note; a patch
(0.1.0 to 0.1.1) never does. That is why the rule above is **up to next minor**: `from: "0.1.0"` alone
would accept 0.2 and its breaks. From 1.0, standard Semantic Versioning applies.

Only source compatibility is promised; the package isn't distributed as a binary.

### Updating

Read the release notes before moving to a new minor version. Breaking changes and their migrations come
first. <doc:Migrating> collects them.
