import PackageDescription

let package = Package(
    name: "SwampProject",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/RadarBee/swamp.git", majorVersion: 0, minor: 2)
    ]
)
