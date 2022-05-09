//
//  Compression.swift
//  
//
//  Created by Van Tol, Ladd on 10/11/21.
//

import Foundation
import Compression

/// Implements simple one-shot compressors for telemetry payloads
/// Maybe worth using a more complete implementation such as: https://github.com/mw99/DataCompression
/// Unfortunately, Apple doesn't let you control compression level
public struct Compression {
	
	enum CompressionError: Error {
		case failure
	}

	public static func compressDeflate(data: Data) throws -> Data {
		let compressed = try compress(source: data, algorithm: COMPRESSION_ZLIB)

		// Now stick on the header and adler to make it deflate format
		var output = Data([0x78, 0x5e])
		output.append(compressed)
		var adler = adler32(data).bigEndian
		output.append(Data(bytes: &adler, count: MemoryLayout<UInt32>.size))
		
		return output
	}

	@available(iOS 15.0, *)
	public static func compressBrotli(data: Data) throws -> Data {
		return try compress(source: data, algorithm: COMPRESSION_BROTLI)
	}
	
	// Not very fast == may be better to use zlib's implementation
	private static func adler32(_ data: Data) -> UInt32 {
		var s1: UInt32 = 1
		var s2: UInt32 = 0
		let prime: UInt32 = 65521
		
		for byte in data {
			s1 += UInt32(byte)
			if s1 >= prime { s1 = s1 % prime }
			s2 += s1
			if s2 >= prime { s2 = s2 % prime }
		}
		return (s2 << 16) | s1
	}

	private static func compress(source: Data, algorithm: compression_algorithm) throws -> Data {
	
		// https://developer.apple.com/documentation/accelerate/compressing_and_decompressing_data_with_buffer_compression
		
		let dstSize = source.count * 2 // it's possible for the compressed contents to be longer
		let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
		defer {
			destinationBuffer.deallocate()
		}

		var output = Data()
		
		try source.withUnsafeBytes { sourceBuffer in
			
			let sourceBufferPointer = sourceBuffer.bindMemory(to: UInt8.self)
			guard let baseAddress = sourceBufferPointer.baseAddress else {
				throw CompressionError.failure
			}
			
			let compressedSize = compression_encode_buffer(destinationBuffer, dstSize,
														   baseAddress, source.count,
														   nil,
														   algorithm)
			if compressedSize > 0 {
				output.append(destinationBuffer, count: compressedSize)
			}
		}
		
		if output.count > 0 {
			return output
		} else {
			throw CompressionError.failure
		}

	}
}
