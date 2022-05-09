//
//  ProcessDetails.swift
//  
//
//  Created by Ladd Van Tol on 9/23/21.
//

import Foundation

/// Provides information about the running process
public struct ProcessDetails {
	
	/// Provide the time since the process started. I can't find a way to get this in absolute time, so we'll just provide wall clock time
	public static var timeSinceStart: TimeInterval  {
		
		var result: TimeInterval = 0.0
		let now = (NSTimeIntervalSince1970+Date.timeIntervalSinceReferenceDate)
		
		var kp = kinfo_proc()
		var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
		
		var len = MemoryLayout.size(ofValue: kp)
		
		mib.withUnsafeMutableBufferPointer() { mib in
			if sysctl(mib.baseAddress, 4, &kp, &len, nil, 0) == 0 && len > 0 {
				let startTime = kp.kp_proc.p_starttime
				let processLaunchTime = Double(startTime.tv_sec) + (Double(startTime.tv_usec) / 1000000.0)
				result = now-processLaunchTime
			} else {
				perror("sysctl")
			}
		}
		
		return result
	}
}

