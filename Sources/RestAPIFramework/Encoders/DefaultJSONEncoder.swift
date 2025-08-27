//
//  DefaultJSONEncoder.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

struct DefaultJSONEncoder: DataEncoder {
	private let encoder: JSONEncoder
	
	init(outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted) {
		self.encoder = JSONEncoder()
		self.encoder.outputFormatting = outputFormatting
	}
	
	func encode<T: Encodable>(_ value: T) throws -> Data {
		return try encoder.encode(value)
	}
}
