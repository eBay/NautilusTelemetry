//
//  MeterTests.swift
//  
//
//  Created by Ladd Van Tol on 3/22/22.
//

import Foundation
import XCTest

@testable import NautilusTelemetry

final class MeterTests: XCTestCase {

	func testCreate() {
		let meter = InstrumentationSystem.meter
		
		let counter1: Counter<Int> = meter.createCounter(name: "counter1", description: "hello")
		XCTAssert(counter1.values.allValues.isEmpty)

		let counter2: UpDownCounter<Int> = meter.createUpDownCounter(name: "counter2", description: "hello")
		XCTAssert(counter2.values.allValues.isEmpty)

		let counter3: ObservableCounter<Int>  = meter.createObservableCounter(name: "counter3", description: "hello") { counter in
			counter.observe(100)
		}
		XCTAssert(counter3.values.allValues.isEmpty)

		let counter4: ObservableUpDownCounter<Int>  = meter.createObservableUpDownCounter(name: "counter4", description: "hello") { counter in
			counter.observe(100)
		}
		XCTAssert(counter4.values.allValues.isEmpty)

		let histogram: Histogram<Int> = meter.createHistogram(name: "histogram", explicitBounds: [0,10,20])
		XCTAssert(histogram.values.allValues.isEmpty)

		let gauge: ObservableGauge<Int> = meter.createObservableGauge(name: "gauge") { gauge in
			gauge.observe(100)
		}
		XCTAssert(gauge.values.allValues.isEmpty)
	}
}

