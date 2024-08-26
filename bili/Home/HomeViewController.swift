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
import RxSwift
import RxCocoa

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
        contentScrollView.bounces = false
//        contentScrollView.isDirectionalLockEnabled = false
//        contentScrollView.backgroundColor = knavibarcolor
        return contentScrollView
    }()
    
    lazy var avatarCoverBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 8, y: 0, width: kNavigationBarHeight, height: kNavigationBarHeight)
        button.setImage(UIImage(named: "common_profile_default"), for: .normal)
        button.layer.cornerRadius = 22
        return button
    }()
    
    lazy var searchBgBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 64, y: 7, width: kScreenWidth - 64 - 10 - kNavigationBarHeight, height: 30)
        button.backgroundColor = .hexColor(str: "f1f2f3")
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0.67
        button.layer.borderColor = UIColor.hexColor(str: "9499a0").cgColor
        button.tintColor = .hexColor(str: "61666d")
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle(" 么么么。。。", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.setTitleColor(.hexColor(str: "61666d"), for: .normal)
        return button
    }()
    
    lazy var messageBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: kScreenWidth - kNavigationBarHeight, y: 7, width: kNavigationBarHeight, height: 30)
        button.setImage(UIImage(systemName: "envelope"), for: .normal)//envelope.badge
        button.tintColor = .hexColor(str: "61666d")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupUI()
        // 默认选中中间的推荐
        contentScrollView.contentOffset = CGPoint(x: kScreenWidth, y: 0)
//        contentScrollView.rx.contentOffset.subscribe(onNext: {(point : CGPoint)  in
//            print(point)
//        }).disposed(by: rx.disposeBag)
        contentScrollView.rx.didEndDecelerating.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let page = round(self.contentScrollView.contentOffset.x / kScreenWidth)
            if page.isNaN || page.isInfinite { return }
            self.segmentedControl.setSelectedSegmentIndex(UInt(page), animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func setNavViewHideStatus(by scrollUp: Bool) {
        var animating = false
        if (self.customNavView.alpha == 1) == scrollUp, !animating {
            animating = true
            UIView.animate(withDuration: 0.2) {
                let factor = scrollUp ? -1.0 : 1.0
                self.customNavView.alpha = factor
                self.customNavView.mj_y += (kNavigationBarHeight*factor)
                self.segmentedControl.mj_y += (kNavigationBarHeight*factor)
                self.contentScrollView.mj_y += (kNavigationBarHeight*factor)
            } completion: { _ in
                animating = false
            }
        }
    }
    
    func onPushDetail(heroTag: String, videoItem: RecVideoItemAppModel) {
        switch videoItem.goto {
        case "bangumi":
            break
        case "av":
            guard let player_args = videoItem.player_args else { break }
            if player_args.aid != -1 {
                let bvid = QUtils.av2bv(avid: player_args.aid)
            }
            let vc = BBVDDetailVC(type: self.type, tab: tab)
            self.navigationController?.pushViewController(vc, animated: true)
        case "picture":
            break
        default:
            break
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController {
    
    fileprivate func setupUI(){
//        customNavView.backgroundColor = .blue
        customNavView.frame = CGRect(x: 0, y: kStatusBarHeight, width: kScreenWidth, height: kTopMargin)
        customNavView.addSubview(avatarCoverBtn)
        customNavView.addSubview(searchBgBtn)
        customNavView.addSubview(messageBtn)
        view.addSubview(customNavView)
        
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

