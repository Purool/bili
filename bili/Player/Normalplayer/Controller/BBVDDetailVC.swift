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
    var cid: Int? = 0
    var epid: Int? = 0 // 港澳台解锁需要
    var isBangumi: Bool = false
    var seasonId: Int? = 0
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
        playerVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(TabVC.view.snp.top).offset(kScreenWidth_9_16)
        }
        
        contentScrollView.snp.makeConstraints { make in
            make.size.equalTo(contentScrollView.frame.size)
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setUpUI() {
        view.addSubview(contentScrollView)
        guard let info = detailInfo else { return }
        playerVC = BBVDPlayerVC(playInfo: info)
        self.addChild(playerVC)
        view.addSubview(playerVC.view)
        
        TabVC = BBMPTabController()
        self.addChild(TabVC)
        contentScrollView.addSubview(TabVC.view)
        
        contentScrollView.rx.contentOffset.buffer(timeSpan: .milliseconds(100), count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (points) in
                guard let self = self, let pointA = points.first, let pointB = points.last else {return}
    //            print("\(pointB)=====\(pointA)")
//                let result = pointB.y - pointA.y
//                if (pointA.y < 0) || (pointB.y < 0){
//                    (self.parent as! HomeViewController).setNavViewHideStatus(by: false)
//                }else if result != 0, result < 20 {
//                    (self.parent as! HomeViewController).setNavViewHideStatus(by: result > 0)
//                }
            }).disposed(by: rx.disposeBag)
        
    }
    
}

