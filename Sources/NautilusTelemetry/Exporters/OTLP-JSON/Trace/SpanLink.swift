//
// SpanLink.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** A pointer from the current span to another span in the same trace or in a different trace. For example, this can be used in batching operations, where a single batch handler processes multiple requests from different traces or when the handler receives a request from a different project. */
	struct SpanLink: Codable, Equatable {
		/** A unique identifier of a trace that this linked span is part of. The ID is a 16-byte array. */
		internal let traceId: Data?
		/** A unique identifier for the linked span. The ID is an 8-byte array. */
		internal let spanId: Data?
		/** The trace_state associated with the link. */
		internal let traceState: String?
		/** attributes is a collection of attribute key/value pairs on the link. */
		internal let attributes: [V1KeyValue]?
		/** dropped_attributes_count is the number of dropped attributes. If the value is 0, then no attributes were dropped. */
		internal let droppedAttributesCount: Int64?

		internal init(traceId: Data?, spanId: Data?, traceState: String?, attributes: [V1KeyValue]?, droppedAttributesCount: Int64?) {
			self.traceId = traceId
			self.spanId = spanId
			self.traceState = traceState
			self.attributes = attributes
			self.droppedAttributesCount = droppedAttributesCount
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case traceId = "trace_id"
			case spanId = "span_id"
			case traceState = "trace_state"
			case attributes
			case droppedAttributesCount = "dropped_attributes_count"
		}
	}
}
