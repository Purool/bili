//
//  BUpnpPlugin.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import AVFoundation
import Foundation

class BUpnpPlugin: NSObject, CommonPlayerPlugin {
    let duration: Int?
    weak var player: AVPlayer?

    init(duration: Int?) {
        self.duration = duration
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func playerWillStart(player: AVPlayer) {
        print("playerWillStart")
    }

    func playerDidStart(player: AVPlayer) {
        print("playerDidStart")
    }

    func playerDidPause(player: AVPlayer) {
        print("playerDidPause")
    }

    func playerDidEnd(player: AVPlayer) {
        print("playerDidEnd")
    }

    func playerDidFail(player: AVPlayer) {
        print("playerDidFail")
    }

    func playerDidCleanUp(player: AVPlayer) {
        print("playerDidCleanUp")
    }
}
