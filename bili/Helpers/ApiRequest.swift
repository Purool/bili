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
import SwiftProtobuf
import CommonCrypto

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
    
    enum Keys {
        static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
        static let liveReferer = "https://live.bilibili.com"
        static let referer = "https://www.bilibili.com"
        static func referer(for aid: Int) -> String {
            return "https://www.bilibili.com/video/av\(aid)"
        }
    }
    
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

    static func biliWbiSign(spdDicParam: [String: Any] ) async throws -> [String: Any] {
        func getMixinKey(orig: String) -> String {
            return String(mixinKeyEncTab.map { orig[orig.index(orig.startIndex, offsetBy: $0)] }.prefix(32))
        }
        
        func encWbi(params: [String: Any], imgKey: String, subKey: String) -> [String: Any] {
            var params = params
            let mixinKey = getMixinKey(orig: imgKey + subKey)
            let currTime = round(Date().timeIntervalSince1970)
            params["wts"] = currTime
            params = params.sorted { $0.key < $1.key }.reduce(into: [:]) { $0[$1.key] = $1.value }
            params = params.mapValues { String(describing: $0).filter { !"!'()*".contains($0) } }
            let query = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            let wbiSign = calculateMD5(string: query + mixinKey)
            params["w_rid"] = wbiSign
            return params
        }
        
        func getWbiKeys() async throws -> (imgKey: String, subKey: String){
            let headers: HTTPHeaders = [
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
                "Referer": "https://www.bilibili.com/"
            ]
            let json = try await ApiRequest.requestGetJson(QApi.userInfo, auth: false, headers: headers)
            let imgURL = json["wbi_img"]["img_url"].string ?? ""
            let subURL = json["wbi_img"]["sub_url"].string ?? ""
            let imgKey = imgURL.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
            let subKey = subURL.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
            UserDefaults.standard.set(codable: ["imgKey": imgKey, "subKey": subKey, "timeStamp": String(Date().timeIntervalSince1970)], forKey: "wbiKeys")
            return (imgKey, subKey)
       }

        
        func calculateMD5(string: String) -> String {
            let data = Data(string.utf8)
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = data.withUnsafeBytes {
                CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
            }
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }
        
        let mixinKeyEncTab = [
            46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
            33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40,
            61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11,
            36, 20, 34, 44, 52
        ]
        
        let keys = try await getWbiKeys()
        if keys.imgKey.count > 0, keys.subKey.count > 0 {
            let signedParams = encWbi(params: spdDicParam, imgKey: keys.imgKey, subKey: keys.subKey)
            return signedParams
        }else {
            throw RequestError.statusFail(code: 101, message: "getWbiKeys failed")
        }
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
    
    static func requestData(_ url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters = [:],
                            headers: HTTPHeaders? = nil,
                            noCookie: Bool = false,
                            complete: ((Result<Data, RequestError>) -> Void)? = nil)
    {
        var parameters = parameters
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
            complete?(.failure(.networkFail))
            return
        }
        AF.request(desURL, method: method, parameters: parameters, headers: headers).responseData { response in
            print("---URL: \(response.request?.url?.absoluteString ?? "")")
            switch response.result {
            case let .success(data):
                complete?(.success(data))
            case let .failure(err):
                print(err)
                complete?(.failure(.networkFail))
            }
        }
    }
    
    static func requestPB<T: SwiftProtobuf.Message>(_ url: URLConvertible,
                                                    method: HTTPMethod = .get,
                                                    parameters: Parameters = [:]) async throws -> T
    {
        return try await withCheckedThrowingContinuation { configure in
            requestData(url, method: method, parameters: parameters) {
                res in
                switch res {
                case let .success(data):
                    do {
                        let protobufObject = try T(serializedBytes: data)
                        configure.resume(returning: protobufObject)
                    } catch let err {
                        print("Protobuf parsing error: \(err.localizedDescription)")
                        configure.resume(throwing: err)
                    }
                case let .failure(err):
                    configure.resume(throwing: err)
                }
            }
        }
    }
    
    static func requestJSON(_ url: URLConvertible,
                            method: HTTPMethod = .get,
                            parameters: Parameters = [:],
                            auth: Bool = true,
                            encoding: ParameterEncoding = URLEncoding.default,
                            headers: HTTPHeaders? = nil,
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
            complete?(.failure(.networkFail))
            return
        }
        
        AF.request(desURL, method: method, parameters: parameters, encoding: encoding, headers: headers).responseData { response in
            print("---URL: \(response.request?.url?.absoluteString ?? "")")
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
    
    static func requestGetJson(_ url: URLConvertible,
                                      method: HTTPMethod = .get,
                                      parameters: Parameters = [:],
                                      auth: Bool = true,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      headers: HTTPHeaders? = nil,
                                      dataObj: String = "data") async throws -> JSON
    {
        return try await withCheckedThrowingContinuation { configure in
            requestJSON(url, method: method, parameters: parameters, auth: auth, encoding: encoding, headers: headers) { result in
                switch result {
                case let .success(data):
                    configure.resume(returning: data[dataObj])
                case let .failure(err):
                    configure.resume(throwing: err)
                }
            }
        }
    }
    
    static func requestGetObj<T: Decodable>(_ url: URLConvertible,
                                      method: HTTPMethod = .get,
                                      parameters: Parameters = [:],
                                      auth: Bool = true,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      headers: HTTPHeaders? = nil,
                                      dataObj: String = "data") async throws -> T
    {
        return try await withCheckedThrowingContinuation { configure in
            requestJSON(url, method: method, parameters: parameters, auth: auth, encoding: encoding, headers: headers) { result in
                switch result {
                case let .success(data):
                    do {
                        let data = try data[dataObj].rawData()
                        let object = try JSONDecoder().decode(T.self, from: data)
                        configure.resume(returning: object)
                    } catch let err {
                        print(err)
                        configure.resume(throwing: err)
                    }
                case let .failure(err):
                    configure.resume(throwing: err)
                }
            }
        }
    }
    
    static func requestLoginInfo() async throws -> UserInfoData {
//        { requestJSON(QApi.userInfo, complete: complete)
        let userInfo: UserInfoData = try await requestGetObj(QApi.userInfo)
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
        let res: Resp = try await requestGetObj(QApi.recommendListWeb, parameters: data)
        return res.item.filter({$0.goto == "av"})
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
        let res: Resp = try await requestGetObj(QApi.getTVCode, method: .post)
        return res.auth_code
    }
    // 获取access_key
    static func cookieToKey() async throws {
        let auth_code = try await getTVCode()
        struct Resp: Codable {
            let code: Int
        }
        let _: Resp = try await requestGetObj(QApi.cookieToKey, method: .post, parameters: ["auth_code": auth_code, "build": 708200, "csrf": QwebCookieTool.csrf() ?? ""])
        try await Task.sleep(nanoseconds: 300)
        try await qrcodePoll(authCode: auth_code)
    }
    static func qrcodePoll(authCode:String) async throws {
        struct Resp: Codable {
            let access_token: String
        }
        let accessKey: Resp  = try await requestGetObj(QApi.qrcodePoll,method: .post)
        UserDefaults.standard.set(accessKey.access_token, forKey: "accessKey")
//        SmartDialog.dismiss();
    }
    //MARK: VideoHttp
    static func rcmdVideoListApp(freshIdx: Int) async throws -> [RecVideoItemAppModel] {
        struct Resp: Codable {
            let items: [RecVideoItemAppModel]
        }
        let data = ["idx": freshIdx, "flush": "0", "column": "2", "pull": freshIdx == 0 ? "1" : "0"] as [String : Any]
        let res: Resp = try await requestGetObj(QApi.recommendListApp, parameters: data)
        return res.items.filter({$0.card_goto != "ad_av"})
    }
    
    static func videoUrl(avid: Int? = nil, bvid: String? = nil, cid: Int, qn: Int? = nil) async throws -> PlayUrlModel {
        var data: [String: Any] = [
            "cid": cid,
            "qn": qn ?? 80,
            // 获取所有格式的视频
            "fnval": 4048
        ]
        if let avid = avid {
            data["avid"] = avid
        }
        if let bvid = bvid {
            data["bvid"] = bvid
        }
        // 免登录查看1080p
        if ApiRequest.getUserInfo() == nil {//&& setting["p1080"] as? Bool?? true {//默认是1080p
            data["try_look"] = 1
        }
        let params = try await biliWbiSign(spdDicParam: data.merging(["fourk": 1, "voice_balance": 1, "gaia_source": "pre-load", "web_location": 1550101]) { $1 })
//        let res = try await ApiRequest.requestGetJson(QApi.videoUrl, parameters: params)
        let model: PlayUrlModel = try await ApiRequest.requestGetObj(QApi.videoUrl, parameters: params)
        return model
    }
    
    static func requestSubtitle(url: URL) async throws -> [SubtitleContent] {
        struct SubtitlContenteResp: Codable {
            let body: [SubtitleContent]
        }
        let resp = try await AF.request(url).serializingDecodable(SubtitlContenteResp.self).value
        return resp.body
    }
    
    static func requestBangumiInfo(epid: Int) async throws -> BangumiInfo {
        let info: BangumiInfo = try await requestGetObj(QApi.bangumiInfo, parameters: ["ep_id": epid], dataObj: "result")
        return info
    }

    static func requestBangumiInfo(seasonID: Int) async throws -> BangumiSeasonInfo {
        let res: BangumiSeasonInfo = try await requestGetObj(QApi.bangumiInfoSeason, parameters: ["season_id": seasonID], dataObj: "result")
        return res
    }
    
}
