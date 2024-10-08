//
//  BilibiliVideoResourceLoaderDelegate.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import Alamofire
import AVFoundation
import SwiftyJSON
import UIKit

class BilibiliVideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    enum URLs {
        static let customScheme = "atv"
        static let customPrefix = customScheme + "://list/"
        static let play = customPrefix + "play"
        static let customSubtitlePrefix = customScheme + "://subtitle/"
        static let customDashPrefix = customScheme + "://dash/"
    }

    struct PlaybackInfo {
        let info: MediaItem
        let url: String
        let duration: Int
    }
    
    private var masterPlaylist = ""
    private let badRequestErrorCode = 455

    private var playlists = [String]()
    private var subtitles = [String: String]()
    private var videoInfo = [PlaybackInfo]()
    private var segmentInfoCache = SidxDownloader()
    private var hasAudioInMasterListAdded = false
    private var hasSubtitle = false
    private var hasPreferSubtitleAdded = false
    private(set) var isHDR = false
    
    deinit {

    }

    let videoCodecBlackList = ["avc1.640034"] // high 5.2 is not supported

    private func reset() {
        playlists.removeAll()
        masterPlaylist = """
        #EXTM3U
        #EXT-X-VERSION:6
        #EXT-X-INDEPENDENT-SEGMENTS


        """
    }

    private func addVideoPlayBackInfo(info: MediaItem, url: String, duration: Int) {
        guard !videoCodecBlackList.contains(info.codecs) else { return }
        let subtitlePlaceHolder = hasSubtitle ? ",SUBTITLES=\"subs\"" : ""
        let isDolby = info.id == MediaQualityEnum.quality_hdr_dolby.qn
        let isHDR10 = info.id == 125
        // hdr 10 formate exp: hev1.2.4.L156.90
        //  Codec.Profile.Flags.TierLevel.Constraints
        let isHDR = isDolby || isHDR10
        if isHDR {
            self.isHDR = true
        }
        var videoRange = isHDR ? "HLG" : "SDR"
        var codecs = info.codecs
        var supplementCodesc = ""
        // TODO: Need update all codecs with https://developer.apple.com/documentation/http_live_streaming/http_live_streaming_hls_authoring_specification_for_apple_devices/hls_authoring_specification_for_apple_devices_appendixes
        var framerate = info.frameRate ?? "25"
        if isHDR10 {
            videoRange = "PQ"
            if let value = Double(framerate), value <= 30 {} else {
                framerate = "30"
            }
        }
        if codecs == "dvh1.08.07" || codecs == "dvh1.08.03" {
            supplementCodesc = codecs + "/db4h"
            codecs = "hvc1.2.4.L153.b0"
            videoRange = "HLG"
        } else if codecs == "dvh1.08.06" {
            supplementCodesc = codecs + "/db1p"
            codecs = "hvc1.2.4.L150"
            videoRange = "PQ"
        } else if codecs.hasPrefix("dvh1.05") {
            videoRange = "PQ"
        } else if isHDR {
            print("unknown hdr codecs: \(codecs)")
        }

        if let value = Double(framerate), value >= 60 {
            framerate = "60"
        }

        if supplementCodesc.count > 0 {
            supplementCodesc = ",SUPPLEMENTAL-CODECS=\"\(supplementCodesc)\""
        }
        let content = """
        #EXT-X-STREAM-INF:AUDIO="audio"\(subtitlePlaceHolder),CODECS="\(codecs)"\(supplementCodesc),RESOLUTION=\(info.width)x\(info.height),FRAME-RATE=\(framerate),BANDWIDTH=\(info.bandwidth),VIDEO-RANGE=\(videoRange)
        \(URLs.customDashPrefix)\(videoInfo.count)?codec=\(info.codecs)&rate=\(info.frameRate ?? framerate)&width=\(info.width)&host=\(URL(string: url)?.host ?? "none")&range=\(info.id)

        """
        masterPlaylist.append(content)
        videoInfo.append(PlaybackInfo(info: info, url: url, duration: duration))
    }

    private func getVideoPlayList(info: PlaybackInfo) async -> String {
        let segment = await segmentInfoCache.sidx(from: info.info)
        let inits = info.info.SegmentBase!.Initialization.components(separatedBy: "-")
        guard let moovIdxStr = inits.last,
              let moovIdx = Int(moovIdxStr),
              let moovOffset = inits.first,
              let offsetStr = info.info.SegmentBase!.indexRange.components(separatedBy: "-").last,
              var offset = Int(offsetStr),
              let segment = segment
        else {
            return """
            #EXTM3U
            #EXT-X-VERSION:7
            #EXT-X-TARGETDURATION:\(info.duration)
            #EXT-X-MEDIA-SEQUENCE:1
            #EXT-X-INDEPENDENT-SEGMENTS
            #EXT-X-PLAYLIST-TYPE:VOD
            #EXTINF:\(info.duration)
            \(info.url)
            #EXT-X-ENDLIST
            """
        }

        var playList = """
        #EXTM3U
        #EXT-X-VERSION:7
        #EXT-X-TARGETDURATION:\(segment.maxSegmentDuration() ?? info.duration)
        #EXT-X-MEDIA-SEQUENCE:1
        #EXT-X-INDEPENDENT-SEGMENTS
        #EXT-X-PLAYLIST-TYPE:VOD
        #EXT-X-MAP:URI="\(info.url)",BYTERANGE="\(moovIdx + 1)@\(moovOffset)"

        """
        offset += 1
        for segInfo in segment.segments {
            let segStr = """
            #EXTINF:\(Double(segInfo.duration) / Double(segment.timescale)),
            #EXT-X-BYTERANGE:\(segInfo.size)@\(offset)
            \(info.url)

            """
            playList.append(segStr)
            offset += (segInfo.size)
        }

        playList.append("\n#EXT-X-ENDLIST")

        return playList
    }

    private func addAudioPlayBackInfo(info: MediaItem, url: String, duration: Int) {
        guard !videoCodecBlackList.contains(info.codecs) else { return }
        let defaultStr = !hasAudioInMasterListAdded ? "YES" : "NO"
        let content = """
        #EXT-X-MEDIA:TYPE=AUDIO,DEFAULT=\(defaultStr),GROUP-ID="audio",NAME="Main",URI="\(URLs.customDashPrefix)\(videoInfo.count)"

        """

        masterPlaylist.append(content)
        videoInfo.append(PlaybackInfo(info: info, url: url, duration: duration))
    }

    private func addAudioPlayBackInfo(codec: String, bandwidth: Int, duration: Int, url: String) {
        let defaultStr = !hasAudioInMasterListAdded ? "YES" : "NO"
        hasAudioInMasterListAdded = true
        let content = """
        #EXT-X-MEDIA:TYPE=AUDIO,DEFAULT=\(defaultStr),GROUP-ID="audio",NAME="Main",URI="\(URLs.customPrefix)\(playlists.count)"

        """
        masterPlaylist.append(content)

        let playList = """
        #EXTM3U
        #EXT-X-VERSION:6
        #EXT-X-TARGETDURATION:\(duration)
        #EXT-X-INDEPENDENT-SEGMENTS
        #EXT-X-MEDIA-SEQUENCE:1
        #EXT-X-PLAYLIST-TYPE:VOD
        #EXTINF:\(duration)
        \(url)
        #EXT-X-ENDLIST
        """
        playlists.append(playList)
    }

    private func addSubtitleData(lang: String, name: String, duration: Int, url: String) {
        var lang = lang
        var canBeDefault = !hasPreferSubtitleAdded
        if lang.hasPrefix("ai-") {
            lang = String(lang.dropFirst(3))
            canBeDefault = false
        }
        if canBeDefault {
            hasPreferSubtitleAdded = true
        }
        let defaultStr = canBeDefault ? "YES" : "NO"

        let master = """
        #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",LANGUAGE="\(lang)",NAME="\(name)",AUTOSELECT=\(defaultStr),DEFAULT=\(defaultStr),URI="\(URLs.customPrefix)\(playlists.count)"

        """
        masterPlaylist.append(master)

        let playList = """
        #EXTM3U
        #EXT-X-TARGETDURATION:\(duration)
        #EXT-X-VERSION:3
        #EXT-X-MEDIA-SEQUENCE:0
        #EXT-X-PLAYLIST-TYPE:VOD
        #EXTINF:\(duration),

        \(URLs.customSubtitlePrefix)\(url.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? url)
        #EXT-X-ENDLIST

        """
        playlists.append(playList)
    }

    func setBilibili(info: PlayUrlModel, subtitles: [SubtitleData]) {
        reset()
        hasSubtitle = subtitles.count > 0
        guard var videos = info.dash?.video, let dash = info.dash else { return }
        if Settings.preferAvc {
            let videosMap = Dictionary(grouping: videos, by: { $0.id })
            for (key, values) in videosMap {
                if values.contains(where: { !$0.isHevc }) {
                    videos.removeAll(where: { $0.id == key && $0.isHevc })
                }
            }
        }

        for video in videos {
            for url in video.playableURLs {
                addVideoPlayBackInfo(info: video, url: url, duration: dash.duration)
            }
        }

        if Settings.losslessAudio {
            if let audios = dash.dolby?.audio {
                for audio in audios {
                    for url in BVideoUrlUtils.sortUrls(base: audio.baseUrl, backup: audio.backupUrl) {
                        addAudioPlayBackInfo(info: audio, url: url, duration: dash.duration)
                    }
                }
            } else if let audio = dash.flac?.audio {
                for url in audio.playableURLs {
                    addAudioPlayBackInfo(info: audio, url: url, duration: dash.duration)
                }
            }
        }

        for audio in dash.audio ?? [] {
            for url in audio.playableURLs {
                addAudioPlayBackInfo(info: audio, url: url, duration: dash.duration)
            }
        }

        for subtitle in subtitles {
            addSubtitleData(lang: subtitle.lan, name: subtitle.lan_doc, duration: dash.duration, url: subtitle.url.absoluteString)
        }

        // i-frame
        if let video = videos.last, let url = video.playableURLs.first {
            let media = """
            #EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=\(video.bandwidth),RESOLUTION=\(video.width)x\(video.height),URI="\(URLs.customDashPrefix)\(videoInfo.count)"

            """
            masterPlaylist.append(media)
            videoInfo.append(PlaybackInfo(info: video, url: url, duration: dash.duration))
        }

        masterPlaylist.append("\n#EXT-X-ENDLIST\n")

        print("masterPlaylist:", masterPlaylist)
    }

    private func reportError(_ loadingRequest: AVAssetResourceLoadingRequest, withErrorCode error: Int) {
        loadingRequest.finishLoading(with: NSError(domain: NSURLErrorDomain, code: error, userInfo: nil))
    }

    private func report(_ loadingRequest: AVAssetResourceLoadingRequest, content: String) {
        if let data = content.data(using: .utf8) {
            loadingRequest.dataRequest?.respond(with: data)
            loadingRequest.finishLoading()
        } else {
            reportError(loadingRequest, withErrorCode: badRequestErrorCode)
        }
    }

    func resourceLoader(_: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool
    {
        guard let scheme = loadingRequest.request.url?.scheme, scheme == URLs.customScheme else {
            return false
        }

        DispatchQueue.main.async {
            self.handleCustomPlaylistRequest(loadingRequest)
        }
        return true
    }
}

private extension BilibiliVideoResourceLoaderDelegate {
    func handleCustomPlaylistRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        guard let customUrl = loadingRequest.request.url else {
            reportError(loadingRequest, withErrorCode: badRequestErrorCode)
            return
        }
        let urlStr = customUrl.absoluteString
        print("handleCustomPlaylistRequest: \(urlStr)")
        if urlStr == URLs.play {
            report(loadingRequest, content: masterPlaylist)
            return
        }

        if urlStr.hasPrefix(URLs.customPrefix), let index = Int(customUrl.lastPathComponent) {
            let playlist = playlists[index]
            report(loadingRequest, content: playlist)
            return
        }
        if urlStr.hasPrefix(URLs.customDashPrefix), let index = Int(customUrl.lastPathComponent) {
            let info = videoInfo[index]
            Task {
                report(loadingRequest, content: await getVideoPlayList(info: info))
            }
        }
        if urlStr.hasPrefix(URLs.customSubtitlePrefix) {
            let url = String(urlStr.dropFirst(URLs.customSubtitlePrefix.count))
            let req = url.removingPercentEncoding ?? url
            Task {
                do {
                    if let content = subtitles[req] {
                        report(loadingRequest, content: content)
                    } else {
                        let content = try await ApiRequest.requestSubtitle(url: URL(string: req)!)
                        let vtt = BVideoUrlUtils.convertToVTT(subtitle: content)
                        subtitles[req] = vtt
                        report(loadingRequest, content: vtt)
                    }
                    return
                } catch let err {
                    loadingRequest.finishLoading(with: err)
                }
            }
            return
        }
        print("handle loading", customUrl)
    }

}

actor SidxDownloader {
    private enum CacheEntry {
        case inProgress(Task<SidxParseUtil.Sidx?, Never>)
        case ready(SidxParseUtil.Sidx?)
    }

    private var cache: [MediaItem: CacheEntry] = [:]

    func sidx(from info: MediaItem) async -> SidxParseUtil.Sidx? {
        if let cached = cache[info] {
            switch cached {
            case let .ready(sidx):
                print("sidx cache hit \(info.id)")
                return sidx
            case let .inProgress(sidx):
                print("sidx cache wait \(info.id)")
                return await sidx.value
            }
        }

        let task = Task {
            await downloadSidx(info: info)
        }

        cache[info] = .inProgress(task)

        let sidx = await task.value
        cache[info] = .ready(sidx)
        print("get sidx \(info.id)")
        return sidx
    }

    private func downloadSidx(info: MediaItem) async -> SidxParseUtil.Sidx? {
        let range = info.SegmentBase!.indexRange
        let url = info.playableURLs.first ?? info.baseUrl
        if let res = try? await AF.request(url,
                                           headers: ["Range": "bytes=\(range)",
                                                     "Referer": "https://www.bilibili.com/"])
            .serializingData().result.get()
        {
            let segment = SidxParseUtil.processIndexData(data: res)
            return segment
        }
        return nil
    }
}
