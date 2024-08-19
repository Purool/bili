//
//  WebRequest.swift
//  bili
//
//  Created by DJ on 2024/8/19.
//

import Alamofire
import Foundation
import SwiftyJSON


enum RequestError: Error {
    case networkFail
    case statusFail(code: Int, message: String)
    case decodeFail(message: String)
}
