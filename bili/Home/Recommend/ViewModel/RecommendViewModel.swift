//
//  RecommendViewModel.swift
//  bili
//
//  Created by DJ on 2024/8/20.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    
    var inputs: Self { self }

    var outputs: Self { self }
    
}

class RecommendViewModel: BaseViewModel, VMInAndOutputs {
    
    let dataSource = BehaviorRelay<[Any]>(value: [])
    
    var pageNum: Int = 0
    
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            pageNum = 0
        case .loadMore:
            pageNum += 1
        }
        
        Task {
            do {
                let list: [Any] = ApiRequest.isLogin() ?
                try await ApiRequest.rcmdVideoListApp(freshIdx: pageNum) : try await ApiRequest.rcmdVideoList(freshIdx: pageNum)
                if actionType == .loadMore {
                    self.dataSource.accept(self.dataSource.value + list)
                    refreshSubject.onNext(.stopLoadmore)
                } else {
                    self.dataSource.accept(list)
                    refreshSubject.onNext(.stopRefresh)
                }
            } catch {
                if actionType == .loadMore {
                    pageNum -= 1
                    refreshSubject.onNext(.stopLoadmore)
                } else {
                    refreshSubject.onNext(.stopRefresh)
                }
            }
        }
    }
    
}
