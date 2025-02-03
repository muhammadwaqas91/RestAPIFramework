//
//  RequestConvertible.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 30/01/2025.
//


import Foundation

public enum RequestError: Error {
	case invalidURL
}

public enum HTTPMethod: String {
	case GET
	case POST
	case PUT
	case DELETE
	case PATCH
}


public protocol RequestConvertible {
	var baseURL: String { get }
	
	var path: String { get }
	
	var queryItems: [URLQueryItem]? { get }
	
	var httpBody: Data? { get }
		
	var allHTTPHeaderFields: [String: String]? { get }
	
	var timeoutInterval: TimeInterval { get }
	
	var httpMethod: HTTPMethod { get }
	
	func asURLRequest() throws -> URLRequest
}

public extension RequestConvertible {
	
	var allHTTPHeaderFields: [String: String]? { nil }
	var queryItems: [URLQueryItem]? { nil }
	var httpBody: Data? { nil }
	var httpMethod: HTTPMethod { .GET }
	var timeoutInterval: TimeInterval { 30.0 }

	func isValidURL(_ url: URL) -> Bool {
		guard let scheme = url.scheme,
			  ["http", "https"].contains(scheme.lowercased()) else {
			return false
		}
		return true
	}
	
	func asURLRequest() throws -> URLRequest {
		guard let url = URL(string: baseURL + path), isValidURL(url), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw RequestError.invalidURL
		}
		
		var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
		request.httpMethod = httpMethod.rawValue

		switch httpMethod {
		case .GET:
			components.queryItems = queryItems
			guard let url = components.url else {
				throw RequestError.invalidURL
			}
			request.url = url
		default:
			request.httpBody = httpBody
		}
		
		request.allHTTPHeaderFields = allHTTPHeaderFields
		return request
	}
}

