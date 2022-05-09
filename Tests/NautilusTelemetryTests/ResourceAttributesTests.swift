//
//  ResourceAttributesTests.swift
//  
//
//  Created by Van Tol, Ladd on 11/4/21.
//

import Foundation
@testable import NautilusTelemetry
import XCTest

final class ResourceAttributesTests: XCTestCase {
	
	func testAttributes() throws {
		let timeReference = TimeReference(serverOffset: 0.0)
		let exporter = Exporter(timeReference: timeReference)

		let attributes = ResourceAttributes.makeWithDefaults(additionalAttributes: ["foo": "bar"]).keyValues
		
		_ = try XCTUnwrap(exporter.convertToOTLP(attributes: attributes)) // make sure it converts
		
		_ = try XCTUnwrap(attributes["service.name"])
		_ = try XCTUnwrap(attributes["service.version"])
		_ = try XCTUnwrap(attributes["telemetry.sdk.name"])
		_ = try XCTUnwrap(attributes["telemetry.sdk.language"])
		_ = try XCTUnwrap(attributes["device.id"])
		_ = try XCTUnwrap(attributes["foo"])
		_ = try XCTUnwrap(attributes["os.type"])
		_ = try XCTUnwrap(attributes["os.name"])
		let osVersion = try XCTUnwrap(attributes["os.version"] as? String)

		let components = osVersion.split(separator: ".")
		XCTAssert(components.count >= 2)
		
		let firstComponent = try XCTUnwrap(Int(String(components[0])))
		
		#if os(iOS)
			XCTAssertGreaterThanOrEqual(firstComponent, 13)
		#elseif os(watchOS)
			XCTAssertGreaterThanOrEqual(firstComponent, 8)
		#else
			XCTAssertGreaterThanOrEqual(firstComponent, 11)
		#endif
	}
}
