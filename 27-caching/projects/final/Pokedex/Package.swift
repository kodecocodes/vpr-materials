// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Pokedex",
  dependencies: [
    // 💧 A server-side Swift web framework. 
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    
    // 🖋 Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
    .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
    ],
  targets: [
    .target(name: "Pokedex", dependencies: ["FluentSQLite", "Vapor"]),
    .target(name: "Run", dependencies: ["Pokedex"]),
    .testTarget(name: "PokedexTests", dependencies: ["Pokedex"]),
    ]
)
