//
// V1Sum.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** Sum represents the type of a scalar metric that is calculated as a sum of all reported measurements over a time interval. */
	struct V1Sum: Codable, Equatable {
		internal let dataPoints: [V1NumberDataPoint]?
		internal let aggregationTemporality: V1AggregationTemporality?
		/** If \"true\" means that the sum is monotonic. */
		internal let isMonotonic: Bool?

		internal init(dataPoints: [V1NumberDataPoint]?, aggregationTemporality: V1AggregationTemporality?, isMonotonic: Bool?) {
			self.dataPoints = dataPoints
			self.aggregationTemporality = aggregationTemporality
			self.isMonotonic = isMonotonic
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case dataPoints = "data_points"
			case aggregationTemporality = "aggregation_temporality"
			case isMonotonic = "is_monotonic"
		}
	}
}