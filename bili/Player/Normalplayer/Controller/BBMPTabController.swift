//
//  BBMPTabController.swift
//  bili
//
//  Created by DJ on 2024/8/28.
//

import UIKit
import HMSegmentedControl
import RxSwift
import RxCocoa
import Kingfisher

class BBMPTabController: UIViewController {
    
    var detailInfo: PlayInfo?
    
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
    
    init(playInfo: PlayInfo) {
        detailInfo = playInfo
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpUI()
        
        pageScrollView.rx.didEndDecelerating.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let page = round(self.pageScrollView.contentOffset.x / kScreenWidth)
            if page.isNaN || page.isInfinite { return }
            self.tabItemView.setSelectedSegmentIndex(UInt(page), animated: true)
        }).disposed(by: rx.disposeBag)
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

class VDDescVC: UITableViewController {
    
    let allClass: [UITableViewCell.Type] = [BBMediaDescUniteUpperCell.self, VDSectionControllerCell.self, BBMediaDescUniteFeatureCell.self, BBMediaUniteRelateCell.self]
    var cells: [UITableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        allClass.forEach { tableView.register($0, forCellReuseIdentifier: String(describing: $0)) }
        cells = allClass.map { self.tableView.dequeueReusableCell(withIdentifier: String(describing: $0))! }
        
        guard let parentVC = self.parent, let info = (parentVC as! BBMPTabController).detailInfo else { return }
        view.mj_size = CGSizeMake(kScreenWidth, (parentVC as! BBMPTabController).pageScrollView.mj_h)
        
        setUpUI()
        
        let viewModel = VDDescViewModel()
        Task { await viewModel.inputs.getData(info: info) }
        
        viewModel.outputs.rxData.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            guard let strongSelf = self else { return }
            if let cell = strongSelf.cells[0] as? BBMediaDescUniteUpperCell{
                cell.avatarView.kf.setImage(with: data.avatar)
                cell.upNameLabel.text = data.ownerName
                (cell.stackView.arrangedSubviews.first as! UILabel).text = QUtils.numFormat(data.Card.follower ?? 0) + "粉丝"
                (cell.stackView.arrangedSubviews.last as! UILabel).text = QUtils.numFormat(data.Card.archive_count ?? 0) + "视频"
            }
            if let cell = strongSelf.cells[1] as? VDSectionControllerCell{
                cell.titleLabel.text = data.title
                cell.playLabel.text = QUtils.numFormat(data.View.stat.view)
                cell.danmakuLabel.text = QUtils.numFormat(data.View.stat.danmaku)
                cell.pubDateLabel.text = data.View.date
                cell.onlineLabel.text = "??正在观看"
                cell.idLabel.text = data.View.bvid
                var notes = [String]()
                let status = data.View.dynamic ?? ""
                if status.count > 1 {
                    notes.append(status)
                }
                notes.append(data.View.desc ?? "")
                cell.descLabel.text = notes.joined(separator: "\n")
            }
            if let cell = strongSelf.cells[2] as? BBMediaDescUniteFeatureCell{
                let array = [QUtils.numFormat(data.View.stat.like), "不喜欢", QUtils.numFormat(data.View.stat.coin), QUtils.numFormat(data.View.stat.favorite), QUtils.numFormat(data.View.stat.share)]
                for (index, value) in array.enumerated() {
                    print("Index: \(index), Value: \(value)")
                    cell.setBtnTitle(value, index: index)
                }
            }
            
            strongSelf.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.rxPages.subscribe(onNext: {pages in
            print(pages)
        }).disposed(by: rx.disposeBag)
        
        Observable.zip(viewModel.coinCount, viewModel.coinStatus, viewModel.likeStatus).subscribe(onNext: {count, coinS, likeS in
            print("\(count)+++\(coinS)+\(likeS)+")
        }).disposed(by: rx.disposeBag)
    }
    
    func setUpUI(){
        
    }
    
    
    
    private func update(with data: VideoDetail) {
        
    }
    //MARK: tableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? VDSectionControllerCell {
                cell.expandCell()
                tableView.reloadRows(at: [indexPath], with: .top)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return super.tableView(tableView, heightForRowAt: indexPath)
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

