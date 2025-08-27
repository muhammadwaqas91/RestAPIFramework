//
//  DataEncoder.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

protocol DataEncoder {
	func encode<T: Encodable>(_ value: T) throws -> Data
}
