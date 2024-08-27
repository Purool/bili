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
import MJRefresh

let kpadding:CGFloat = 15
let klinePadding:CGFloat = 0

class HomeRecommendViewController: QBaseViewController {
    
    let allClass: [UICollectionViewCell.Type] = [UICollectionViewCell.self,
                                                 RecommendActivityCell.self,]
    
    private lazy var collectionView: UICollectionView = {
        let lt = UICollectionViewFlowLayout()
        lt.minimumInteritemSpacing = 8
        lt.minimumLineSpacing = 8
        lt.itemSize = CGSize(width: kScreenWidth*0.46, height: kScreenWidth*0.29+32+30)//item高度由其cell自己决定
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: lt)
        collectionView.backgroundColor = .hexColor(str: "f1f2f3")
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .top
        _ = allClass.map{collectionView.register($0, forCellWithReuseIdentifier: $0.description())}
        let viewModel = RecommendViewModel()
        viewModel.inputs.loadData(actionType: .refresh)
        viewModel.outputs.dataSource.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items){
            collectionView,row,element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendActivityCell.self.description(), for: IndexPath(row: row, section: 0)) as! RecommendActivityCell
            cell.videoModel = element
            return cell
        }.disposed(by: rx.disposeBag)
        
        collectionView.uempty = UEmptyView { viewModel.inputs.loadData(actionType: .refresh) }
        collectionView.uempty?.allowShow = true
        collectionView.reloadData()
        
        QFreshHeader {
            viewModel.inputs.loadData(actionType: .refresh)
        }.link(to: collectionView)
        MJRefreshAutoFooter {
            viewModel.inputs.loadData(actionType: .loadMore)
        }.link(to: collectionView)
        //以下方法感觉不如上面的方便
//        collectionView.mj_header?.rx.refreshing.asDriver().startWith((0)).drive(onNext: viewModel.inputs.loadData).disposed(by: rx.disposeBag)
//        collectionView.mj_footer?.rx.refreshing.asDriver().map{$0+1}.drive(onNext: viewModel.inputs.loadData).disposed(by: rx.disposeBag)
        
        if let header = collectionView.mj_header, let footer = collectionView.mj_footer {
            viewModel.outputs.refreshSubject.bind(to: header.rx.refreshAction).disposed(by: rx.disposeBag)
            viewModel.outputs.refreshSubject.bind(to: footer.rx.refreshAction).disposed(by: rx.disposeBag)
        }
        collectionView.rx.modelSelected((Any).self).subscribe(onNext: {
            [weak self] videoModel in
            guard let self else { return }
            if let model = videoModel as? RecVideoItemModel {
                print("没处理RecVideoItemModel的点击")
            } else if let model = videoModel as? RecVideoItemAppModel{
                let heroTag = QUtils.makeHeroTag(model.param)
                (self.parent as! HomeViewController).onPushDetail(heroTag: heroTag, videoItem: model)
            }
        }).disposed(by: rx.disposeBag)
        
     
        collectionView.rx.contentOffset.buffer(timeSpan: .milliseconds(100), count: 2, scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self] (points) in
            guard let self = self, let pointA = points.first, let pointB = points.last else {return}
//            print("\(pointB)=====\(pointA)")
            let result = pointB.y - pointA.y
            if (pointA.y < 0) || (pointB.y < 0){
                (self.parent as! HomeViewController).setNavViewHideStatus(by: false)
            }else if result != 0, result < 20 {
                (self.parent as! HomeViewController).setNavViewHideStatus(by: result > 0)
            }
        }).disposed(by: rx.disposeBag)
    }
     
    override func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {(make) in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)).priority(.low)
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

