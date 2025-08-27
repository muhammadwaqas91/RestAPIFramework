//
//  DataParser.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public protocol DataParser {
	func parse<T: Decodable>(data: Data) throws -> T
}
