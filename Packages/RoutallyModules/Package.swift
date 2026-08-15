// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "RoutallyModules",
  defaultLocalization: "it",
  platforms: [.iOS(.v26)],
  products: [
    .library(name: "RoutallyDomain", targets: ["RoutallyDomain"]),
    .library(name: "RoutallyDesign", targets: ["RoutallyDesign"]),
    .library(name: "RoutallyFeatures", targets: ["RoutallyFeatures"]),
    .library(name: "RoutallyFixtures", targets: ["RoutallyFixtures"]),
  ],
  targets: [
    .target(name: "RoutallyDomain"),
    .target(
      name: "RoutallyDesign",
      resources: [.process("Resources")]
    ),
    .target(
      name: "RoutallyFeatures",
      dependencies: ["RoutallyDomain", "RoutallyDesign"],
      resources: [.process("Resources")]
    ),
    .target(
      name: "RoutallyFixtures",
      dependencies: ["RoutallyDomain"],
      resources: [.process("Resources")]
    ),
  ],
  swiftLanguageModes: [.v6]
)
