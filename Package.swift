// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bootstrap",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .executable(name: "tamplier", targets: ["Tamplier"]),
        .library(name: "Bootstrap", targets: ["Bootstrap"]),
        .library(name: "BootstrapUtilites", targets: ["BootstrapUtilites"]),
        .library(name: "BootstrapUI", targets: ["BootstrapUI"]),
        .library(name: "BootstrapAPI", targets: ["BootstrapAPI"]),
        .library(name: "BootstrapModules", targets: ["BootstrapModules"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.3")),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "BootstrapUtilites",
            dependencies: [],
            path: "Sources/Utilites",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "BootstrapUI",
            dependencies: [
                "BootstrapUtilites"
            ],
            path: "Sources/UI",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "BootstrapAPI",
            dependencies: [
                "BootstrapUtilites"
            ],
            path: "Sources/API",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "Bootstrap",
            dependencies: [
                "BootstrapAPI",
                "BootstrapUI",
                "BootstrapUtilites"
            ],
            path: "Sources/Bootstrap",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "Tamplier",
            dependencies: [
                "Rainbow",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "BootstrapModules",
            dependencies: [
                "BootstrapAPI",
                "BootstrapUI",
                "BootstrapUtilites"
            ],
            path: "Sources/Modules",
            resources: [
                .process("Resources/Images.xcassets"),
                .process("Resources/Strings"),
                .process("Loading/LoadingSFViewController/LoadingSFView.xib"),
                .process("Authentication/AuthenticationView.xib")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        )
    ]
)
