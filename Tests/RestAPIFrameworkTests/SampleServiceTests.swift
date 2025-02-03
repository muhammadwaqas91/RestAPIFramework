//
//  SampleServiceTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 03/02/2025.
//

import Foundation
import XCTest
@testable import RestAPIFramework
class SampleServiceTests: XCTestCase {
	
	var sampleService: SampleService!
	var mockNetworkClient: MockNetworkClient!
	var mockParser: DataParser!
	
	override func setUp() {
		super.setUp()
		mockNetworkClient = MockNetworkClient()
		mockParser = DataParser()
		sampleService = SampleService(networkClient: mockNetworkClient, parser: mockParser)
	}
	
	override func tearDown() {
		sampleService = nil
		mockNetworkClient = nil
		mockParser = nil
		super.tearDown()
	}
	
	struct MockResponse: Codable, Equatable {
		let id: Int
		let name: String
	}

	func testFetchData_ValidResponse_ShouldReturnDecodedObject() async throws {
		let jsonData = """
		{
			"id": 1,
			"name": "Service Test"
		}
		""".data(using: .utf8)!
		
		mockNetworkClient.mockData = jsonData
		
		let result: MockResponse = try await sampleService.fetchData(
			decocableType: MockResponse.self,
			baseURL: "https://example.com",
			path: "/mock"
		) as! MockResponse
		
		XCTAssertEqual(result, MockResponse(id: 1, name: "Service Test"))
	}
}

class MockNetworkClient: NetworkClientProtocol {
	var mockData: Data?

	func execute<T: Decodable>(_ decodableType: T.Type,
							   request: RequestConvertible,
							   parser: DataParserProtocol) async throws -> T {
		guard let data = mockData else {
			throw NetworkError.emptyResponse
		}
		return try parser.parse(T.self, data: data)
	}
}
