//
//  Requestable+Extension.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

public extension Requestable {
	var method: HTTPMethod {
		.GET
	}
	var headers: [String: String]? {
		nil
	}
	
	var queryParameters: [String: String]? {
		nil
	}
	
	var body: Data? {
		nil
	}
	
	var timeoutInterval: TimeInterval {
		30
	}
}
