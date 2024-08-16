//
//  QNetworkTool.swift
//  bili
//
//  Created by Purool on 14/8/2024.
//

import UIKit
import Alamofire
import WebKit

typealias FlutterResult = (_ result: [HTTPCookie]?) -> Void

class QNetworkTool {
    //先简单加一层，后续看需求
    static let shared = QNetworkTool()
    var httpCookieStore: WKHTTPCookieStore?
    var baseUrlHeaders: HTTPHeaders?
    private init() {
        httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
    }
    struct responseData {
        var request:URLRequest?
        var response:HTTPURLResponse?
        var json:AnyObject?
        var error:NSError?
        var data:Data?
    }
    
    public func requestWith(Method method:Alamofire.HTTPMethod, URL url:String, Parameter para:[String:Any]?, Headers headers:HTTPHeaders?, handler: @escaping (responseData) -> Void){
       
//        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        AF.sessionConfiguration.timeoutIntervalForRequest = 10
        AF.request(url, method: method, parameters: para, encoding: URLEncoding.default, headers: self.baseUrlHeaders).response(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    public func getCookies(urlString: String?) async -> [HTTPCookie]{
        // map empty string and nil to "", indicating that no filter should be applied
        let url = urlString.map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        // ensure passed in url is parseable, and extract the host
        let host = URL(string: url)?.host
       
        // fetch and filter cookies from WKHTTPCookieStore
        let wkCookies = await httpCookieStore!.allCookies()
        
        func matches(cookie: HTTPCookie) -> Bool {
            // nil host means unparseable url or empty string
            let containsHost = host.map{cookie.domain.contains($0)} ?? false
            let containsDomain = host?.contains(cookie.domain) ?? false
            return url == "" || containsHost || containsDomain
        }
                                    
        var cookies = wkCookies.filter{ matches(cookie: $0) }

        // If the cookie value is empty in WKHTTPCookieStore,
        // get the cookie value from HTTPCookieStorage
        if cookies.count == 0 {
            if let httpCookies = HTTPCookieStorage.shared.cookies {
                cookies = httpCookies.filter{ matches(cookie: $0) }
            }
        }
        return cookies
    }
    
    func setCookie() async {
        var cookies = await getCookies(urlString: HttpString.baseUrl)
        AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: HttpString.baseUrl), mainDocumentURL: nil)
        let cookieString = cookies.map { cookie in
            return "\(cookie.name)=\(cookie.value)"
        }.joined(separator: "; ")
        baseUrlHeaders = ["cookie": cookieString]
        
        cookies = await getCookies(urlString: HttpString.apiBaseUrl)
        AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: HttpString.apiBaseUrl), mainDocumentURL: nil)
        
        cookies = await getCookies(urlString: HttpString.tUrl)
        AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: HttpString.tUrl), mainDocumentURL: nil)
        
    }
    
}

class UserHttp {
    
}
