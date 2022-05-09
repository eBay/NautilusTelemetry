//
//  Tracer.swift
//  
//
//  Created by Van Tol, Ladd on 10/4/21.
//

import Foundation

public final class Tracer {
	static let lock = UnfairLock()
	
	var currentBaggage: Baggage {
		var baggage: Baggage? = nil
		
#if compiler(>=5.6.0) && canImport(_Concurrency)
		baggage = Baggage.currentBaggageTaskLocal
#endif
		
		if baggage == nil {
			baggage = Baggage.get()
		}
		
		if let baggage = baggage {
			return baggage
		} else {
			return Baggage(span: root)
		}
	}
	
	var traceId = Identifiers.generateTraceId()
	var root: Span
	var retiredSpans = [Span]()
	var flushTimer: DispatchSourceTimer? = nil
	
	public init() {
		root = Span(name: "root", kind: .internal, traceId: traceId, parentId: nil)
		flushInterval = 60
		root.retireCallback = retire // initialization order
	}
	
	/// Fetch the current span, using task local or thread local values, falling back to the root span
	public var currentSpan: Span { currentBaggage.span }
	
	func retire(span: Span) {
		Tracer.lock.sync {
			retiredSpans.append(span)
		}
	}
	
	/// Flushes the root span, and cycles the trace id
	public func flushTrace() {
		root.end() // this implicitly retires
		
		Tracer.lock.sync {
			traceId = Identifiers.generateTraceId()
			root = Span(name: "root", traceId: traceId, parentId: nil, retireCallback: retire)
		}
		
		flushRetiredSpans()
	}
	
	func flushRetiredSpans() {
		let spansToReport: [Span] = Tracer.lock.sync {
			// copy and empty the array
			let spans = retiredSpans
			retiredSpans.removeAll()
			return spans
		}
		
		// If we have no reporter, we'll drop them on the floor to avoid unbounded growth
		if spansToReport.count > 0, let reporter = InstrumentationSystem.reporter {
			reporter.reportSpans(spansToReport)
		}
	}
	
	/// Sets the flush interval for reporting back to the configured ``Reporter``
	var flushInterval: TimeInterval {
		didSet {
			if let flushTimer = flushTimer {
				flushTimer.cancel()
				self.flushTimer = nil
			}
			
			flushTimer = DispatchSource.makeTimerSource(flags: [], queue: NautilusTelemetry.queue)
			
			if let flushTimer = flushTimer {
				flushTimer.setEventHandler(handler: { [weak self] in self?.flushRetiredSpans() })
				flushTimer.schedule(deadline: DispatchTime.now() + flushInterval, repeating: flushInterval, leeway: DispatchTimeInterval.milliseconds(100))
				flushTimer.activate()
			}
		}
	}
	
	/// Create a manually managed span
	/// - Parameters:
	///   - name: the name of the operation
	///   - kind: the kind of the span - may be safely left unspecified in most cases
	///   - attributes: optional attributes
	///   - baggage: Optional ``Baggage``, describing parent span. If nil, will be inferred from task/thread local baggage.
	/// - Returns: A newly created span
	public func startSpan(name: String, kind: SpanKind = .unspecified, attributes: TelemetryAttributes? = nil, baggage: Baggage? = nil) -> Span {
		let resolvedBaggage = baggage ?? currentBaggage
		let finalKind = (kind == .unspecified) ? resolvedBaggage.span.kind : kind // infer from parent span if unspecified
		let span = Span(name: name, kind: finalKind, attributes: attributes, traceId: resolvedBaggage.span.traceId, parentId: resolvedBaggage.span.id, retireCallback: retire)
		return span
	}
	
	/// Create a span that measures a specific block of code
	/// - Parameters:
	///   - name: the name of the operation
	///   - kind: the kind of the span - may be safely left unspecified in most cases
	///   - attributes: optional attributes
	///   - baggage: Optional ``Baggage``, describing parent span. If nil, will be inferred from task/thread local baggage.
	/// - Returns: the result of the wrapped code
	public func withSpan<T>(name: String, kind: SpanKind = .unspecified, attributes: TelemetryAttributes? = nil, baggage: Baggage? = nil, block: () throws -> T) rethrows -> T {
		let previousBaggage = currentBaggage
		let resolvedBaggage = baggage ?? previousBaggage
		let finalKind = (kind == .unspecified) ? resolvedBaggage.span.kind : kind // infer from parent span if unspecified
		let span = Span(name: name, kind: finalKind, attributes: attributes, traceId: resolvedBaggage.span.traceId, parentId: resolvedBaggage.span.id, retireCallback: retire)
		
		defer {
			span.end() // automatically retires the span
			Baggage.set(baggage: previousBaggage)
		}
		
		let baggage = Baggage(span: span)
		Baggage.set(baggage: baggage)
		
		// Still need to set the task local if possible
#if compiler(>=5.6.0) && canImport(_Concurrency)
		return try Baggage.$currentBaggageTaskLocal.withValue(baggage) {
			do {
				return try block()
			} catch {
				span.recordError(error)
				throw error // rethrow
			}
		}
#else
		do {
			return try block()
		} catch {
			span.recordError(error)
			throw error // rethrow
		}
#endif
	}
	
	/// Create a span that measures a specific async block
	/// - Parameters:
	///   - name: the name of the span
	///   - kind: the kind of the span - may be safely left unspecified in most cases
	///   - attributes: optional attributes
	///   - baggage: Optional ``Baggage``, describing parent span. If nil, will be inferred from task/thread local baggage.
	/// - Returns: the result of the wrapped code
#if compiler(>=5.6.0) && canImport(_Concurrency)
	public func withSpan<T>(name: String, kind: SpanKind = .unspecified, attributes: TelemetryAttributes? = nil, baggage: Baggage? = nil, block: () async throws -> T) async rethrows -> T {
		let previousBaggage = currentBaggage
		let resolvedBaggage = baggage ?? previousBaggage
		let finalKind = (kind == .unspecified) ? resolvedBaggage.span.kind : kind // infer from parent span if unspecified
		let span = Span(name: name, kind: finalKind, attributes: attributes, traceId: resolvedBaggage.span.traceId, parentId: resolvedBaggage.span.id, retireCallback: retire)
		
		defer {
			span.end() // automatically retires the span
		}
		
		let baggage = Baggage(span: span)
		return try await Baggage.$currentBaggageTaskLocal.withValue(baggage) {
			do {
				return try await block()
			} catch {
				span.recordError(error)
				throw error // rethrow
			}
		}
	}
#endif
}
