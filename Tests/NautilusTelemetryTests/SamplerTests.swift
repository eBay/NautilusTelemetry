//
//  SamplerTests.swift
//  
//
//  Created by Ladd Van Tol on 1/13/22.
//

import Foundation
import XCTest
@testable import NautilusTelemetry

final class SamplerTests: XCTestCase {
	
	func testStableGuidSampler() {
		let seed = Data([0x00])
		let guid = Data([0xFF])
		
		let sampler1 = StableGuidSampler(sampleRate: 1.0, seed: seed, guid: guid)
		XCTAssert(!sampler1.shouldSample)
		
		sampler1.sampleRate = 100.0
		XCTAssert(sampler1.shouldSample)
		
		let sampler2 = StableGuidSampler(sampleRate: 25.0, seed: seed, guid: guid)
		XCTAssert(!sampler2.shouldSample)
		
		sampler2.guid = Data([0x04])
		XCTAssert(sampler2.shouldSample) // should be true with the new GUID
	}
}
