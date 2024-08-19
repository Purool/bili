//
//  QwebCookieTool.swift
//  bili
//
//  Created by Purool on 14/8/2024.
//

import UIKit
import Alamofire
import WebKit

typealias FlutterResult = (_ result: [HTTPCookie]?) -> Void

class QwebCookieTool {
    //先简单加一层，后续看需求
    static let shared = QwebCookieTool()
    var httpCookieStore: WKHTTPCookieStore?
    var baseUrlHeaders: HTTPHeaders?
    private init() {
        httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
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
