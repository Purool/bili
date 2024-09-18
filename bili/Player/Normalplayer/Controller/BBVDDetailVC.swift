//
//  BBVDDetailVC.swift
//  bili
//
//  Created by DJ on 2024/8/26.
//

import UIKit
import RxSwift
import MBProgressHUD
import RxCocoa

struct PlayInfo {
    let aid: Int
    var cid: Int = 0
    var epid: Int = 0 // 港澳台解锁需要
    var isBangumi: Bool = false
    var seasonId: Int = 0
}
class BBVDDetailVC: QBaseViewController {
    
    var detailInfo: PlayInfo?
    
    var playerVC: BBVDPlayerVC!
    private var TabVC: BBMPTabController!
    private var canScroll = true
    
    lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.frame = CGRect(x: 0, y: kStatusBarHeight, width: kScreenWidth, height: kScreenHeight - kStatusBarHeight)
        contentScrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight - kTopMargin + kScreenWidth_9_16)
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.bounces = false
        contentScrollView.showsVerticalScrollIndicator = false
//        contentScrollView.isDirectionalLockEnabled = false
//        contentScrollView.backgroundColor = knavibarcolor
        return contentScrollView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
//        Task { await fetchData() }
        setUpUI()
//        Task { await queryVideoUrl() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUpUI() {
        view.addSubview(contentScrollView)
        guard let info = detailInfo else { return }
        playerVC = BBVDPlayerVC(playInfo: info)
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        
        TabVC = BBMPTabController(playInfo: info)
        self.addChild(TabVC)
        contentScrollView.addSubview(TabVC.view)
        
        contentScrollView.rx.contentOffset.map({ [weak self] (points) in
            let retY = kStatusBarHeight - points.y
            self?.playerVC.view.mj_y = retY
            let distance = kScreenWidth_9_16 - kTopMargin + retY
            let isHidden = !(retY < 0 && distance < 0.1)
            return isHidden
        }).bind(to: self.playerVC.backBtn.rx.isHidden).disposed(by: rx.disposeBag)
        
        contentScrollView.rx.didScroll.filter({ [weak self] _ in
            guard let vc = (self?.children.last?.children.first as? VDDescVC) else { return false }
            return vc.tableView.contentOffset.y > 0.1
        }).map({ CGPoint(x: 0, y: kScreenWidth_9_16 - kNavigationBarHeight) })
            .bind(to: contentScrollView.rx.contentOffset).disposed(by: rx.disposeBag)
    }
    
    
    
}

