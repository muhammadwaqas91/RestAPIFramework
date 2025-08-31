//
//  URLRequestConvertible+Extension.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public extension URLRequestConvertible where Self: Requestable {
	private func isValidURL(_ url: URL) -> Bool {
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
		
		if let queryParams = queryParameters {
			components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
		}
		
		request.url = components.url
		request.httpMethod = method.rawValue
		request.allHTTPHeaderFields = headers
		let payload = body
		switch method {
		case .GET, .DELETE:
			request.httpBody = nil
		default:
			request.httpBody = payload
		}
		
		return request
	}
}

