// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ShareTouchServer",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
    ]
)

