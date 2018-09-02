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
        return MainConstant.apiEndpoint.appendingPathComponent("school/vote")
    }
    
    var path: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
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
            return .requestParameters(parameters: ["id": id.uuidString], encoding: URLEncoding.default)
        case .vote(let id, let options):
            return .requestParameters(parameters: ["id": id.uuidString, "options": options], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
