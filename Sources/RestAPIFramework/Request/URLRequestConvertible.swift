//
//  URLRequestConvertible.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public protocol URLRequestConvertible {
	func asURLRequest() throws -> URLRequest
}






