//
// V1Status.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

extension OTLP {
	/** The Status type defines a logical error model that is suitable for different programming environments, including REST APIs and RPC APIs. */
	struct V1Status: Codable, Equatable {
		/** A developer-facing human readable error message. */
		internal let message: String?
		internal let code: StatusStatusCode?

		internal init(message: String?, code: StatusStatusCode?) {
			self.message = message
			self.code = code
		}

		internal enum CodingKeys: String, CodingKey, CaseIterable {
			case message
			case code
		}
	}
}