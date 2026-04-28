// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KhmerDatePicker",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "KhmerDatePicker",
            targets: ["KhmerDatePicker"]
        )
    ],
    targets: [
        .target(
            name: "KhmerDatePicker",
            path: "Sources/KhmerDatePicker",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "KhmerDatePickerTests",
            dependencies: ["KhmerDatePicker"],
            path: "Tests/KhmerDatePickerTests"
        )
    ]
)
