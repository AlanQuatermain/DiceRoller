// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiceRoller",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DiceRoller",
            targets: ["DiceRoller"]),
        .executable(
            name: "roll",
            targets: ["RollUtil"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/roop/citron.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DiceRoller",
            dependencies: [
                .product(name: "CitronParserModule", package: "citron"),
                .product(name: "CitronLexerModule", package: "citron"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            exclude: ["Parser/Grammar.y"]),

        .executableTarget(
            name: "RollUtil",
            dependencies: [
                "DiceRoller",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),

        .testTarget(
            name: "DiceRollerTests",
            dependencies: ["DiceRoller"],
            exclude: ["ComparisonTests.swift.gyb", "ParserTests.swift.gyb"]),
    ]
)
