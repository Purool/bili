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

let kpadding:CGFloat = 15
let klinePadding:CGFloat = 0

class HomeRecommendViewController: QBaseViewController {
    private let currentPage = 0
    private let headHeight: CGFloat = 300
    let allClass: [UICollectionViewCell.Type] = [UICollectionViewCell.self,
                                                 RecommendActivityCell.self,]
    
    private lazy var collectionView: UICollectionView = {
        let lt = UICollectionViewFlowLayout()
        lt.minimumInteritemSpacing = 8
        lt.minimumLineSpacing = 8
        lt.itemSize = CGSize(width: kscreenWidth*0.45, height: kscreenWidth*0.48)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        collectionView.backgroundColor = .hexColor(str: "f1f2f3")
//        collectionView.delegate = self
//        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        return collectionView

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .top
        _ = allClass.map{collectionView.register($0, forCellWithReuseIdentifier: $0.description())}
        let viewModel = RecommendViewModel()
        viewModel.inputs.loadData(page: 0)
        viewModel.outputs.dataSource.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items){
            collectionView,row,element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendActivityCell.self.description(), for: IndexPath(row: row, section: 0)) as! RecommendActivityCell
            cell.videoModel = element
            return cell
            //_ cellFactory: @escaping (UICollectionView, Int, Sequence.Element) -> UICollectionViewCell
        }.disposed(by: rx.disposeBag)
    }
     
    override func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {(make) in
            make.edges.equalTo(self.view.snp.edges).priority(.low)
            make.top.equalToSuperview()
        }
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationController?.barStyle(.clear)
//        collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.parallaxHeader.height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Task{
            try await ApiRequest.cookieToKey()
        }
    }
}

