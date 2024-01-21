// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Swift_App",
    dependencies: [
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.1"),
    ],
    targets: [
        .target(
            name: "Swift_App",
            dependencies: ["Zip"],
            path: ".",
            sources: ["main.swift"],
            resources: [
                .process("certificates/certificate.pem"),
                .process("pass.pkpass"),
                .process("qr_codes/qr_data.txt"),
                .process("qr_codes/qr_code.png"),
                .process("certificates/key.pem"),
                .process("certificates/wwdr.pem")
            ]
        ),
    ]
)