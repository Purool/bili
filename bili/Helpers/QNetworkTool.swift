//
//  QNetworkTool.swift
//  bili
//
//  Created by Purool on 14/8/2024.
//

import UIKit
import Alamofire

class QNetworkTool {
    //先简单加一层，后续看需求

    struct responseData {
        var request:URLRequest?
        var response:HTTPURLResponse?
        var json:AnyObject?
        var error:NSError?
        var data:Data?
    }
    
    class func requestWith(Method method:Alamofire.HTTPMethod, URL url:String, Parameter para:[String:Any]?, Headers headers:HTTPHeaders?, handler: @escaping (responseData) -> Void){
        
        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        AF.sessionConfiguration.timeoutIntervalForRequest = 10
        AF.request(url, method: method, parameters: para, encoding: URLEncoding.default, headers: headers).response(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        })
    }
}
