//
//  DataParserTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 03/02/2025.
//

import Foundation
import XCTest
@testable import RestAPIFramework

class DataParserTests: XCTestCase {
	
	var parser: DataParser!
	
	override func setUp() {
		super.setUp()
		parser = DataParser()
	}
	
	override func tearDown() {
		parser = nil
		super.tearDown()
	}
	
	struct MockResponse: Codable, Equatable {
		let id: Int
		let name: String
	}

	func testParse_ValidJSON_ShouldDecodeSuccessfully() throws {
		let jsonData = """
		{
			"id": 1,
			"name": "John Doe"
		}
		""".data(using: .utf8)!
		
		do {
			let result: MockResponse = try parser.parse(MockResponse.self, data: jsonData)
			XCTAssertEqual(result, MockResponse(id: 1, name: "John Doe"))
		} catch {
			XCTFail("Expected successful parsing, got error: \(error)")
		}
	}
	
	func testParse_InvalidJSON_ShouldThrowDecodingError() throws {
		let invalidData = "Invalid JSON".data(using: .utf8)!
		
		XCTAssertThrowsError(try parser.parse(MockResponse.self, data: invalidData)) { error in
			guard case DataParsingError.decodingFailed = error else {
				return XCTFail("Expected decodingFailed error, got \(error)")
			}
		}
	}
}
