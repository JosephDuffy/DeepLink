// swift-tools-version:5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DeepLink",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "DeepLink", targets: ["DeepLink"]),
        .library(name: "CallsheetDeepLink", targets: ["CallsheetDeepLink"]),
        .executable(name: "deeplink", targets: ["DeepLinkTUI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            branch: "main"
        ),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(
            url: "https://github.com/rensbreur/SwiftTUI.git",
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

        .executableTarget(
            name: "DeepLinkTUI",
            dependencies: [
                "CallsheetDeepLink",
                "DeepLink",
                "SwiftTUI",
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
            name: "FeedbackAssistantDeepLink",
            dependencies: ["DeepLink"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "FeedbackAssistantDeepLinkTests",
            dependencies: [
                "DeepLinkTestSupport",
                "FeedbackAssistantDeepLink",
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
