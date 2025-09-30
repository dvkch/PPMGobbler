// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "PPMGobbler",
    platforms: [.macOS(.v13), .iOS(.v13)],
    products: [
        .library(
            name: "PPMGobbler",
            targets: ["PPMGobbler"]
        ),
    ],
    targets: [
        .target(
            name: "PPMGobbler",
            swiftSettings: [
                .unsafeFlags(["-Osize"], .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "PPMGobblerTests",
            dependencies: ["PPMGobbler"],
            resources: [.copy("Resources")]
        ),
    ]
)
