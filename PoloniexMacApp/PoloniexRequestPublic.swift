
import Foundation

struct PoloniexRequestPublic {
  let body: String
  let urlAddress:String
  var bodyData: Data {
    return body.data(using: .utf8)!
  }
  var qIs : [URLQueryItem] = []
  var urlRequest: URLRequest {
    var request = URLRequest(url: URL(string: urlAddress)!)
    request.httpBody = bodyData
    request.httpMethod = "GET"
    return request
  }
    init(params: [String: String]) {
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
          queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents()
        components.queryItems = queryItems
        let body = components.query!
        self.body = body
        self.qIs = queryItems
        urlAddress = "https://poloniex.com/public?" + body
        
        print("Public: All headers")
        print(self.urlRequest.allHTTPHeaderFields as Any)
        print("Public: Body: "+String(body))
        print("url from components:")
        print(components.url as Any)
      }
}
