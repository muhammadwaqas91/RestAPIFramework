//
//  DataParser.swift
//  theMovieDB
//
//  Created by Muhammad Waqas on 30/01/2025.
//

import Foundation

public protocol DataParserProtocol {
	func parse<T: Decodable>(_ decodableType: T.Type, data: Data) throws -> T
}

public enum DataParsingError: Error {
	case decodingFailed(String)
}

public struct DataParser: DataParserProtocol {
	private let decoder: JSONDecoder
	
	public init(decoder: JSONDecoder = JSONDecoder()) {
		self.decoder = decoder
	}
	
	public func parse<T: Decodable>(_ decodableType: T.Type, data: Data) throws -> T {
		do {
			return try decoder.decode(T.self, from: data)
		}
		catch let decodingError as DecodingError {
			let errorDescription = handleDecodingError(decodingError, data: data)
			debugPrint(errorDescription)
			throw DataParsingError.decodingFailed(errorDescription)
		}
		catch {
			throw DataParsingError.decodingFailed(error.localizedDescription)
		}
	}
	
	private func handleDecodingError(_ error: DecodingError, data: Data) -> String {
		defer {
			// Print Raw JSON Response for Debugging
			if let jsonString = String(data: data, encoding: .utf8) {
				debugPrint("📝 Raw API Response: \(jsonString)")
			} else {
				debugPrint("📝 Could not decode raw response.")
			}
		}
		
		switch error {
		case .dataCorrupted(let context):
			return "❌ Data Corrupted: \(context.debugDescription)"
			
		case .keyNotFound(let key, let context):
			return "❌ Key Not Found: \(key.stringValue) - debugDescription: \(context.debugDescription) - codingPath: \(context.codingPath)"
			
		case .typeMismatch(let type, let context):
			return "❌ Type Mismatch: \(type) - debugDescription: \(context.debugDescription) - codingPath: \(context.codingPath)"
			
		case .valueNotFound(let type, let context):
			return "❌ Value Not Found: \(type) - debugDescription: \(context.debugDescription) - codingPath: \(context.codingPath)"
		@unknown default:
			return "❌ Unknown Decoding Error"
		}
	}
}
