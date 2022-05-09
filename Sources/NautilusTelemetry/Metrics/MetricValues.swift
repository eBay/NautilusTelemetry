//
//  MetricValues.swift
//  
//
//  Created by Van Tol, Ladd on 12/20/21.
//

import Foundation

struct MetricValues<T: MetricNumeric> {

	private var values = [TelemetryAttributes: T]()
	
	var allValues: [TelemetryAttributes: T] { Meter.valueLock.sync { values } }

	mutating func add(_ number: T, attributes: TelemetryAttributes = [:]) {
		Meter.valueLock.sync {
			var metricValue = values[attributes] ?? number
			metricValue += number
			values[attributes] = metricValue
		}
	}

	mutating func set(_ number: T, attributes: TelemetryAttributes = [:]) {
		Meter.valueLock.sync {
			values[attributes] = number
		}
	}

	mutating func reset() {
		Meter.valueLock.sync {
			values.removeAll()
		}
	}
	
	func valueFor(attributes: TelemetryAttributes) -> T? {
		Meter.valueLock.sync { values[attributes] }
	}
}
