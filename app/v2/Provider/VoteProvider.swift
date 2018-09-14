//
//  VoteProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/2.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class VoteProvider: AbstractProvider<VoteRequest> {
    public var list: [Vote] = []
    public var detail: Vote? = nil
    
    public func list(_ completion: @escaping (Bool) -> Void) {
        self.request(target: VoteRequest.list(), type: ListWrapper<Vote>.self, success: { (votes) in
            self.list = votes.data.list
            completion(true)
        })
    }
    
    public func detail(id: UUID, _ completion: @escaping (Bool) -> Void) {
        self.request(target: VoteRequest.detail(id: id), type: Vote.self, success: { (detail) in
            self.detail = detail.data
            completion(true)
        })
    }
    
    public func submit(options: [Int], password: String, _ completion: @escaping (String) -> Void) {
        self.request(target: VoteRequest.vote(id: self.detail!.id, options: options, password: password), type: Ticket.self, success: { (ticket) in
            completion(ticket.data.code)
        })
    }
    
    public func check(_ completion: @escaping (String?) -> Void) {
        self.request(target: VoteRequest.vote(id: self.detail!.id, options: [], password: ""), type: DataWrapper<String>.self, success: { (ticket) in
            if ticket.code == 401 && !self.detail!.isEnabled! {
                completion("投票未开始，或已经结束")
            } else if ticket.code == 401 && self.detail!.isEnabled! {
                completion("您所在的用户组无法投票")
            } else if ticket.code == 403 {
                completion("您已经投过票了")
            } else {
                completion(nil)
            }
        })
    }
}
