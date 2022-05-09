//
//  SpanTests.swift
//  
//
//  Created by Van Tol, Ladd on 9/27/21.
//

import Foundation
import XCTest

@testable import NautilusTelemetry

final class SpanTests: XCTestCase {
	
	enum TestError: Error {
		case failure
	}
	
	let tracer = Tracer()
	
	let iterations = 100
	
	override func tearDown() {
		tracer.flushRetiredSpans()
	}
	
	func testTraceId() {
		let traceId = Identifiers.generateTraceId()
		XCTAssertEqual(traceId.count, 16)
		XCTAssertNotEqual(traceId, Data(repeating: 0, count: 16))
		
		let serial = DispatchQueue(label: "serial")
		var set = Set<Data>()
		
		DispatchQueue.concurrentPerform(iterations: iterations) { _ in
			let traceId = Identifiers.generateTraceId()
			_ = serial.sync { set.insert(traceId) }
		}
		
		XCTAssert(set.count == iterations) // check for duplicates
	}
	
	func testSpanId() {
		let spanId = Identifiers.generateSpanId()
		XCTAssertEqual(spanId.count, 8)
		XCTAssertNotEqual(spanId, Data(repeating: 0, count: 8))
		
		let serial = DispatchQueue(label: "serial")
		var set = Set<Data>()
		
		DispatchQueue.concurrentPerform(iterations: iterations) { _ in
			let traceId = Identifiers.generateSpanId()
			_ = serial.sync { set.insert(traceId) }
		}
		
		XCTAssert(set.count == iterations) // check for duplicates
	}
	
	func testTrace() throws {
		
		// we expect this test to run on main queue
		dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
		
		try tracer.withSpan(name: "span1") {
			XCTAssert(tracer.currentBaggage.span.parentId != nil)
			try span2Run()
		}
		
		XCTAssert(tracer.retiredSpans.count == 2)
		
		let span2 = tracer.retiredSpans[0]
		XCTAssert(span2.events.count == 2)
		XCTAssert(span2.status == .ok)
		
		let traceParentHeader = span2.traceParentHeader
		XCTAssertEqual(traceParentHeader.count, 55)
	}
	
	func testThrowing() throws {
		
		// we expect this test to run on main queue
		dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
		
		do {
			try tracer.withSpan(name: "span1") {
				throw TestError.failure
			}
		} catch {
			
		}
		
		XCTAssert(tracer.retiredSpans.count == 1)
		
		let span1 = tracer.retiredSpans[0]
		XCTAssert(span1.status != .ok)
	}
	
#if compiler(>=5.6.0) && canImport(_Concurrency)
	func testAsync() async throws {
		
		try await tracer.withSpan(name: "span1") {
			XCTAssert(tracer.currentBaggage.span.parentId != nil)
			try await span2RunAsync()
		}
		
		XCTAssert(tracer.retiredSpans.count == 2)
		
		let span2 = tracer.retiredSpans[0]
		XCTAssert(span2.events.count == 2)
		XCTAssert(span2.status == .ok)
	}
#endif
	
	func span2Run() throws {
		var ranSpan = false
		tracer.withSpan(name: "span2") {
			
			let span = tracer.currentBaggage.span
			span.addEvent("event1")
			Thread.sleep(forTimeInterval: 0.1)
			span.addEvent("event2")
			span.status = .ok
			ranSpan = true
		}
		
		XCTAssert(ranSpan)
	}
	
#if compiler(>=5.6.0) && canImport(_Concurrency)
	func span2RunAsync() async throws {
		var ranSpan = false
		tracer.withSpan(name: "span2async") {
			
			let span = tracer.currentBaggage.span
			span.addEvent("event1")
			Thread.sleep(forTimeInterval: 0.1)
			span.addEvent("event2")
			span.status = .ok
			ranSpan = true
		}
		
		XCTAssert(ranSpan)
	}
#endif
	
}
