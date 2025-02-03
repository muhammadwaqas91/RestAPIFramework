//
//  RequestConvertibleTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 03/02/2025.
//

import Foundation
import XCTest
@testable import RestAPIFramework

class RequestConvertibleTests: XCTestCase {
	
	struct MockRequest: RequestConvertible {
		let baseURL: String = "https://api.example.com"
		var path: String = "/test"
		var queryItems: [URLQueryItem]? = [URLQueryItem(name: "key", value: "value")]
		var httpMethod: HTTPMethod = .GET
	}

	func testAsURLRequest_ShouldReturnCorrectURL() throws {
		let request = MockRequest()
		let urlRequest = try request.asURLRequest()
		
		XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/test?key=value")
		XCTAssertEqual(urlRequest.httpMethod, "GET")
	}
	
	func testAsURLRequest_InvalidURL_ShouldThrowError() {
		struct InvalidRequest: RequestConvertible {
			let baseURL: String = "INVALID URL"
			var path: String = "/test"
		}
		
		let request = InvalidRequest()
		
		XCTAssertThrowsError(try request.asURLRequest()) { error in
			XCTAssertEqual(error as? RequestError, RequestError.invalidURL)
		}
	}
}
