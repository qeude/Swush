// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JWT",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "JWT",
            targets: ["JWT"]),
    ],
    targets: [
        .target(
            name: "JWT",
            dependencies: []),
        .testTarget(
            name: "JWTTests",
            dependencies: ["JWT"]),
    ]
)
