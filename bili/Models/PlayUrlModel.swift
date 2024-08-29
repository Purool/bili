//
//  PlayUrlModel.swift
//  bili
//
//  Created by DJ on 2024/8/29.
//

import Foundation

struct VideoItem: Codable {
    @Default var id: Int
    @Default var baseUrl: String
    @Default var backupUrl: String
    @Default var bandWidth: Int
    @Default var mimeType: String
    @Default var codecs: String
    @Default var width: Int
    @Default var height: Int
    @Default var frameRate: Int
    @Default var sar: String
    @Default var startWithSap: Int
    @Default var segmentBase: String
    @Default var codecid: Int
    @Default var quality: Int
}

struct Dash: Codable {
    @Default var duration: Int
    @Default var minBufferTime: Double
    var video: [VideoItem]?
    var audio: [AudioItem]?
    var dolby: Dolby?
    var flac: Flac?
}

struct PlayUrlModel: Codable {
    @Default var from: String
    @Default var result: String
    @Default var message: String
    @Default var quality: Int
    @Default var format: String
    @Default var timeLength: Int
    @Default var accept_format: String
    @Default var accept_description: [String]
    @Default var accept_quality: [Int]
    @Default var video_codecid: Int
    @Default var seek_param: String
    @Default var seek_type: String
    var dash: Dash?
    var durl: [Durl]?
    var support_formats: [FormatItem]?
    // @Default var highFormat: String
    @Default var last_play_time: Int
    @Default var last_play_cid: Int
}

// AudioItem类
struct AudioItem: Codable {
    @Default var id: Int
    @Default var baseUrl: String
    @Default var backupUrl: String
    @Default var bandWidth: Int
    @Default var mime_type: String
    @Default var codecs: String
    @Default var width: Int
    @Default var height: Int
    @Default var frameRate: String
    @Default var sar: String
    @Default var startWithSap: Int
//    var segmentBase: [String: Any]
    @Default var codecid: Int
    //var quality: String// AudioQuality.init(rawValue: json["id"] as Int).description
}

// FormatItem类
struct FormatItem: Codable {
    @Default var quality: Int
    @Default var format: String
    @Default var new_description: String
    @Default var display_desc: String
//    var codecs: [Any]
}

// Dolby类
struct Dolby: Codable {
    // 1：普通杜比音效 2：全景杜比音效
    @Default var type: Int
    var audio: [AudioItem]?
}

// Flac类
struct Flac: Codable {
    @Default var display: Bool
    var audio: AudioItem?
}

// Durl类
struct Durl: Codable {
    @Default var order: Int
    @Default var length: Int
    @Default var size: Int
    @Default var ahead: String
    @Default var vhead: String
    @Default var url: String
}


