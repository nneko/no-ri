// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "no-ri",

    products: [
        .library(
            name: "no-ri_language",
            targets: ["no_ri_language"]
        )
    ],

    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),

        // Apple developed library for 🔑 Hashing (SHA2, HMAC), encryption (AES),
        // public-key (RSA and ECDSA etc), and random data generation.
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.12.3"),
    ],

    targets: [
        .target(
            name: "no_ri_language",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "no-ri/language"
        )
    ]
)