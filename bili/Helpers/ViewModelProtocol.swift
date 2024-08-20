//
//  ViewModelProtocol.swift
//  bili
//
//  Created by DJ on 2024/8/20.
//

import Foundation
import RxSwift
import RxCocoa

enum ScrollViewActionType {
    case refresh
    case loadMore
}
/// vm接受页面输入行为
protocol VMInAndOutputs {
    /// - Parameter actionType: 操作行为
    func loadData(page: Int)
    
    associatedtype T
            
    /// 数据源数组
    var dataSource: BehaviorRelay<[T]> { get }
}
