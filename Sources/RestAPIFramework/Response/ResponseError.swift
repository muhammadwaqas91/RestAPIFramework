//
//  ResponseError.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public enum ResponseError: Error, LocalizedError {
	case invalidResponse
	case badResponse(statusCode: Int)
	
	public var errorDescription: String? {
		switch self {
		case .invalidResponse:
			return "No data was received from the server."
		case .badResponse(let statusCode):
			return "Bad response from server with status code \(statusCode)."
		}
	}
}
