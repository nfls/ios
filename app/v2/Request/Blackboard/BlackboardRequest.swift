//
//  BlackboardRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum BlackboardRequest {
    case list()
    case detail(id: UUID)
    case join(code: String)
}

extension BlackboardRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint
    }
    
    var path: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .list(), .detail(_):
            return .get
        case .join(_):
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
        case .join(let code):
            return .requestParameters(parameters: ["code": code], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
