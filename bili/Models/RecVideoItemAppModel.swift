//
//  RecVideoItemAppModel.swift
//  bili
//
//  Created by DJ on 2024/8/20.
//
import SwiftyJSON


struct RecVideoItemAppModel: Codable {
    
    struct PlayerArgs: Codable {
        @Default<Int> var aid: Int// IdUtils.av2bv()
        @Default<Int> var duration: Int
        @Default<String> var type: String
        @Default<Int> var cid: Int
    }
    
    struct Args: Codable {
        @Default<Int> var up_id: Int
        @Default<String> var up_name: String
    }

    struct RcmdReason: Codable {
        @Default<String> var content: String//isFollowed
        @Default<String> var text: String
    }
    
    @Default<String> var param: String //id
    var player_args: PlayerArgs?
    @Default<String> var cover: String
    @Default<String> var cover_left_text_1: String
    @Default<Int> var like: Int
    @Default<String> var cover_left_text_2: String
    @Default<String> var cover_left_text_3: String
    var rcmd_reason_style: RcmdReason?
    @Default<String> var title: String
    @Default<Int> var is_followed: Int//app端无此字段，待处理
    var args: Args?
    @Default<String> var goto: String
    @Default<String> var uri: String
    @Default<String> var talk_back: String
    @Default<String> var card_type: String
    var ad_info: JSON?
    @Default<Int> var pubdate: Int
    @Default<String> var card_goto: String
}
