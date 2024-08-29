//
//  BBVDDetailVC.swift
//  bili
//
//  Created by DJ on 2024/8/26.
//

import UIKit
import RxSwift
import MBProgressHUD

class BBVDDetailVC: QBaseViewController {
    
    var param: Dictionary<String, Any> = Dictionary()
    
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
        setUpUI()
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
        
        playerVC = BBVDPlayerVC()
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
    
    func queryVideoUrl() async {
        guard let model = await ApiRequest.videoUrl(bvid: param["bvid"] as? String, cid: param["cid"] as! Int) else { return }
        if model.accept_description.contains("试看") {
            EWMBProgressHud.showTextHudTips(message: "该视频为专属视频，仅提供试看", isTranslucent: true)
                videoUrl = data["durl"] as! [AnyObject].first.url
                audioUrl = ""
                defaultST = Duration.zero
                firstVideo = VideoItem()
                if autoPlay.value {
                    try await playerInit()
                    isShowCover.value = false
                }
                return result
            }
            let allVideosList = data["dash"] as! [String: Any]["video"] as! [VideoItem]
            do {
                // 当前可播放的最高质量视频
                let currentHighVideoQa = allVideosList.first.quality.code
                // 预设的画质为null，则当前可用的最高质量
                cacheVideoQa = cacheVideoQa?? currentHighVideoQa
                var resVideoQa = currentHighVideoQa
                if cacheVideoQa! <= currentHighVideoQa {
                    // 如果预设的画质低于当前最高
                    let numbers = data["acceptQuality"] as! [Int].filter { $0 <= currentHighVideoQa }
                    resVideoQa = Utils.findClosestNumber(cacheVideoQa!, numbers)
                }
                currentVideoQa = VideoQualityCode.fromCode(resVideoQa)!

                /// 取出符合当前画质的videoList
                let videosList = allVideosList.filter { $0.quality.code == resVideoQa }

                /// 优先顺序 设置中指定解码格式 -> 当前可选的首个解码格式
                let supportFormats = data["supportFormats"] as! [FormatItem]
                // 根据画质选编码格式
                let supportDecodeFormats = supportFormats.first(where: { $0.quality == resVideoQa }).codecs
                // 默认从设置中取AVC
                currentDecodeFormats = VideoDecodeFormatsCode.fromString(cacheDecode)!
                do {
                    // 当前视频没有对应格式返回第一个
                    var flag = false
                    for i in supportDecodeFormats {
                        if i.starts(with: currentDecodeFormats.code) {
                            flag = true
                        }
                    }
                    currentDecodeFormats = flag? currentDecodeFormats : VideoDecodeFormatsCode.fromString(supportDecodeFormats.first)!
                } catch {
                    SmartDialog.showToast("DecodeFormats error: \(error)")
                }

                /// 取出符合当前解码格式的videoItem
                do {
                    firstVideo = videosList.first(where: { $0.codecs.starts(with: currentDecodeFormats.code) })!
                } catch {
                    firstVideo = videosList.first
                }
                videoUrl = enableCDN? VideoUtils.getCdnUrl(firstVideo) : (firstVideo.backupUrl?? firstVideo.baseUrl)!
            } catch {
                SmartDialog.showToast("firstVideo error: \(error)")
            }

            /// 优先顺序 设置中指定质量 -> 当前可选的最高质量
            var firstAudio: AudioItem?
            let audiosList = data["dash"] as! [String: Any]["audio"] as! [AudioItem]

            do {
                if data["dash"] as! [String: Any]["dolby"]?["audio"]?.isEmpty == false {
                    // 杜比
                    audiosList.insert(data["dash"] as! [String: Any]["dolby"]!.audio!.first, at: 0)
                }

                if data["dash"] as! [String: Any]["flac"]?["audio"]!= nil {
                    // 无损
                    audiosList.insert(data["dash"] as! [String: Any]["flac"]!.audio!, at: 0)
                }

                if audiosList.isEmpty {
                    let numbers = audiosList.map { $0.id! }
                    let closestNumber = Utils.findClosestNumber(defaultAudioQa, numbers)
                    if!numbers.contains(defaultAudioQa) && numbers.contains(where: { $0 > defaultAudioQa }) {
                        closestNumber = 30280
                    }
                    firstAudio = audiosList.first(where: { $0.id == closestNumber })
                } else {
                    firstAudio = AudioItem()
                }
            } catch {
                firstAudio = audiosList.isEmpty? audiosList.first : AudioItem()
                SmartDialog.showToast("firstAudio error: \(error)")
            }

            audioUrl = enableCDN? VideoUtils.getCdnUrl(firstAudio!) : (firstAudio!.backupUrl?? firstAudio!.baseUrl)!
            //
            if firstAudio?.id!= nil {
                currentAudioQa = AudioQualityCode.fromCode(firstAudio!.id!)!
            }
            defaultST = Duration(milliseconds: data["lastPlayTime"] as! Int)
            if autoPlay.value {
                try await playerInit()
                isShowCover.value = false
            }
        } else {
            if result["code"] as! Int == -404 {
                isShowCover.value = false
            }
            SmartDialog.showToast(result["msg"] as! String)
        }
        return result
    }

    
}
