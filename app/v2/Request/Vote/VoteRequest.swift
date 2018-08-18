//
//  VoteRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/17.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum VoteRequest {
    case list()
    case detail(id: UUID)
    case vote(id: UUID, options: [Int])
}

extension VoteRequest: TargetType {
    var baseURL: URL {
        return Constant.mainApiEndpoint.appendingPathComponent("school/vote")
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .list(), .detail(_):
            return .get
        case .vote(_, _):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .list():
            return .requestPlain
        case .detail(let id):
            return .requestParameters(parameters: ["id": id.uuidString], encoding: JSONEncoding.default)
        case .vote(let id, let options):
            return .requestParameters(parameters: ["id": id.uuidString, "options": options], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
