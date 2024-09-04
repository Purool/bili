//
//  String+ET.swift
//  bili
//
//  Created by DJ on 2024/9/4.
//

import Foundation

extension String {
    static func += (lhs: inout String, rhs: Int) {
        if let number = Int(lhs) {
            lhs = String(number + rhs)
        }
    }

    static func -= (lhs: inout String, rhs: Int) {
        if let number = Int(lhs) {
            lhs = String(number - rhs)
        }
    }

    func isMatch(pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, utf16.count)) != nil
    }
}
