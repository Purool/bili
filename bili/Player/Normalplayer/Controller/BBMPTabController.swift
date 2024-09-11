//
//  BBMPTabController.swift
//  bili
//
//  Created by DJ on 2024/8/28.
//

import UIKit
import HMSegmentedControl

class BBMPTabController: UIViewController {

    lazy var tabItemView: HMSegmentedControl = {[unowned self] in
        let segmentedView = HMSegmentedControl(sectionTitles: ["简介","评论xxx"])
        segmentedView.frame = CGRect(x: 0, y: 0, width: kScreenWidth*0.6, height: 40)
//        segmentedView.backgroundColor = .clear
        segmentedView.selectionIndicatorColor = .hexColor(str: "ff6699")
        segmentedView.selectionIndicatorHeight = 2
        segmentedView.selectionIndicatorLocation = .bottom
//        segmentedView.selectedSegmentIndex = 0
        segmentedView.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hexColor(str: "61666d"),
                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)]
        segmentedView.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        return segmentedView
    }()
    
    lazy var pageScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.frame = CGRect(x: 0, y: CGRectGetMaxY(tabItemView.superview!.frame), width: kScreenWidth, height: CGRectGetMaxY(view.frame) - CGRectGetMaxY(tabItemView.superview!.frame))
        contentScrollView.contentSize = CGSize(width: kScreenWidth*2, height: contentScrollView.mj_h)
        contentScrollView.isPagingEnabled = true
        contentScrollView.bounces = false
        contentScrollView.showsHorizontalScrollIndicator = false
        return contentScrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpUI()
    }
    
    func setUpUI() {
        view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTopMargin + kScreenWidth_9_16)
        let headerView = UIView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth_9_16))
        headerView.backgroundColor = .orange
        view.addSubview(headerView)
        
        let tabView = UIView(frame: CGRectMake(0, kScreenWidth_9_16, kScreenWidth, 40))
        tabView.addSubview(tabItemView)
        view.addSubview(tabView)
        
        let rightView = UIView(frame: CGRectMake(kScreenWidth*0.6, 5, kScreenWidth*0.4 - 12, 30))
        rightView.layer.cornerRadius = 15
        rightView.backgroundColor = .hexColor(str: "e3e5e7")
        rightView.layer.masksToBounds = true
        tabView.addSubview(rightView)
        
        view.addSubview(pageScrollView)
        let VCs: [UIViewController] = [VDDescVC(),VDCommentVC()]
        addChild(VCs.first!)
        addChild(VCs.last!)
        pageScrollView.addSubview(VCs.first!.view)
        pageScrollView.addSubview(VCs.last!.view)
    }
    
    @objc func segmentedControlChangedValue(segmentedControl: HMSegmentedControl) {
        pageScrollView.scrollRectToVisible(CGRect(x: kScreenWidth * CGFloat(segmentedControl.selectedSegmentIndex), y: 0, width: kScreenWidth, height: 100), animated: true)
    }
    
}

class VDDescVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        guard let parentVC = self.parent else { return }
        view.mj_h = (parentVC as! BBMPTabController).pageScrollView.mj_h
        setUpUI()
    }
    func setUpUI(){
        
    }
}

class VDCommentVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray
        guard let parentVC = self.parent else { return }
        view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, (parentVC as! BBMPTabController).pageScrollView.mj_h)
//        setUpUI()
    }
}

