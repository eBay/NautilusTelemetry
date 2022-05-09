//
//  Identifiers.swift
//  
//
//  Created by Van Tol, Ladd on 10/4/21.
//

import Foundation

// Identifiers and shared types

public typealias MetricNumeric = Numeric & Comparable

/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/datamodel.md
/// The spec definition of attributes is a little confusing -- I may have gotten this wrong
public typealias TelemetryAttributes = [String: AnyHashable]

public typealias SpanId = Data
public typealias TraceId = Data

internal struct Identifiers {
	// MARK: utilities
	private static var random = SystemRandomNumberGenerator()
	
	/// Generates a 128 session GUID
	/// - Returns: 128 bit identifier as Data
	static func generateSessionGUID() -> TraceId {
		let bytes = [random.next(), random.next()]
		return bytes.withUnsafeBufferPointer { Data(buffer: $0) }
	}

	/// Generates a 128 trace id
	/// - Returns: 128 bit identifier as Data
	static func generateTraceId() -> TraceId {
		let bytes = [random.next(), random.next()]
		return bytes.withUnsafeBufferPointer { Data(buffer: $0) }
	}
	
	/// Generates a 128 span id
	/// Sequential identifiers might be better for collision avoidance: https://en.wikipedia.org/wiki/Birthday_attack#Mathematics
	/// - Returns: 64 bit identifier as Data
	static func generateSpanId() -> SpanId {
		let bytes = [random.next()]
		return bytes.withUnsafeBufferPointer { Data(buffer: $0) }
	}
}

internal extension Data {
	func hexEncodedString() -> String {
		if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
			return hexEncodedStringFastPath()
		} else {
			return hexEncodedStringSlowPath()
		}
	}
	
	@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
	func hexEncodedStringFastPath() -> String {
		let hexDigits = "0123456789abcdef"
		let utf8Digits = Array(hexDigits.utf8)
		return String(unsafeUninitializedCapacity: 2 * self.count) { (ptr) -> Int in
			if var p = ptr.baseAddress {
				for byte in self {
					p[0] = utf8Digits[Int(byte / 16)]
					p[1] = utf8Digits[Int(byte % 16)]
					p += 2
				}
				return 2 * self.count
			} else {
				return 0
			}
		}
	}
	
	func hexEncodedStringSlowPath() -> String {
		let hexDigits = "0123456789abcdef"
		let utf16Digits = Array(hexDigits.utf16)
		var chars: [unichar] = []
		chars.reserveCapacity(2 * self.count)
		for byte in self {
			chars.append(utf16Digits[Int(byte / 16)])
			chars.append(utf16Digits[Int(byte % 16)])
		}
		return String(utf16CodeUnits: chars, count: chars.count)
	}
}
