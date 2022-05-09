//
//  TraceExporterTests.swift
//  
//
//  Created by Ladd Van Tol on 10/5/21.
//

import Foundation
import XCTest
import OSLog
import MetricKit
import os

@testable import NautilusTelemetry

final class TraceExporterTests: XCTestCase {
	
	// Since OTLP is defined in protobuf, we have to use the standard JSON mapping
	// I used `protoc-gen-swagger` for this, then a swagger -> OpenAPI 3 converter
	// Clunky, but works?
	// https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md
	// https://github.com/open-telemetry/opentelemetry-proto
	// https://developers.google.com/protocol-buffers/docs/proto3#json
	
	/// If you're running OpenTelemetry Collector locally, you can test out the integration:
	/// I used the Mac Docker Desktop:
	/// https://docs.docker.com/desktop/mac/install/
	/// See detailed instructions in OpenTelemetryCollector directory
	let testWithLocalCollector = TraceExporterTests.testEnabled("testWithLocalCollector")
	let testWithSherlock = TraceExporterTests.testEnabled("testWithSherlock")
	
	let instrumentationLibrary = OTLP.V1InstrumentationLibrary(name: "NautilusTelemetry", version: "1.0")
	let schemaUrl = "https://api.ebay.com/nautilus-tracing"
	
	let sherlockTraceEndpoint = "https://otel-collector-http.sherlock-tracing.svc.130.tess.io/v1/traces"
	let localEndpointBase = "http://localhost:55681"
	
	enum TestError: Error {
		case failure
	}
	
	static func testEnabled(_ name: String) -> Bool {
		if let val = ProcessInfo.processInfo.environment[name] {
			return Bool(val) ?? false
		}
		return false
	}
	
	func testOTLPExporterTraces() throws {
		let timeReference = TimeReference(serverOffset: 0.0)
		
		let tracer = Tracer()
		tracer.withSpan(name: "span1", attributes: [:]) {
			let span1 = tracer.currentBaggage.span
			span1.status = .ok
			
			tracer.withSpan(name: "span2") {
				let span2 = tracer.currentBaggage.span
				span2.addEvent("event1")
				
				Thread.sleep(forTimeInterval: 0.05)
				
				try? tracer.withSpan(name: "span3") {
					Thread.sleep(forTimeInterval: 0.01)
					throw TestError.failure
				}
				
				tracer.withSpan(name: "span4") {
					Thread.sleep(forTimeInterval: 0.00001)
				}
				
				Thread.sleep(forTimeInterval: 0.05)
				
				span2.addEvent("event2")
				span2.status = .ok
			}
		}
		
		let spans = tracer.retiredSpans
		let exporter = Exporter(timeReference: timeReference)
		let otlpSpans = spans.map { exporter.exportOTLP(span: $0) }
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try encoder.encode(otlpSpans)
		let decoded = try XCTUnwrap(JSONSerialization.jsonObject(with: data, options: []) as? [Any])
		
		XCTAssertEqual(decoded.count, 4)
		
		let first = try XCTUnwrap(decoded[0] as? [String: Any])
		XCTAssertEqual(first["name"] as? String, "span3")
		
		let second = try XCTUnwrap(decoded[1] as? [String: Any])
		XCTAssertEqual(second["name"] as? String, "span4")
		
		let third = try XCTUnwrap(decoded[2] as? [String: Any])
		XCTAssertEqual(third["name"] as? String, "span2")
		
		let fourth = try XCTUnwrap(decoded[3] as? [String: Any])
		XCTAssertEqual(fourth["name"] as? String, "span1")
				
		let json = try exporter.exportOTLPToJSON(spans: spans, additionalAttributes: [:])
		
		let jsonString = try XCTUnwrap(String(data: json, encoding: .utf8))
		print(jsonString)
		
		if testWithSherlock {
			try postJSON(url: sherlockTraceEndpoint, json: json)
		}
		
		if testWithLocalCollector {
			try postJSON(url: "\(localEndpointBase)/v1/traces", json: json)
		}
		
		tracer.flushTrace()
	}
	
	func testOTLPExporterLogs() throws {
		
		let timeReference = TimeReference(serverOffset: 0.0)
		let exporter = Exporter(timeReference: timeReference)
		
		let tracer = Tracer()
		tracer.withSpan(name: "hi", attributes: nil) { }
		
		let traceId = tracer.traceId
		let spanId = tracer.retiredSpans[0].id
		
		var logRecords = [OTLP.V1LogRecord]()
		
		if #available(iOS 15.0, macOS 12.0, *) {
			
			let logger = Logger(subsystem: "OTLPExporterTests", category: "testOTLPExporterLogs")
			
			for i in 0...100 {
				logger.info("Here's some sample data: \(i)")
			}
			
			// try dumping OS logs
			let startDate = Date().addingTimeInterval(-60)
			
			let logStore = try OSLogStore(scope: .currentProcessIdentifier)
			let position = logStore.position(date: startDate)
			let entries = try logStore.getEntries(at: position)
			
			for logEntry in entries {
				
				if let logEntry = logEntry as? OSLogEntryLog {
					let date = logEntry.date
					let time = timeReference.nanosecondsSinceEpoch(from: date)
					
					let severity = exporter.severityFrom(level: logEntry.level)
					// https://www.w3.org/TR/trace-context/#sampled-flag
					// 1 == sampled
					let flags = Int64(0x01)
					let name = logEntry.subsystem
					let body = logEntry.composedMessage
					
					let attributes: TelemetryAttributes = [
						// These don't seem to be useful yet. Can we map thread id to thread number?
						//	"activity": logEntry.activityIdentifier,
						//	"thread": logEntry.threadIdentifier,
						
						"category": logEntry.category,
						"process": logEntry.process,
						"sender": logEntry.sender,
						"subsystem": logEntry.subsystem
					]
					
					let attributesKV = exporter.convertToOTLP(attributes: attributes)
					
					let logRecord = OTLP.V1LogRecord(timeUnixNano: "\(time)",
													 severityNumber: severity,
													 severityText: nil,
													 name: name,
													 body: OTLP.V1AnyValue(stringValue: body),
													 attributes: attributesKV,
													 droppedAttributesCount: nil,
													 flags: flags,
													 traceId: traceId,
													 spanId: spanId)
					
					logRecords.append(logRecord)
				}
			}
		}
		
		let instrumentationLibraryLogs = OTLP.V1InstrumentationLibraryLogs(instrumentationLibrary: instrumentationLibrary, logs: logRecords, schemaUrl: schemaUrl)
		
		let resource = OTLP.V1Resource(attributes: [], droppedAttributesCount: nil)
		let resourceLogs = OTLP.V1ResourceLogs(resource: resource, instrumentationLibraryLogs: [instrumentationLibraryLogs], schemaUrl: schemaUrl)
		let exportLogsServiceRequest = OTLP.V1ExportLogsServiceRequest(resourceLogs: [resourceLogs])
		
		let json = try encodeJSON(exportLogsServiceRequest)
		
		if testWithLocalCollector {
			try postJSON(url: "\(localEndpointBase)/v1/logs", json: json)
		}
	}
	
	func testOTLPExporterMetrics() throws {
		// HOO boy: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/datamodel.md
		
		let tracer = Tracer()
		tracer.withSpan(name: "hi", attributes: nil) { }
		
		let traceId = tracer.traceId
		let spanId = tracer.retiredSpans[0].id
		
		let timeReference = TimeReference(serverOffset: 0.0)
		
		var metrics = [OTLP.V1Metric]()
		
		var dataPoints = [OTLP.V1NumberDataPoint]()
		
		let now = AbsoluteTime()
		let time = timeReference.nanosecondsSinceEpoch(from: now)
		let timeString = "\(time)"
		
		let residentMemory = 10000 // EBNResidentMemory() or not exposed to swift: let freeMemory = os_proc_available_memory()
		
		let exemplar = OTLP.V1Exemplar(filteredAttributes: nil, timeUnixNano: timeString, asDouble: nil, asInt: "\(residentMemory)", spanId: spanId, traceId: traceId)
		
		// TBD: understand all these fields, especially exemplars
		let dataPoint = OTLP.V1NumberDataPoint(attributes: nil, startTimeUnixNano: timeString, timeUnixNano: timeString, asDouble: nil, asInt: "\(residentMemory)", exemplars: [exemplar], flags: nil)
		
		dataPoints.append(dataPoint)
		
		let gauge = OTLP.V1Gauge(dataPoints: dataPoints)
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument-naming-rule
		// http://unitsofmeasure.org/ucum.html
		let freeMemoryMetric = OTLP.V1Metric(name: "resident_memory", description: "How many bytes of memory are resident", unit: "byte", gauge: gauge)
		
		metrics.append(freeMemoryMetric)
		
		let instrumentationLibraryMetrics = OTLP.V1InstrumentationLibraryMetrics(instrumentationLibrary: instrumentationLibrary, metrics: metrics, schemaUrl: schemaUrl)
		let resource = OTLP.V1Resource(attributes: [], droppedAttributesCount: nil)
		let resourceMetrics = OTLP.V1ResourceMetrics(resource: resource, instrumentationLibraryMetrics: [instrumentationLibraryMetrics], schemaUrl: schemaUrl)
		
		let exportMetricsServiceRequest = OTLP.V1ExportMetricsServiceRequest(resourceMetrics: [resourceMetrics])
		
		let json = try encodeJSON(exportMetricsServiceRequest)
		
		if testWithLocalCollector {
			try postJSON(url: "\(localEndpointBase)/v1/metrics", json: json)
		}
	}
	
	// MARK: utilities
	
	func encodeJSON<T>(_ value: T) throws -> Data where T : Encodable {
		let encoder = JSONEncoder()
		OTLP.configure(encoder: encoder) // setup hex
		//encoder.outputFormatting = .prettyPrinted
		let json = try encoder.encode(value)
		
		let jsonString = try XCTUnwrap(String(data: json, encoding: .utf8))
		print("\(jsonString)")
		
		return json
	}
	
	func formattedHeaders(_ headers: [String:String]) -> String {
		var result = ""
		
		let keys = headers.keys.sorted()
		for key in keys {
			if let value = headers[key] {
				result.append("\(key): \(value)\n")
			}
		}
		
		return result
	}
	
	// https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md
	func postJSON(url: String, json: Data) throws {
		
		let url = try XCTUnwrap(URL(string: url))
		var urlRequest = URLRequest(url: url)
		
		urlRequest.httpMethod = "POST"
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
		
		
		let compressedJSON = try Compression.compressDeflate(data: json)
		urlRequest.setValue("deflate", forHTTPHeaderField: "Content-Encoding")
		urlRequest.httpBody = compressedJSON
		let requestHeaders = formattedHeaders(try XCTUnwrap(urlRequest.allHTTPHeaderFields))
		print ("\(urlRequest.httpMethod?.description ?? "nil") \(url.path)\n\(requestHeaders)")
		
		let completion = expectation(description: "postToLocalOpenTelemetryCollector")
		let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
			
			if let response = response as? HTTPURLResponse {
				XCTAssertEqual(response.statusCode, 200)
				
				let responseHeaders = self.formattedHeaders(response.allHeaderFields as! [String:String])
				print ("Response:\n\(responseHeaders)")
			}
			
			if let data = data, let jsonString = String(data: data, encoding: .utf8) {
				print("\(jsonString)")
			}
			
			completion.fulfill()
		}
		
		task.resume()
		
		waitForExpectations(timeout: 30) { error in
			if let error = error {
				print("error: \(error)")
			}
		}
	}
}

