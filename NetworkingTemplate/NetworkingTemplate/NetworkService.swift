import Foundation

// 완료 핸들러 기반의 NetworkService를 만들어보았슴니다.
// async 버전도 만들어봐야겠씀니다.
// 아쉬운 부분이 후행 클로저에서 반복을 종료시켜줄려면 클래스 내부
// 프로퍼티로 하는 방법말고는 잘 떠오르지가 않아서 플래그 변수를
// 선언했는데 요게 좀 아쉬운느낌..
// 같은 범위 내에서 진행할 수 있는 async에서는
// 좀 더 깔끔하게 관리가 될 거 같슴니당

final class NetworkService {
    let interceptor: RequestInterceptor?
    let retrier: RequestRetrier?
    
    init(interceptor: RequestInterceptor?, retrier: RequestRetrier?) {
        self.interceptor = interceptor
        self.retrier = retrier
    }
    
    func request<T: Codable>(request: URLRequest, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        // intercept 처리를 먼저 진행함 interceptor가 nil인 경우는 예외했씀니다
        var request = (interceptor?.intercept(request))!
        var attempt = 0 // 현재 시도 횟수
        var `repeat` = true // 반복을 종료할 변수
        
        repeat {
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 401 {
                        
                        if let shoudRetry = self.retrier?.shouldRetry(request, with: error!, attempt: attempt + 1) {
                            
                            // retry 코드 내부에서 request를 수정해서 내려보내는 코드가 많았슴니다
                            // Alamofire의 retry 함수 내부에서 주로
                            // 토큰을 새로 발급받는 코드를 많이 작성하는듯함니당
                            
                            // 확실히 지금 간략하게 작성해도 가독성이 좀 떨어지고 코드가 길어지는데
                            // 라이브러리(Alamofire, Moya)등을 쓰는게 좋은거같기도함니당
                            
                            request = (self.retrier?.retry(request, with: error!, attempt: attempt + 1))!
                            
                            attempt += 1
                            return
                        }
                    }
                    
                    // 200~299 사이에 코드가 있다면 성공으로 판단하고
                    // 디코딩처리후 값을 넘긴다음 반복을 종료함
                    else if (200..<300).contains(httpResponse.statusCode) {
                        let decoder = JSONDecoder()
                        let data = try? decoder.decode(T.self, from: data!)
                        completion(.success(data!))
                        `repeat` = false
                        return
                    }
                    
                    // 코드가 401이 아닌 경우에 실패처리를 하고 반복을 종료함
                    else {
                        completion(.failure(.unknown))
                        `repeat` = false
                        return
                    }
                }
            }
        } while `repeat`
    }
}
