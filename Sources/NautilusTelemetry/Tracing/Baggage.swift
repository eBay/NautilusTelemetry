//
//  Baggage.swift
//  
//
//  Created by Van Tol, Ladd on 11/15/21.
//

import Foundation

/// Implemented as NSObject, so we can be stored in threadDictionary
public final class Baggage: NSObject {
	static let lock = UnfairLock()

	/// Experimental thread-bound baggage
	/// Task locals will  be a better model: https://developer.apple.com/documentation/swift/tasklocal
	
	static let key = "NautilusTelemetryBaggage"
	
	static func set(baggage: Baggage, thread: Thread = Thread.current) {
		lock.sync {
			thread.threadDictionary[key] = baggage
		}
	}
	
	static func get(thread: Thread = Thread.current) -> Baggage? {
		lock.sync {
			return thread.threadDictionary[key] as? Baggage
		}
	}

#if compiler(>=5.6.0) && canImport(_Concurrency)
	@TaskLocal static var currentBaggageTaskLocal: Baggage?
#endif
	
	public init(span: Span) {
		self.span = span
	}
	
	let span: Span
}
