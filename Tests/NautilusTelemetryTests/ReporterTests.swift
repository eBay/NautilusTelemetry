//
//  ReporterTests.swift
//  
//
//  Created by Ladd Van Tol on 3/22/22.
//

import Foundation
import XCTest

@testable import NautilusTelemetry

final class ReporterTests: XCTestCase {
	
	func testNoOpReporter() {
		let reporter = NoOpReporter()
		InstrumentationSystem.bootstrap(reporter: reporter)
		XCTAssert((InstrumentationSystem.reporter as? NoOpReporter) === reporter)
		
		XCTAssertEqual(reporter.flushInterval, 60)
		reporter.reportSpans([])
		reporter.reportInstruments([])
		reporter.subscribeToLifecycleEvents()
	}
}

