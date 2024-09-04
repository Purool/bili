//
//  BBPlayerViewController.swift
//  bili
//
//  Created by DJ on 2024/8/28.
//

import UIKit
import Combine

class BBVDPlayerVC: CommonPlayerViewController {
    
    private let viewModel: VideoPlayerViewModel
    private var cancelable = Set<AnyCancellable>()
    
    lazy var playBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setTitle("立即播放", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()
    
    lazy var backBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    lazy var moreBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    init(playInfo: PlayInfo) {
        viewModel = VideoPlayerViewModel(playInfo: playInfo)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth_9_16)
        
        view.addSubview(backBtn)
        view.addSubview(moreBtn)
        view.addSubview(playBtn)
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(kNavigationBarHeight)
            make.left.bottom.equalToSuperview()
        }
        moreBtn.snp.makeConstraints { make in
            make.width.height.equalTo(kNavigationBarHeight)
            make.right.bottom.equalToSuperview()
        }
        playBtn.snp.makeConstraints { make in
            make.width.equalTo(130)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
        }

//        viewModel.nextProvider = nextProvider
        viewModel.onPluginReady.receive(on: DispatchQueue.main).sink { [weak self] completion in
            switch completion {
            case let .failure(err):
//                self?.showErrorAlertAndExit(message: err)
                EWMBProgressHud.showTextHudTips(message: err, isTranslucent: true)
            default:
                break
            }
        } receiveValue: { [weak self] plugins in
            plugins.forEach { self?.addPlugin(plugin: $0) }
        }.store(in: &cancelable)
        viewModel.onPluginRemove.sink { [weak self] in
            self?.removePlugin(plugin: $0)
        }.store(in: &cancelable)
        viewModel.onExit = { [weak self] in
            self?.dismiss(animated: true)
        }
        Task {
            await viewModel.load()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backBtn.isHidden = view.mj_h != kNavigationBarHeight
        moreBtn.isHidden = view.mj_h != kNavigationBarHeight
        playBtn.isHidden = view.mj_h > kScreenWidth_9_16-2
        playBtn.alpha = kNavigationBarHeight/view.mj_h + 0.5
    }
    
}
