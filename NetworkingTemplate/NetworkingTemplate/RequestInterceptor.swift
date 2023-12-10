import Foundation

// 인터셉터 기능을 하는 객체
// 토큰을 추가하거나 바꾸거나 하는 등의 기능을 수행함
protocol RequestInterceptor {
    func intercept(_ request: URLRequest) -> URLRequest
}

class AuthRequestInterceptor: RequestInterceptor {
    private let token: String

    init(token: String) {
        self.token = token
    }
    
    // 사용예시로는 accessToken이 만료되면
    // 앱 내부에 저장된 refreshToken을 찾고
    // 헤더에 담아서 새로운 요청을 반환하는 경우가 있습니당.
    func intercept(_ request: URLRequest) -> URLRequest {
        var request = request
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
