//
//  MetricKitInstrument.swift
//  
//
//  Created by Ladd Van Tol on 10/12/21.
//

import Foundation
import MetricKit

#if os(iOS)
public final class MetricKitInstrument: NSObject, MXMetricManagerSubscriber {
	
	// https://developer.apple.com/documentation/metrickit/mxmetricmanager

	func start() {
		let metricManager = MXMetricManager.shared
		metricManager.add(self)
		
		let customMetricLogger = MXMetricManager.makeLogHandle(category: "testOTLPExporterMetrics")
		
		os_signpost(.begin, log: customMetricLogger, name: "test")
		Thread.sleep(forTimeInterval: 0.1)
		os_signpost(.end, log: customMetricLogger, name: "test")

		if #available(iOS 14.0, *) {
			let pastPayloads = metricManager.pastPayloads
			
			if pastPayloads.count > 0 {
				print("MetricKitInstrument: \(pastPayloads)")
			}
		
			let diagnosticPayloads = metricManager.pastDiagnosticPayloads
			if diagnosticPayloads.count > 0 {
				print("MetricKitInstrument: \(diagnosticPayloads)")
			}
		}
	}
	
	public func didReceive(_ payloads: [MXMetricPayload]) {
		print("MetricKitInstrument: \(payloads)")
		
		for payload in payloads {
			let json = payload.jsonRepresentation() // try JSON representation
			if let jsonString = String(data: json, encoding: .utf8) {
				print("\(jsonString)")
			}
			
			dump(payload: payload)
		}
	}
	
	@available(iOS 14.0, *)
	public func didReceive(_ payloads: [MXDiagnosticPayload]) {
		print("MetricKitInstrument: \(payloads)")
		
		for payload in payloads {
			let json = payload.jsonRepresentation() // could pull this apart, but JSON representation may be most useful
			if let jsonString = String(data: json, encoding: .utf8) {
				print("\(jsonString)")
			}
		}
	}
	
	func dump<UnitType>(histogram: MXHistogram<UnitType>) where UnitType : Unit {
		for bucket in histogram.bucketEnumerator {
			if let bucket = bucket as? MXHistogramBucket<UnitType> {
				print("\(bucket.bucketStart)-\(bucket.bucketEnd): \(bucket.bucketCount)")
			}
		}
	}
	
	func dump(payload: MXMetricPayload) {
		print("latestApplicationVersion: \(payload.latestApplicationVersion)")
		print("timeStampBegin: \(payload.timeStampBegin)")
		print("timeStampEnd: \(payload.timeStampEnd)")

		if let cpuMetrics = payload.cpuMetrics {
			print("cpuMetrics: \(cpuMetrics)")
		}

		if let gpuMetrics = payload.gpuMetrics {
			print("gpuMetrics: \(gpuMetrics)")
		}

		if let cellularConditionMetrics = payload.cellularConditionMetrics {
			print("cellularConditionMetrics: \(cellularConditionMetrics)")
			dump(histogram: cellularConditionMetrics.histogrammedCellularConditionTime)
		}

		if let applicationTimeMetrics = payload.applicationTimeMetrics {
			print("applicationTimeMetrics: \(applicationTimeMetrics)")
		}

		if let locationActivityMetrics = payload.locationActivityMetrics {
			print("locationActivityMetrics: \(locationActivityMetrics)")
		}

		if let networkTransferMetrics = payload.networkTransferMetrics {
			print("networkTransferMetrics: \(networkTransferMetrics)")
		}

		if let applicationLaunchMetrics = payload.applicationLaunchMetrics {
			print("applicationLaunchMetrics: \(applicationLaunchMetrics)")
			dump(histogram: applicationLaunchMetrics.histogrammedTimeToFirstDraw)
			dump(histogram: applicationLaunchMetrics.histogrammedApplicationResumeTime)

		}

		if let applicationResponsivenessMetrics = payload.applicationResponsivenessMetrics {
			print("applicationResponsivenessMetrics: \(applicationResponsivenessMetrics)")
			dump(histogram: applicationResponsivenessMetrics.histogrammedApplicationHangTime)
		}

		if let diskIOMetrics = payload.diskIOMetrics {
			print("diskIOMetrics: \(diskIOMetrics)")
		}

		if let memoryMetrics = payload.memoryMetrics {
			print("memoryMetrics: \(memoryMetrics)")
		}

		if let displayMetrics = payload.displayMetrics {
			print("displayMetrics: \(displayMetrics)")
		}

		if #available(iOS 14.0, *) {
			if let animationMetrics = payload.animationMetrics {
				print("animationMetrics: \(animationMetrics)")
			}

			if let applicationExitMetrics = payload.applicationExitMetrics {
				print("applicationExitMetrics: \(applicationExitMetrics)")
			}
		}
		
		if let signpostMetrics = payload.signpostMetrics {
			print("signpostMetrics: \(signpostMetrics)")
		}

		if let metaData = payload.metaData {
			print("metaData: \(metaData)")
		}
	}
}
#endif

