//
//  UnfairLockTest.swift
//  NautilusKernelUnitTests
//
//  Created by Van Tol, Ladd on 7/14/21.
//  Copyright © 2021 eBay, Inc. All rights reserved.
//

import XCTest
@testable import NautilusTelemetry

class UnfairLockTest: XCTestCase {
	
	func testLock() throws {
		let lock = UnfairLock()
		
		lock.lock()
		
		let expectation1 = expectation(description: "wait for thread to start")
		let expectation2 = expectation(description: "wait for thread to cycle lock")
		
		DispatchQueue.global().async {
			expectation1.fulfill()
			lock.lock()
			lock.unlock()
			expectation2.fulfill()
		}
		wait(for: [expectation1], timeout: 10)
		lock.unlock()
		wait(for: [expectation2], timeout: 10)
	}
	
	func testLockSync() throws {
		
		let lock = UnfairLock()
		
		var executedBlock = false
		
		lock.sync {
			executedBlock = true
		}
		
		XCTAssertTrue(executedBlock)
	}
	
}
