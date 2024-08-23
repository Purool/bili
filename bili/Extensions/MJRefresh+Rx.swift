//
//  MJRefresh+Rx.swift
//  bili
//
//  Created by DJ on 2024/8/23.
//

import Foundation
import MJRefresh
import RxSwift
import RxCocoa

enum MJRefreshAction {
    case stopRefresh
    
    case stopLoadmore
    
    case showNomoreData
   
    case resetNomoreData
}

extension Reactive where Base: MJRefreshComponent {
    //不用这个了->默认刷新header给page:0,footer不使用,上下拉时触发block发出事件
    var refreshing: ControlEvent<Int> {
        let source = Observable.create { [weak component = self.base] observer in
            if let component {
                component.refreshingBlock = {
                    observer.on(.next((0)))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    //被事件唤起
    var refreshAction: Binder<MJRefreshAction> {
        return Binder(self.base) { headerOrfooter, action in
            switch action {
            case .resetNomoreData:
                if let footer = headerOrfooter as? MJRefreshFooter {
                    footer.resetNoMoreData()
                }
            case .stopRefresh:
                if let header = headerOrfooter as? MJRefreshHeader {
                    header.endRefreshing()
                }
            case .stopLoadmore:
                if let footer = headerOrfooter as? MJRefreshFooter {
                    footer.endRefreshing()
                }
            case .showNomoreData:
                if let footer = headerOrfooter as? MJRefreshFooter {
                    footer.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
}
