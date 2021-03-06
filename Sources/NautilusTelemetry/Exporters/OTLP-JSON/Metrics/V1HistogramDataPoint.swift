//
// V1HistogramDataPoint.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** HistogramDataPoint is a single data point in a timeseries that describes the time-varying values of a Histogram. A Histogram contains summary statistics for a population of values, it may optionally contain the distribution of those values across a set of buckets.  If the histogram contains the distribution of values, then both \"explicit_bounds\" and \"bucket counts\" fields must be defined. If the histogram does not contain the distribution of values, then both \"explicit_bounds\" and \"bucket_counts\" must be omitted and only \"count\" and \"sum\" are known. */
	struct V1HistogramDataPoint: Codable, Equatable {
		/** The set of key/value pairs that uniquely identify the timeseries from where this point belongs. The list may be empty (may contain 0 elements). */
		internal let attributes: [V1KeyValue]?
		/** StartTimeUnixNano is optional but strongly encouraged, see the the detailed comments above Metric.  Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970. */
		internal let startTimeUnixNano: String?
		/** TimeUnixNano is required, see the detailed comments above Metric.  Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970. */
		internal let timeUnixNano: String?
		/** count is the number of values in the population. Must be non-negative. This value must be equal to the sum of the \"count\" fields in buckets if a histogram is provided. */
		internal let count: String?
		/** sum of the values in the population. If count is zero then this field must be zero.  Note: Sum should only be filled out when measuring non-negative discrete events, and is assumed to be monotonic over the values of these events. Negative events *can* be recorded, but sum should not be filled out when doing so.  This is specifically to enforce compatibility w/ OpenMetrics, see: https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#histogram */
		internal let sum: Double?
		/** bucket_counts is an optional field contains the count values of histogram for each bucket.  The sum of the bucket_counts must equal the value in the count field.  The number of elements in bucket_counts array must be by one greater than the number of elements in explicit_bounds array. */
		internal let bucketCounts: [String]?
		/** explicit_bounds specifies buckets with explicitly defined bounds for values.  The boundaries for bucket at index i are:  (-infinity, explicit_bounds[i]] for i == 0 (explicit_bounds[i-1], explicit_bounds[i]] for 0 < i < size(explicit_bounds) (explicit_bounds[i-1], +infinity) for i == size(explicit_bounds)  The values in the explicit_bounds array must be strictly increasing.  Histogram buckets are inclusive of their upper boundary, except the last bucket where the boundary is at infinity. This format is intentionally compatible with the OpenMetrics histogram definition. */
		internal let explicitBounds: [Double]?
		internal let exemplars: [V1Exemplar]?
		/** Flags that apply to this specific data point.  See DataPointFlags for the available flags and their meaning. */
		internal let flags: Int64?

		internal init(attributes: [V1KeyValue]?, startTimeUnixNano: String?, timeUnixNano: String?, count: String?, sum: Double?, bucketCounts: [String]?, explicitBounds: [Double]?, exemplars: [V1Exemplar]?, flags: Int64?) {
			self.attributes = attributes
			self.startTimeUnixNano = startTimeUnixNano
			self.timeUnixNano = timeUnixNano
			self.count = count
			self.sum = sum
			self.bucketCounts = bucketCounts
			self.explicitBounds = explicitBounds
			self.exemplars = exemplars
			self.flags = flags
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case attributes
			case startTimeUnixNano = "start_time_unix_nano"
			case timeUnixNano = "time_unix_nano"
			case count
			case sum
			case bucketCounts = "bucket_counts"
			case explicitBounds = "explicit_bounds"
			case exemplars
			case flags
		}
	}
}
