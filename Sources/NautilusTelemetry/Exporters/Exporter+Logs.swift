//
//  Exporter+Logs.swift
//  
//
//  Created by Ladd Van Tol on 3/1/22.
//

import Foundation
import OSLog

/// Exporter utilities for Logs models
extension Exporter {
	@available(iOS 15.0, *)
	/// Converts OSLog levels to OTLP severity
	/// - Parameter level: OSLogEntryLog.Level
	/// - Returns: level converted to OTLP format
	func severityFrom(level: OSLogEntryLog.Level) -> OTLP.V1SeverityNumber? {
		switch level {
		case .debug:
			return .debug
		case .info:
			return .info
		case .notice:
			return .warn
		case .error:
			return .error
		case .fault:
			return .fatal
		case .undefined:
			return nil // per docs, don't use unspecified
		@unknown default:
			return nil // per docs, don't use unspecified
		}
	}
}
