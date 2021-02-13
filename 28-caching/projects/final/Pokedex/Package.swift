// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "pokedex",
  platforms: [
    .macOS(.v10_15)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", .branch("cache-protocol")),
    .package(url: "https://github.com/vapor/fluent.git", .branch("cache-protocol")),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
  ],
  targets: [
    .target(name: "Pokedex", dependencies: [
      .product(name: "Fluent", package: "fluent"),
      .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      .product(name: "Vapor", package: "vapor")
    ]),
    .target(name: "Run", dependencies: [
      .target(name:"Pokedex")
    ]),
    .testTarget(name: "PokedexTests", dependencies: ["Pokedex"]),
  ]
)
