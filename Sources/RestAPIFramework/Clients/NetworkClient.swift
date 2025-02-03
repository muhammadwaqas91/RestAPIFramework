//
//  NetworkClient.swift
//  theMovieDB
//
//  Created by Muhammad Waqas on 30/01/2025.
//

import Foundation

public enum NetworkError: Error {
	case emptyResponse
}

@available(iOS 13.0.0, *)
public protocol NetworkClientProtocol {
	func execute<T: Decodable>(_ decodableType: T.Type,
							   request: RequestConvertible,
							   parser: DataParserProtocol) async throws -> T
}

@available(iOS 13.0.0, *)
public final class NetworkClient: NetworkClientProtocol {
	private let urlSession: URLSession
	
	public init(urlSession: URLSession = .shared) {
		self.urlSession = urlSession
	}
	
	public func execute<T: Decodable>(_ decodableType: T.Type,
									  request: RequestConvertible,
									  parser: DataParserProtocol) async throws -> T {
		let urlRequest = try request.asURLRequest()
		let (data, _) = try await urlSession.data(for: urlRequest)
		guard !data.isEmpty else {
			throw NetworkError.emptyResponse
		}
		let decoded: T = try parser.parse(T.self, data: data)
		return decoded
	}
}
