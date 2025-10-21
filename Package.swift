// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoundpipeAudioKit",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(name: "SoundpipeAudioKit", targets: ["SoundpipeAudioKit"]),
        .library(name: "CSoundpipeAudioKit", targets: ["CSoundpipeAudioKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/KissFFT", from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX", from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/Tonic", from: "2.0.0"),
    ],
    targets: [
        .target(name: "Soundpipe",
                dependencies: ["KissFFT"],
                exclude: ["lib/inih/LICENSE.txt"],
                cSettings: [
                    .headerSearchPath("lib/inih"),
                    .headerSearchPath("Sources/soundpipe/lib/inih"),
                    .headerSearchPath("modules"),
                    .headerSearchPath("external"),
                ]),
        .target(name: "SoundpipeAudioKit", dependencies: ["AudioKit", "AudioKitEX", "CSoundpipeAudioKit", "Tonic"]),
        .target(name: "CSoundpipeAudioKit", dependencies: ["AudioKit", "AudioKitEX", "Soundpipe"]),
        .testTarget(name: "SoundpipeAudioKitTests", dependencies: ["SoundpipeAudioKit", "Tonic"], resources: [.copy("TestResources/")]),
        .testTarget(name: "CSoundpipeAudioKitTests", dependencies: ["CSoundpipeAudioKit"]),
    ],
    cxxLanguageStandard: .cxx14
)
