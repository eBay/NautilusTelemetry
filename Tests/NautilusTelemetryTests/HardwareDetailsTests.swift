//
//  HardwareDetailsTests.swift
//  
//
//  Created by Van Tol, Ladd on 11/4/21.
//

import Foundation
import XCTest
@testable import NautilusTelemetry

final class HardwareDetailsTests: XCTestCase {

	func testPlatformCachedValue() throws {
		let value = try XCTUnwrap(HardwareDetails.platformCachedValue)
		XCTAssert(value.count > 0)
	}
}

