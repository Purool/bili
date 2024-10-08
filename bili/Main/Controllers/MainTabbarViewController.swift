//
//  MainTabbarViewController.swift
//  zhnbilibili
//
//  Created by zhn on 16/11/21.
//  Copyright © 2016年 zhn. All rights reserved.
//

import UIKit

class MainTabbarViewController: UITabBarController,UITabBarControllerDelegate {

    struct maintabbarItem {
        var title = ""
        var image = ""
        var selectedImage = ""
    }
    
    
    lazy var controllersArray: [UIViewController] = {
        var controllers = [UIViewController]()
        
        // 1.
        let item1 = QUINavigationController(rootViewController: HomeViewController())
        controllers.append(item1)
        // 2.
//        let item2 = QUINavigationController(rootViewController: ZHNzoneViewController())
//        controllers.append(item2)
//        // 3
//        let item3 = QUINavigationController(rootViewController: ZHNbilibiliFocuseViewController())
//        controllers.append(item3)
//        // 4
//        let item4 = QUINavigationController(rootViewController: ZHNbilibiliFindViewController())
//        controllers.append(item4)
//        // 5
        
        let item5 = QUINavigationController(rootViewController: BBPhoneUserCenterVC())
        controllers.append(item5)
        
        return controllers
    }()
    
    lazy var tabbarItemsArray: [maintabbarItem] = {
        var itemsArray = [maintabbarItem]()
        
        // 1. 首页
        let item1 = maintabbarItem(title: "首页", image: "home_home_tab", selectedImage: "home_home_tab_s")
        itemsArray.append(item1)
        
        // 2. 分区
        let item2 = maintabbarItem(title: "分区", image: "home_category_tab", selectedImage: "home_category_tab_s")
        itemsArray.append(item2)
        
        // 3. 关注
        let item3 = maintabbarItem(title: "关注", image: "home_attention_tab", selectedImage: "home_attention_tab_s")
        itemsArray.append(item3)
        
        // 4. 发现
        let item4 = maintabbarItem(title: "发现", image: "home_discovery_tab", selectedImage: "home_discovery_tab_s")
        itemsArray.append(item4)
        
        // 5. 我的
        let item5 = maintabbarItem(title: "我的", image: "home_mine_tab", selectedImage: "home_mine_tab_s")
        itemsArray.append(item5)
        
        return itemsArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear    //removing navigationbar 1 px bottom border.
//            self.tabBar.appearance().standardAppearance = appearance
//            self.tabBar.appearance().scrollEdgeAppearance = appearance
            self.tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = appearance
            }
        }
        
        // 1. 添加控制器
        for (index,value) in controllersArray.enumerated() {
            let item = tabbarItemsArray[index]
//            value.tabBarItem.title = item.title
            value.tabBarItem.image = UIImage(named: item.image)
            value.tabBarItem.selectedImage = UIImage(named: item.selectedImage)
            //让只显示图片的时候图片居中显示 （bilibili包里面拿下来的图片是默认带字的）
            value.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            self.addChild(value)
        }
        
        self.tabBar.tintColor = .gray//temp
    }
    
    // 和statusbar的旋转相呼应
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
