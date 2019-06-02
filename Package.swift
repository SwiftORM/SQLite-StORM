// swift-tools-version:4.2
// Generated automatically by Perfect Assistant Application
// Date: 2017-10-03 17:03:00 +0000
import PackageDescription
let package = Package(
	name: "SQLiteStORM",
	products: [
		.library(name: "SQLiteStORM", targets: ["SQLiteStORM"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", from: "3.0.0"),
		.package(url: "https://github.com/SwiftORM/StORM.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "SQLiteStORM", dependencies: ["StORM", "PerfectSQLite", "PerfectLogger"]),
        .testTarget(name: "SQLiteStORMTests", dependencies: ["SQLiteStORM"])
	]
)
