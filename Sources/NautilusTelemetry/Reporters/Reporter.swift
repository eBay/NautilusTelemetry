//
//  Reporter.swift
//  
//
//  Created by Van Tol, Ladd on 11/29/21.
//

import Foundation

public protocol Reporter {
	
	/// Desired flush interval
	var flushInterval: TimeInterval { get }
	
	func reportSpans(_ spans: [Span])

	func reportInstruments(_ instruments: [Instrument])

	/// Add listeners for application lifecycle events -- typically called during didFinishLaunching
	func subscribeToLifecycleEvents()
}
