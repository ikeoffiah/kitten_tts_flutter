// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "kitten_tts_flutter",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "kitten-tts-flutter", targets: ["kitten_tts_flutter"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "espeak_ng",
            path: "Sources/espeak_ng",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("include"),
                .headerSearchPath("include/espeak-ng"),
                .headerSearchPath("ucd-include"),
                .define("HAVE_STDINT_H", to: "1"),
                .define("HAVE_MKSTEMP", to: "1"),
                .define("USE_ASYNC", to: "0"),
                .define("USE_KLATT", to: "1"),
                .define("USE_LIBPCAUDIO", to: "0"),
                .define("USE_LIBSONIC", to: "0"),
                .define("USE_MBROLA", to: "0"),
                .define("USE_SPEECHPLAYER", to: "0"),
                .define("PACKAGE_VERSION", to: "\"1.52.0\""),
                .unsafeFlags(["-w", "-include", "espeak_config.h"]),
            ]
        ),
        .target(
            name: "kitten_tts_flutter",
            dependencies: ["espeak_ng"],
            resources: []
        )
    ]
)
