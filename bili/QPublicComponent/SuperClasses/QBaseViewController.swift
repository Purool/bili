//
//  BaseViewController.swift
//  bili
//
//  Created by Purool on 14/8/2024.
//

import UIKit
import RxSwift
import RxCocoa

class QBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .hexColor(str: "f1f2f3")
        
//        if #available(iOS 11.0, *) {
//            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        setupLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func setupLayout() {}
    
    func configNavigationBar() {
        guard let navi = navigationController else { return }
        if navi.visibleViewController == self {
//            navi.disablePopGesture = false
//            navi.setNavigationBarHidden(false, animated: true)
            if (navi.viewControllers.count > 1 || nil != navigationController?.presentingViewController){
                navi.barStyle(.white)
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                                   target: self,
                                                                   action: #selector(pressBack))
                navigationController?.interactivePopGestureRecognizer?.delegate = navi.viewControllers.count > 1 ? self : nil
            }
        }
    }
    
    @objc func pressBack() {
        if let _ = navigationController?.presentingViewController {
            navigationController?.dismiss(animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    

}

extension QBaseViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count != 1;
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
