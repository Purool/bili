//
//  BVideoPlayPlugin.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import AVKit

class BVideoPlayPlugin: NSObject, CommonPlayerPlugin {
    private weak var playerVC: AVPlayerViewController?
    private var playerDelegate: BilibiliVideoResourceLoaderDelegate?
    private let playData: PlayerDetailData

    init(detailData: PlayerDetailData) {
        playData = detailData
    }

    func playerDidLoad(playerVC: AVPlayerViewController) {
        self.playerVC = playerVC
        playerVC.player = nil
//        playerVC.appliesPreferredDisplayCriteriaAutomatically = Settings.contentMatch
        Task {
            try? await playmedia(urlInfo: playData.videoPlayURLInfo, playerInfo: playData.playerInfo)
        }
    }

    func playerWillStart(player: AVPlayer) {
        if let playerStartPos = playData.playerStartPos {
            player.seek(to: CMTime(seconds: Double(playerStartPos), preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    func playerDidDismiss(playerVC: AVPlayerViewController) {
        guard let currentTime = playerVC.player?.currentTime().seconds, currentTime > 0 else { return }
        ApiRequest.requestJSON(QApi.reportHistory, parameters: ["aid": playData.aid, "cid": playData.cid, "progress": currentTime])
    }

    @MainActor
    private func playmedia(urlInfo: PlayUrlModel, playerInfo: PlayerInfo?) async throws {
        let playURL = URL(string: BilibiliVideoResourceLoaderDelegate.URLs.play)!
        let headers: [String: String] = [
            "User-Agent": ApiRequest.Keys.userAgent,
            "Referer": ApiRequest.Keys.referer(for: playData.aid),
        ]
        let asset = AVURLAsset(url: playURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        playerDelegate = BilibiliVideoResourceLoaderDelegate()
        playerDelegate?.setBilibili(info: urlInfo, subtitles: playerInfo?.subtitle?.subtitles ?? [], aid: playData.aid)
        if Settings.contentMatchOnlyInHDR {
            if playerDelegate?.isHDR != true {
//                playerVC?.appliesPreferredDisplayCriteriaAutomatically = false
            }
        }
        asset.resourceLoader.setDelegate(playerDelegate, queue: DispatchQueue(label: "loader"))
        if #available(iOS 15, *) {
            let playable = try await asset.load(.isPlayable)
            if !playable {
                throw "加载资源失败"
            }
        }
        let canPlay = asset.tracks(withMediaType: .video).isEmpty
        await prepare(toPlay: asset)
    }

    @MainActor
    func prepare(toPlay asset: AVURLAsset) async {
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        playerVC?.player = player
    }
}
