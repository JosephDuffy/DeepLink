// swift-tools-version:5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DeepLinks",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "DeepLink", targets: ["DeepLink"]),
        .library(name: "CallsheetDeepLink", targets: ["CallsheetDeepLink"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "DeepLink",
            dependencies: [
                "DeepLinkPlugin",
            ]
        ),
        .macro(
            name: "DeepLinkPlugin",
            dependencies: [
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "DeepLinkPluginTests",
            dependencies: [
                "DeepLinkPlugin",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),

        .target(name: "CallsheetDeepLink", dependencies: ["DeepLink"]),
        .testTarget(
            name: "CallsheetDeepLinkTests",
            dependencies: [
                "CallsheetDeepLink",
            ]
        ),

        .target(name: "MailDeepLink", dependencies: ["DeepLink"]),
        .testTarget(
            name: "MailDeepLinkTests",
            dependencies: [
                "MailDeepLink",
            ]
        ),
    ]
)
