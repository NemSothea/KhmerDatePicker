// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KhmerDatePickerSwiftUI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "KhmerDatePickerSwiftUI",
            targets: ["KhmerDatePickerSwiftUI"]
        )
    ],
    targets: [
        .target(
            name: "KhmerDatePickerSwiftUI",
            path: "Sources/KhmerDatePickerSwiftUI",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "KhmerDatePickerSwiftUITests",
            dependencies: ["KhmerDatePickerSwiftUI"],
            path: "Tests/KhmerDatePickerSwiftUITests"
        )
    ]
)
