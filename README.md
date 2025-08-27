# RestAPIFramework

[![Swift](https://img.shields.io/badge/Swift-5.5-orange?style=flat-square)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015.0%2B%2C%20macOS%2012.0%2B%2C%20watchOS%208.0%2B%2C%20tvOS%2015.0%2B-orange?style=flat-square)](https://swift.org/platforms)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://swift.org/package-manager)

**RestAPIFramework** is a lightweight, protocol-oriented networking framework for Swift applications. It simplifies API requests, response handling, and error management using Swift's modern concurrency features, providing a modular and robust architecture.

## Features

* [x] **Modern Async/Await API** for cleaner, asynchronous networking code.
* [x] **Protocol-Oriented Design** for highly modular and testable components.
* [x] **Decodable JSON Parsing** for seamless and automatic API response handling.
* [x] **Structured Error Handling** with custom error types for clear diagnostics.
* [x] **Customizable HTTP Headers and Authentication**.
* [x] **Comprehensive Unit and Integration Test Coverage**.
* [x] **Swift Package Manager Support**.

## Requirements

* **iOS 15.0+**
* **macOS 12.0+**
* **watchOS 8.0+**
* **tvOS 15.0+**
* **Swift 5.7+**

## Installation

### Swift Package Manager (Recommended)

You can add **RestAPIFramework** to your Swift project using Swift Package Manager.

1. In Xcode, navigate to **File > Add Packages...**
2. In the search bar, enter the URL of your repository: `https://github.com/muhammadwaqas91/RestAPIFramework.git`.
3. Choose the package and add it to your project.

Alternatively, you can add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/muhammadwaqas91/RestAPIFramework.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

### 1. Define Your Data Models

Your data models should conform to `Decodable` to enable automatic JSON parsing.

```swift
// Example: Article.swift
import Foundation

struct Article: Identifiable, Decodable {
    let id: Int
    let title: String
    let byline: String?
    let publishedDate: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id, title, byline, url
        case publishedDate = "published_date"
    }
}
```

### 2. Define Your Requests

Create an enum that conforms to the `Requestable` protocol to define your endpoints, paths, methods, and any required parameters.

```swift
// Example: MostViewedArticlesRequest.swift
import Foundation

enum MostViewedArticlesRequest: Requestable {
    typealias ResponseType = ArticlesResponse
    case viewed(period: Period)

    var baseURL: String { "https://api.nytimes.com/svc/mostpopular/v2" }
    var path: String {
        switch self {
        case .viewed(let period):
            return "/viewed/\(period.rawValue).json"
        }
    }
    // ... other properties like query parameters, HTTP headers, etc.
}
```

### 3. Define your NetworkServiceProtocol, ResponseValidator and DataParser implementations (It's totally Optional)

If you want to define your impelementations thats also supported, otherwise just use default implementations (`NetworkService`, `HTTPURLResponseValidator`, `DefaultJSONDecoder`)

The `ResponseValidator` and `DataParser` protocols are designed to give you more control over the network request and data handling processes. By separating response validation and data parsing into their own protocols, you create a more flexible, modular, and testable architecture.

#### `ResponseValidator` Protocol

The `ResponseValidator` ensures that the network response is valid before any parsing occurs. This could include checking HTTP status codes, verifying headers, or any other response-specific checks.

```swift
public protocol ResponseValidator {
    func validate(data: Data, response: URLResponse) throws -> Data
}

public struct StatusCodeValidator: ResponseValidator {
    public func validate(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidResponse
        }
        if !(200...299).contains(httpResponse.statusCode) {
            throw ResponseError.invalidStatusCode(httpResponse.statusCode)
        }
        return data
    }
}
```

#### `DataParser` Protocol

The `DataParser` protocol is responsible for parsing raw network data into a structured model. It uses the `Decodable` protocol to transform JSON (or other formats) into your model objects.

```swift
public protocol DataParser {
    func parse<T: Decodable>(data: Data) throws -> T
}

public struct JSONDataParser: DataParser {
    public func parse<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
```

#### `NetworkServiceProtocol` Protocol

The `NetworkServiceProtocol` ties everything together. It uses the `ResponseValidator` to validate the response, the `DataParser` to parse the data, and performs the network request using `URLSession`.

```swift
public protocol NetworkServiceProtocol {
    var responseValidator: ResponseValidator { get }
    var dataParser: DataParser { get }
    var urlSession: URLSession { get }
    
    func execute<T: Requestable>(request: T) async throws -> T.ResponseType
}
```


### 4. Example Usage of NetworkService:

Use the `NetworkService` or any of your implementations conforming to `NetworkServiceProtocol` to execute your defined request in an async context.

```swift
// Example: ArticlesVM.swift
import Foundation
import RestAPIFramework

class ArticlesVM: ObservableObject {
    @Published var articles: [Article] = []
    
    let networkService: NetworkServiceProtocol
    let responseValidator: ResponseValidator
    let dataParser: DataParser
    
    init(networkService: NetworkServiceProtocol, responseValidator: ResponseValidator, dataParser: DataParser) {
        self.networkService = networkService
        self.responseValidator = responseValidator
        self.dataParser = dataParser
    }
    
    func fetchArticles(period: Period) async {
        do {
            let req = MostViewedArticlesRequest.viewed(period: period)
            let res = try await networkService.execute(request: req)
            self.articles = res.results
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

### Benefits of Using `ResponseValidator`, `DataParser`, and `NetworkServiceProtocol`

#### 1. **Separation of Concerns**

By using separate protocols for **response validation** and **data parsing**, the responsibilities are clearly defined and modularized. Each component has a single responsibility:

* **ResponseValidator** ensures the response is valid.
* **DataParser** handles the transformation of raw data into a model.
* **NetworkService** coordinates the entire process, including network requests, validation, and parsing.

#### 2. **Reusability**

The `NetworkService` can be reused with different validators and parsers, making it adaptable for different API endpoints and response formats. For example, you can easily swap in a different `ResponseValidator` or `DataParser` for different endpoints.

#### 3. **Testability**

Each protocol is independently testable:

* You can mock the `ResponseValidator` to test how different responses are handled.
* You can mock the `DataParser` to test different parsing scenarios.
* You can test the `NetworkService` with various combinations of validators and parsers.

#### 4. **Flexibility**

The modular architecture allows for easy extension:

* Add new validation strategies (e.g., handling authentication or rate-limiting errors).
* Add new data parsers (e.g., for XML or custom JSON structures).
* Modify or extend the `NetworkService` without affecting other parts of your application.

#### 5. **Error Handling**

Structured error handling can be done at each stage:

* **Response validation errors** (e.g., invalid status codes) can be handled separately from parsing errors.
* **Parsing errors** (e.g., malformed JSON) are handled gracefully.
* You can provide detailed error messages to users, improving the debugging process.

#### 6. **Scalability**

As your project grows, you can add more complex validation and parsing logic without cluttering the `NetworkService`. For example, adding retry logic, handling different response codes, or supporting multiple formats can be done without modifying the core networking logic.


### License

**RestAPIFramework** is released under the MIT license.
