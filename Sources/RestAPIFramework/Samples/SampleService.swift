//
//  SampleService.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 30/01/2025.
//

import Foundation

@available(iOS 13.0.0, *)
public class SampleService {
	private let networkClient: NetworkClientProtocol
	private let parser: DataParserProtocol
	
	public init(
		networkClient: NetworkClientProtocol = NetworkClient(),
		parser: DataParserProtocol = DataParser()
	) {
		self.networkClient = networkClient
		self.parser = parser
	}
	
	public func fetchData<T:Decodable>(
		decocableType: T.Type,
		baseURL: String,
		path: String) async throws -> Decodable {
			let request = SampleRequest(baseURL: baseURL, path: path)
			return try await networkClient.execute(T.self, request: request, parser: parser)
		}
}
