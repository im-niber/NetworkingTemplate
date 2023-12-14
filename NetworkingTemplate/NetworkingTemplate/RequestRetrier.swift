import Foundation

// retry를 담당하는 객체를 만들어보겠슴니다
// Retrier로 명명하고 최대 3번 재시도하도록 구현하겠슴니다.
protocol RequestRetrier {
    func shouldRetry(_ requet: URLRequest, with error: Error, attempt: Int) -> Bool
    func retry(_ request: URLRequest, with error: Error, attempt: Int) -> URLRequest?
}

final class SimpleRequestRetrier: RequestRetrier {
    private let maxAttempts: Int

    init(maxAttempts: Int = 3){
        self.maxAttempts = maxAttempts
    }
    
    // 이 메서드는 요청이 실패하였을 때 재시도 여부를 결정함니다.
    func shouldRetry(_ requet: URLRequest, with error: Error, attempt: Int) -> Bool {
        return attempt < maxAttempts
    }
   
    // 이 메서드는 재시도를 위해 요청을 수정할 수 있슴니다.
    func retry(_ request: URLRequest, with error: Error, attempt: Int) -> URLRequest? {
        // 여기서 request를 수정해서 반환할 수 있슴니다.
        return request
    }
}
