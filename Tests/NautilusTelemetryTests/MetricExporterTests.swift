//
//  MetricExporterTests.swift
//  
//
//  Created by Ladd Van Tol on 3/2/22.
//

import Foundation
import XCTest

@testable import NautilusTelemetry

final class MetricExporterTests: XCTestCase {

	let redaction = ["start_time_unix_nano", "time_unix_nano"]
	let unit = Unit(symbol: "bytes")

	func testexportOTLPToJSON() throws {
		let counter = Counter<Int>(name: "ByteCounter", unit: unit, description: "Counts accumulated bytes")
		counter.add(100)

		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)

		let json = try XCTUnwrap(exporter.exportOTLPToJSON(instruments: [counter], additionalAttributes: ["scenario":"test"]))
		
		// redact the attribute list as well
		let normalizedJsonString = try XCTUnwrap(try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction + ["attributes"]))

		let expectedOutput = #"{"resource_metrics":[{"instrumentation_library_metrics":[{"instrumentation_library":{"name":"NautilusTelemetry","version":"1.0"},"metrics":[{"description":"Counts accumulated bytes","name":"ByteCounter","sum":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"as_int":"200","attributes":"***","start_time_unix_nano":"***","time_unix_nano":"***"}],"is_monotonic":true},"unit":"bytes"}]}],"resource":{"attributes":"***"}}]}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
	}
	
	func testCounter() throws {
		let counter = Counter<Int>(name: "ByteCounter", unit: unit, description: "Counts accumulated bytes")
		counter.add(100)
		
		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = counter.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Counts accumulated bytes","name":"ByteCounter","sum":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"as_int":"200","attributes":[],"start_time_unix_nano":"***","time_unix_nano":"***"}],"is_monotonic":true},"unit":"bytes"}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
		counter.reset()
		XCTAssert(counter.values.allValues.isEmpty)
	}
	
	func testUpDownCounter() throws {
		let counter = UpDownCounter<Int>(name: "ByteCounter", unit: unit, description: "Counts accumulated bytes")
		
		counter.add(100)
		
		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = counter.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Counts accumulated bytes","name":"ByteCounter","sum":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"as_int":"200","attributes":[],"start_time_unix_nano":"***","time_unix_nano":"***"}],"is_monotonic":false},"unit":"bytes"}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
		counter.reset()
		XCTAssert(counter.values.allValues.isEmpty)
	}

	func testObservableCounter() throws {
		
		let unit = Unit(symbol: "bytes")
		let counter = ObservableCounter<Int>(name: "Test", unit: unit, description: "Test observable Counter") { counter in
			counter.observe(500)
		}
		
		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = counter.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Test observable Counter","name":"Test","sum":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"as_int":"500","attributes":[],"start_time_unix_nano":"***","time_unix_nano":"***"}],"is_monotonic":true},"unit":"bytes"}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
		counter.reset()
		XCTAssert(counter.values.allValues.isEmpty)
	}

	func testObservableUpDownCounter() throws {
		let counter = ObservableUpDownCounter<Int>(name: "Test", unit: unit, description: "Test observable UpDownCounter") { counter in
			counter.observe(500)
		}
		
		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = counter.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Test observable UpDownCounter","name":"Test","sum":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"as_int":"500","attributes":[],"start_time_unix_nano":"***","time_unix_nano":"***"}],"is_monotonic":false},"unit":"bytes"}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
		counter.reset()
		XCTAssert(counter.values.allValues.isEmpty)
	}

	func testObservableGauge() throws {
		let gauge = ObservableGauge<Int>(name: "Test", unit: unit, description: "Test observable gauge") { gauge in
			gauge.observe(500)
		}
		
		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = gauge.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Test observable gauge","gauge":{"data_points":[{"as_int":"500","attributes":[],"start_time_unix_nano":"***","time_unix_nano":"***"}]},"name":"Test","unit":"bytes"}"#

		XCTAssertEqual(normalizedJsonString, expectedOutput)
		gauge.reset()
		XCTAssert(gauge.values.allValues.isEmpty)
	}

	func testHistogram() throws {
		let bucketSize = 1024
		
		let histogram = Histogram<Int>(name: "ByteHistogram", unit: unit, description: "Counts byte sizes by bucket", explicitBounds: [bucketSize*1,bucketSize*2,bucketSize*3,bucketSize*4])

		histogram.record(100)
		histogram.record(4000)
		histogram.record(16000)

		let timeReference = TimeReference(serverOffset: 0)
		let exporter = Exporter(timeReference: timeReference)
		
		let metric = histogram.exportOTLP(exporter)
		let json = try exporter.encodeJSON(metric)
		
		let normalizedJsonString = try TestDataNormalization.normalizedJsonString(data: json, keyValuesToRedact: redaction)
		
		let expectedOutput = #"{"description":"Counts byte sizes by bucket","histogram":{"aggregation_temporality":"AGGREGATION_TEMPORALITY_DELTA","data_points":[{"attributes":[],"bucket_counts":["1","0","0","1","1"],"count":"3","explicit_bounds":[1024,2048,3072,4096],"start_time_unix_nano":"***","sum":20100,"time_unix_nano":"***"}]},"name":"ByteHistogram","unit":"bytes"}"#
		
		XCTAssertEqual(normalizedJsonString, expectedOutput)
		histogram.reset()
		XCTAssert(histogram.values.allValues.isEmpty)
	}

}
