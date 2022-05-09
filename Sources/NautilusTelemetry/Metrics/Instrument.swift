//
//  Instrument.swift
//  
//
//  Created by Van Tol, Ladd on 12/20/21.
//

import Foundation

public protocol Instrument: AnyObject {
	/// The name of the instrument
	var name: String { get }
	
	/// Optional unit of measurement
	var unit: Unit? { get }
	
	/// Optional description
	var description: String? { get }

	/// A timestamp (start_time_unix_nano) which best represents the first possible moment a measurement could be recorded. This is commonly set to the timestamp when a metric collection system started.
	var startTime: AbsoluteTime { get }

	var aggregationTemporality: AggregationTemporality { get }
	
	func reset()
}

internal protocol ExportableInstrument {
	func exportOTLP(_ exporter: Exporter) -> OTLP.V1Metric
}

public enum AggregationTemporality {
	/// The gauge has no aggregation
	case unspecified
	case delta
	case cumulative
}
