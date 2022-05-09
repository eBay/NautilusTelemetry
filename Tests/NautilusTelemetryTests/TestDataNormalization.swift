//
//  TestDataNormalization.swift
//  
//
//  Created by Ladd Van Tol on 3/2/22.
//

import Foundation

public struct TestDataNormalization {

	/// Redacts any keys in the provided list, returning a sorted normalized JSON string
	/// Typically used for variable outputs like hashes or timestamps where we don't care about the specific value
	/// - Parameters:
	///   - data: json data
	///   - keyValuesToRedact: Any keys to be redacted. Their values will be replaced with `***`
	/// - Throws: errors
	/// - Returns: normalized json string, or nil
	public static func normalizedJsonString(data: Data, keyValuesToRedact: [String]) throws -> String? {
		// recursive redaction
		func redact(_ obj: Any) -> Any {
			if var dict = obj as? Dictionary<String,Any> {
				for (key,value) in dict {
					if keyValuesToRedact.contains(key) {
						dict[key] = "***"
					} else {
						dict[key] = redact(value)
					}
				}
				return dict
			}
			else if let array = obj as? Array<Any> {
				return array.map() { redact($0) }
			} else {
				return obj
			}
		}
		
		let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableLeaves, .mutableContainers])
		let redacted = redact(jsonObject)
		let serialized = try JSONSerialization.data(withJSONObject: redacted, options: .sortedKeys)

		return String(data: serialized, encoding: .utf8)
	}
}
