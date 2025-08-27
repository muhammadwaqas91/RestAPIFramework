//
//  ResponseValidator.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public protocol ResponseValidator {
	func validate(data: Data, response: URLResponse) throws -> Data
}

