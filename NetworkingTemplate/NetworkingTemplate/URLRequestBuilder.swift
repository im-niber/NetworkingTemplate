import Foundation

// 구조체 ver
struct URLRequestBuilder {
    private var url: URL?
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var body: Data?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    init(url: URL? = nil, method: HTTPMethod, headers: [String : String], body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    func setMethod(_ method: HTTPMethod) -> URLRequestBuilder {
        return URLRequestBuilder(url: url, method: method, headers: headers, body: body)
    }

    mutating func addHeader(field: String, value: String) -> URLRequestBuilder {
        self.headers[field] = value
        return URLRequestBuilder(url: url, method: method, headers: headers, body: body)
    }

    func setBody(_ body: Data) -> URLRequestBuilder {
        return URLRequestBuilder(url: url, method: method, headers: headers, body: body)
    }

    func build() -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}

// 클래스 ver
class URLRequestBuilderClass {
    private var url: URL?
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var body: Data?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    init(url: String) {
        self.url = URL(string: url)
    }

    func setMethod(_ method: HTTPMethod) -> URLRequestBuilderClass {
        self.method = method
        return self
    }

    func addHeader(field: String, value: String) -> URLRequestBuilderClass {
        self.headers[field] = value
        return self
    }

    func setBody(_ body: Data) -> URLRequestBuilderClass {
        self.body = body
        return self
    }

    func build() -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
