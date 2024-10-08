//
//  DanmakuTextCellModel.swift
//  bili
//
//  Created by DJ on 2024/9/5.
//

import Foundation
import SwiftyJSON
import UIKit
import DanmakuKit

class DanmakuTextCellModel: DanmakuCellModel, Equatable {
    var identifier = ""

    var text = ""
    var color: UIColor = .white
    var font = UIFont.systemFont(ofSize: Settings.danmuSize.size)

    var cellClass: DanmakuCell.Type {
        return DanmakuTextCell.self
    }

    var size: CGSize = .zero

    var track: UInt?

    var displayTime: Double = Settings.danmuDuration

    var type: DanmakuCellType = .floating

    var isPause = false

    func calculateSize() {
        size = NSString(string: text).boundingRect(with: CGSize(width: CGFloat(Float.infinity
        ), height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
    }

    static func == (lhs: DanmakuTextCellModel, rhs: DanmakuTextCellModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func isEqual(to cellModel: DanmakuCellModel) -> Bool {
        return identifier == cellModel.identifier
    }

    init(str: String) {
        text = str
        type = .floating
        calculateSize()
    }

    init(dm: Danmu) {
        text = dm.isUp ? "up: " + dm.text : dm.text // TODO: UP主弹幕样式
        color = UIColor.white

        switch dm.mode {
        case 4:
            type = .bottom
        case 5:
            type = .top
        default:
            type = .floating
        }

        calculateSize()
    }
}
