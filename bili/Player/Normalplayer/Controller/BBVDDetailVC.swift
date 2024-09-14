//
//  BBVDDetailVC.swift
//  bili
//
//  Created by DJ on 2024/8/26.
//

import UIKit
import RxSwift
import MBProgressHUD

struct PlayInfo {
    let aid: Int
    var cid: Int = 0
    var epid: Int = 0 // 港澳台解锁需要
    var isBangumi: Bool = false
    var seasonId: Int = 0
}
class BBVDDetailVC: QBaseViewController {
    
    var detailInfo: PlayInfo?
    
    private var playerVC: BBVDPlayerVC!
    private var TabVC: BBMPTabController!
    
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
        
        contentScrollView.rx.contentOffset.subscribe(onNext: { [weak self] (points) in
            let retY = kStatusBarHeight - points.y
            self?.playerVC.view.mj_y = retY
            let distance = kScreenWidth_9_16 - kTopMargin + retY
            self?.playerVC.backBtn.isHidden = !(retY < 0 && distance < 0.1)
        }).disposed(by: rx.disposeBag)
        
    }
    
}

