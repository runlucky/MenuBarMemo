// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuBarMemo",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MenuBarMemo", targets: ["MenuBarMemo"])
    ],
    targets: [
        .executableTarget(
            name: "MenuBarMemo",
            path: "Sources/MenuBarMemo"
        ),
        .testTarget(
            name: "MenuBarMemoTests",
            dependencies: ["MenuBarMemo"],
            path: "Tests/MenuBarMemoTests"
        )
    ]
)
