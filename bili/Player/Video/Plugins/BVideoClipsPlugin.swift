//
//  BVideoClipsPlugin.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import AVKit

class BVideoClipsPlugin: NSObject, CommonPlayerPlugin {
    let clipInfos: [PlayUrlModel.ClipInfo]

    private var observers = [Any]()
    private weak var playerVC: AVPlayerViewController?

    init(clipInfos: [PlayUrlModel.ClipInfo]) {
        self.clipInfos = clipInfos
    }

    func playerDidLoad(playerVC: AVPlayerViewController) {
        self.playerVC = playerVC
    }

    func playerWillStart(player: AVPlayer) {
        for clip in clipInfos {
            let start = CMTime(seconds: clip.start, preferredTimescale: 1)
            let end = CMTime(seconds: clip.end, preferredTimescale: 1)
            let startObserver = player.addBoundaryTimeObserver(forTimes: [NSValue(time: start)], queue: .main) {
                [weak player, weak self] in
                let action = {
                    clip.skipped = true
                    player?.seek(to: CMTime(seconds: Double(clip.end), preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                }
                if clip.skipped == true, Settings.autoSkip {
                    action()
                } else {
                    let action = UIAction(title: clip.customText) { _ in action() }
//                    self?.playerVC?.contextualActions = [action]
                }
            }
            observers.append(startObserver)

            let endObserver = player.addBoundaryTimeObserver(forTimes: [NSValue(time: end)], queue: .main) {
                [weak self] in
                self?.playerVC?.accessibilityCustomActions = []
            }
            observers.append(endObserver)
        }
    }

    func playerDidCleanUp(player: AVPlayer) {
        for observer in observers {
            player.removeTimeObserver(observer)
        }
    }
}
