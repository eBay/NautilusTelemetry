//
// V1ResourceMetrics.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** A collection of InstrumentationLibraryMetrics from a Resource. */
	struct V1ResourceMetrics: Codable, Equatable {
		internal let resource: V1Resource?
		/** A list of metrics that originate from a resource. */
		internal let instrumentationLibraryMetrics: [V1InstrumentationLibraryMetrics]?
		/** This schema_url applies to the data in the \"resource\" field. It does not apply to the data in the \"instrumentation_library_metrics\" field which have their own schema_url field. */
		internal let schemaUrl: String?

		internal init(resource: V1Resource?, instrumentationLibraryMetrics: [V1InstrumentationLibraryMetrics]?, schemaUrl: String?) {
			self.resource = resource
			self.instrumentationLibraryMetrics = instrumentationLibraryMetrics
			self.schemaUrl = schemaUrl
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case resource
			case instrumentationLibraryMetrics = "instrumentation_library_metrics"
			case schemaUrl = "schema_url"
		}
	}
}
