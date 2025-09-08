// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EZAudio",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "EZAudio", targets: ["EZAudio"]),
        .library(name: "EZAudioUI", targets: ["EZAudioUI"]),
        .library(name: "EZAudioSwiftUI", targets: ["EZAudioSwiftUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/michaeltyson/TPCircularBuffer.git", from: "1.6.2")
    ],
    targets: [
        .target(
            name: "EZAudio",
            dependencies: [
                .product(name: "TPCircularBuffer", package: "TPCircularBuffer")
            ],
            path: "Sources/EZAudio/Core",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Accelerate")
            ]
        ),
        .target(
            name: "EZAudioUI",
            dependencies: ["EZAudio"],
            path: "Sources/EZAudio/UI",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS])),
                .linkedFramework("QuartzCore")
            ]
        ),
        .target(
            name: "EZAudioSwiftUI",
            dependencies: ["EZAudioUI"],
            path: "Sources/EZAudio/SwiftUI"
        )
    ]
)
