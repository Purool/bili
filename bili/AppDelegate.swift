//
//  AppDelegate.swift
//  bili
//
//  Created by DJ on 2024/8/13.
//

import UIKit
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化控制器
        initMainController()
        AF.sessionConfiguration.timeoutIntervalForRequest = 15
        AF.sessionConfiguration.timeoutIntervalForResource = 15
        AF.sessionConfiguration.httpMaximumConnectionsPerHost = 3
        return true
    }

    
    fileprivate func initMainController() {
        let keyWindow =  UIWindow(frame: UIScreen.main.bounds)
        window = keyWindow
        window?.makeKeyAndVisible()
        let mainController = MainTabbarViewController()
        window?.rootViewController = mainController
    }

}

