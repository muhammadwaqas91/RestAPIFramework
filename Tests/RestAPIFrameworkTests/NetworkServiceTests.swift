//
//  NetworkServiceTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import XCTest
@testable import RestAPIFramework

/// Took help from below sources
///
/// https://forums.swift.org/t/mock-urlprotocol-with-strict-swift-6-concurrency/77135/4
/// https://growwithanyone.medium.com/stubbing-mocking-network-responses-for-unit-tests-in-ios-with-urlsession-b648218da916
///
///
/// An actor to manage and store mock responses in a concurrency-safe way.
actor MockResponsesManager {
	private var responses: [Result<(HTTPURLResponse, Data), Error>] = []
	
	func setResponse(_ result: Result<(HTTPURLResponse, Data), Error>) async {
		responses = [result]
	}
	
	func setResponses(_ results: [Result<(HTTPURLResponse, Data), Error>]) async {
		responses = results
	}
	
	func nextResponse() -> Result<(HTTPURLResponse, Data), Error>? {
		guard !responses.isEmpty else { return nil }
		return responses.removeFirst()
	}
	
	func clear() {
		responses.removeAll()
	}
}

/// A mock URLProtocol to intercept and handle network requests during testing.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
	private static let manager = MockResponsesManager()
	
	/// Sets a single mock response for the next request.
	static func setResponse(_ result: Result<(HTTPURLResponse, Data), Error>) async {
		await manager.setResponse(result)
	}
	
	/// Sets a queue of mock responses for a series of requests.
	static func setResponses(_ results: [Result<(HTTPURLResponse, Data), Error>]) async {
		await manager.setResponses(results)
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
		false
	}
	
	override func startLoading() {
		Task {
			do {
				if let nextResponse = await MockURLProtocol.manager.nextResponse() {
					switch nextResponse {
					case .success(let (response, data)):
						client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
						client?.urlProtocol(self, didLoad: data)
						client?.urlProtocolDidFinishLoading(self)
					case .failure(let error):
						client?.urlProtocol(self, didFailWithError: error)
					}
				} else {
					client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
				}
			}
		}
	}
	
	override func stopLoading() {}
}

// MARK: - Mocks for Unit Testing

/// A simple struct representing a mock response for testing purposes.
struct MockResponse: Decodable, Equatable {
	let title: String
	let author: String
}

/// A mock request that conforms to Requestable for testing.
struct MockRequest: Requestable {
	typealias ResponseType = MockResponse
	
	var baseURL: String = "https://mock.api.com"
	var path: String = "/article"
	var method: HTTPMethod { .GET }
	var headers: [String: String]? { nil }
	var queryItems: [URLQueryItem]? { nil }
	var body: Data? { nil }
}

// MARK: - Test Suite


/// The unit test class for the NetworkService.
final class NetworkServiceTests: XCTestCase {
	var networkService: NetworkService!
	
	/// Set up the test environment before each test case runs.
	override func setUp() {
		super.setUp()
		
		// Configure the URLSession to use our MockURLProtocol.
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let mockSession = URLSession(configuration: config)
		
		// Inject the mocked session into the network service.
		self.networkService = NetworkService(urlSession: mockSession)
	}
	
	// MARK: - Test Cases
	
	/// Test for a successful network request with a valid 200 response.
	func testExecute_Success_ReturnsDecodedObject() async throws {
		// 1. Arrange: Define the mock data and set the handler.
		let expectedData = "{\"title\": \"Mock Title\", \"author\": \"Mock Author\"}".data(using: .utf8)!
		let mockURL = try XCTUnwrap(URL(string: "https://mock.api.com/article"))
		let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
		
		await MockURLProtocol.setResponse(.success((mockResponse, expectedData)))
		
		let mockRequest = MockRequest()
		
		// 2. Act: Execute the async function.
		let result = try await networkService.execute(request: mockRequest)
		
		// 3. Assert: Verify the returned object matches the expected data.
		XCTAssertEqual(result.title, "Mock Title", "The title should be decoded correctly.")
		XCTAssertEqual(result.author, "Mock Author", "The author should be decoded correctly.")
	}
	
	/// Test for a bad HTTP response (e.g., 404 Not Found).
	func testExecute_BadResponse_ThrowsError() async {
		// 1. Arrange: Set up a handler that returns a bad status code.
		let mockURL = try! XCTUnwrap(URL(string: "https://mock.api.com/article"))
		let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
		
		await MockURLProtocol.setResponse(.success((mockResponse, Data())))
		
		let mockRequest = MockRequest()
		
		// 2. Act & Assert: Use a do-catch block to handle the expected error.
		do {
			_ = try await networkService.execute(request: mockRequest)
			XCTFail("The request should have thrown an error.")
		} catch let error as ResponseError {
			if case .badResponse(let statusCode) = error {
				XCTAssertEqual(statusCode, 404, "The status code should be 404.")
			} else {
				XCTFail("The thrown error was not a ResponseError.badResponse.")
			}
		} catch {
			XCTFail("The thrown error was of an unexpected type: \(error).")
		}
	}
	
	/// Test for a network connectivity error.
	func testExecute_NetworkError_ThrowsError() async {
		// 1. Arrange: Set up a handler that throws a network error.
		await MockURLProtocol.setResponse(.failure(URLError(.notConnectedToInternet)))
		
		let mockRequest = MockRequest()
		
		// 2. Act & Assert: Use a do-catch block to handle the expected error.
		do {
			_ = try await networkService.execute(request: mockRequest)
			XCTFail("The request should have thrown an error.")
		} catch let error as URLError {
			XCTAssertEqual(error.code, URLError(.notConnectedToInternet).code, "The thrown error should be a URLError.")
		} catch {
			XCTFail("The thrown error was of an unexpected type: \(error).")
		}
	}
	
	/// Test for invalid JSON data that causes a decoding failure.
	func testExecute_InvalidJSON_ThrowsDecodingError() async {
		// 1. Arrange: Provide data that is not valid JSON.
		let mockResponseData = "This is not valid JSON".data(using: .utf8)!
		let mockURL = try! XCTUnwrap(URL(string: "https://mock.api.com/article"))
		let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
		
		await MockURLProtocol.setResponse(.success((mockResponse, mockResponseData)))
		
		let mockRequest = MockRequest()
		
		// 2. Act & Assert: Use a do-catch block to handle the expected error.
		do {
			_ = try await networkService.execute(request: mockRequest)
			XCTFail("The request should have thrown an error.")
		} catch {
			XCTAssertTrue(error is DecodingError, "The error should be of type DecodingError.")
		}
	}
	
	/// Test for a sequence of multiple network requests.
	func testExecute_MultipleRequests_WithQueuedResponses() async throws {
		// 1. Arrange: Define a queue of different mock responses.
		let mockURL = try XCTUnwrap(URL(string: "https://mock.api.com/article"))
		let successResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
		let badResponse = HTTPURLResponse(url: mockURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
		let mockData = "{\"title\": \"Mock Title\", \"author\": \"Mock Author\"}".data(using: .utf8)!
		
		let responses: [Result<(HTTPURLResponse, Data), Error>] = [
			.success((successResponse, mockData)),
			.success((badResponse, Data())),
			.failure(URLError(.notConnectedToInternet))
		]
		
		await MockURLProtocol.setResponses(responses)
		
		let mockRequest = MockRequest()
		
		// 2. Act & Assert: First request should succeed.
		let result1 = try await networkService.execute(request: mockRequest)
		XCTAssertEqual(result1.title, "Mock Title")
		
		// 3. Act & Assert: Second request should fail with a bad response.
		do {
			_ = try await networkService.execute(request: mockRequest)
			XCTFail("The request should have thrown an error.")
		} catch let error as ResponseError {
			if case .badResponse(let statusCode) = error {
				XCTAssertEqual(statusCode, 404, "The status code should be 404.")
			} else {
				XCTFail("The thrown error was not the expected ResponseError.badResponse.")
			}
		} catch {
			XCTFail("The second request failed with an unexpected error type: \(error).")
		}
		
		// 4. Act & Assert: Third request should fail with a network error.
		do {
			_ = try await networkService.execute(request: mockRequest)
			XCTFail("The request should have thrown an error.")
		}  catch let error as URLError {
			XCTAssertEqual(error.code, URLError(.notConnectedToInternet).code, "The thrown error should be a URLError.")
		} catch {
			XCTFail("The third request failed with an unexpected error type: \(error).")
		}
	}
}
