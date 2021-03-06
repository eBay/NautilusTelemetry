//
// V1Resource.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** Resource information. */
	struct V1Resource: Codable, Equatable {
		/** Set of labels that describe the resource. */
		internal let attributes: [V1KeyValue]?
		/** dropped_attributes_count is the number of dropped attributes. If the value is 0, then no attributes were dropped. */
		internal let droppedAttributesCount: Int64?

		internal init(attributes: [V1KeyValue]?, droppedAttributesCount: Int64?) {
			self.attributes = attributes
			self.droppedAttributesCount = droppedAttributesCount
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case attributes
			case droppedAttributesCount = "dropped_attributes_count"
		}
	}
}
