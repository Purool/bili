//
//  QWebViewController.swift
//  bili
//
//  Created by DJ on 2024/8/16.
//

import UIKit
import WebKit

class QWebViewController: QBaseViewController {
    
    var request: URLRequest!
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self;
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackImage = UIImage.init(named: "nav_bg")
        progressView.progressTintColor = UIColor.white
        return progressView
    }()
    
    // 构造器
    convenience init(url: String?) {
        self.init()
        self.request = URLRequest(url: URL(string: url ?? "")!)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(request)
    }
    
    override func setupLayout() {
        view.addSubview(webView)
        webView.snp.makeConstraints{ $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges) }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()

        let barButtons = [
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reload)),
            UIBarButtonItem(title: "刷新登录状态", style: .plain, target: self, action: #selector(QWebViewController.confirmLogin)),
        ]
//        .map { item in
//            item.tintColor = UIColor.red
//                return item
//        }
        navigationItem.rightBarButtonItems = barButtons;
        
    }
    
    override func pressBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            super.pressBack()
        }
    }
    
    @objc func confirmLogin() {
        Task{
            await QwebCookieTool.shared.setCookie()
            do {
                let info = try await ApiRequest.requestLoginInfo()
                if info.isLogin {
//                    SmartDialog.showToast('登录成功');
                    UserDefaults.standard.set(codable: info, forKey: "userInfoCache")
                } else {
                    // 获取用户信息失败
//                    SmartDialog.showToast(result['msg']);
                }
            } catch let err {
                print(err)
            }
        }
    }
    
    @objc func reload() {
        ApiRequest.isLogin()
        webView.reload()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

extension QWebViewController: WKNavigationDelegate, WKUIDelegate {
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress >= 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        progressView.setProgress(0.0, animated: false)
        navigationItem.title = title ?? (webView.title ?? webView.url?.host)
    }
}
