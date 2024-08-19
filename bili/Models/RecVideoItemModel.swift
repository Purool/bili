//
//  RecVideoItemModel.swift
//  bili
//
//  Created by Purool on 19/8/2024.
//

import SwiftyJSON

struct Owner: Codable {
    @Default<Int> var mid: Int
    @Default<String> var name: String
    @Default<String> var face: String
}

struct Stat: Codable {
    @Default<Int> var view: Int
    @Default<Int> var like: Int
    @Default<Int> var danmu: Int
}

struct RcmdReason: Codable {
    @Default<Int> var reasonType: Int
    @Default<String> var content: String
}

struct RecVideoItemModel: Codable {
    
    @Default<Int> var id: Int
    @Default<String> var bvid: String
    @Default<Int> var cid: Int
    @Default<String> var goto: String
    @Default<String> var uri: String
    @Default<String> var pic: String
    @Default<String> var title: String
    @Default<Int> var duration: Int
    @Default<Int> var pubdate: Int
    var owner: Owner
    var stat: Stat
    @Default<Int> var is_followed: Int
    var rcmd_reason: RcmdReason
}
