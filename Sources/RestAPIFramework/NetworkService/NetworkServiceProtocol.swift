//
//  NetworkServiceProtocol.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//


import Foundation

public protocol NetworkServiceProtocol {
	var responseValidator: ResponseValidator { get }
	var dataParser: DataParser { get }
	var urlSession: URLSession { get }
	
	func execute<T: Requestable>(request: T) async throws -> T.ResponseType
}
