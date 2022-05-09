// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2021 eBay. All rights reserved.

import PackageDescription

let package = Package(
	name: "NautilusTelemetry",
	platforms: [.iOS("13.4"), .tvOS("13.4"), .macOS("11.0"), .watchOS("8.0")],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "NautilusTelemetry",
			type: .static,
			targets: ["NautilusTelemetry"]),
	],
	dependencies: [
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "NautilusTelemetry",
			dependencies: [],
			exclude: [
				"Exporters/OTLP-JSON/generator-config.json",
				"Exporters/OTLP-JSON/Metrics/metrics_service.yaml",
				"Exporters/OTLP-JSON/Trace/trace_service.yaml",
				"Exporters/OTLP-JSON/Logs/logs_service.yaml",
				"Instrumentation/MetricKit-sample.json"
			]),
		.testTarget(
			name: "NautilusTelemetryTests",
			dependencies: ["NautilusTelemetry"]),
	]
)
