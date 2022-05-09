//
//  ExampleReporter.swift
//  NautilusBase
//
//  Created by Ladd Van Tol on 4/6/2021.
//  Copyright © 2021 eBay Inc. All rights reserved.
//

import Foundation
#if canImport(UIKit)
	import UIKit
#endif

/// An example telemetry reporter. Intended to be modified for specific use cases.
@available(iOS 13.0, *)
public class ExampleReporter: Reporter {

	/// If collector supports brotli in the future
	let brotliAllowed = false

	enum ReporterError: Error {
		case failure
	}

	static let lock = UnfairLock()
	
	let timeReference = TimeReference(serverOffset: 0) // Ideally the offset to server time should be computed
	
	let traceEndpoint = URL(string: "https://api.example.com/v1/traces")!
	let metricEndpoint = URL(string: "https://api.example.com/v1/metrics")!
	let logEndpoint = URL(string: "https://api.example.com/v1/logs")!
	
	let urlSession: URLSession
	
	public init() {
		let configuration = URLSessionConfiguration.default
		configuration.networkServiceType = .background
		configuration.httpAdditionalHeaders = ["User-Agent": Self.userAgent]
		urlSession = URLSession(configuration: configuration)
	}
	
	public func subscribeToLifecycleEvents() {
		let backgroundNotificationName = UIApplication.shared.supportsMultipleScenes ? UIScene.didEnterBackgroundNotification : UIApplication.didEnterBackgroundNotification
		NotificationCenter.default.addObserver(forName: backgroundNotificationName, object: nil, queue: OperationQueue.main) { _ in self.didEnterBackground() }
	}
	
	static var userAgent: String = {
		let bundle = Bundle.main
		let bundleIdentifier = bundle.bundleIdentifier ?? "unknown"
		let bundleVersion = (bundle.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
		return "\(bundleIdentifier)/\(bundleVersion)"
	}()
	
	static private var _sessionGUID: Data?
	static var sessionGUID: Data {
		lock.sync {
			if let guid = _sessionGUID {
				return guid
			} else {
				let guid = Identifiers.generateSessionGUID()
				_sessionGUID = guid
				return guid
			}
		}
	}
	
	static func resetSessionGUID() {
		lock.sync {
			_sessionGUID = nil
		}
	}
	
	// MARK: Lifecycle events
	func didEnterBackground() {
		InstrumentationSystem.tracer.flushTrace()
		Self.resetSessionGUID()
	}
	
	// MARK: Reporting
	public var flushInterval: TimeInterval {
		return 60
	}
	
	static let sampler = StableGuidSampler(sampleRate: 1.0, seed: Data("OpenTelemetry".utf8), guid: sessionGUID)
	static var samplingEnabled: Bool {
		sampler.guid = Self.sessionGUID
		return sampler.shouldSample
	}
	
	public func reportSpans(_ spans: [Span]) {
		guard Self.samplingEnabled else {
			return
		}
		
		let additionalAttributes = ["sample": "value"]
		let exporter = Exporter(timeReference: timeReference)
		
		if let jsonPayload = try? exporter.exportOTLPToJSON(spans: spans, additionalAttributes: additionalAttributes) {
			try? dispatchPayload(jsonPayload: jsonPayload, url: traceEndpoint)
		}
	}
	
	public func reportInstruments(_ instruments: [Instrument]) {
		guard Self.samplingEnabled else {
			return
		}
		
		let additionalAttributes = ["sample": "value"]
		let exporter = Exporter(timeReference: timeReference)
		
		if let jsonPayload = try? exporter.exportOTLPToJSON(instruments: instruments, additionalAttributes: additionalAttributes) {
			try? dispatchPayload(jsonPayload: jsonPayload, url: traceEndpoint)
		}
	}
	
	func dispatchPayload(jsonPayload: Data, url: URL) throws {
		var compressedPayload: Data? = nil
		var contentEncoding: String? = nil
		
		if brotliAllowed, #available(iOS 15.0, *) {
			compressedPayload = try Compression.compressBrotli(data: jsonPayload)
			contentEncoding = "br"
		} else {
			compressedPayload = try Compression.compressDeflate(data: jsonPayload)
			contentEncoding = "deflate"
		}
		
		guard let compressedPayload = compressedPayload, let contentEncoding = contentEncoding else {
			throw ReporterError.failure
		}
		
		let traceIdString = InstrumentationSystem.tracer.currentSpan.traceId.hex
		var urlRequest = URLRequest(url: url)
		urlRequest.httpBody = compressedPayload
		urlRequest.addValue(contentEncoding, forHTTPHeaderField: "Content-Encoding")
		let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
			if self.success(urlResponse) {
				print("\(url): success, traceId = \(traceIdString)")
			} else {
				print("\(url): error=\(String(describing: error))")
			}
		}
		
		// priority is only significant for HTTP/2+ when sharing an URLSession object with other concurrent requests
		task.priority = 0.25
		task.resume()
	}
	
	func success(_ urlResponse: URLResponse?) -> Bool {
		if let httpUrlResponse = urlResponse as? HTTPURLResponse {
			return httpUrlResponse.statusCode == 200
		} else {
			return false
		}
	}
}

fileprivate extension Data {
	var hex: String {
		return self.reduce("") {$0 + String(format: "%02x", $1)} // slow but one line to get hex
	}
}

