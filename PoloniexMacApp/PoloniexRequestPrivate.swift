
import Foundation

struct PoloniexRequestPrivate {
    let body: String
    let hash: String
    let keys: APIKeys
    var bodyData: Data {
        return body.data(using: .utf8)!
    }
    var urlRequest: URLRequest {
        var request = URLRequest(url: URL(string: "https://poloniex.com/tradingApi")!)
        request.setValue(keys.key, forHTTPHeaderField: "Key")
        request.setValue(hash, forHTTPHeaderField: "Sign")
        request.httpBody = bodyData
        request.httpMethod = "POST"
        return request
    }
    init(params: [String: String], keys: APIKeys) {
        self.keys = keys
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        let nonce = Int64(Date().timeIntervalSince1970 * 1000)
        queryItems.append(URLQueryItem(name: "nonce", value: "\(nonce)"))
        var components = URLComponents()
        components.queryItems = queryItems
        let body = components.query! /*the body of the URL request contains all the parameters from PoloniexRequest and nonce parameter, the Key and the Hash (basically encrypted body) are in the header fields */
        let hash = body.hmac(algorithm: HMACAlgorithm.SHA512, key: keys.secret)
        self.hash = hash
        self.body = body
        print("Private: All headers")
        print(self.urlRequest.allHTTPHeaderFields as Any)
        print("Private: Body: "+String(body))
    }
}
