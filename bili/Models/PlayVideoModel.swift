//
//  PlayVideoModel.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import Foundation

extension DateFormatter {
    static let date = {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        return formater
    }()

    static func stringFor(timestamp: Int?) -> String? {
        guard let timestamp = timestamp else { return nil }
        return date.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
}

protocol DisplayData: Hashable {
    var title: String { get }
    var ownerName: String { get }
    var pic: URL? { get }
    var avatar: URL? { get }
    var date: String? { get }
}

extension DisplayData {
    var avatar: URL? { return nil }
    var date: String? { return nil }
}

protocol PlayableData: DisplayData {
    var aid: Int { get }
    var cid: Int { get }
}

struct HistoryData: DisplayData, Codable {
    struct HistoryPage: Codable, Hashable {
        let cid: Int
    }

    let title: String
    var ownerName: String { owner.name }
    var avatar: URL? {
        if owner.face != nil {
            return URL(string: owner.face!)
        }
        return nil
    }

    let pic: URL?

    let owner: VideoOwner
    let cid: Int?
    let aid: Int
    let progress: Int
    let duration: Int
//    let bangumi: BangumiData?
}

struct FavData: PlayableData, Codable {
    var cover: String
    var upper: VideoOwner
    var id: Int
    var type: Int?
    var title: String
    var ogv: Ogv?
    var ownerName: String { upper.name }
    var pic: URL? { URL(string: cover) }

    struct Ogv: Codable, Hashable {
        let season_id: Int?
    }

    var aid: Int {
        return id
    }

    var cid: Int {
        return 0
    }
}

class FavListData: Codable, Hashable {
    let title: String
    let id: Int
    var mid: Int?
    var currentPage = 1
    var end = false
    var loading = false
    // 收藏夹是否为用户自己创建
    var createBySelf = false
    enum CodingKeys: String, CodingKey {
        case title, id, mid
    }

    static func == (lhs: FavListData, rhs: FavListData) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(title: String, id: Int, currentPage: Int = 1) {
        self.title = title
        self.id = id
        self.currentPage = currentPage
    }
}

struct VideoDetail: Codable, Hashable {
    struct Info: Codable, Hashable {
        let aid: Int
        let cid: Int
        let title: String
        let videos: Int?
        let pic: URL?
        let desc: String?
        let owner: VideoOwner
        let pages: [VideoPage]?
        let dynamic: String?
        let bvid: String?
        let duration: Int
        let pubdate: Int?
        let ugc_season: UgcSeason?
        let redirect_url: URL?
        let stat: Stat
        var ctime: Int?
        struct Stat: Codable, Hashable {
            let favorite: Int
            let coin: Int
            let like: Int
            let share: Int
            let danmaku: Int
            let view: Int
        }

        struct UgcSeason: Codable, Hashable {
            let id: Int
            let title: String
            let cover: URL
            let mid: Int
            let intro: String
            let attribute: Int
            let sections: [UgcSeasonDetail]

            struct UgcSeasonDetail: Codable, Hashable {
                let season_id: Int
                let id: Int
                let title: String
                let episodes: [UgcVideoInfo]
            }

            struct UgcVideoInfo: Codable, Hashable, DisplayData {
                var ownerName: String { "" }
                var pic: URL? { arc.pic }
                let id: Int
                let aid: Int
                let cid: Int
                let arc: Arc
                let title: String

                struct Arc: Codable, Hashable {
                    let pic: URL
                    let ctime: Int
                }
            }
        }

        var durationString: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .brief
            return formatter.string(from: TimeInterval(duration)) ?? ""
        }
    }

    struct Owner: Hashable, Codable {
        let following: Bool
        let follower: Int?
        let archive_count: Int?
    }

    let View: Info
    let Related: [Info]
    let Card: Owner
}

extension VideoDetail: DisplayData {
    var title: String { View.title }
    var ownerName: String { View.owner.name }
    var pic: URL? { View.pic }
    var avatar: URL? {
        if View.owner.face != nil {
            return URL(string: View.owner.face!)
        }
        return nil
    }

    var date: String? { DateFormatter.stringFor(timestamp: View.pubdate) }
}

extension VideoDetail.Info: DisplayData, PlayableData {
    var ownerName: String { owner.name }
    var avatar: URL? {
        if owner.face != nil {
            return URL(string: owner.face!)
        }
        return nil
    }

    var date: String? { DateFormatter.stringFor(timestamp: pubdate) }
}

struct SubtitleResp: Codable {
    let subtitles: [SubtitleData]
}

struct SubtitleData: Codable, Hashable {
    let lan_doc: String
    let subtitle_url: URL
    let lan: String

    var url: URL { subtitle_url.addSchemeIfNeed() }
    var subtitleContents: [SubtitleContent]?
}

struct Replys: Codable, Hashable {
    struct Reply: Codable, Hashable {
        struct Member: Codable, Hashable {
            let uname: String
            let avatar: String
        }

        struct Content: Codable, Hashable {
            let message: String
        }

        let member: Member
        let content: Content
        let replies: [Reply]?
    }

    let replies: [Reply]?
}

struct BangumiSeasonInfo: Codable {
    let main_section: BangumiInfo
    let section: [BangumiInfo]
}

struct BangumiInfo: Codable, Hashable {
    struct Episode: Codable, Hashable {
        let id: Int
        let aid: Int
        let cid: Int
        let cover: URL
        let long_title: String
        let title: String
    }

    let episodes: [Episode] // 正片剧集列表
}

struct BangumiSeasonView: Codable, Hashable {
    struct Episode: Codable, Hashable {
        let ep_id: Int
        let aid: Int
        let cid: Int
        let bvid: String?
        let duration: Int
        let cover: URL
        let index_title: String?
        let index: String
        let pub_real_time: String
        let section_type: Int

        var pubdate: Int? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: pub_real_time) {
                return Int(date.timeIntervalSince1970)
            }
            return nil
        }

        var durationSeconds: Int {
            return Int(duration / 1000)
        }
    }

    struct UpInfo: Codable, Hashable {
        let mid: Int
        let uname: String
        let avatar: String
        let follower: Int?
    }

    let up_info: UpInfo
    let episodes: [Episode]
    let title: String
    let series_title: String
    let evaluate: String
}

struct UserEpisodeInfo: Codable, Hashable {
    struct RelatedUp: Codable, Hashable {
        let avatar: String
        let is_follow: Int
        let mid: Int
        let uname: String
    }

    struct Stat: Codable, Hashable {
        let coin: Int
        let dm: Int
        let like: Int
        let reply: Int
        let view: Int
    }

    struct UserCommunity: Codable, Hashable {
        let coin_number: Int
        let favorite: Int
        let is_original: Int
        let like: Int
    }

    let related_up: [RelatedUp]
    let stat: Stat
    let user_community: UserCommunity
}

struct VideoOwner: Codable, Hashable {
    let mid: Int
    let name: String
    var face: String?
}

struct VideoPage: Codable, Hashable {
    let cid: Int
    let page: Int
    let epid: Int?
    let from: String
    let part: String
}

struct UpSpaceReq: Codable, Hashable {
    let list: List
    struct List: Codable, Hashable {
        let vlist: [VListData]
        struct VListData: Codable, Hashable, DisplayData, PlayableData {
            let title: String
            let author: String
            let aid: Int
            let pic: URL?
            var ownerName: String {
                return author
            }

            var cid: Int { return 0 }
        }
    }
}

struct PlayerInfo: Codable {
    let last_play_time: Int
    let subtitle: SubtitleResp?
    let view_points: [ViewPoint]?
    let dm_mask: MaskInfo?
    let last_play_cid: Int
    let is_upower_exclusive: Bool?
    var playTimeInSecond: Int {
        last_play_time / 1000
    }

    class ViewPoint: Codable {
        let type: Int
        let from: TimeInterval
        let to: TimeInterval
        let content: String
        let imgUrl: URL?

        var imageData: Data?

        enum CodingKeys: String, CodingKey {
            case type, from, to, content, imgUrl
        }
    }

    struct MaskInfo: Codable {
        let mask_url: URL?
        let fps: Int
    }
}

struct VideoPlayURLInfo: Codable {
    let quality: Int
    let format: String
    let timelength: Int
    let accept_format: String
    let accept_description: [String]
    let accept_quality: [Int]
    let video_codecid: Int
    let support_formats: [SupportFormate]
    let dash: DashInfo
    let clip_info_list: [ClipInfo]?

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

    struct SupportFormate: Codable {
        let quality: Int
        let format: String
        let new_description: String
        let display_desc: String
        let codecs: [String]?
    }

    struct DashInfo: Codable {
        let duration: Int
        let minBufferTime: CGFloat
        let video: [DashMediaInfo]
        let audio: [DashMediaInfo]?
        let dolby: DolbyInfo?
        let flac: FlacInfo?
        struct DashMediaInfo: Codable, Hashable {
            let id: Int
            let base_url: String
            let backup_url: [String]?
            let bandwidth: Int
            let mime_type: String
            let codecs: String
            let width: Int?
            let height: Int?
            let frame_rate: String?
            let sar: String?
            let start_with_sap: Int?
            let segment_base: DashSegmentBase
            let codecid: Int?
        }

        struct DashSegmentBase: Codable, Hashable {
            let initialization: String
            let index_range: String
        }

        struct DolbyInfo: Codable {
            let type: Int
            let audio: [DashMediaInfo]?
        }

        struct FlacInfo: Codable {
            let display: Bool
            let audio: DashMediaInfo?
        }
    }
}

struct SubtitleContent: Codable, Hashable {
    let from: CGFloat
    let to: CGFloat
    let location: Int
    let content: String
}

extension URL {
    func addSchemeIfNeed() -> URL {
        if scheme == nil {
            return URL(string: "https:\(absoluteString)")!
        }
        return self
    }
}

