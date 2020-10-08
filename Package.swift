// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwifterJSON",
    products: [
        .library(
            name: "SwifterJSON",
            targets: ["SwifterJSON"]
        )
    ],
    targets: [
        .target(
            name: "SwifterJSON",
            dependencies: [],
            path: "Source"
        )
    ]
)
