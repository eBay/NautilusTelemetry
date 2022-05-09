//
//  ExporterTests.swift
//  
//
//  Created by Ladd Van Tol on 3/22/22.
//

import Foundation
import XCTest

@testable import NautilusTelemetry

final class ExporterTests: XCTestCase {
	let timeReference = TimeReference(serverOffset: 0)

	func testConvertToOTLPString() throws {
		let exporter = Exporter(timeReference: timeReference, prettyPrint: false)
		
		let string = "abc"
		let stringVal = try XCTUnwrap(exporter.convertToOTLP(value: string))
		XCTAssertEqual(stringVal.stringValue, "abc")
	}

	func testConvertToOTLPBool() throws {
		let exporter = Exporter(timeReference: timeReference, prettyPrint: false)

		let bool1 = true
		let boolVal1 = try XCTUnwrap(exporter.convertToOTLP(value: bool1))
		XCTAssertEqual(boolVal1.boolValue, true)

		let bool2 = false
		let boolVal2 = try XCTUnwrap(exporter.convertToOTLP(value: bool2))
		XCTAssertEqual(boolVal2.boolValue, false)
	}
	
	func testConvertToOTLPFloats() throws {
		let exporter = Exporter(timeReference: timeReference, prettyPrint: false)

		let float = Float(100)
		let floatValue = try XCTUnwrap(exporter.convertToOTLP(value: float))
		XCTAssertEqual(Float(try XCTUnwrap(floatValue.doubleValue)), float)

		let double = Double(32)
		let doubleValue = try XCTUnwrap(exporter.convertToOTLP(value: double))
		XCTAssertEqual(doubleValue.doubleValue, double)
	}
	
	func testConvertToOTLPIntegers() throws {
		let exporter = Exporter(timeReference: timeReference, prettyPrint: false)

		let uint64 = UInt64.max
		let intValue1 = try XCTUnwrap(exporter.convertToOTLP(value: uint64))
		XCTAssertEqual(intValue1.intValue, "\(uint64)")

		let int64 = Int64.max
		let intValue2 = try XCTUnwrap(exporter.convertToOTLP(value: int64))
		XCTAssertEqual(intValue2.intValue, "\(int64)")

		let uint32 = UInt32.max
		let intValue3 = try XCTUnwrap(exporter.convertToOTLP(value: uint32))
		XCTAssertEqual(intValue3.intValue, "\(uint32)")

		// make sure we don't cast to Bool accidentally
		let uint: UInt = 0
		let intValue4 = try XCTUnwrap(exporter.convertToOTLP(value: uint))
		XCTAssertEqual(intValue4.intValue, "\(uint)")
		XCTAssertNil(intValue4.boolValue)

		let int32 = Int32.max
		let intValue5 = try XCTUnwrap(exporter.convertToOTLP(value: int32))
		XCTAssertEqual(intValue5.intValue, "\(int32)")
	}
	
	func testConvertToOTLPComplexTypes() throws {
		let exporter = Exporter(timeReference: timeReference, prettyPrint: false)
		let data = try XCTUnwrap("📀".data(using: .utf8))
		let dataValue = try XCTUnwrap(exporter.convertToOTLP(value: data))
		XCTAssertEqual(dataValue.bytesValue, data)
		let encodedJsonString = String(data: try exporter.encodeJSON(dataValue), encoding: .utf8)
		XCTAssertEqual(encodedJsonString, #"{"bytes_value":"f09f9380"}"#)
		
		let array: [Any] = ["foo", 1]
		let arrayValue = try XCTUnwrap(exporter.convertToOTLP(value: array))
		let values = try XCTUnwrap(arrayValue.arrayValue?.values)
		let value0 = values[0]
		XCTAssertEqual("foo", value0.stringValue)
		let value1 = values[1]
		XCTAssertEqual("1", value1.intValue)

		let dictionary = ["foo": 1]
		let dictionaryValue = try XCTUnwrap(exporter.convertToOTLP(value: dictionary))
		let kvValue = try XCTUnwrap(dictionaryValue.kvlistValue?.values?[0])
		XCTAssertEqual(kvValue.key, "foo")
		XCTAssertEqual(kvValue.value?.intValue, "1")

		let notConvertible = self
		let notConvertibleValue = exporter.convertToOTLP(value: notConvertible)
		XCTAssertNil(notConvertibleValue)
	}
}

