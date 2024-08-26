//
//  Utils.swift
//  bili
//
//  Created by DJ on 2024/8/21.
//

import Foundation
struct QUtils {
    static func timeFormat(_ time: Any) -> String {
        // 1小时内
        if let timeString = time as? String, timeString.contains(":") {
            return timeString
        }
        
        if let timeInt = time as? Int {
            if timeInt < 3600 {
                if timeInt == 0 {
                    return "00:00"
                }
                let minute = timeInt / 60
                let res = Double(timeInt) / 60.0
                
                if Double(minute) != res {
                    let seconds = timeInt - minute * 60
                    return String(format: "%02d:%02d", minute, seconds)
                } else {
                    return String(format: "%d:00", minute)
                }
            } else {
                let hour = timeInt / 3600
                let hourStr = String(format: "%02d", hour)
                let remainingTime = timeInt - hour * 3600
                let remainingTimeStr = timeFormat(remainingTime)
                return "\(hourStr):\(remainingTimeStr)"
            }
        }
        
        return "-x"
    }
    
    static func numFormat(_ number: Any?) -> String {
        guard let number = number else {
            return "0"
        }
        
        if let numberString = number as? String {
            return numberString
        }
        
        if let numberDouble = number as? Double {
            let res = numberDouble / 10000
            if Int(res) >= 1 {
                return String(format: "%.1f万", res)
            } else {
                return String(numberDouble)
            }
        }
        
        return String(describing: number)
    }
    
    static func makeHeroTag(_ v: String) -> String {
        let randomInt = Int.random(in: 0..<9999)
        return "\(v)\(randomInt)"
    }

    
    //MARK: IdUtils
    static fileprivate let XOR_CODE: UInt64 = 23442827791579
    static fileprivate let MASK_CODE: UInt64 = 2251799813685247
    static fileprivate let MAX_AID: UInt64 = 1 << 51

    static fileprivate let data: [UInt8] = [70, 99, 119, 65, 80, 78, 75, 84, 77, 117, 103, 51, 71, 86, 53, 76, 106, 55, 69, 74, 110, 72, 112, 87, 115, 120, 52, 116, 98, 56, 104, 97, 89, 101, 118, 105, 113, 66, 122, 54, 114, 107, 67, 121, 49, 50, 109, 85, 83, 68, 81, 88, 57, 82, 100, 111, 90, 102]

    static fileprivate let BASE: UInt64 = 58
    static fileprivate let BV_LEN: Int = 12
    static fileprivate let PREFIX: String = "BV1"

    static func av2bv(avid: UInt64) -> String {
        var bytes: [UInt8] = [66, 86, 49, 48, 48, 48, 48, 48, 48, 48, 48, 48]
        var bvIdx = BV_LEN - 1
        var tmp = (MAX_AID | avid) ^ XOR_CODE

        while tmp != 0 {
            bytes[bvIdx] = data[Int(tmp % BASE)]
            tmp /= BASE
            bvIdx -= 1
        }

        bytes.swapAt(3, 9)
        bytes.swapAt(4, 7)

        return String(decoding: bytes, as: UTF8.self)
    }

    static func bv2av(bvid: String) -> UInt64 {
        let fixedBvid: String
        if bvid.hasPrefix("BV") {
            fixedBvid = bvid
        } else {
            fixedBvid = "BV" + bvid
        }
        var bvidArray = Array(fixedBvid.utf8)

        bvidArray.swapAt(3, 9)
        bvidArray.swapAt(4, 7)

        let trimmedBvid = String(decoding: bvidArray[3...], as: UTF8.self)

        var tmp: UInt64 = 0

        for char in trimmedBvid {
            if let idx = data.firstIndex(of: char.utf8.first!) {
                tmp = tmp * BASE + UInt64(idx)
            }
        }

        return (tmp & MASK_CODE) ^ XOR_CODE
    }

}

