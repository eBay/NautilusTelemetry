//
//  Exporter+Trace.swift
//  
//
//  Created by Ladd Van Tol on 3/1/22.
//

import Foundation

/// Exporter utilities for Trace models
extension Exporter {
	
	/// Exports an array of `Span` objects to OTLP format
	/// - Parameters:
	///   - spans: array of spans
	///   - additionalAttributes: Additional attributes to be added to resource attributes
	/// - Returns: JSON data
	public func exportOTLPToJSON(spans: [Span], additionalAttributes: TelemetryAttributes?) throws -> Data {
		let otlpSpans = spans.map { exportOTLP(span: $0) }

		let instrumentationLibrary = OTLP.V1InstrumentationLibrary(name: "NautilusTelemetry", version: "1.0")
		let resourceAttributes = ResourceAttributes.makeWithDefaults(additionalAttributes: additionalAttributes)
		let attributes = convertToOTLP(attributes: resourceAttributes.keyValues)
		let resource = OTLP.V1Resource(attributes: attributes, droppedAttributesCount: nil)
		let instrumentationLibrarySpan = OTLP.V1InstrumentationLibrarySpans(instrumentationLibrary: instrumentationLibrary, spans: otlpSpans, schemaUrl: schemaUrl)
		
		let resourceSpans = OTLP.V1ResourceSpans(resource: resource, instrumentationLibrarySpans: [instrumentationLibrarySpan], schemaUrl: schemaUrl)
		let traceServiceRequest = OTLP.V1ExportTraceServiceRequest(resourceSpans: [resourceSpans])
		
		let json = try encodeJSON(traceServiceRequest)
		return json
	}

	/// Converts Span to OTLPv1 format Span
	/// - Parameter span: Span
	/// - Returns: Equivalent OTLP Span
	func exportOTLP(span: Span) -> OTLP.V1Span {
		let startTime = convertToOTLP(time: span.startTime)
		let endTime = convertToOTLP(time: span.endTime)

		let attributes = convertToOTLP(attributes: span.attributes)
		let events = convertToOTLP(events: span.events)
		let status = convertToOTLP(status: span.status)
		
		// Map the enumerate
		let kind: OTLP.SpanSpanKind = {
			switch span.kind {
			case .unspecified:
				return ._internal // we didn't figure it out, we'll assume internal
			case .internal:
				return ._internal
			case .client:
				return .client
			}
		}()
		
		return OTLP.V1Span(traceId: span.traceId,
						   spanId: span.id,
						   traceState: nil,
						   parentSpanId: span.parentId,
						   name: span.name,
						   kind: kind,
						   startTimeUnixNano: startTime,
						   endTimeUnixNano: endTime,
						   attributes: attributes,
						   droppedAttributesCount: nil,
						   events: events,
						   droppedEventsCount: nil,
						   links: nil,
						   droppedLinksCount: nil,
						   status: status)
	}
	
	
	/// Converts Span.Status to OTLP.V1Status
	/// - Parameter status: Span status
	/// - Returns: OTLP span status
	func convertToOTLP(status: Span.Status) -> OTLP.V1Status {
		switch status {
		case .unset:
			return OTLP.V1Status(message: nil, code: .unset)
		case .ok:
			return OTLP.V1Status(message: nil, code: .ok)
		case .error(let message):
			return OTLP.V1Status(message: message, code: .error)
		}
	}

	
	/// Converts `Event` to OTLP format
	/// - Parameter events: An array of `Event` objects
	/// - Returns: events converted to OTLP format.
	func convertToOTLP(events: [Span.Event]?) -> [OTLP.SpanEvent]? {
		guard let events = events else {
			return nil
		}
		
		let otlpEvents: [OTLP.SpanEvent] = events.map { event in
			let time = String(timeReference.nanosecondsSinceEpoch(from: event.time))
			let attributes = convertToOTLP(attributes: event.attributes)
			
			return OTLP.SpanEvent(timeUnixNano: time, name: event.name, attributes: attributes, droppedAttributesCount: nil)
		}
		
		return otlpEvents
	}
}
