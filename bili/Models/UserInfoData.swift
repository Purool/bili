//
//  UserInfoData.swift
//  bili
//
//  Created by DJ on 2024/8/19.
//

import Foundation
import SwiftyJSON

struct Official: Codable {
    @Default<String> var title: String
    @Default<Int> var role: Int
    @Default<String> var desc: String
    @Default<Int> var type: Int
}

struct UserInfoData: Codable {
    
    @Default<Bool> var isLogin: Bool
    @Default<String> var face: String
//    var levelInfo: LevelInfo
    @Default<Int> var mid: Int
    @Default<Int> var mobileVerified: Int
    @Default<Double> var money: Double
    @Default<Int> var moral: Int
    var official: Official
    var officialVerify: JSON
    var pendant: JSON
    @Default<Int> var scores: Int
    @Default<String> var uname: String
    @Default<Int> var vipDueDate: Int
    @Default<Int> var vipStatus: Int
    @Default<Int> var vipType: Int
    @Default<Int> var vipPayType: Int
    @Default<Int> var vipThemeType: Int
    @Default<Int> var vipAvatarSub: Int
    @Default<String> var vipNicknameColor: String
    @Default<Bool> var hasShop: Bool
    @Default<String> var shopUrl: String
    @Default<String> var accessKey: String
}
