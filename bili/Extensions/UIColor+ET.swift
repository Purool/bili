//
//  UIColor+ET.swift
//  bili
//
//  Created by DJ on 2024/8/13.
//

import UIKit

extension UIColor{
    class func etColor(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat = 1.0) -> UIColor {
       return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    class func hexColor(str: String?, alpha: CGFloat = 1.0) -> UIColor {

        let scanner = Scanner(string: str ?? "")
        var hexNum: UInt32 = 0
        if !scanner.scanHexInt32(UnsafeMutablePointer<UInt32>(mutating: &hexNum)) {
            print("16进制转UIColor, hexString为空")
            return UIColor.red
        }
        return etColor(r: CGFloat((hexNum & 0xff0000) >> 16), g: CGFloat((hexNum & 0x00ff00) >> 8), b: CGFloat(hexNum & 0x0000ff), a: alpha)
    }
}
