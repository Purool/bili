//
//  BilibiliMineViewController.swift
//  bili
//
//  Created by DJ on 2024/8/13.
//

import UIKit

class BilibiliMineViewController: UIViewController {
    
    lazy var loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitleColor(knavibarcolor, for: .normal)
        loginButton.backgroundColor = UIColor.white
        loginButton.setTitle("登录", for: .normal)
        loginButton.layer.cornerRadius = 5
        return loginButton
    }()
    
    lazy var registButton: UIButton = {
        let registButton = UIButton()
        registButton.setTitle("注册", for: .normal)
        registButton.backgroundColor = UIColor.etColor(r: 247, g: 117, b: 156)
        registButton.setTitleColor(UIColor.white, for: .normal)
        registButton.layer.cornerRadius = 5
        return registButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = knavibarcolor
        
        view.addSubview(registButton)
        registButton.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(70)
            make.right.equalTo(view.snp.centerX).offset(-15)
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(registButton.snp.top)
            make.left.equalTo(view.snp.centerX).offset(15)
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
        
        loginButton.addTarget(self, action: #selector(testPush), for: .touchUpInside)
        loginButton.rx.tap.subscribe(onNext: {
            _ in
//            let vc = LoginViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    @objc func testPush() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
