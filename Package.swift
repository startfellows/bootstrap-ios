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
        .library(name: "BootstrapObjC", targets: ["BootstrapObjC"]),
        .library(name: "BootstrapMicrophone", targets: ["BootstrapMicrophone"]),
        .library(name: "BootstrapModules", targets: ["BootstrapModules"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.3")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.2")),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/jpsim/Yams", .upToNextMajor(from: "4.0.6")),
        .package(url: "https://github.com/stencilproject/Stencil", .upToNextMajor(from: "0.14.1"))
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
            name: "BootstrapObjC",
            dependencies: [],
            path: "Sources/ObjC",
            publicHeadersPath: "Include"
        ),
        .target(
            name: "BootstrapUI",
            dependencies: [
                "BootstrapObjC",
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
                "BootstrapUtilites",
                "KeychainAccess"
            ],
            path: "Sources/API",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "BootstrapMicrophone",
            dependencies: [
                "BootstrapUtilites"
            ],
            path: "Sources/Microphone",
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
                "Yams",
                "Stencil",
                "BootstrapUtilites",
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
