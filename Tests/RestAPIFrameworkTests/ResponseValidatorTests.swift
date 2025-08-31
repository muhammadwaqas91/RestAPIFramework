//
//  ResponseValidatorTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import XCTest
import RestAPIFramework

final class ResponseValidatorTests: XCTestCase {
		
	var validator: HTTPURLResponseValidator!
	
	override func setUp() {
		super.setUp()
		validator = HTTPURLResponseValidator()
	}
	
	override func tearDown() {
		validator = nil
		super.tearDown()
	}
	
	func testValidate_Success() throws {
		let url = URL(string: "http://test.com")!
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		let data = "{}".data(using: .utf8)!
		
		XCTAssertNoThrow(try validator.validate(data: data, response: response))
	}
	
	func testValidate_InvalidResponse_ThrowsError() {
		let response = URLResponse()
		let data = "{}".data(using: .utf8)!
		
		XCTAssertThrowsError(try validator.validate(data: data, response: response)) { error in
			guard let responseError = error as? ResponseError else {
				XCTFail("Expected `ResponseError` but got a different error type.")
				return
			}
			XCTAssertEqual(responseError.errorDescription, ResponseError.invalidResponse.errorDescription, "The thrown error's description should be `ResponseError.invalidResponse`.")
		}
	}
	
	func testValidate_BadStatusCode_ThrowsError() {
		let url = URL(string: "http://test.com")!
		let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
		let data = "{}".data(using: .utf8)!
		
		XCTAssertThrowsError(try validator.validate(data: data, response: response)) { error in
			guard let responseError = error as? ResponseError else {
				XCTFail("Expected `ResponseError` but got a different error type.")
				return
			}
			
			if case .badResponse(let statusCode) = responseError {
				XCTAssertEqual(statusCode, 500, "The thrown error's status code should be 500.")
				XCTAssertEqual(responseError.errorDescription, "Bad response from server with status code \(statusCode).", "The thrown error's description should be `ResponseError.badResponse(statusCode: 500)`.")
			} else {
				XCTFail("Expected `ResponseError.badResponse` error but got \(error)")
			}
		}
	}
}
