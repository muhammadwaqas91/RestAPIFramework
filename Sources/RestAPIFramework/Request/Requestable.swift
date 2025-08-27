//
//  Requestable.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public enum HTTPMethod: String {
	case GET
	case POST
	case PUT
	case DELETE
	case PATCH
}

public protocol Requestable: URLRequestConvertible {
	associatedtype ResponseType: Decodable
	
	var baseURL: String { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var headers: [String: String]? { get }
	var queryParameters: [String: String]? { get }
	var body: Data? { get }
	var timeoutInterval: TimeInterval { get }
}


