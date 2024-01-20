// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Swift_App",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Swift_App",
            dependencies: ["Zip"],
            path: "."),
    ]
)