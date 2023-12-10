import UIKit

class ViewController: UIViewController {
    
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
    
    // 클래스버전은 순서에 상관없이 호출이 가능하며
    // 클래스 내부 코드도 깔끔하게 작성되는 모습을 볼 수 있다.
    func getURLRequestClassVer() {
        let builder = URLRequestBuilderClass(url: "https://api.example.com")
        let request = builder
            .setMethod(.get)
            .setBody(Data())
            .addHeader(field: "hi", value: "bye")
            .build()
        
        print(request?.url ,request?.allHTTPHeaderFields)
        print(request?.httpBody, request?.httpMethod)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getURLRequestStructVer()
        getURLRequestClassVer()
    }
}
