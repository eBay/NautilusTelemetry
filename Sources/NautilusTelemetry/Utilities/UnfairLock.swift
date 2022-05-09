//
//  UnfairLock.swift
//  NautilusKernel
//
//  Created by Van Tol, Ladd on 7/14/21.
//  Copyright © 2021 eBay, Inc. All rights reserved.
//

import os

/// A Swift wrapper for `os_unfair_lock`
/// This is faster than using a serial GCD queue or other higher-level constructs.
/// Caution is advised though. Unfair lock:
/// - Is unfair, and may cause waiter starvation
/// - Does not support recursive locking (but neither does dispatch sync)
/// - Does not allow you to lock and unlock from different threads
/// - Is only recommended for protecting small critical sections
public final class UnfairLock {
	// Thread sanitizer didn't like the old implementation
	// See http://www.russbishop.net/the-law for explanation
	
	@usableFromInline
	internal private(set) var unfairLock: UnsafeMutablePointer<os_unfair_lock>
	
	@inlinable
	public init() {
		unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
		unfairLock.initialize(to: os_unfair_lock())
	}
	
	deinit {
		unfairLock.deallocate()
	}

	@inlinable
	public func lock() {
		os_unfair_lock_lock(unfairLock)
	}
	
	@inlinable
	public func unlock() {
		os_unfair_lock_unlock(unfairLock)
	}
	
	@inlinable
	public func sync<T>(block: () throws -> T) rethrows -> T {
		lock()
		defer {
			unlock()
		}
		return try block()
	}
}
