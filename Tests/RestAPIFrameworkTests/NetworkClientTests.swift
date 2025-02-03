//
//  NetworkClientTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 03/02/2025.
//

import Foundation
import XCTest
@testable import RestAPIFramework
class NetworkClientTests: XCTestCase {
	
	var networkClient: NetworkClient!
	var urlSession: URLSession!
	var mockParser: DataParser!
	
	override func setUp() {
		super.setUp()
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		urlSession = URLSession(configuration: config)
		
		networkClient = NetworkClient(urlSession: urlSession)
		mockParser = DataParser()
	}
	
	override func tearDown() {
		networkClient = nil
		urlSession = nil
		mockParser = nil
		super.tearDown()
	}
	
	struct MockResponse: Codable, Equatable {
		let id: Int
		let name: String
	}

	func testExecute_ValidResponse_ShouldReturnDecodedObject() async throws {
		let jsonData = """
		{
			"id": 1,
			"name": "Test"
		}
		""".data(using: .utf8)!
		
		MockURLProtocol.mockData = jsonData
		MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
													   statusCode: 200,
													   httpVersion: nil,
													   headerFields: nil)
		
		let request = SampleRequest(baseURL: "https://example.com", path: "/test")
		
		let result: MockResponse = try await networkClient.execute(MockResponse.self, request: request, parser: mockParser)
		
		XCTAssertEqual(result, MockResponse(id: 1, name: "Test"))
	}

	func testExecute_EmptyResponse_ShouldThrowEmptyResponseError() async {
		MockURLProtocol.mockData = Data()
		MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
													   statusCode: 200,
													   httpVersion: nil,
													   headerFields: nil)
		
		let request = SampleRequest(baseURL: "https://example.com", path: "/test")
		
		do {
			let _: MockResponse = try await networkClient.execute(MockResponse.self, request: request, parser: mockParser)
			XCTFail("Expected NetworkError.emptyResponse but got success")
		} catch NetworkError.emptyResponse {
			XCTAssertTrue(true)
		} catch {
			XCTFail("Expected NetworkError.emptyResponse but got \(error)")
		}
	}
}



final class MockURLProtocol: URLProtocol {
	nonisolated(unsafe) static var mockData: Data?
	nonisolated(unsafe) static var mockResponse: URLResponse?
	nonisolated(unsafe) static var mockError: Error?

	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	override func startLoading() {
		if let error = MockURLProtocol.mockError {
			client?.urlProtocol(self, didFailWithError: error)
		} else {
			if let response = MockURLProtocol.mockResponse {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			if let data = MockURLProtocol.mockData {
				client?.urlProtocol(self, didLoad: data)
			}
		}
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {}
}
