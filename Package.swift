// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NorthlightSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NorthlightSDK",
            targets: ["NorthlightSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NorthlightSDK",
            dependencies: [],
            path: "northlight-ios-sdk/Sources/NorthlightSDK"),
        .testTarget(
            name: "NorthlightSDKTests",
            dependencies: ["NorthlightSDK"],
            path: "Tests/NorthlightSDKTests"),
    ]
)