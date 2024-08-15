//
//  LoginViewController.swift
//  bili
//
//  Created by DJ on 2024/8/14.
//

import UIKit

import RxSwift
import RxCocoa
import Alamofire

class LoginViewController: QBaseViewController {
    
    var phoneBgView: UIView!
    var countryButton: UIButton!
    var lineView1: UIView!
    var phoneTextField: UITextField!
    
    var codeBgView: UIView!
    var sendSmsButton: UIButton!
    var lineView2: UIView!
    var codeTextField: UITextField!
    
    var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "手机登录"
        
        setupUI()
        setAction()
    }
    
    
    func setupUI() {
        
        phoneBgView = UIView()
        phoneBgView.layer.borderColor = UIColor.hexColor(str: "E3E5E7").cgColor
        phoneBgView.layer.borderWidth = 1
        phoneBgView.layer.cornerRadius = 4
        phoneBgView.layer.masksToBounds = true
        view.addSubview(phoneBgView)
        
        phoneBgView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(12)
            make.right.equalTo(view).offset(-12)
            make.top.equalTo(view).offset(topSafeAreaHeight + statusBarHeight + 16)
            make.height.equalTo(44)
        }
        
        codeBgView = UIView()
        codeBgView.layer.borderColor = UIColor.hexColor(str: "E3E5E7").cgColor
        codeBgView.layer.borderWidth = 1
        codeBgView.layer.cornerRadius = 4
        codeBgView.layer.masksToBounds = true
        view.addSubview(codeBgView)
        
        codeBgView.snp.makeConstraints { make in
            make.left.right.height.equalTo(phoneBgView)
            make.top.equalTo(phoneBgView.snp.bottom).offset(8)
        }
        
        countryButton = HLImagePositionButton(type: .left, space: 0)
        countryButton.setTitle("+86", for: .normal)
        countryButton.setTitleColor(.black, for: .normal)
        countryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        countryButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        countryButton.tintColor = .hexColor(str: "e3e5e7")
        countryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        phoneBgView.addSubview(countryButton)
        
        countryButton.snp.makeConstraints { make in
            make.left.equalTo(phoneBgView)
            make.centerY.equalTo(phoneBgView)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        
        lineView1 = UIView()
        lineView1.backgroundColor = .gray
        phoneBgView.addSubview(lineView1)
        lineView1.snp.makeConstraints { make in
            make.left.equalTo(countryButton.snp.right)
            make.centerY.equalTo(phoneBgView)
            make.width.equalTo(1)
            make.height.equalTo(20)
        }
        
        
        phoneTextField = UITextField()
        let phoneTextPlace = NSMutableAttributedString(string: "Enter your phoneNumber")
        
        phoneTextPlace.addAttribute(.foregroundColor, value: UIColor.hexColor(str: "aeb3b9"), range: NSMakeRange(0, phoneTextPlace.length))
        phoneTextPlace.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSMakeRange(0, phoneTextPlace.length))
        phoneTextField.attributedPlaceholder = phoneTextPlace
        phoneBgView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.left.equalTo(countryButton.snp.right).offset(9)
            make.top.right.bottom.equalTo(phoneBgView)
        }


        
        sendSmsButton = UIButton(type: .custom)
        codeBgView.addSubview(sendSmsButton)
        sendSmsButton.setTitle("获取验证码", for: .normal)
        sendSmsButton.titleLabel?.font  = UIFont.systemFont(ofSize: 14)
        sendSmsButton.setTitleColor(UIColor.hexColor(str: "ff6699"), for: .normal)
        sendSmsButton.layer.masksToBounds = true
//        view.layoutIfNeeded()
        
        sendSmsButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(93)
            make.right.equalToSuperview()
        }
        
        lineView2 = UIView()
        lineView2.backgroundColor = .gray
        codeBgView.addSubview(lineView2)
        lineView2.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(sendSmsButton.snp.left).offset(-1)
        }
        
        codeTextField = UITextField()
        let pwdPlace = NSMutableAttributedString(string: "Enter your code")
//        if let pwd = UserDefaults.standard.value(forKey: "loginPwd") as? String {
//            codeTextField.text = pwd
//        }
        pwdPlace.addAttribute(.foregroundColor, value: UIColor.hexColor(str: "aeb3b9"), range: NSMakeRange(0, pwdPlace.length))
        pwdPlace.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSMakeRange(0, pwdPlace.length))
        codeTextField.attributedPlaceholder = pwdPlace
        codeBgView.addSubview(codeTextField)
        
        codeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.bottom.equalTo(codeBgView)
            make.right.equalTo(lineView2.snp.left).offset(11)
        }
        
        loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = .hexColor(str: "e3e5e7")
//        loginButton.addTarget(self, action: #selector(forgetAction), for: .touchUpInside)
        loginButton.setTitle("验证登录", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.left.right.equalTo(codeBgView)
            make.top.equalTo(codeBgView.snp.bottom).offset(8)
            make.height.equalTo(44)
        }
    }
    func setAction() {
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Authorization", value: "Basic VXNlcm5hbWU6UGFzc3dvcmQ="),
            HTTPHeader(name: "Accept", value: "application/json")
        ]
        let para = ["a":"b"]
        sendSmsButton.rx.tap.subscribe(onNext: {
            AF.request("https://passport.bilibili.com/x/passport-login/sms/send", method: .post, parameters: para, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            }
        }).disposed(by: rx.disposeBag)
    }
}



