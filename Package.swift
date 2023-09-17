// swift-tools-version:5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DeepLinks",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
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
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "DeepLinkTestSupport",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
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
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DeepLinkPluginTests",
            dependencies: [
                "DeepLinkPlugin",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "CallsheetDeepLink",
            dependencies: ["DeepLink"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CallsheetDeepLinkTests",
            dependencies: [
                "CallsheetDeepLink",
                "DeepLinkTestSupport",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "IvoryDeepLink",
            dependencies: ["DeepLink"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "IvoryDeepLinkTests",
            dependencies: [
                "DeepLinkTestSupport",
                "IvoryDeepLink",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "MailDeepLink",
            dependencies: ["DeepLink"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "MailDeepLinkTests",
            dependencies: [
                "DeepLinkTestSupport",
                "MailDeepLink",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .target(
            name: "OvercastDeepLink",
            dependencies: ["DeepLink"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "OvercastDeepLinkTests",
            dependencies: [
                "DeepLinkTestSupport",
                "OvercastDeepLink",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
