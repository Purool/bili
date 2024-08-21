//
//  configs.swift
//  zhnbilibili
//
//  Created by zhn on 16/12/1.
//  Copyright © 2016年 zhn. All rights reserved.
//

import UIKit
/*
 010f894570:
 "0ac1706090f12cfc"
 "bilibili.qqwallet"
 "unionpay.bilibili"
 "wxcb8d4298c6a09bcb"
 "https://i0.hdslb.com/bfs"
 "27eb53fc9058f8c3"
 "c2ed53a74eeefe3cf99fbd01d8c9c375"
 "cdb18f9752ab7a1d09d5941c62893b0c"
 
 */
// MARK: - 长宽
// 自定义tabbar的高度
let kHomeHeaderHeight:CGFloat = 77
// 轮播的高度
let kcarouselHeight:CGFloat = 110
let knormalHeadeHeight:CGFloat = 40
// 圆角
let kcellcornerradius:CGFloat = 6
let cellIconHeight:CGFloat = 8
let cellIconWidth:CGFloat = 10

// MARK: - 字体
// cell 标题的字体
let knormalItemCellTitleFont = UIFont.systemFont(ofSize: 13)
// cell header的标题的字体
let kcollecviewHeaderTitleFont = UIFont.systemFont(ofSize: 15)
// cell 内提示的字体
let celldetailLabelsFont = UIFont.systemFont(ofSize: 11)

// MARK: - 颜色
// navibar的颜色
let knavibarcolor = UIColor.etColor(r: 252, g: 132, b: 164, a: 1)
let kmainColor = UIColor.etColor(r: 252, g: 132, b: 164, a: 1)
let ktableCellLineColor = UIColor.etColor(r: 188, g: 187, b: 193, a: 1)
// 首页的head的右边的标题的颜色
let khomeHeadrightLabeltextColor = UIColor.etColor(r: 163, g: 163, b: 163, a: 1)
// 首页排行榜文字颜色
let knormalHeartextLabelHotColor = UIColor.etColor(r: 254, g: 192, b: 50, a: 1)
// 首页背景颜色
let kHomeBackColor = UIColor.etColor(r: 244, g: 244, b: 244, a: 1)
// 分割线的颜色
let kcellLineColor = UIColor.etColor(r: 225, g: 225, b: 225, a: 1)

let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
/// 状态栏的高度(竖屏限定)
let kStatusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20

/// 导航栏的高度(竖屏限定)
let kNavigationBarHeight: CGFloat = 44.0

/// 整体顶部间距(竖屏限定)
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

////适配iPhoneX
//获取底部的安全距离，全面屏手机为34pt，非全面屏手机为0pt
//底部的安全距离
let kSafeBottomMargin: CGFloat = window?.safeAreaInsets.bottom ?? 0

/// tabbar的高度
let kTabbarHeight: CGFloat = 49

/// 屏宽
let kScreenWidth = UIScreen.main.bounds.width

/// 屏宽的9/16
let kScreenWidth_9_16 = UIScreen.main.bounds.width / 16.0 * 9

/// 屏高
let kScreenHeight = UIScreen.main.bounds.height

/// 整体底部间距
let kBottomMargin = kSafeBottomMargin + kTabbarHeight


//顶部的安全距离
let topSafeAreaHeight: CGFloat = (kSafeBottomMargin == 0 ? 0 : 24)

//状态栏高度
let statusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0

//导航栏高度
let navigationHeight: CGFloat = (kSafeBottomMargin == 0 ? 64 :88)

//tabbar 高度
let tabBarHeight: CGFloat = (kSafeBottomMargin + 49)


enum HttpString {
    static let baseUrl = "https://www.bilibili.com"
    static let apiBaseUrl = "https://api.bilibili.com"
    static let tUrl = "https://api.vc.bilibili.com"
    static let appBaseUrl = "https://app.bilibili.com"
    static let liveBaseUrl = "https://api.live.bilibili.com"
    static let passBaseUrl = "https://passport.bilibili.com"
    static let validateStatusCodes: [Int]  = [
        302,
        304,
        307,
        400,
        401,
        403,
        404,
        405,
        409,
        412,
        500,
        503,
        504,
        509,
        616,
        617,
        625,
        626,
        628,
        629,
        632,
        643,
        650,
        652,
        658,
        662,
        688,
        689,
        701,
        799,
        8888
    ];
}
