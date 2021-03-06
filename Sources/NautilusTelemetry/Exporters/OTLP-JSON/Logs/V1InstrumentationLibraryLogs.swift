//
// V1InstrumentationLibraryLogs.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** A collection of Logs produced by an InstrumentationLibrary. */
	struct V1InstrumentationLibraryLogs: Codable, Equatable {
		internal let instrumentationLibrary: V1InstrumentationLibrary?
		/** A list of log records. */
		internal let logs: [V1LogRecord]?
		/** This schema_url applies to all logs in the \"logs\" field. */
		internal let schemaUrl: String?

		internal init(instrumentationLibrary: V1InstrumentationLibrary?, logs: [V1LogRecord]?, schemaUrl: String?) {
			self.instrumentationLibrary = instrumentationLibrary
			self.logs = logs
			self.schemaUrl = schemaUrl
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case instrumentationLibrary = "instrumentation_library"
			case logs
			case schemaUrl = "schema_url"
		}
	}
}
