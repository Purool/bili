//
//  PlayUrlModel.swift
//  bili
//
//  Created by DJ on 2024/8/29.
//

import Foundation

enum BVideoUrlUtils {
    static func sortUrls(base: String, backup: [String]?) -> [String] {
        var urls = [base]
        if let backup {
            urls.append(contentsOf: backup)
        }
        return
            urls.sorted { lhs, rhs in
                let lhsIsPCDN = lhs.contains("szbdyd.com") || lhs.contains("mcdn.bilivideo.cn")
                let rhsIsPCDN = rhs.contains("szbdyd.com") || rhs.contains("mcdn.bilivideo.cn")
                switch (lhsIsPCDN, rhsIsPCDN) {
                case (true, false): return false
                case (false, true): return true
                case (true, true): fallthrough
                case (false, false): return lhs > rhs
                }
            }
    }

    static func convertVTTFormate(_ time: CGFloat) -> String {
        let seconds = Int(time)
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        let second = CGFloat((seconds % 3600) % 60) + time - CGFloat(Int(time))
        return String(format: "%02d:%02d:%06.3f", hour, min, second)
    }

    static func convertToVTT(subtitle: [SubtitleContent]) -> String {
        var vtt = "WEBVTT\n\n"
        for model in subtitle {
            let from = convertVTTFormate(model.from)
            let to = convertVTTFormate(model.to)
            // hours:minutes:seconds.millisecond
            vtt.append("\(from) --> \(to)\n\(model.content)\n\n")
        }
        return vtt
    }
}

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

extension MediaItem {
    var playableURLs: [String] {
        BVideoUrlUtils.sortUrls(base: baseUrl, backup: backupUrl)
    }

    var isHevc: Bool {
        return codecs.starts(with: "hev") || codecs.starts(with: "hvc") || codecs.starts(with: "dvh1")
    }
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
