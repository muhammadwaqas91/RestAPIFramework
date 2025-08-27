//
//  DefaultJSONDecoder.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public struct DefaultJSONDecoder: DataParser {
	private let decoder: JSONDecoder
	
	public init(decoder: JSONDecoder = JSONDecoder()) {
		self.decoder = decoder
	}
	
	public func parse<T: Decodable>(data: Data) throws -> T {
		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			throw error
		}
	}
}
