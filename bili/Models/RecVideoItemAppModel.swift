//
//  RecVideoItemAppModel.swift
//  bili
//
//  Created by DJ on 2024/8/20.
//
import SwiftyJSON


struct RecVideoItemAppModel: Codable {
    struct Owner: Codable {
        @Default<Int> var mid: Int
        @Default<String> var name: String
        @Default<String> var face: String
    }

    struct Stat: Codable {
        @Default<Int> var view: Int
        @Default<Int> var like: Int
        @Default<Int> var danmaku: Int
        enum CodingKeys: String, CodingKey {
            case view = "cover_left_text_1"
            case like
            case danmaku = "cover_left_text_2"
        }
    }

    struct RcmdReason: Codable {
        @Default<Int> var reason_type: Int
        @Default<String> var content: String
    }
    @Default<Int> var id: Int
    @Default<Int> var aid: Int
    @Default<String> var bvid: String
    @Default<Int> var cid: Int
    @Default<String> var pic: String
    var stat: Stat?
    @Default<String> var title: String
    @Default<Int> var is_followed: Int//app端无此字段，待处理
    var owner: Owner?
    var rcmd_reason: RcmdReason?
    @Default<String> var goto: String
    @Default<Int> var param: Int
    @Default<String> var uri: String
    @Default<String> var talkBack: String
    @Default<String> var bangumiFollow: String
    @Default<String> var bangumiBadge: String
    @Default<String> var cardType: String
    var adInfo: JSON?
    @Default<Int> var pubdate: Int
}
