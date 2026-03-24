// swift-tools-version: 5.9
// This Package.swift documents SPM dependencies for AnchorBloom.
// In Xcode, add these via File > Add Package Dependencies.

import PackageDescription

let package = Package(
    name: "AnchorBloom",
    platforms: [.iOS(.v17)],
    dependencies: [
        // Firebase iOS SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0"),
    ],
    targets: [
        .target(
            name: "AnchorBloom",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            ],
            path: "AnchorBloom/AnchorBloom"
        ),
    ]
)
