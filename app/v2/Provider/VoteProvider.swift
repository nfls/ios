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
            self.list = votes.list
            completion(true)
        })
    }
    
    public func detail(id: UUID, _ completion: @escaping (Bool) -> Void) {
        self.request(target: VoteRequest.detail(id: id), type: Vote.self, success: { (detail) in
            self.detail = detail
            completion(true)
        })
    }
}
