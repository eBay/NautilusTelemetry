import XCTest
@testable import NautilusTelemetry

final class AbsoluteTimeTests: XCTestCase {
	
	func testBasics() {
		
		let time1 = AbsoluteTime()
		print("something very short")
		let time2 = AbsoluteTime()
		
		XCTAssert(time1 < time2)
		
		let elapsed = AbsoluteTimeInterval(time1, time2)
		
		XCTAssertGreaterThan(elapsed.seconds, 0)
		XCTAssertGreaterThanOrEqual(elapsed.milliseconds, Int64(elapsed.seconds))
		XCTAssertGreaterThanOrEqual(elapsed.microseconds, elapsed.milliseconds)
		XCTAssertGreaterThanOrEqual(elapsed.nanoseconds, elapsed.microseconds)
		
		let elapsedInverse = AbsoluteTimeInterval(time2, time1)
		
		XCTAssertEqual(elapsed.seconds, -elapsedInverse.seconds)
		XCTAssertEqual(elapsed.milliseconds, -elapsedInverse.milliseconds)
		XCTAssertEqual(elapsed.microseconds, -elapsedInverse.microseconds)
		XCTAssertEqual(elapsed.nanoseconds, -elapsedInverse.nanoseconds)
		
		// Can't really assert exact timings without making the test flakey
	}
	
	func testToSeconds() {
		
		let time1 = mach_continuous_time()
		let time2 = mach_continuous_time()
		
		let elapsed = AbsoluteTime.toSeconds(time2-time1)
		
		XCTAssertLessThan(elapsed, 0.1)
	}
}
