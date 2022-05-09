//
//  IdentifiersTests.swift
//  
//
//  Created by Ladd Van Tol on 3/22/22.
//

import Foundation
import XCTest
@testable import NautilusTelemetry

final class IdentifiersTests: XCTestCase {

	func testGenerateTraceId() {
		let traceId = Identifiers.generateTraceId()
		XCTAssertEqual(traceId.count, 16)
	}

	func testGenerateSpanId() {
		let spanId = Identifiers.generateSpanId()
		XCTAssertEqual(spanId.count, 8)
	}
	
	func testHexEncoding() {
		let test = Data(repeating: 0xFF, count: 8)
		
		let hex1 = test.hexEncodedString()
		XCTAssertEqual(hex1, "ffffffffffffffff")

		if #available(iOS 14.0, tvOS 14.0, *) {
			let hex2 = test.hexEncodedStringFastPath()
			XCTAssertEqual(hex2, "ffffffffffffffff")
		}
		
		let hex3 = test.hexEncodedStringSlowPath()
		XCTAssertEqual(hex3, "ffffffffffffffff")
	}
}

