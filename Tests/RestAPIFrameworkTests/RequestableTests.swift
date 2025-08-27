//
//  RequestableTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import XCTest
@testable import RestAPIFramework

final class RequestableTests: XCTestCase {
	
	struct GetRequest: Requestable {
		typealias ResponseType = String
		
		var baseURL: String { "https://test.api" }
		var path: String { "/get-data" }
		var queryParameters: [String: String]? {
			return ["param1": "value1", "param2": "value2"]
		}
	}
	
	struct PostRequest: Requestable {
		typealias ResponseType = String
		
		var baseURL: String { "https://test.api" }
		var path: String { "/create-resource" }
		var method: HTTPMethod { .POST }
		var body: Data? {
			let json = ["name": "test_item", "value": 123] as [String : Any]
			return try? JSONSerialization.data(withJSONObject: json)
		}
		var headers: [String: String]? {
			return ["Content-Type": "application/json", "Authorization": "Bearer token"]
		}
	}
	
	struct DeleteRequest: Requestable {
		typealias ResponseType = String
		
		var baseURL: String { "https://test.api" }
		var path: String { "/delete-resource/123" }
		var method: HTTPMethod { .DELETE }
	}
	
	struct SimpleRequest: Requestable {
		typealias ResponseType = String
		
		var baseURL: String { "https://simple.api" }
		var path: String { "/hello" }
	}
	
	struct InvalidRequest: Requestable {
		typealias ResponseType = String
		
		var baseURL: String { "invalid-url-string" }
		var path: String { "/path" }
	}
	
	
	
	func testGetRequestCreation() throws {
		let request = GetRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.httpMethod, "GET", "HTTP method should be GET")
		XCTAssertNil(urlRequest.httpBody, "GET request should not have a body")
		
		guard let url = urlRequest.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			XCTFail("Failed to create URLComponents from URL")
			return
		}
		
		XCTAssertEqual(urlComponents.path, "/get-data")
		
		let queryItems = try XCTUnwrap(urlComponents.queryItems)
		XCTAssertEqual(queryItems.count, 2)
		
		let queryParamsDict = queryItems.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
		XCTAssertEqual(queryParamsDict["param1"], "value1")
		XCTAssertEqual(queryParamsDict["param2"], "value2")
	}
	
	func testPostRequestWithHeadersAndBody() throws {
		let request = PostRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.httpMethod, "POST", "HTTP method should be POST")
		XCTAssertNotNil(urlRequest.httpBody, "POST request should have a body")
		XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json", "Content-Type header should be set")
		XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer token", "Authorization header should be set")
		
		let bodyData = try XCTUnwrap(urlRequest.httpBody)
		let jsonObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
		XCTAssertEqual(jsonObject["name"] as? String, "test_item")
	}
	
	func testDeleteRequestCreation() throws {
		let request = DeleteRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.httpMethod, "DELETE", "HTTP method should be DELETE")
		XCTAssertEqual(urlRequest.url?.absoluteString, "https://test.api/delete-resource/123", "URL should be correct")
		XCTAssertNil(urlRequest.httpBody, "DELETE request should not have a body")
	}
	
	func testSimpleRequestCreation() throws {
		let request = SimpleRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.httpMethod, "GET")
		XCTAssertEqual(urlRequest.url?.absoluteString, "https://simple.api/hello")
		XCTAssertNil(urlRequest.httpBody)
	}
	
	func testInvalidURL_ThrowsError() {
		let invalidRequest = InvalidRequest()
		
		XCTAssertThrowsError(try invalidRequest.asURLRequest()) { error in
			guard let requestError = error as? RequestError, requestError == .invalidURL else {
				XCTFail("Expected RequestError.invalidURL but got a different error.")
				return
			}
			XCTAssertEqual(requestError.errorDescription, "The URL provided is invalid.", "Failed to provide a clear error description")
		}
	}
	
	func testCustomTimeoutInterval() throws {
		struct CustomTimeoutRequest: Requestable {
			typealias ResponseType = String
			var baseURL: String { "https://test.api" }
			var path: String { "/timeout" }
			var timeoutInterval: TimeInterval { 60 }
		}
		
		let request = CustomTimeoutRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.timeoutInterval, 60, "Custom timeout interval should be applied")
	}
}
