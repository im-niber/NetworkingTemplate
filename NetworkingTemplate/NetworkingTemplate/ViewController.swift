import UIKit
import Combine

class ViewController: UIViewController {
    
    var cancellable = Set<AnyCancellable>()
    
    // 구조체 버전을 호출하면 addHeader를 무조건 먼저 작성해줘야한다는 단점이 있다
    // 만약 setMethod 를 먼저 호출하여 반환받으면 상수라서
    // 값이 불변하기 때문임.
    // 아래처럼 체이닝 방식으로 호출은 불가함.
    // 함수를 하나 호출하고 저장하고, 또 호출하고 저장하고 이런 방식은 가능.
    func getURLRequestStructVer() {
        var builder = URLRequestBuilder(url: URL(string:"https://api.example.com")!, method: .get, headers: [:], body: nil)
        let request = builder
            .addHeader(field: "hi", value: "bye")
            .setMethod(.get)
            .setBody(Data())
            .build()
        
        print(request?.url, request?.allHTTPHeaderFields)
        print(request?.httpBody, request?.httpMethod)
    }
    
    // 구조체2 ver
    // 구조체로 사용할거면 아래처럼 사용하는게 더 깔끔하지 싶다
    // 기존의 구조체 방식은 체이닝을 이루어서 해보고자 했는데
    // 막상 아래처럼 작성해도 가독성이 썩 나쁘진 않아서 괜찮은듯함
    func getURLRequestStructVer2() {
        var builder = URLRequestBuilder2(url: "https://api.example.com")
        builder.setMethod(.get)
        builder.setBody(Data())
        builder.addHeader(field: "hihi", value: "byebye")
        let request = builder.build()
        
        print(request?.url, request?.allHTTPHeaderFields)
        print(request?.httpBody, request?.httpMethod)
    }
    
    // 클래스버전은 순서에 상관없이 호출이 가능하며
    // 클래스 내부 코드도 깔끔하게 작성되는 모습을 볼 수 있다.
    func getURLRequestClassVer() -> URLRequest? {
        let builder = URLRequestBuilderClass(url: "https://api.example.com")
        let request = builder
            .setMethod(.get)
            .setBody(Data())
            .addHeader(field: "hi", value: "bye")
            .build()
        
        print(request?.url ,request?.allHTTPHeaderFields)
        print(request?.httpBody, request?.httpMethod)
        
        return request
    }
    
    // 네트워크 요청에 헤더를 추가하여 새로운 요청을 반환하는 코드
    func intercept() {
        var builder = URLRequestBuilderClass(url: "https://api.example.com/data")
        let authInterceptor = AuthRequestInterceptor(token: "your_token")
        
        if let request = builder
            .setMethod(.get)
            .build() {
            let interceptedRequest = authInterceptor.intercept(request)
            
            print("intercept", interceptedRequest)
            print("intercept", interceptedRequest.allHTTPHeaderFields)
        }
    }
    
    // 기존 URLRequest를 받는 경우
    func intercept(with request: URLRequest?) {
        guard let request else { return }
        let authInterceptor = AuthRequestInterceptor(token: "your_token")
        let interceptedRequest = authInterceptor.intercept(request)
        
        print("intercept", interceptedRequest)
        print("intercept", interceptedRequest.allHTTPHeaderFields)
    }

    // 만료일을 기준을 토큰을 담는다면 아래 처럼 사용도 가능할듯합니다.
    func intercept(with request: URLRequest, date: Date) -> URLRequest {
        guard date.timeIntervalSince(.now) < 0 else { return request }
        let authInterceptor = AuthRequestInterceptor(token: "your_token")
        
        return authInterceptor.intercept(request)
    }
    
    // 401 코드를 받는다면 새로 토큰을 담아서 요청하는 함수입니다
    // 아래처럼 사용 가능할듯,,,함니다..!
    func exampleNetworking(request: URLRequest) {
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map{ (data: Data, response: URLResponse) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode != 401 else {
                    
                    // 401 코드면 refreshToken을 담아서 새로 함수를 실행하고
                    // 여기서는 빈 데이터를 리턴합니당
                    self.exampleNetworking(request: AuthRequestInterceptor(token: "refreshToken").intercept(request))
                    
                    return Data()
                }
                
                return data
            }
            .replaceError(with: Data())
            .compactMap { UIImage(data:$0) }
            .receive(on: DispatchQueue.main)
            .sink { image in
                // self.imageView.image = image
                // ...
            }.store(in: &cancellable)
    }
    
    // retry 예제
    func exampleRetry(request: URLRequest) {
        let requestRetrier = SimpleRequestRetrier()
        let error = NSError(domain: "NetworkError", code: -1009)
        let shouldRetry = requestRetrier.shouldRetry(request, with: error, attempt: 1)
            
        if shouldRetry {
            if let retriedRequest = requestRetrier.retry(request, with: error, attempt: 1) {
                print("Retrying request, \(retriedRequest)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = getURLRequestClassVer()
        
        getURLRequestStructVer()
        getURLRequestStructVer2()
        intercept()
        intercept(with: request)
        exampleRetry(request: request!)
        exampleNetworkServiceFetch()
    }
    
    // service 예제 함수
    func exampleNetworkServiceFetch() {
        let builder = URLRequestBuilderClass(url: "https://api.example.com")
        let request = builder
            .setMethod(.get)
            .setBody(Data())
            .addHeader(field: "hi", value: "bye")
            .build()
        
        guard let request = request else { return }
        
        let networkService = NetworkService(interceptor: nil, retrier: nil)
        networkService.request(request: request, type: String.self) { data in
            print(data)
        }
    }
}
