//
//  ObservableGauge.swift
//  
//
//  Created by Van Tol, Ladd on 12/15/21.
//

import Foundation

public class ObservableGauge<T: MetricNumeric>: Instrument, ExportableInstrument {

	public let name: String
	public let unit: Unit?
	public let description: String?
	public private(set) var startTime = AbsoluteTime()
	public let aggregationTemporality: AggregationTemporality = .unspecified

	let callback: (ObservableGauge<T>) -> Void
	var values = MetricValues<T>()

	internal init(name: String, unit: Unit?, description: String?, callback: @escaping (ObservableGauge<T>) -> Void) {
		self.name = name
		self.unit = unit
		self.description = description
		self.callback = callback
	}
		
	public func observe(_ number: T, attributes: TelemetryAttributes = [:]) {
		values.set(number, attributes: attributes)
	}
	
	public func reset() {
		startTime = AbsoluteTime()
		values.reset()
	}
	
	func invokeCallback() {
		callback(self)
	}
	
	func exportOTLP(_ exporter: Exporter) -> OTLP.V1Metric {
		return exporter.exportOTLP(gauge: self)
	}
}
