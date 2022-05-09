//
//  ResourceAttributes.swift
//  
//
//  Created by Van Tol, Ladd on 11/4/21.
//

import Foundation

#if canImport(UIKit)
	import UIKit
#endif

// Defines top-level 
public struct ResourceAttributes {
	
	static var osVersion: String {
		let osv = ProcessInfo.processInfo.operatingSystemVersion
		if osv.patchVersion > 0 {
			return "\(osv.majorVersion).\(osv.minorVersion).\(osv.patchVersion)"
		}
		else {
			return "\(osv.majorVersion).\(osv.minorVersion)"
		}
	}
	
	/// Create a default set of resource attributes
	/// - Parameter additionalAttributes: Additional attributes. Must conform to https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/attribute-naming.md
	/// - Returns: Built attributes
	public static func makeWithDefaults(additionalAttributes: TelemetryAttributes?) -> ResourceAttributes {
		let placeholder = "unknown"

		let bundle = Bundle.main
		let bundleIdentifier = bundle.bundleIdentifier ?? placeholder
		let applicationVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? placeholder

		#if canImport(UIKit) && os(iOS)
		let vendorIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? placeholder
		#else
		let vendorIdentifier = placeholder
		#endif
		
		let model = HardwareDetails.platformCachedValue ?? placeholder
		
		return ResourceAttributes(bundleIdentifier: bundleIdentifier,
										   applicationVersion: applicationVersion,
										   vendorIdentifier: vendorIdentifier,
										   deviceModelIdentifier: model,
										   osVersion: osVersion,
											additionalAttributes: additionalAttributes)
	}
	
	public init(bundleIdentifier: String, applicationVersion: String, vendorIdentifier: String, deviceModelIdentifier: String, osType: String = "darwin", osName: String = "iOS", osVersion: String, additionalAttributes: TelemetryAttributes?) {
		self.bundleIdentifier = bundleIdentifier
		self.applicationVersion = applicationVersion
		self.vendorIdentifier = vendorIdentifier
		self.deviceModelIdentifier = deviceModelIdentifier
		self.osType = osType
		self.osName = osName
		self.osVersion = osVersion
		self.additionalAttributes = additionalAttributes
	}
	
	let bundleIdentifier: String
	let applicationVersion: String

	let vendorIdentifier: String
	let deviceModelIdentifier: String
	
	let osType: String
	let osName: String
	let osVersion: String
	let additionalAttributes: TelemetryAttributes?

	var keyValues: TelemetryAttributes {
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/common.md
		
		var attributes = TelemetryAttributes()
		
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/README.md
		attributes["service.name"] = bundleIdentifier
		attributes["service.version"] = applicationVersion
		attributes["telemetry.sdk.name"] = "NautilusTracing"
		attributes["telemetry.sdk.language"] = "swift"
		attributes["device.id"] = vendorIdentifier
		
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/device.md
		attributes["device.manufacturer"] = "Apple"
		attributes["device.model"] = deviceModelIdentifier
		
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/os.md
		attributes["os.type"] = osType
		attributes["os.name"] = osName
		attributes["os.version"] = osVersion

		if let additionalAttributes = additionalAttributes {
			// Don't overwrite any existing keys
			attributes.merge(additionalAttributes) { (current, _) in current }
		}

		return attributes
	}
}
