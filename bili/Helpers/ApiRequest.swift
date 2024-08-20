//
//  ApiRequest.swift
//  bili
//
//  Created by DJ on 2024/8/19.
//

import Alamofire
import CryptoKit
import Foundation
import SwiftyJSON

struct LoginToken: Codable {
    let mid: Int
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    var expireDate: Date?
}

enum ApiRequest {
    static let appkey = "5ae412b53418aac5"
    static let appsec = "5b9cf6c9786efd204dcf0c1ce2d08436"
    
    enum EndPoint {
        static let loginQR = "https://passport.bilibili.com/x/passport-tv-login/qrcode/auth_code"
        static let verifyQR = "https://passport.bilibili.com/x/passport-tv-login/qrcode/poll"
        static let refresh = "https://passport.bilibili.com/api/v2/oauth2/refresh_token"
        static let ssoCookie = "https://passport.bilibili.com/api/login/sso"
        static let feed = "https://app.bilibili.com/x/v2/feed/index"
        static let season = "https://api.bilibili.com/pgc/view/v2/app/season"
    }
    
    enum LoginState {
        case success(token: LoginToken)
        case fail
        case expire
        case waiting
    }
    
    static func save(token: LoginToken) {
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    static func getUserInfo() -> UserInfoData? {
        if let userInfo: UserInfoData = UserDefaults.standard.codable(forKey: "userInfoCache") {
            return userInfo
        }
        return nil
    }
    
    static func isLogin() -> Bool {
        return getUserInfo() != nil
    }
    //        "iphone_i" "phone" "iphone 12 mini"
    static func sign(for param: [String: Any]) -> [String: Any] {
        var newParam = param
        newParam["appkey"] = appkey
        newParam["ts"] = "\(Int(Date().timeIntervalSince1970))"
        newParam["local_id"] = "0"
        newParam["mobi_app"] = "iphone"
        newParam["device"] = "pad"
        newParam["device_name"] = "iPad"
        var rawParam = newParam
            .sorted(by: { $0.0 < $1.0 })
            .map({ "\($0.key)=\($0.value)" })
            .joined(separator: "&")
        rawParam.append(appsec)
        
        let md5 = Insecure.MD5
            .hash(data: rawParam.data(using: .utf8)!)
            .map { String(format: "%02hhx", $0) }
            .joined()
        newParam["sign"] = md5
        return newParam
    }
    
    static func logout(complete: (() -> Void)? = nil) {
        UserDefaults.standard.removeObject(forKey: "token")
        complete?()
    }
    
    static func requestJSON(_ url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters = [:],
                            auth: Bool = true,
                            encoding: ParameterEncoding = URLEncoding.default,
                            complete: ((Result<JSON, RequestError>) -> Void)? = nil)
    {
        var parameters = parameters
        if auth {
            parameters["access_key"] = UserDefaults.standard.string(forKey: "accessKey") ?? ""//getUserInfo()?.accessToken
        }
        parameters = sign(for: parameters)
        
        var desURL = HttpString.apiBaseUrl
        
        do {
            let tempURL = try url.asURL()
            if nil == tempURL.host {
                desURL += tempURL.absoluteString
            } else {
                desURL = tempURL.absoluteString
            }
        } catch {
            print("Error: \(error)")
            return
        }
        
        AF.request(desURL, method: method, parameters: parameters, encoding: encoding).responseData { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                print(json)
                let errorCode = json["code"].intValue
                if errorCode != 0 {
                    if errorCode == -101 {
                        UserDefaults.standard.removeObject(forKey: "token")
//                        AppDelegate.shared.showLogin()
                    }
                    let message = json["message"].stringValue
                    print(errorCode, message)
                    complete?(.failure(.statusFail(code: errorCode, message: message)))
                    return
                }
                complete?(.success(json))
            case let .failure(err):
                print(err)
                complete?(.failure(.networkFail))
            }
        }
    }
    
    static func request<T: Decodable>(_ url: URLConvertible,
                                      method: HTTPMethod = .get,
                                      parameters: Parameters = [:],
                                      auth: Bool = true,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      decoder: JSONDecoder = JSONDecoder(),
                                      complete: ((Result<T, RequestError>) -> Void)?)
    {
        requestJSON(url, method: method, parameters: parameters, auth: auth, encoding: encoding) { result in
            switch result {
            case let .success(data):
                do {
                    let data = try data["data"].rawData()
                    let object = try decoder.decode(T.self, from: data)
                    complete?(.success(object))
                } catch let err {
                    print(err)
                    complete?(.failure(.decodeFail(message: err.localizedDescription + String(describing: err))))
                }
            case let .failure(err):
                complete?(.failure(err))
            }
        }
    }
    
    static func request<T: Decodable>(_ url: URLConvertible,
                                      method: HTTPMethod = .get,
                                      parameters: Parameters = [:],
                                      auth: Bool = true,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      decoder: JSONDecoder = JSONDecoder()) async throws -> T
    {
        try await withCheckedThrowingContinuation { configure in
            request(url, method: method, parameters: parameters, auth: auth, encoding: encoding, decoder: decoder) { resp in
                configure.resume(with: resp)
            }
        }
    }
    
    struct UpSpaceListData: Codable, Hashable {
        var pic: URL? { return cover }

        var aid: Int { return Int(param) ?? 0 }

        let title: String
        let author: String
        let param: String
        let cover: URL?
        var ownerName: String {
            return author
        }

        var cid: Int { return 0 }
    }
    
    static func requestLoginInfo() async throws -> UserInfoData {
//        { requestJSON(QApi.userInfo, complete: complete)
        let userInfo: UserInfoData = try await request(QApi.userInfo)
        return userInfo
    }
    
    static func rcmdVideoList(freshIdx: Int) async throws -> [RecVideoItemModel] {
        struct Resp: Codable {
            let item: [RecVideoItemModel]
        }
        let data = [
          "version": 1,
          "feed_version": "V8",
          "homepage_ver": 1,
          "ps": 20,
          "fresh_idx": freshIdx,
          "brush": freshIdx,
          "fresh_type": 4
        ] as [String : Any]
        let res: Resp = try await request(QApi.recommendListWeb, parameters: data)
        return res.item.filter({$0.goto != "av"})
    }
    
//    static func queryRcmdFeed(type: String) async throws -> [RecVideoItemModel] {
//        struct Resp: Codable {
//            let list: [RecVideoItemModel]
//        }
//        let res: Resp = try await request(QApi.userInfo)
//        return userInfo
//    }
    //d7ca7f5b6dc01ab11165b32ba05de421
    static func getTVCode() async throws -> String{
        struct Resp: Codable {
            let auth_code: String
        }
        let res: Resp = try await request(QApi.getTVCode, method: .post)
        return res.auth_code
    }
    // 获取access_key
    static func cookieToKey() async throws {
        let auth_code = try await getTVCode()
        struct Resp: Codable {
            let code: Int
        }
        let _: Resp = try await request(QApi.cookieToKey, method: .post, parameters: ["auth_code": auth_code, "build": 708200, "csrf": QwebCookieTool.csrf() ?? ""])
        try await Task.sleep(nanoseconds: 300)
        try await qrcodePoll(authCode: auth_code)
    }
    static func qrcodePoll(authCode:String) async throws {
        struct Resp: Codable {
            let access_token: String
        }
        let accessKey: Resp  = try await request(QApi.qrcodePoll,method: .post)
        UserDefaults.standard.set(accessKey.access_token, forKey: "accessKey")
//        SmartDialog.dismiss();
    }
    //MARK: VideoHttp
    static func rcmdVideoListApp(freshIdx: Int) async throws -> [RecVideoItemAppModel] {
        struct Resp: Codable {
            let items: [RecVideoItemAppModel]
        }
        let data = ["idx": freshIdx, "flush": "0", "column": "2", "pull": freshIdx == 0 ? "1" : "0"] as [String : Any]
        let res: Resp = try await request(QApi.recommendListApp, parameters: data)
        return res.items.filter({$0.goto != "av"})
    }
}
