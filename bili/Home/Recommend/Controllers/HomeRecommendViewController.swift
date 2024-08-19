//
//  HomeRecommendViewController.swift
//  bili
//
//  Created by DJ on 2024/8/13.
//

import UIKit
import NSObject_Rx
import RxCocoa
import RxSwift

class HomeRecommendViewController: QBaseViewController {
    private let headHeight: CGFloat = 300
    
    private lazy var titleArray: Array = {
        return [["icon":"sep_register", "title": "签到"],
                ["icon":"sep_mywallet", "title": "钱包"],
                ["icon":"sep_subscription", "title": "订阅"],
                ["icon":"sep_fengyintu", "title": "封印图"],
                ["icon":"sep_theme", "title": "皮肤"],
                ["icon":"myvotebiao", "title": "我的投票"],
                ["icon":"sep_help", "title": "帮助反馈"],
                ["icon":"sep_beijing", "title": "首都网警"],
                ["icon":"sep_auther", "title": "作者中心"],
                ["icon":"sep_setting", "title": "设置"]]
    }()
    
    private lazy var collectionView: UICollectionView = {
        let lt = UICollectionViewFlowLayout()
        lt.minimumInteritemSpacing = 10
        lt.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        return collectionView

    }()

    private lazy var navigationBarY: CGFloat = {
        return navigationController?.navigationBar.frame.maxY ?? 0
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .top
//        let items = Observable.just(titleArray)
//        items.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items){
//            collectionView,row,element in
//            return UICollectionViewCell()
//            //_ cellFactory: @escaping (UICollectionView, Int, Sequence.Element) -> UICollectionViewCell
//        }.disposed(by: rx.disposeBag)
    }
     
    override func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {(make) in
            make.edges.equalTo(self.view.snp.edges).priority(.low)
            make.top.equalToSuperview()
        }
        collectionView.register(MineCollectionViewCell.self, forCellWithReuseIdentifier: "MineCollectionViewCell")
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationController?.barStyle(.clear)
//        collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.parallaxHeader.height)
    }
    private func collectionViewLayout1() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.itemSize = Dimensions.photosItemSize
//        let numberOfCellsInRow = floor(Dimensions.screenWidth / Dimensions.photosItemSize.width)
//        let inset = (Dimensions.screenWidth - (numberOfCellsInRow * Dimensions.photosItemSize.width)) / (numberOfCellsInRow + 1)
//        layout.sectionInset = .init(top: inset,
//                                    left: inset,
//                                    bottom: inset,
//                                    right: inset)
        return layout
    }
}

extension HomeRecommendViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 {
            navigationController?.barStyle(.theme)
            navigationItem.title = "我的"
        } else {
            navigationController?.barStyle(.clear)
            navigationItem.title = ""
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MineCollectionViewCell", for: indexPath) as! MineCollectionViewCell? {
            cell.dict = titleArray[indexPath.row]
            return cell
        } else {
            let cell = MineCollectionViewCell(frame: CGRectZero)
            cell.dict = titleArray[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(Double(kScreenWidth - 40.0) / 3.0)
        return CGSize(width: width, height: (width * 0.75 + 30))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task{
            try await ApiRequest.getTVCode()
        }
    }

}
