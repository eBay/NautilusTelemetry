//
//  ProcessDetailsTests.swift
//  
//
//  Created by Ladd Van Tol on 9/23/21.
//

import Foundation
import XCTest
@testable import NautilusTelemetry

final class ProcessDetailsTests: XCTestCase {
	
	func testTimeSinceProcessStart() {
		let time = ProcessDetails.timeSinceStart
		XCTAssertGreaterThan(time, 0)
		XCTAssertLessThan(time, 300) // should take less than 5 minutes, unless Symantec DLP gets involved
	}
}
