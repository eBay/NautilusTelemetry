//
//  NoOpReporter.swift
//  
//
//  Created by Ladd Van Tol on 11/30/21.
//

import Foundation

public final class NoOpReporter: Reporter {
	
	public init() {
	}
	
	public var flushInterval: TimeInterval {
		return 60
	}
		
	public func reportSpans(_ spans: [Span]) {
	}
	
	public func reportInstruments(_ instruments: [Instrument]) {
	}
	
	public func subscribeToLifecycleEvents() {
	}
}
