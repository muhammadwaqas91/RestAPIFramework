# RestAPIFramework

[![Swift](https://img.shields.io/badge/Swift-5.7-orange?style=flat-square)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://swift.org/platforms)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://swift.org/package-manager)

**RestAPIFramework** is a lightweight and modular networking framework for Swift applications. It simplifies API requests, response handling, error management, and JSON parsing using Swift's modern concurrency features.

## Features

- [x] **Modern Async/Await API** for cleaner networking code.
- [x] **Decodable JSON Parsing** for seamless API responses.
- [x] **Error Handling** with structured error types.
- [x] **Customizable HTTP Headers and Authentication.**
- [x] **Comprehensive Unit and Integration Test Coverage.**
- [x] **Swift Package Manager Support.**

## Installation

### Swift Package Manager (Recommended)

You can add RestAPIFramework to your Swift project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/muhammadwaqas91/RestAPIFramework.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

### Making API Requests

```swift
import RestAPIFramework

let client = NetworkClient()
let request = SampleRequest(baseURL: "https://api.example.com", path: "/users")

Task {
    do {
        let users: [User] = try await client.execute([User].self, request: request)
        print(users)
    } catch {
        print("Failed to fetch users: \(error)")
    }
}
```

### Custom Request Implementation

```swift
struct SampleRequest: RequestConvertible {
    let baseURL: String = "https://api.example.com"
    var path: String = "/users"
    var httpMethod: HTTPMethod = .GET
}
```

### Response Parsing with `Decodable`

```swift
struct User: Codable {
    let id: Int
    let name: String
}
```

## Error Handling

RestAPIFramework provides structured error handling:

```swift
public enum NetworkError: Error {
	case emptyResponse
}

public enum RequestError: Error {
	case invalidURL
}

public enum DataParsingError: Error {
	case decodingFailed(String)
}
```

## Testing

RestAPIFramework includes comprehensive unit and integration tests. Use `XCTest` for validating API calls and JSON parsing.

```swift
func testAPIRequest() async {
    let mockClient = MockNetworkClient()
    let request = SampleRequest()
    let result: [User] = try await mockClient.execute([User].self, request: request)
    XCTAssertEqual(result.count, 3)
}
```

## License

RestAPIFramework is released under the MIT license. See [LICENSE](https://github.com/muhammadwaqas91/RestAPIFramework/blob/main/LICENSE) for details.

