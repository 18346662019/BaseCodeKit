// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BaseKit",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BaseKit",
            targets: ["BaseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        
    ],
        
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BaseKit",
            dependencies: ["Swinject",
                           .product(name: "Alamofire", package: "Alamofire") // 关键配置
                         
        ],
        path: "Sources"),
        
        .testTarget(
            name: "BaseKitTests",
            dependencies: ["BaseKit"]
        ),
    ]
)
