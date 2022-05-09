//
//  Histogram.swift
//  
//
//  Created by Van Tol, Ladd on 12/15/21.
//

import Foundation

public class Histogram<T: MetricNumeric>: Instrument, ExportableInstrument {

	public let name: String
	public let unit: Unit?
	public let description: String?
	public private(set) var startTime = AbsoluteTime()
	public var aggregationTemporality: AggregationTemporality = .delta

	var values: HistogramValues<T>
	
	/// Initialize a histogram
	/// - Parameters:
	///   - name: the name of the histogram
	///   - unit: the unit of measure
	///   - description: a descriptive string
	///   - explicitBounds: See definition in `V1HistogramDataPoint.swift`
	internal init(name: String, unit: Unit?, description: String?, explicitBounds: [T]) {
		self.name = name
		self.unit = unit
		self.description = description
		self.values = HistogramValues<T>(explicitBounds: explicitBounds)
	}
	
	public func record(_ number: T, attributes: TelemetryAttributes = [:]) {
		precondition(number >= 0, "counters can only be increased")
		values.record(number, attributes: attributes)
	}

	public func reset() {
		startTime = AbsoluteTime()
		values.reset()
	}

	func exportOTLP(_ exporter: Exporter) -> OTLP.V1Metric {
		return exporter.exportOTLP(histogram: self)
	}
}
