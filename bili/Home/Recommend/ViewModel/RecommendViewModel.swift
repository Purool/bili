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
    
    func loadData(page: Int) {
        let task = Task {
            do {
                let list: [Any] = ApiRequest.isLogin() ?
                try await ApiRequest.rcmdVideoListApp(freshIdx: page) : try await ApiRequest.rcmdVideoList(freshIdx: page)
                self.dataSource.accept(list)
            } catch {
                
            }
        }
    }
    
}
