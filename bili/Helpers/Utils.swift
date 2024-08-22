//
//  Utils.swift
//  bili
//
//  Created by DJ on 2024/8/21.
//

import Foundation
enum QUtils {
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
}

