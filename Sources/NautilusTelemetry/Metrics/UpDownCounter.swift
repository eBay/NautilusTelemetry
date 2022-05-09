//
//  UpDownCounter.swift
//  
//
//  Created by Van Tol, Ladd on 12/15/21.
//

import Foundation

public class UpDownCounter<T: MetricNumeric>: Counter<T> {
	override public var isMonotonic: Bool { return false }

	// may be negative
	override public func add(_ number: T, attributes: TelemetryAttributes = [:]) {
		values.add(number, attributes: attributes)
	}
}
