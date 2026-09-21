// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "OpenMessageArchiveCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "OpenMessageArchiveCore", targets: ["OpenMessageArchiveCore"])
    ],
    targets: [
        .target(name: "OpenMessageArchiveCore"),
        .testTarget(
            name: "OpenMessageArchiveCoreTests",
            dependencies: ["OpenMessageArchiveCore"]
        )
    ]
)
