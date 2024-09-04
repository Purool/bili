//
//  PlayUrlModel.swift
//  bili
//
//  Created by DJ on 2024/8/29.
//

import Foundation

let VideoQualityList: [Int] = [6,16,32,64,74,80,112,116,120,125,126,127];
let DecodeList: [String]  = ["dvh1", "av01", "hev1", "avc1"];

enum VideoQuality: Int {
    case speed240 = 6
    case flunt360 = 16
    case clear480 = 32
    case high720 = 64
    case high72060 = 74
    case high1080 = 80
    case high1080plus = 112
    case high108060 = 116
    case super4K = 120
    case hdr = 125
    case dolbyVision = 126
    case super8k = 127
}

enum AudioQuality: Int {
    case k64 = 30216
    case k132 = 30232
    case k192 = 30280
    case dolby = 30250
    case hiRes = 30251
}

enum VideoDecodeFormats: String {
    case DVH1 = "dvh1"
    case AV1 = "av01"
    case HEVC = "hev1"
    case AVC = "avc1"
}

extension VideoQuality {
    var description: String {
        switch self {
        case.speed240:
            return "240P 极速"
        case.flunt360:
            return "360P 流畅"
        case.clear480:
            return "480P 清晰"
        case.high720:
            return "720P 高清"
        case.high72060:
            return "720P60 高帧率"
        case.high1080:
            return "1080P 高清"
        case.high1080plus:
            return "1080P+ 高码率"
        case.high108060:
            return "1080P60 高帧率"
        case.super4K:
            return "4K 超清"
        case.hdr:
            return "HDR 真彩色"
        case.dolbyVision:
            return "杜比视界"
        case.super8k:
            return "8K 超高清"
        }
    }
}

extension AudioQuality {
    var description: String {
        switch self {
        case.k64:
            return "64K"
        case.k132:
            return "132K"
        case.k192:
            return "192K"
        case.dolby:
            return "杜比全景声"
        case.hiRes:
            return "Hi-Res无损"
        }
    }
}

extension VideoDecodeFormats {
    var description: String {
        return rawValue
    }
    
    static func fromCode(_ code: String) -> VideoDecodeFormats? {
        return VideoDecodeFormats(rawValue: code)
    }
    
    static func fromString(_ val: String) -> VideoDecodeFormats? {
//        for format in VideoDecodeFormats {
//            if val.hasPrefix(format.rawValue) {
//                return format
//            }
//        }
        return nil
    }
}
/*
 let videoQuality = VideoQuality.speed240
 print(videoQuality.description) // 输出: 240P 极速

 let audioQuality = AudioQuality.hiRes
 print(audioQuality.description) // 输出: Hi-Res无损

 let videoDecodeFormat = VideoDecodeFormats.fromString("hev1")
 if let format = videoDecodeFormat {
     print(format.description) // 输出: hev1
 }
 */
struct MediaItem: Codable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct DashSegmentBase: Codable, Hashable {
        var Initialization: String
        var indexRange: String
    }
    @Default var id: Int
    @Default var baseUrl: String
    @Default var backupUrl: [String]
    var bandwidth: Int
    @Default var mimeType: String
    @Default var codecs: String
    @Default var width: Int
    @Default var height: Int
    var frameRate: String?
    @Default var sar: String
    @Default var startWithSap: Int
    var SegmentBase: DashSegmentBase?
    @Default var codecid: Int
    var quality: Int?
}

struct PlayUrlModel: Codable {
    
    struct Dash: Codable {
        @Default var duration: Int
        @Default var minBufferTime: Double
        var video: [MediaItem]?
        var audio: [MediaItem]?
        var dolby: Dolby?
        var flac: Flac?
    }
    
    class ClipInfo: Codable {
        let start: CGFloat
        let end: CGFloat
        let clipType: String?
        let toastText: String?
        var a11Tag: String {
            "\(start)\(end)"
        }

        var skipped: Bool? = false

        var customText: String {
            if clipType == "CLIP_TYPE_OP" {
                return "跳过片头"
            } else if clipType == "CLIP_TYPE_ED" {
                return "跳过片尾"
            } else {
                return toastText ?? "跳过"
            }
        }

        init(start: CGFloat, end: CGFloat, clipType: String?, toastText: String?) {
            self.start = start
            self.end = end
            self.clipType = clipType
            self.toastText = toastText
        }
    }
    
    @Default var from: String
    @Default var result: String
    @Default var message: String
    @Default var quality: Int
    @Default var format: String
    @Default var timelength: Int
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
    let clip_info_list: [ClipInfo]?
}


// FormatItem类
struct FormatItem: Codable {
    @Default var quality: Int
    @Default var format: String
    @Default var new_description: String
    @Default var display_desc: String
    var codecs: [String]
}

// Dolby类
struct Dolby: Codable {
    // 1：普通杜比音效 2：全景杜比音效
    @Default var type: Int
    var audio: [MediaItem]?
}

// Flac类
struct Flac: Codable {
    @Default var display: Bool
    var audio: MediaItem?
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


