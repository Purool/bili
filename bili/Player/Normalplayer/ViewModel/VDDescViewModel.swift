//
//  VDDescViewModel.swift
//  bili
//
//  Created by DJ on 2024/9/12.
//

import Foundation
import RxSwift
import RxCocoa

class VDDescViewModel: BaseViewModel {
    
    let rxPages = PublishSubject<[VideoPage]>()
    let rxData = PublishSubject<VideoDetail>()
    let likeStatus = PublishSubject<Bool>()
    let coinCount = PublishSubject<Int>()
    let coinStatus = PublishSubject<Bool>()
    let rxReplys = PublishSubject<[Replys.Reply]>()
    
    func getData(info: PlayInfo) async {
//        pageView.isHidden = true
//        ugcView.isHidden = true
        
        var pages = [VideoPage]()
        
        var seasonId = info.seasonId
        var aid = info.aid
        var cid = info.cid
        var epid = info.epid
        var isBangumi = info.isBangumi
        
        do {
            if seasonId > 0 {
                isBangumi = true
                let info: BangumiSeasonInfo = try await ApiRequest.requestGetObj(QApi.bangumiInfoSeason, parameters: ["season_id": seasonId], dataObj: "result")
                if let epi = info.main_section.episodes.first ?? info.section.first?.episodes.first {
                    aid = epi.aid
                    cid = epi.cid
                    epid = epi.id
                }
                pages = info.main_section.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, epid: $0.id, from: "", part: $0.title + " " + $0.long_title) })
            } else if epid > 0 {
                isBangumi = true
                let info: BangumiInfo = try await ApiRequest.requestGetObj(QApi.bangumiInfo, parameters: ["ep_id": epid], dataObj: "result")
                if let epi = info.episodes.first(where: { $0.id == epid }) ?? info.episodes.first {
                    aid = epi.aid
                    cid = epi.cid
                } else {
                    throw NSError(domain: "get epi fail", code: -1)
                }
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, epid: $0.id, from: "", part: $0.title + " " + $0.long_title) })
            }
            let data: VideoDetail = try await ApiRequest.requestGetObj(QApi.videoIntroDetail, parameters: ["aid": aid])
            self.rxData.onNext(data)
            
            if let redirect = data.View.redirect_url?.lastPathComponent, redirect.starts(with: "ep"), let id = Int(redirect.dropFirst(2)), !isBangumi {
                isBangumi = true
                epid = id
                let info: BangumiInfo = try await ApiRequest.requestGetObj(QApi.bangumiInfo, parameters: ["ep_id": epid], dataObj: "result")
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, epid: $0.id, from: "", part: $0.title + " " + $0.long_title) })
            }
            self.rxPages.onNext(pages)
        } catch let err {
            self.rxPages.onError(err)
            self.rxData.onError(err)
            if case let .statusFail(code, _) = err as? RequestError, code == -404 {
                // 解锁港澳台番剧处理
//                if let ok = await fetchAreaLimitBangumiData(), !ok {
//                    self.exit(with: err)
//                }
            } else {
//                self.exit(with: err)
            }
        }
        if let replys: Replys = try? await ApiRequest.requestGetObj(QApi.replyList, parameters: ["type": 1, "oid": aid, "sort": 1, "nohot": 0]){
            self.rxReplys.onNext(replys.replies ?? [])
        }
        if let likeStatusJson = try? await ApiRequest.requestGetJson(QApi.hasLikeVideo, parameters: ["aid": aid]){
            self.likeStatus.onNext(likeStatusJson.intValue == 1)
        }
        if let coinCountJson = try? await ApiRequest.requestGetJson(QApi.hasCoinVideo, parameters: ["aid": aid]){
            self.coinCount.onNext(coinCountJson["multiply"].intValue)
        }
        if let coinStatusJson = try? await ApiRequest.requestGetJson(QApi.hasFavVideo, parameters: ["aid": aid]){
            self.coinStatus.onNext(coinStatusJson["favoured"].boolValue)
        }
    }
    
    
}
