//
//  Exporter.swift
//  
//
//  Created by Van Tol, Ladd on 10/4/21.
//

import Foundation

/// Provides conversions to OTLP-JSON format
public struct Exporter {
	
	let schemaUrl: String? = nil

	/// Provides a mapping between absolute locale time and remote clock time, including server offset
	let timeReference: TimeReference
	
	/// Should the JSON output be pretty printed? Defaults to false
	let prettyPrint: Bool
	
	/// Initialize the exporter with a time reference
	/// - Parameter timeReference: describes the computed offset to server time
	public init(timeReference: TimeReference, prettyPrint: Bool = false) {
		self.timeReference = timeReference
		self.prettyPrint = prettyPrint
	}

	/// Encodes JSON, with Data objects encoded as hex
	/// - Returns: JSON data
	func encodeJSON<T>(_ value: T) throws -> Data where T : Encodable {
		let encoder = JSONEncoder()
		OTLP.configure(encoder: encoder) // setup hex
		
		if prettyPrint {
			encoder.outputFormatting = .prettyPrinted
		}
		let json = try encoder.encode(value)
		return json
	}

	/// Convert `AbsoluteTime` to OTLP nanoseconds since epoch format
	/// - Parameter time: `AbsoluteTime` object
	/// - Returns: String describing nanoseconds since epoch (avoids JSON numeric precision issue)
	func convertToOTLP(time: AbsoluteTime?) -> String? {
		guard let time = time else {
			return nil
		}
		
		return String(timeReference.nanosecondsSinceEpoch(from: time))
	}

	/// Converts common value types to OTLP format
	/// - Parameter value: Any value type
	/// - Returns: OTLP wrapped type, or nil if it could not be converted
	func convertToOTLP(value: Any) -> OTLP.V1AnyValue? {
		var v1AnyValue: OTLP.V1AnyValue? = nil
		
		switch value {
		case let value as String:
			v1AnyValue = OTLP.V1AnyValue(stringValue: value)
		// Look for common int types -- they're expressed as String in OTLP JSON
		// I tried a few options for genericizing the Int types, but couldn't get the [Any] array mapping to work
		case let value as UInt64:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as Int64:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as UInt32:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as Int32:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as UInt:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as Int:
			v1AnyValue = OTLP.V1AnyValue(intValue: "\(value)")
		case let value as Bool:
			v1AnyValue = OTLP.V1AnyValue(boolValue: value)
		case let value as Float:
			v1AnyValue = OTLP.V1AnyValue(doubleValue: Double(value))
		case let value as Double:
			v1AnyValue = OTLP.V1AnyValue(doubleValue: value)
		case let value as Data:
			v1AnyValue = OTLP.V1AnyValue(bytesValue: value)
		case let value as [Any]:
			let otlpArray = value.compactMap { convertToOTLP(value: $0) }
			v1AnyValue = OTLP.V1AnyValue(arrayValue: OTLP.V1ArrayValue(values: otlpArray))
		case let value as [String: Any]:
			let otlpValues = value.compactMap { (key, value) in OTLP.V1KeyValue(key: key, value: convertToOTLP(value: value)) }
			v1AnyValue = OTLP.V1AnyValue(kvlistValue: OTLP.V1KeyValueList(values: otlpValues))
		default:
			v1AnyValue = nil
		}
		
		return v1AnyValue
	}
	
	/// Converts `TelemetryAttributes` to OTLP format
	/// - Parameter attributes: TelemetryAttributes 
	/// - Returns: attributes converted to OTLP format. Values that cannot be converted are omitted.
	func convertToOTLP(attributes: TelemetryAttributes?) -> [OTLP.V1KeyValue]? {
		guard let attributes = attributes else {
			return nil
		}
		
		var otlpAttributes = [OTLP.V1KeyValue]()
		
		let keys = attributes.keys.sorted()
		for key in keys {
			if let value = attributes[key] {
				if let v1AnyValue = convertToOTLP(value: value) {
					let keyValue = OTLP.V1KeyValue(key: key, value: v1AnyValue)
					otlpAttributes.append(keyValue)
				} else {
					assert(false, "failed to convert \(key), \(value)")
				}
			}
		}
		
		return otlpAttributes
	}	
	
}
