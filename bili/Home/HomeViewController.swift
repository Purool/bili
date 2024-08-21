//
//  HomeViewController.swift
//  zhnbilibili
//
//  Created by zhn on 16/11/21.
//  Copyright © 2016年 zhn. All rights reserved.
//

import UIKit
import MJRefresh
import HMSegmentedControl

class HomeViewController: QBaseViewController {
    var customNavView = UIView()
    
    lazy var segmentedControl: HMSegmentedControl = {[unowned self] in
        let segmentedView = HMSegmentedControl(sectionTitles: ["热门","推荐","番剧"])
        segmentedView.frame = CGRect(x: (kScreenWidth - 180)/2, y: kTopMargin, width: 180, height: 30)
        segmentedView.backgroundColor = .clear
        segmentedView.selectionIndicatorColor = .hexColor(str: "ff6699")
        segmentedView.selectionIndicatorHeight = 3
        segmentedView.selectionIndicatorLocation = .bottom
        segmentedView.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hexColor(str: "ff6699"),
                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
        segmentedView.selectedSegmentIndex = 1
        segmentedView.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hexColor(str: "61666d"),
                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        segmentedView.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        return segmentedView
    }()
    
    lazy var contentScrollView: UIScrollView = {[unowned self] in
        let contentScrollView = UIScrollView()
        contentScrollView.frame = CGRect(x: 0, y: CGRectGetMaxY(segmentedControl.frame), width: kScreenWidth, height: kScreenHeight - CGRectGetMaxY(segmentedControl.frame))
        contentScrollView.contentSize = CGSize(width: kScreenWidth*3, height: contentScrollView.mj_h)
        contentScrollView.isPagingEnabled = true
//        contentScrollView.backgroundColor = knavibarcolor
        return contentScrollView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupUI()
        print(kScreenHeight)
        // 默认选中中间的推荐
        self.contentScrollView.contentOffset = CGPoint(x: kScreenWidth, y: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController {
    
    fileprivate func setupUI(){
        customNavView.backgroundColor = .blue
        view.addSubview(customNavView)
        customNavView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kTopMargin)
        
        view.addSubview(segmentedControl)
        view.addSubview(contentScrollView)
//        view.addSubview(titleMenu)
        
        
        addChildVCs()

    }
    
    fileprivate func addChildVCs() {
        
        // 1 直播
        let liveVC = HomeLiveShowViewController()
        self.addChild(liveVC)
        contentScrollView.addSubview(liveVC.view)
        liveVC.view.frame = CGRect(x: 0, y: 0, width: view.mj_w, height: kScreenHeight - CGRectGetMaxY(segmentedControl.frame))
        
        // 2 推荐
        let recommondVC = HomeRecommendViewController()
        self.addChild(recommondVC)
        contentScrollView.addSubview(recommondVC.view)
        recommondVC.view.frame = CGRect(x: view.mj_w, y: 0, width: view.mj_w, height: kScreenHeight - CGRectGetMaxY(segmentedControl.frame))
        
        // 3 番剧
        let serialVC = HomebangumiViewController()
        self.addChild(serialVC)
        contentScrollView.addSubview(serialVC.view)
        serialVC.view.frame = CGRect(x: view.mj_w*2, y: 0, width: view.mj_w, height: kScreenHeight - CGRectGetMaxY(segmentedControl.frame))
    }
    
    
    @objc func segmentedControlChangedValue(segmentedControl: HMSegmentedControl) {
        print("Selected index \(segmentedControl.selectedSegmentIndex)")
        UIView.animate(withDuration: 0.2) {
            self.customNavView.mj_y -= 44
            self.segmentedControl.mj_y -= 44
            self.contentScrollView.mj_y -= 44
        } completion: { status in
            if status {
                print("ok")
            }
        }
        self.contentScrollView.scrollRectToVisible(CGRect(x: kScreenWidth * CGFloat(segmentedControl.selectedSegmentIndex), y: 0, width: kScreenWidth, height: 100), animated: true)
    }
}

extension HomeViewController {
    @objc func showLive() {
        DispatchQueue.main.async {
          self.contentScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: kScreenWidth, height: 100), animated: false)
        }
    }
}

