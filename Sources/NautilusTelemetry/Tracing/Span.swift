//
//  Span.swift
//  
//
//  Created by Van Tol, Ladd on 9/27/21.
//

import Foundation


/// Subset of types available in OTLP.SpanSpanKind
public enum SpanKind {
	/// Unspecified. The implementation will infer the kind from the parent span.
	case unspecified
	/// Indicates that the span represents an internal operation within an application, as opposed to an operation happening at the boundaries. This is the default.
	case `internal`
	/// Indicates that the span describes a request to some remote service.
	case client
}

/// Pared down version of the spec
public final class Span: Identifiable {
	let name: String
	let kind: SpanKind
	public let traceId: TraceId
	public let id: SpanId
	let parentId: SpanId?
	let startTime: AbsoluteTime
	var attributes: TelemetryAttributes?
	var events = [Event]()
	var status: Status = .ok
	var endTime: AbsoluteTime?
	var retireCallback: ((_: Span) -> Void)?

	/// This can be set by the consuming code to affect the traceParentHeader value
	public var sampled: Bool = true
	
	var elapsed: AbsoluteTimeInterval? {
		get {
			guard let endTime = endTime else { return nil }
			return AbsoluteTimeInterval(startTime, endTime)
		}
	}
	
	/// returns a value that can be used as a "traceparent" header
	public var traceParentHeader: String {
		get {
			// https://www.w3.org/TR/trace-context/#traceparent-header-field-values
			
			var flags: UInt8 = 0x00
			flags |= sampled ? 1 : 0
			
			let hexFlags = Data([flags]).hexEncodedString()
			/// version, trace-id, parent-id, trace-flags
			return "00-\(traceId.hexEncodedString())-\(id.hexEncodedString())-\(hexFlags)"
		}
	}
	
	internal init(name: String,
				  kind: SpanKind = .internal,
				  attributes: TelemetryAttributes? = nil,
				  startTime: AbsoluteTime = AbsoluteTime(),
				  endTime: AbsoluteTime? = nil,
				  traceId: TraceId,
				  id: SpanId = Identifiers.generateSpanId(),
				  parentId: SpanId?,
				  retireCallback: ((_: Span) -> Void)? = nil) {

		self.name = name
		self.kind = kind
		self.attributes = attributes
		self.traceId = traceId
		self.id = id
		self.parentId = parentId
		self.startTime = startTime
		self.endTime = endTime
		self.retireCallback = retireCallback

		addDefaultAttributes()
	}
	
	public func end() {
		assert(endTime == nil)
		endTime = AbsoluteTime()
		
		if let retireCallback = retireCallback {
			retireCallback(self)
			self.retireCallback = nil
		}
	}
	
	public var ended: Bool {
		return endTime != nil
	}
	
	/// Adds an attribute to the span
	/// - Parameters:
	///   - name: a name, conforming to https://github.com/open-telemetry/opentelemetry-specification/tree/main/specification/trace/semantic_conventions
	///   - value: a value
	public func addAttribute(_ name: String, value: AnyHashable?) {
		if attributes == nil {
			attributes = TelemetryAttributes()
		}
		
		attributes?[name] = value
	}
	
	func addDefaultAttributes() {
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/semantic_conventions/span-general.md#general-thread-attributes
		
		if Thread.isMainThread {
			addAttribute("thread.name", value: "main")
		} else {
			// No nice way to get the current queue, so we'll try thread name
			if let threadName = Thread.current.name, threadName.count > 0 {
				addAttribute("thread.name", value: threadName)
			}
		}
	}
	
	public func addEvent(_ event: Event) {
		events.append(event)
	}
	
	public func recordError(_ error: Error) {
		// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/semantic_conventions/exceptions.md
		
		let message = error.localizedDescription
		
		// TBD: figure out Swift symbol demangling?
		// This doesn't seem to exist yet: https://forums.swift.org/t/demangle-function/25416
		// This looks OK, but is ≈9K lines: https://github.com/oozoofrog/SwiftDemangle
		let callStackLimit = 20
		let callstackSymbols = Thread.callStackSymbols.prefix(callStackLimit)
		let callstack = callstackSymbols.joined(separator: "\n")
		
		let attributes = [
			"exception.type": String(describing: type(of: error)),
			"exception.message": message,
			"exception.stacktrace": callstack
		]
		
		let exceptionEvent = Event(name: "exception", attributes: attributes)
		addEvent(exceptionEvent)
		status = .error(message: message) // this duplicates exception.message above, but makes the reporting work better
	}
	
	public struct Event: ExpressibleByStringLiteral {
		let time: AbsoluteTime
		let name: String
		
		let attributes: TelemetryAttributes?
		
		public init(stringLiteral name: String) {
			self.init(name: name)
		}
		
		public init(name: String, attributes: TelemetryAttributes? = nil) {
			self.time = AbsoluteTime()
			self.name = name
			self.attributes = attributes
		}
	}
	
	public enum Status: Equatable {
		case unset
		case ok
		case error(message: String)
	}
}
