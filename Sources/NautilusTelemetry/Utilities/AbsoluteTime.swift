//
//  AbsoluteTime.swift
//  
//
//  Created by Ladd Van Tol on 9/23/21.
//

import Foundation
import Dispatch
import Darwin.C.time

/// pins wall clock time to an absolute time
public struct TimeReference {
	
	let serverOffsetNanos: Int64
	let wallTimeReference = clock_gettime_nsec_np(CLOCK_REALTIME)
	let absoluteTimeReference = AbsoluteTime()

	public init(serverOffset: TimeInterval) {
		serverOffsetNanos = Int64(serverOffset * Double(NSEC_PER_SEC))
	}
	
	public func millisecondsSinceEpoch(from time: AbsoluteTime) -> Int64 {
		return microsecondsSinceEpoch(from: time) / 1000
	}

	public func microsecondsSinceEpoch(from time: AbsoluteTime) -> Int64 {
		return nanosecondsSinceEpoch(from: time) / 1000
	}
	
	// Overflows in the year 2262
	public func nanosecondsSinceEpoch(from time: AbsoluteTime) -> Int64 {
		let delta = AbsoluteTimeInterval(absoluteTimeReference, time).nanoseconds
		return Int64(wallTimeReference)+delta+serverOffsetNanos
	}
	
	public func nanosecondsSinceEpoch(from date: Date) -> Int64 {
		// reduce precision loss by splitting into the integer and fractional parts
		let timeInterval = date.timeIntervalSince1970
		let seconds = Int64(timeInterval)
		let fractionalComponent = modf(timeInterval).1
		
		let nanos = seconds * Int64(NSEC_PER_SEC) + Int64(fractionalComponent * Double(NSEC_PER_SEC))
		return Int64(nanos) + serverOffsetNanos
	}
}

/// Container for absolute time
public struct AbsoluteTime: Comparable, Hashable {
	
	static let timebaseInfo: mach_timebase_info = {
		var info = mach_timebase_info()
		guard mach_timebase_info(&info) == KERN_SUCCESS, info.denom != 0 else { fatalError("need mach_timebase_info") }
		return info
	}()
	
	/// Provided for legacy Obj-C compatibility. Not recommended
	public static func toSeconds(_ time: UInt64) -> Double {
		let timeNano = time * UInt64(AbsoluteTime.timebaseInfo.numer) / UInt64(AbsoluteTime.timebaseInfo.denom)
		return Double(timeNano) / Double(NSEC_PER_SEC)
	}
	
	let time: UInt64
	
	public init() {
		// "like mach_absolute_time, but advances during sleep"
		// We could also use `mach_continuous_approximate_time`, which is faster but slightly less accurate:
		// https://opensource.apple.com/source/xnu/xnu-4570.71.2/libsyscall/wrappers/mach_continuous_time.c.auto.html
		time = mach_continuous_time()
	}
	
	/// Convenience to determine current elapsed
	public var elapsed: AbsoluteTimeInterval { return AbsoluteTimeInterval(self, AbsoluteTime()) }
	
	public static func < (lhs: AbsoluteTime, rhs: AbsoluteTime) -> Bool {
		return lhs.time < rhs.time
	}
	
	public static func == (lhs: AbsoluteTime, rhs: AbsoluteTime) -> Bool {
		return lhs.time == rhs.time
	}
}


/// Container for a pair of absolute times, representing an interval.
/// Typically `time1 < time2`, but this is not required.
public struct AbsoluteTimeInterval {
	let time1: AbsoluteTime
	let time2: AbsoluteTime
	let elapsed: Int64
	
	public init(_ time1: AbsoluteTime, _ time2: AbsoluteTime) {
		// Signed 64 bit int is still 292 years of range in nanoseconds
		// I *think* the sign conversions work out here -- let me know how wrong I am
		assert(time1.time < Int64.max)
		assert(time2.time < Int64.max)
		
		self.time1 = time1
		self.time2 = time2
		elapsed = Int64(time2.time)-Int64(time1.time)
	}
	
	public var nanoseconds: Int64 {
		elapsed * Int64(AbsoluteTime.timebaseInfo.numer) / Int64(AbsoluteTime.timebaseInfo.denom)
	}
	
	public var microseconds: Int64 {
		self.nanoseconds / 1000
	}
	
	public var milliseconds: Int64 {
		self.microseconds / 1000
	}
	
	public var seconds: TimeInterval {
		Double(self.nanoseconds) / Double(NSEC_PER_SEC)
	}
}
