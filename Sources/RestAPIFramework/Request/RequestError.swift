//
//  RequestError.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public enum RequestError: Error, LocalizedError {
	case invalidURL
	
	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "The URL provided is invalid."
		}
	}
}
