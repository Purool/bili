//
//  BBPlayerViewController.swift
//  bili
//
//  Created by DJ on 2024/8/28.
//

import UIKit
import RxSwift

class BBVDPlayerVC: CommonPlayerViewController {
    
    private let viewModel: VideoPlayerViewModel
    
    lazy var backBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(pressBack), for: .touchUpInside)
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
        view.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenWidth_9_16)
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(kNavigationBarHeight)
            make.left.bottom.equalToSuperview()
        }
        
//        viewModel.nextProvider = nextProvider
        viewModel.onPluginReady.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] plugins in
            plugins.forEach { self?.addPlugin(plugin: $0) }
        }, onError: { err in
            self.showErrorAlertAndExit(message: err.localizedDescription)
        }).disposed(by: rx.disposeBag)
        
        viewModel.onPluginRemove.subscribe(onNext: { [weak self] in
            self?.removePlugin(plugin: $0)
        }).disposed(by: rx.disposeBag)
        
        viewModel.onExit = { [weak self] in
            self?.dismiss(animated: true)
        }
        Task {
            await viewModel.load()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func pressBack() {
        navigationController?.popViewController(animated: true)
    }
}
