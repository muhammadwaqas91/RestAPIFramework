//
//  DataParserTests.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import XCTest
import RestAPIFramework

final class DataParserTests: XCTestCase {
	
	
	var parser: DefaultJSONDecoder!
	
	override func setUp() {
		super.setUp()
		parser = DefaultJSONDecoder()
	}
	
	override func tearDown() {
		parser = nil
		super.tearDown()
	}
	
	struct MockData: Decodable {
		let id: Int
		let title: String
	}
	
	func testParse_Success() throws {
		let jsonString = """
		{
			"id": 1,
			"title": "Test Title"
		}
		"""
		let data = jsonString.data(using: .utf8)!
		
		let decodedData = try parser.parse(data: data) as MockData
		XCTAssertEqual(decodedData.id, 1)
		XCTAssertEqual(decodedData.title, "Test Title")
	}
	
	func testParse_DataCorrupted_ThrowsError() {
		
		let corruptedJson = "This is not a valid JSON"
		let corruptedData = corruptedJson.data(using: .utf8)!
		XCTAssertThrowsError(try parser.parse(data: corruptedData) as MockData) { error in
			if case DecodingError.dataCorrupted(let context) = error {
				XCTAssert(context.debugDescription.contains("The given data was not valid JSON."))
			} else {
				XCTFail("Expected `DecodingError.dataCorrupted` but got \(error)")
			}
		}
	}
	
	func testParse_MissingRequiredKey_ThrowsError() {
		let invalidJsonString = """
		{
			"title": "Test Title"
		}
		"""
		let invalidData = invalidJsonString.data(using: .utf8)!
		
		XCTAssertThrowsError(try parser.parse(data: invalidData) as MockData) { error in
			if case DecodingError.keyNotFound(let key, _) = error {
				XCTAssertEqual(key.stringValue, "id")
			} else {
				XCTFail("Expected `DecodingError.keyNotFound` but got \(error)")
			}
		}
	}
	
	func testParse_TypeMismatch_ThrowsError() {
		let typeMismatchJson = """
		{
			"id": "not an integer",
			"title": "Test Title"
		}
		"""
		let typeMismatchData = typeMismatchJson.data(using: .utf8)!
		
		XCTAssertThrowsError(try parser.parse(data: typeMismatchData) as MockData) { error in
			if case DecodingError.typeMismatch(let type, _) = error {
				XCTAssertTrue("\(type)".contains("Int"))
			} else {
				XCTFail("Expected `DecodingError.typeMismatch` but got \(error)")
			}
		}
	}
	
	func testParse_ValueNotFound_ThrowsError() {
		let valueNotFoundJson = """
		{
			"id": null,
			"title": "Test Title"
		}
		"""
		let valueNotFoundData = valueNotFoundJson.data(using: .utf8)!
		
		XCTAssertThrowsError(try parser.parse(data: valueNotFoundData) as MockData) { error in
			if case DecodingError.valueNotFound(let type, _) = error {
				XCTAssertTrue("\(type)".contains("Int"))
			} else {
				XCTFail("Expected `DecodingError.valueNotFound` but got \(error)")
			}
		}
	}
}
