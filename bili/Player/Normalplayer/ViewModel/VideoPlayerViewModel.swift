//
//  VideoPlayerViewModel.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import Combine
import UIKit

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

struct PlayerDetailData {
    let aid: Int
    let cid: Int
    let epid: Int? // 港澳台解锁需要
    let isBangumi: Bool

    var playerStartPos: Int?
    var detail: VideoDetail?
    var clips: [PlayUrlModel.ClipInfo]?
    var playerInfo: PlayerInfo?
    var videoPlayURLInfo: PlayUrlModel
}

class VideoPlayerViewModel {
    var onPluginReady = PassthroughSubject<[CommonPlayerPlugin], String>()
    var onPluginRemove = PassthroughSubject<CommonPlayerPlugin, Never>()
    var onExit: (() -> Void)?
//    var nextProvider: VideoNextProvider?

    private var playInfo: PlayInfo
    private let danmuProvider = VideoDanmuProvider()
    private var videoDetail: VideoDetail?
    private var cancellable = Set<AnyCancellable>()
    private var playPlugin: CommonPlayerPlugin?

    init(playInfo: PlayInfo) {
        self.playInfo = playInfo
    }

    func load() async {
        do {
            let data = try await loadVideoInfo()
            let plugin = await generatePlayerPlugin(data)
            onPluginReady.send(plugin)
        } catch let err {
            onPluginReady.send(completion: .failure(err.localizedDescription))
        }
    }

    private func loadVideoInfo() async throws -> PlayerDetailData {
//        try await initPlayInfo()
        let data = try await fetchVideoData()
        await danmuProvider.initVideo(cid: data.cid, startPos: data.playerStartPos ?? 0)
        return data
    }

    private func initPlayInfo() async throws {
//        if !playInfo.isCidVaild {
//            playInfo.cid = try await WebRequest.requestCid(aid: playInfo.aid)
//        }
    }

    private func updateVideoDetailIfNeeded() async {
        if videoDetail == nil {
            videoDetail = try? await ApiRequest.requestGetObj(QApi.videoIntroDetail, parameters: ["aid": playInfo.aid])
        }
    }

    private func fetchVideoData() async throws -> PlayerDetailData {
        assert(playInfo.cid ?? 0 > 0)
        let aid = playInfo.aid
        let cid = playInfo.cid!
        async let infoReq: PlayerInfo? = try? ApiRequest.requestGetObj(QApi.getSubtitleConfig, parameters: ["aid": aid, "cid": cid])
        async let detailUpdate: () = updateVideoDetailIfNeeded()
        do {
            let playData: PlayUrlModel
            var clipInfos: [PlayUrlModel.ClipInfo]?

            if playInfo.isBangumi {
                do {
                    playData = try await ApiRequest.requestGetObj(QApi.pcgPlayUrl, parameters: ["avid": aid, "cid": cid, "qn": Settings.mediaQuality.qn, "type": "", "fnver": 0, "fnval": Settings.mediaQuality.fnval, "otype": "json"])
                } catch let err as RequestError {
                    if case let .statusFail(code, _) = err,
                       code == -404 || code == -10403,
                       let data = try await fetchAreaLimitPcgVideoData()
                    {
                        playData = data
                    } else {
                        throw err
                    }
                }

                clipInfos = playData.clip_info_list
            } else {
                playData = try await ApiRequest.videoUrl(bvid: QUtils.av2bv(avid: UInt64(aid)), cid: cid)
            }

            let info = await infoReq
            _ = await detailUpdate

            var detail = PlayerDetailData(aid: playInfo.aid, cid: playInfo.cid!, epid: playInfo.epid, isBangumi: playInfo.isBangumi, detail: videoDetail, clips: clipInfos, playerInfo: info, videoPlayURLInfo: playData)

            if let info, info.last_play_cid == cid, (playData.dash?.duration ?? 0) - info.playTimeInSecond > 5, Settings.continuePlay {
                detail.playerStartPos = info.playTimeInSecond
            }

            return detail

        } catch let err {
            if case let .statusFail(code, message) = err as? RequestError {
                throw "\(code) \(message)，可能需要大会员"
            } else if await infoReq?.is_upower_exclusive == true {
                throw "该视频为充电专属视频 \(err)"
            } else {
                throw err
            }
        }
    }

    private func playNext(newPlayInfo: PlayInfo) {
        playInfo = newPlayInfo
        if let playPlugin {
            onPluginRemove.send(playPlugin)
        }
        Task {
            do {
                let data = try await loadVideoInfo()
                let player = BVideoPlayPlugin(detailData: data)
                onPluginReady.send([player])
            } catch let err {
                onPluginReady.send(completion: .failure(err.localizedDescription))
            }
        }
    }

    @MainActor private func generatePlayerPlugin(_ data: PlayerDetailData) async -> [CommonPlayerPlugin] {
        let player = BVideoPlayPlugin(detailData: data)
        let danmu = DanmuViewPlugin(provider: danmuProvider)
//        let debug = DebugPlugin()
//        let playSpeed = SpeedChangerPlugin()
//        playSpeed.$currentPlaySpeed.sink { [weak danmu] speed in
//            danmu?.danMuView.playingSpeed = speed.value
//        }.store(in: &cancellable)

//        let playlist = VideoPlayListPlugin(nextProvider: nextProvider)
//        playlist.onPlayEnd = { [weak self] in
//            self?.onExit?()
//        }
//        playlist.onPlayNextWithInfo = {
//            [weak self] info in
//            guard let self else { return }
//            playNext(newPlayInfo: info)
//        }

        playPlugin = player

//        var plugins: [CommonPlayerPlugin] = [player, danmu, playSpeed, upnp, debug, playlist]
        var plugins: [CommonPlayerPlugin] = [player, danmu]
        if let clips = data.clips {
            let clip = BVideoClipsPlugin(clipInfos: clips)
            plugins.append(clip)
        }

        if let detail = data.detail {
            let info = BVideoInfoPlugin(title: detail.title, subTitle: detail.ownerName, desp: detail.View.desc, pic: detail.pic, viewPoints: data.playerInfo?.view_points)
            plugins.append(info)
        }

        return plugins
    }
}

// 港澳台解锁
extension VideoPlayerViewModel {
    private func fetchAreaLimitPcgVideoData() async throws -> PlayUrlModel? {
        guard Settings.areaLimitUnlock else { return nil }
        guard let epid = playInfo.epid, epid > 0 else { return nil }

//        let season = try await WebRequest.requestBangumiSeasonView(epid: epid)
//        let checkTitle = season.title.contains("僅") ? season.title : season.series_title
//        let checkAreaList = parseAreaByTitle(title: checkTitle)
//        guard !checkAreaList.isEmpty else { return nil }
//
//        let playData = try await requestAreaLimitPcgPlayUrl(epid: epid, cid: playInfo.cid!, areaList: checkAreaList)
        return nil//playData
    }

    private func requestAreaLimitPcgPlayUrl(epid: Int, cid: Int, areaList: [String]) async throws -> PlayUrlModel? {
        for area in areaList {
            do {
                return nil//try await WebRequest.requestAreaLimitPcgPlayUrl(epid: epid, cid: cid, area: area)
            } catch let err {
                if area == areaList.last {
                    throw err
                } else {
                    print(err)
                }
            }
        }
        return nil
    }

    private func parseAreaByTitle(title: String) -> [String] {
        if title.isMatch(pattern: "[仅|僅].*[东南亚|其他]") {
            // TODO: 未支持
            return []
        }

        var areas: [String] = []
        if title.isMatch(pattern: "僅.*台") {
            areas.append("tw")
        }
        if title.isMatch(pattern: "僅.*港") {
            areas.append("hk")
        }

        if areas.isEmpty {
            // 标题没有地区限制信息，返回尝试检测的区域
            return ["tw", "hk"]
        } else {
            return areas
        }
    }
}
