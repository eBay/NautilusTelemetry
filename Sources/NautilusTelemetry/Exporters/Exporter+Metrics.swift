//
//  Exporter+Metrics.swift
//  
//
//  Created by Ladd Van Tol on 3/1/22.
//

import Foundation

/// Exporter utilities for Metrics models
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/datamodel.md
extension Exporter {
	
	/// Exports an array of `Instrument` objects to OTLP format
	/// - Parameters:
	///   - instruments: array of instruments
	///   - additionalAttributes: Additional attributes to be added to resource attributes
	/// - Returns: JSON data
	public func exportOTLPToJSON(instruments: [Instrument], additionalAttributes: TelemetryAttributes?) throws -> Data {

		let metrics = exportOTLP(instruments: instruments)

		let instrumentationLibrary = OTLP.V1InstrumentationLibrary(name: "NautilusTelemetry", version: "1.0")
		let resourceAttributes = ResourceAttributes.makeWithDefaults(additionalAttributes: additionalAttributes)
		let attributes = convertToOTLP(attributes: resourceAttributes.keyValues)
		let resource = OTLP.V1Resource(attributes: attributes, droppedAttributesCount: nil)
		
		let instrumentationLibraryMetrics = OTLP.V1InstrumentationLibraryMetrics(instrumentationLibrary: instrumentationLibrary, metrics: metrics, schemaUrl: schemaUrl)
		let resourceMetrics = OTLP.V1ResourceMetrics(resource: resource, instrumentationLibraryMetrics: [instrumentationLibraryMetrics], schemaUrl: schemaUrl)
		let metricServiceRequest = OTLP.V1ExportMetricsServiceRequest(resourceMetrics: [resourceMetrics])
		
		let json = try encodeJSON(metricServiceRequest)
		return json
	}

	func exportOTLP(instruments: [Instrument]) -> [OTLP.V1Metric] {
		return instruments.compactMap { instrument in
			if let instrument = instrument as? ExportableInstrument {
				return instrument.exportOTLP(self)
			} else {
				assertionFailure("couldn't map \(instrument)")
				return nil
			}
		}
	}
	
	func exportOTLP<T>(counter: Counter<T>) -> OTLP.V1Metric {
		let values = counter.values.allValues
		var dataPoints = [OTLP.V1NumberDataPoint]()
		
		for key in values.keys {
			guard let value = values[key] else {
				continue
			}
			
			let attributes = convertToOTLP(attributes: key)
			let startTimeUnixNano = convertToOTLP(time: counter.startTime)
			
			let doubleValue: Double? = value as? Double
			var intValueString: String? = nil
			if let intValue = value as? Int {
				intValueString = "\(intValue)"
			}
			
			let timeUnixNano = convertToOTLP(time: AbsoluteTime())
			
			let dataPoint = OTLP.V1NumberDataPoint(attributes: attributes,
												   startTimeUnixNano: startTimeUnixNano,
												   timeUnixNano: timeUnixNano,
												   asDouble: doubleValue,
												   asInt: intValueString,
												   exemplars: nil, // no exemplar support yet
												   flags: nil) // no flags support yet
			
			dataPoints.append(dataPoint)
		}
		
		let sum = OTLP.V1Sum(dataPoints: dataPoints,
							 aggregationTemporality: convertToOTLP(counter.aggregationTemporality),
							 isMonotonic: counter.isMonotonic)
		
		let metric = OTLP.V1Metric(name: counter.name,
								   description: counter.description,
								   unit: convertToOTLP(counter.unit),
								   gauge: nil,
								   sum: sum,
								   histogram: nil,
								   exponentialHistogram: nil,
								   summary: nil)
		return metric
	}

	func exportOTLP<T>(counter: ObservableCounter<T>) -> OTLP.V1Metric {
		counter.invokeCallback()
		
		let values = counter.values.allValues
		var dataPoints = [OTLP.V1NumberDataPoint]()
		
		for key in values.keys {
			guard let value = values[key] else {
				continue
			}
			
			let attributes = convertToOTLP(attributes: key)
			let startTimeUnixNano = convertToOTLP(time: counter.startTime)
			
			let doubleValue: Double? = value as? Double
			var intValueString: String? = nil
			if let intValue = value as? Int {
				intValueString = "\(intValue)"
			}
			
			let timeUnixNano = convertToOTLP(time: AbsoluteTime())
			
			let dataPoint = OTLP.V1NumberDataPoint(attributes: attributes,
												   startTimeUnixNano: startTimeUnixNano,
												   timeUnixNano: timeUnixNano,
												   asDouble: doubleValue,
												   asInt: intValueString,
												   exemplars: nil, // no exemplar support yet
												   flags: nil) // no flags support yet
			
			dataPoints.append(dataPoint)
		}
		
		let sum = OTLP.V1Sum(dataPoints: dataPoints,
							 aggregationTemporality: convertToOTLP(counter.aggregationTemporality),
							 isMonotonic: counter.isMonotonic)
		
		let metric = OTLP.V1Metric(name: counter.name,
								   description: counter.description,
								   unit: convertToOTLP(counter.unit),
								   gauge: nil,
								   sum: sum,
								   histogram: nil,
								   exponentialHistogram: nil,
								   summary: nil)
		return metric
	}

	func exportOTLP<T>(counter: ObservableUpDownCounter<T>) -> OTLP.V1Metric {
		counter.invokeCallback()
		
		let values = counter.values.allValues
		var dataPoints = [OTLP.V1NumberDataPoint]()
		
		for key in values.keys {
			guard let value = values[key] else {
				continue
			}
			
			let attributes = convertToOTLP(attributes: key)
			let startTimeUnixNano = convertToOTLP(time: counter.startTime)
			
			let doubleValue: Double? = value as? Double
			var intValueString: String? = nil
			if let intValue = value as? Int {
				intValueString = "\(intValue)"
			}
			
			let timeUnixNano = convertToOTLP(time: AbsoluteTime())
			
			let dataPoint = OTLP.V1NumberDataPoint(attributes: attributes,
												   startTimeUnixNano: startTimeUnixNano,
												   timeUnixNano: timeUnixNano,
												   asDouble: doubleValue,
												   asInt: intValueString,
												   exemplars: nil, // no exemplar support yet
												   flags: nil) // no flags support yet
			
			dataPoints.append(dataPoint)
		}
		
		let sum = OTLP.V1Sum(dataPoints: dataPoints,
							 aggregationTemporality: convertToOTLP(counter.aggregationTemporality),
							 isMonotonic: counter.isMonotonic)
		
		let metric = OTLP.V1Metric(name: counter.name,
								   description: counter.description,
								   unit: convertToOTLP(counter.unit),
								   gauge: nil,
								   sum: sum,
								   histogram: nil,
								   exponentialHistogram: nil,
								   summary: nil)
		return metric
	}

	func exportOTLP<T>(gauge: ObservableGauge<T>) -> OTLP.V1Metric {
		gauge.invokeCallback()
		
		let values = gauge.values.allValues
		var dataPoints = [OTLP.V1NumberDataPoint]()
		
		for key in values.keys {
			guard let value = values[key] else {
				continue
			}
			
			let attributes = convertToOTLP(attributes: key)
			let startTimeUnixNano = convertToOTLP(time: gauge.startTime)
			
			let doubleValue: Double? = value as? Double
			var intValueString: String? = nil
			if let intValue = value as? Int {
				intValueString = "\(intValue)"
			}
			
			let timeUnixNano = convertToOTLP(time: AbsoluteTime())
			
			let dataPoint = OTLP.V1NumberDataPoint(attributes: attributes,
												   startTimeUnixNano: startTimeUnixNano,
												   timeUnixNano: timeUnixNano,
												   asDouble: doubleValue,
												   asInt: intValueString,
												   exemplars: nil, // no exemplar support yet
												   flags: nil) // no flags support yet
			
			dataPoints.append(dataPoint)
		}
		
		let gaugeOTLP = OTLP.V1Gauge(dataPoints: dataPoints)
		let metric = OTLP.V1Metric(name: gauge.name,
								   description: gauge.description,
								   unit: convertToOTLP(gauge.unit),
								   gauge: gaugeOTLP,
								   sum: nil,
								   histogram: nil,
								   exponentialHistogram: nil,
								   summary: nil)
		return metric
	}

	func exportOTLP<T>(histogram: Histogram<T>) -> OTLP.V1Metric {

		let values = histogram.values.allValues
		var dataPoints = [OTLP.V1HistogramDataPoint]()
		
		for key in values.keys {
			guard let value = values[key] else {
				continue
			}

			let attributes = convertToOTLP(attributes: key)
			let startTimeUnixNano = convertToOTLP(time: histogram.startTime)

			let bucketCounts = convertToOTLP(bucketCounts: value.data)
			let sum = asDouble(value.sum)

			let timeUnixNano = convertToOTLP(time: AbsoluteTime())

			let dataPoint = OTLP.V1HistogramDataPoint(attributes: attributes,
													  startTimeUnixNano: startTimeUnixNano,
													  timeUnixNano: timeUnixNano,
													  count: "\(value.count)",
													  sum: sum,
													  bucketCounts: bucketCounts,
													  explicitBounds: convertToOTLP(explicitBounds: value.explicitBounds),
													  exemplars: nil, // no exemplar support
													  flags: nil)
			dataPoints.append(dataPoint)
		}
		
		let v1Histogram = OTLP.V1Histogram(dataPoints: dataPoints, aggregationTemporality: convertToOTLP(histogram.aggregationTemporality))
	
		let metric = OTLP.V1Metric(name: histogram.name,
								   description: histogram.description,
								   unit: convertToOTLP(histogram.unit),
								   gauge: nil,
								   sum: nil,
								   histogram: v1Histogram,
								   exponentialHistogram: nil,
								   summary: nil)
		
		return metric
	}
	
	func convertToOTLP(bucketCounts: [UInt64]) -> [String] {
		bucketCounts.map { "\($0)" }
	}

	func convertToOTLP<T: MetricNumeric>(explicitBounds: [T]) -> [Double] {
		explicitBounds.map { asDouble($0) }
	}

	func convertToOTLP(_ temporality: AggregationTemporality) -> OTLP.V1AggregationTemporality {
		switch temporality {
		case .unspecified:
			return .unspecified
		case .delta:
			return .delta
		case .cumulative:
			return .cumulative
		}
	}
	
	func convertToOTLP(_ unit: Unit?) -> String? {
		
		guard let unit = unit else {
			return nil
		}
		
		// http://unitsofmeasure.org/ucum.html
		// TBD: implementation
		return unit.symbol
	}

	func asDouble<T: MetricNumeric>(_ val: T) -> Double {
		switch val {
		case let d as Double: return d
		case let i as Int: return Double(i)
		default: fatalError()
		}
	}
}
