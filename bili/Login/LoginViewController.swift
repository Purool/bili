//
//  LoginViewController.swift
//  bili
//
//  Created by DJ on 2024/8/14.
//

import UIKit

import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    lazy var usernameFiled: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.attributedPlaceholder = NSAttributedString(string: "请输入手机号", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.textColor = .black
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "请输入验证码", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.textColor = .black
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var toRegisterButton: UIButton = {
        let button = UIButton(type: .custom)
        let attString = NSAttributedString(string: "发送验证码", attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 15)])
        button.setAttributedTitle(attString, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        title = "登录"
        actionButton.setTitle(title, for: .normal)
        
        view.backgroundColor = .gray
        
        view.addSubview(usernameFiled)
        usernameFiled.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30 + 16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        usernameFiled.layer.cornerRadius = 22
        usernameFiled.layer.masksToBounds = true
        
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameFiled.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        passwordField.layer.cornerRadius = 22
        passwordField.layer.masksToBounds = true
        
        view.addSubview(toRegisterButton)
        toRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.trailing.equalTo(usernameFiled)
        }
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(toRegisterButton.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        

        let everythingValid = Observable.combineLatest(usernameFiled, <#T##source2: ObservableType##ObservableType#>)
        
    }
}

