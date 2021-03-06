//
// V1InstrumentationLibrarySpans.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** A collection of Spans produced by an InstrumentationLibrary. */
	struct V1InstrumentationLibrarySpans: Codable, Equatable {
		internal let instrumentationLibrary: V1InstrumentationLibrary?
		/** A list of Spans that originate from an instrumentation library. */
		internal let spans: [V1Span]?
		/** This schema_url applies to all spans and span events in the \"spans\" field. */
		internal let schemaUrl: String?

		internal init(instrumentationLibrary: V1InstrumentationLibrary?, spans: [V1Span]?, schemaUrl: String?) {
			self.instrumentationLibrary = instrumentationLibrary
			self.spans = spans
			self.schemaUrl = schemaUrl
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case instrumentationLibrary = "instrumentation_library"
			case spans
			case schemaUrl = "schema_url"
		}
	}
}
