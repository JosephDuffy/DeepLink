// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "DeepLinks",
    platforms: [.macOS(.v10_13), .iOS(.v13)],
    products: [
        .library(name: "DeepLink", targets: ["DeepLink"]),
        .library(name: "CallsheetDeepLink", targets: ["CallsheetDeepLink"]),
    ],
    targets: [
        .target(name: "DeepLink"),
        .target(name: "CallsheetDeepLink", dependencies: ["DeepLink"])
    ]
)
