//
//  HTTPURLResponseValidator.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public struct HTTPURLResponseValidator: ResponseValidator {
	
	public init() {
		
	}
	
	public func validate(data: Data, response: URLResponse) throws -> Data {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw ResponseError.invalidResponse
		}
		
		guard (200...299).contains(httpResponse.statusCode) else {
			throw ResponseError.badResponse(statusCode: httpResponse.statusCode)
		}
		
		return data
	}
}
