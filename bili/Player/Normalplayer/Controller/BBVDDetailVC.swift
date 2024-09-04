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
    
    var param: Dictionary<String, Any> = Dictionary()
    var videoUrl: String = ""
    var audioUrl: String = ""
    var firstVideoItem: MediaItem?
    var cacheVideoQa: Int?
    var currentVideoQa: VideoQuality?
    var currentDecodeFormats: VideoDecodeFormats?
    var autoPlay: Bool = false
    var cacheDecode: String = "av01"
    var enableCDN: Bool = false
    var defaultAudioQa: Int = 0
    var currentAudioQa: AudioQuality?
    var defaultST: DispatchTimeInterval = .never
    var isShowCover: Bool = false
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

extension BBVDDetailVC {
    func queryVideoUrl() async -> PlayUrlModel?{
        let param = param
        guard let model = try? await ApiRequest.videoUrl(bvid: param["bvid"] as? String, cid: param["cid"] as! Int) else {
            isShowCover = false
            EWMBProgressHud.showTextHudTips(message: "PlayUrlModel获取失败", isTranslucent: true)
            return nil
        }
        if model.accept_description.contains("试看") {
            EWMBProgressHud.showTextHudTips(message: "该视频为专属视频，仅提供试看", isTranslucent: true)
            videoUrl = model.durl?.first?.url ?? ""
            audioUrl = ""
            //            defaultST = Duration.zero
            //            firstVideo = VideoItem()
            if autoPlay {
//                try await playerInit()
                isShowCover = false
            }
            return model
        }
        let allVideosList: [MediaItem] = model.dash?.video ?? []
        // 当前可播放的最高质量视频
        let currentHighVideoQa = VideoQualityList[allVideosList.first?.quality ?? 1]
        // 预设的画质为null，则当前可用的最高质量
        cacheVideoQa = cacheVideoQa ?? currentHighVideoQa
        var resVideoQa = currentHighVideoQa
        if cacheVideoQa! <= currentHighVideoQa {
            // 如果预设的画质低于当前最高
            let numbers = model.accept_quality.filter { $0 <= currentHighVideoQa }
            resVideoQa = QUtils.findClosestNumber(target: cacheVideoQa!, numbers: numbers)
        }
        currentVideoQa = VideoQuality.init(rawValue: resVideoQa)
        
        /// 取出符合当前画质的videoList
        let videosList = allVideosList.filter { VideoQualityList[$0.quality ?? 1] == resVideoQa }
        
        /// 优先顺序 设置中指定解码格式 -> 当前可选的首个解码格式
        // 根据画质选编码格式
        let supportDecodeFormats = model.support_formats?.filter{ $0.quality == resVideoQa }.flatMap({ item in
            item.codecs
        }) ?? []
        // 默认从设置中取AVC
        currentDecodeFormats = VideoDecodeFormats.init(rawValue: cacheDecode)
        // 当前视频没有对应格式返回第一个
        var flag = false
        for i in supportDecodeFormats {
            if i.starts(with: currentDecodeFormats!.rawValue) {
                flag = true
            }
        }
        currentDecodeFormats = flag ? currentDecodeFormats : VideoDecodeFormats.init(rawValue: supportDecodeFormats.first ?? cacheDecode)
        /// 取出符合当前解码格式的videoItem
        if let firstVideo = videosList.first(where: { $0.codecs.starts(with: currentDecodeFormats!.rawValue) }) ?? videosList.first {
            firstVideoItem = firstVideo
            videoUrl = enableCDN ? QUtils.getCdnUrl(item: firstVideo) : (firstVideo.backupUrl.count > 0 ? firstVideo.backupUrl.first! : firstVideo.baseUrl)
        } else {
            EWMBProgressHud.showTextHudTips(message: "firstVideo error", isTranslucent: true)
        }

            /// 优先顺序 设置中指定质量 -> 当前可选的最高质量
        var firstAudio: MediaItem?
        var audiosList = model.dash?.audio ?? []
        
        if let audioItem = model.dash?.dolby?.audio {
            // 杜比
            audiosList.insert(audioItem.first!, at: 0)
        }
        if let audioItem = model.dash?.flac?.audio {
            // 无损
            audiosList.insert(audioItem, at: 0)
        }
        if !audiosList.isEmpty {
            let numbers = audiosList.map { $0.id }
            var closestNumber = QUtils.findClosestNumber(target: defaultAudioQa, numbers: numbers)
            if !numbers.contains(defaultAudioQa), numbers.contains(where: { $0 > defaultAudioQa }) {
                closestNumber = 30280
            }
            firstAudio = audiosList.first(where: { $0.id == closestNumber })
        } else {
            firstAudio = nil
            EWMBProgressHud.showTextHudTips(message: "firstAudio error", isTranslucent: true)
        }

        audioUrl = enableCDN ? QUtils.getCdnUrl(item: firstAudio!) : (firstAudio!.backupUrl.count > 0 ? firstAudio!.backupUrl.first! : firstAudio!.baseUrl)
            //
            if let audioId = firstAudio?.id {
                currentAudioQa = AudioQuality.init(rawValue: audioId)
            }
        defaultST = .seconds(model.last_play_time)
        if autoPlay {
//            try await playerInit()
            isShowCover = false
        }
        return model
    }
}
