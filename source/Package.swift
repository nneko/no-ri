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

    targets: [
        .target(
            name: "no_ri_language",
            path: "no-ri/language"
        )
    ]
)