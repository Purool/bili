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
    
    class NestTableView: UITableView {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if let val = (otherGestureRecognizer.view as? UIScrollView)?.isPagingEnabled {
                return !val
            }
            return true
        }
    }
    
    var detailInfo: PlayInfo?
    let viewModel = VDDescViewModel()
    
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
        
        Task { await viewModel.inputs.getData(info: detailInfo!) }
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
        
        pageScrollView.rx.didEndDecelerating.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let page = round(self.pageScrollView.contentOffset.x / kScreenWidth)
            if page.isNaN || page.isInfinite { return }
            self.tabItemView.setSelectedSegmentIndex(UInt(page), animated: true)
        }).disposed(by: rx.disposeBag)
        
    }
    
    @objc func segmentedControlChangedValue(segmentedControl: HMSegmentedControl) {
        pageScrollView.scrollRectToVisible(CGRect(x: kScreenWidth * CGFloat(segmentedControl.selectedSegmentIndex), y: 0, width: kScreenWidth, height: 100), animated: true)
    }
    
    //MARK: VDDescVC
    class VDDescVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
        let allClass = [BBMediaDescUniteUpperCell.self, VDSectionControllerCell.self, BBMediaDescUniteFeatureCell.self, BBMediaUniteRelateCell.self]
        var cells: [UITableViewCell] = []
        private var data: VideoDetail?
        var tableView = NestTableView(frame: CGRectZero)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            guard let parentVC = self.parent as? BBMPTabController else { return }
            
            setUpUI(parentVC: parentVC)
            
            bindDataToView(viewModel: parentVC.viewModel)
            
        }
        
        private func setUpUI(parentVC: BBMPTabController){
            
            view.addSubview(tableView)
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            allClass.forEach { tableView.register($0, forCellReuseIdentifier: String(describing: $0)) }
            cells = allClass.dropLast().map { self.tableView.dequeueReusableCell(withIdentifier: String(describing: $0))! }
            
            view.mj_size = CGSizeMake(kScreenWidth, parentVC.pageScrollView.mj_h)
            tableView.frame = view.bounds
            
            tableView.rx.didScroll.subscribe(onNext: {[weak self] _ in
                guard let scrollView = self?.tableView, let vc = self?.parent?.parent as? BBVDDetailVC else { return }
                if kScreenWidth_9_16 - kNavigationBarHeight - vc.contentScrollView.contentOffset.y > 0.1 {
                    scrollView.contentOffset = CGPointZero
                }
            }).disposed(by: rx.disposeBag)
        }
        
        private func bindDataToView(viewModel: VDDescViewModel){
            
            viewModel.outputs.rxData.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.data = data
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
                var allUgcEpisodes = [VideoDetail.Info.UgcSeason.UgcVideoInfo]()
                if let season = data.View.ugc_season {
                    if season.sections.count > 1 {
                        if let section = season.sections.first(where: { section in section.episodes.contains(where: { episode in episode.aid == data.View.aid }) }) {
                            allUgcEpisodes = section.episodes
                        }
                    } else {
                        allUgcEpisodes = season.sections.first?.episodes ?? []
                    }
                    allUgcEpisodes.sort { $0.arc.ctime < $1.arc.ctime }
                }
                
                strongSelf.tableView.reloadData()
            }).disposed(by: rx.disposeBag)
            
            viewModel.outputs.rxPages.subscribe(onNext: {pages in
    //            print(pages)//视频合集
            }).disposed(by: rx.disposeBag)
            
            Observable.zip(viewModel.coinCount, viewModel.coinStatus, viewModel.likeStatus).subscribe(onNext: {count, coinS, likeS in
                print("\(count)+++\(coinS)+\(likeS)+")
            }).disposed(by: rx.disposeBag)
        }
        
        private func update(with data: VideoDetail) {
            
        }
        //MARK: tableViewDelegate
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data?.Related.count ?? 0 + 3
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row < 3 {
                return cells[indexPath.row]
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: allClass.last!)) as? BBMediaUniteRelateCell{
                if let related = data?.Related[indexPath.row - 3] {
                    cell.update(data: related)
                }
                return cell
            }
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row == 1 {
                if let cell = tableView.cellForRow(at: indexPath) as? VDSectionControllerCell {
                    cell.expandCell()
                    tableView.reloadRows(at: [indexPath], with: .top)
                }
            }
        }
        
        
        
    }
    //MARK: VDCommentVC
    class VDCommentVC: UIViewController {
        
        var tableView = NestTableView(frame: CGRectZero)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGray
            guard let parentVC = (self.parent as? BBMPTabController) else { return }
            view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, parentVC.pageScrollView.mj_h)
            setUpUI()
            
            parentVC.viewModel.outputs.rxReplys.bind(to: tableView.rx.items) { (tableView, row, element) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BFCCommentListCell.self)) as? BFCCommentListCell{
                    cell.videoModel = element
                    return cell
                }
                return UITableViewCell()
            }.disposed(by: rx.disposeBag)
        }
        
        func setUpUI() {
            view.addSubview(tableView)
            tableView.separatorStyle = .none
            tableView.register(BFCCommentListCell.self, forCellReuseIdentifier: String(describing: BFCCommentListCell.self))
            tableView.frame = view.bounds
            tableView.rx.didScroll.subscribe(onNext: {[weak self] _ in
                guard let scrollView = self?.tableView, let vc = self?.parent?.parent as? BBVDDetailVC else { return }
                if kScreenWidth_9_16 - kNavigationBarHeight - vc.contentScrollView.contentOffset.y > 0.1 {
                    scrollView.contentOffset = CGPointZero
                }
            }).disposed(by: rx.disposeBag)
        }
        
    }
    
}
