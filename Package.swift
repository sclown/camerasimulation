// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraSimulation",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "ImageGenerator",
            targets: ["ImageGenerator"]
        ),
        .library(
            name: "CameraSimulation",
            targets: ["CameraSimulation"]
        )
    ],
    targets: [
        .target(name: "ImageGenerator"),
        .target(name: "CameraSimulation", dependencies: ["ImageGenerator"]),
    ]
)
