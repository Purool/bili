//
//  BBPhoneUserCenterVC.swift
//  bili
//
//  Created by DJ on 2024/8/13.
//

import UIKit
import SnapKit

class BBPhoneUserCenterVC: QBaseViewController {
    lazy var avatarImage = UIImageView(image: UIImage(named: "common_profile_default"))
    lazy var myInfoTips = UILabel()
    lazy var rowView1 = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    @objc func rowView1Tapped() {
        let vc = UINavigationController(rootViewController: LoginViewController())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func setupUI() {
        view.backgroundColor = .hexColor(str: "f1f2f3")
        
        rowView1 = UIView(frame: CGRectMake(0, 50, kscreenWidth, 100))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowView1Tapped))
        rowView1.addGestureRecognizer(tapGesture)
        view.addSubview(rowView1)
        
        rowView1.addSubview(avatarImage)
        avatarImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
        }
        avatarImage.layer.cornerRadius = 30
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.borderWidth = 0.5
        avatarImage.layer.borderColor = UIColor.systemGray.cgColor
        avatarImage.isUserInteractionEnabled = true

        rowView1.addSubview(myInfoTips)
        
        let isLogin = false
        if isLogin {
            
            //TODO: login
        }else {
            myInfoTips.text = "Tap to Login"
            myInfoTips.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            myInfoTips.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(avatarImage.snp.right).offset(20)
                make.height.equalTo(25)
            }
        }
        
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.forward"))
        arrowImage.tintColor = UIColor.gray
        rowView1.addSubview(arrowImage)
        arrowImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
    }
}
