//
//  NetworkService.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//


import Foundation

public class NetworkService: NetworkServiceProtocol {
	public var responseValidator: ResponseValidator
	public var dataParser: DataParser
	public var urlSession: URLSession
	init(responseValidator: ResponseValidator = HTTPURLResponseValidator(), dataParser: DataParser = DefaultJSONDecoder(), urlSession: URLSession = .shared) {
		self.responseValidator = responseValidator
		self.dataParser = dataParser
		self.urlSession = urlSession
	}
	
	public func execute<T: Requestable>(request: T) async throws -> T.ResponseType {
		do {
			let urlRequest = try request.asURLRequest()
			let (data, response) = try await urlSession.data(for: urlRequest)
			let validatedData = try responseValidator.validate(data: data, response: response)
			let parsedObject: T.ResponseType = try dataParser.parse(data: validatedData)
			return parsedObject
		} catch let error as URLError {
			throw error
		} catch let requestError as RequestError {
			throw requestError
		} catch let responseError as ResponseError {
			throw responseError
		} catch let decodingError as DecodingError {
			throw decodingError
		} catch {
			throw error
		}
	}
}
