//
//  HardwareDetails.swift
//  
//
//  Created by Van Tol, Ladd on 11/4/21.
//

import Foundation

public struct HardwareDetails {
	
	public static var platformCachedValue: String? = {
		// This doesn't change after launch, so evaluate once
		
		// The meanings are swapped between iOS and Mac OS:
		// https://www.cocoawithlove.com/blog/2016/03/08/swift-wrapper-for-sysctl.html#looking-for-the-source
		// In `isiOSAppOnMac` mode, the device pretends to be an iPad Pro -- we don't want this, so switch to `hw.model`
		// to retrieve the actual Mac model name. This is also slightly useful when running on sim (or if we support catalyst in the future).
		let sysctlName = isOnMac ? "hw.model" : "hw.machine"
		return sysctlbyname(sysctlName)
	}()
	
	private static var isOnMac: Bool = {
		// This doesn't change after launch, so evaluate once
		var isOnMac = false
		
#if targetEnvironment(simulator)
		isOnMac = true
#else
		let processInfo = ProcessInfo.processInfo
		
		if processInfo.isMacCatalystApp {
			isOnMac = true
		}
		
		if #available(iOS 14, *) {
			if processInfo.isiOSAppOnMac {
				isOnMac = true
			}
		}
#endif
		
		return isOnMac
	}()
	
	private static func sysctlbyname(_ name: String) -> String {
		var size = 0
		Darwin.sysctlbyname(name, nil, &size, nil, 0)
		var val = [CChar](repeating: 0,  count: size)
		Darwin.sysctlbyname(name, &val, &size, nil, 0)
		return String(cString: val)
	}
}

