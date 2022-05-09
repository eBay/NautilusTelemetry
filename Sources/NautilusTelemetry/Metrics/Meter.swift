//
//  Meter.swift
//  
//
//  Created by Van Tol, Ladd on 12/15/21.
//

import Foundation

// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md
// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/datamodel.md

/// The meter is responsible for creating Instruments.
public final class Meter {
	
	// Used for protecting *Values structures
	static let valueLock = UnfairLock()

	public init() {
	}
	
	public func createCounter<T: MetricNumeric>(name: String,
								   unit: Unit? = nil,
								   description: String? = nil) -> Counter<T> {
		return Counter<T>(name: name, unit: unit, description: description)
	}

	public func createObservableCounter<T: MetricNumeric>(name: String,
											 unit: Unit? = nil,
											 description: String? = nil,
											 callback: @escaping (ObservableCounter<T>) -> Void) -> ObservableCounter<T> {
		return ObservableCounter(name: name, unit: unit, description: description, callback: callback)
	}

	public func createUpDownCounter<T: MetricNumeric>(name: String,
										 unit: Unit? = nil,
										 description: String? = nil) -> UpDownCounter<T> {
		return UpDownCounter<T>(name: name, unit: unit, description: description)
	}

	public func createObservableUpDownCounter<T: MetricNumeric>(name: String,
												   unit: Unit? = nil,
												   description: String? = nil,
												   callback: @escaping (ObservableUpDownCounter<T>) -> Void) -> ObservableUpDownCounter<T> {
		return ObservableUpDownCounter<T>(name: name, unit: unit, description: description, callback: callback)
	}

	public func createHistogram<T: MetricNumeric>(name: String,
										   unit: Unit? = nil,
										   description: String? = nil,
										   explicitBounds: [T]) -> Histogram<T> {
		return Histogram<T>(name: name, unit: unit, description: description, explicitBounds: explicitBounds)
	}
	
	public func createObservableGauge<T: MetricNumeric>(name: String,
										   unit: Unit? = nil,
										   description: String? = nil,
										   callback: @escaping (ObservableGauge<T>) -> Void) -> ObservableGauge<T> {
		return ObservableGauge<T>(name: name, unit: unit, description: description, callback: callback)
	}
}
