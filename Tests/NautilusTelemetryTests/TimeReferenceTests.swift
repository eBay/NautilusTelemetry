//
//  TimeReferenceTests.swift
//  
//
//  Created by Ladd Van Tol on 3/22/22.
//

import XCTest
@testable import NautilusTelemetry

final class TimeReferenceTests: XCTestCase {

	let toleranceMS: Int64 = 500
	
	func testTestReference() {
		let timeReference = TimeReference(serverOffset: 0)
		
		let time = AbsoluteTime()
		let date = Date()
		
		let millisecondsSinceEpoch = timeReference.millisecondsSinceEpoch(from: time)
		let millisecondsSinceEpochFromDate = Int64(date.timeIntervalSince1970 * 1_000.0)
		let diff1 = abs(millisecondsSinceEpoch-millisecondsSinceEpochFromDate)
		XCTAssertLessThan(diff1, toleranceMS)
		
		let microsecondsSinceEpoch = timeReference.microsecondsSinceEpoch(from: time)
		let microsecondsSinceEpochFromDate = Int64(date.timeIntervalSince1970 * 1_000_000.0)
		let diff2 = abs(microsecondsSinceEpoch-microsecondsSinceEpochFromDate)
		XCTAssertLessThan(diff2, toleranceMS*1_000)

		let nanosecondsSinceEpoch = timeReference.nanosecondsSinceEpoch(from: time)
		let nanosecondsSinceEpochFromDate = Int64(date.timeIntervalSince1970 * 1_000_000_000.0)
		let diff3 = abs(nanosecondsSinceEpoch-nanosecondsSinceEpochFromDate)
		XCTAssertLessThan(diff3, toleranceMS*1_000_000)
	}
}

