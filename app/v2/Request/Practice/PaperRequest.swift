//
//  PaperRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/14.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum PaperRequest {
    case list(id: UUID)
    case detail(id: UUID)
    case recent()
}

extension PaperRequest: TargetType {
    
    var baseURL: URL {
        return WaterConstant.apiEndpoint.appendingPathComponent("paper")
    }
    
    var path: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .detail(let id), .list(let id) :
            return .requestParameters(parameters: ["id": id.uuidString], encoding: URLEncoding.default)
        case .recent():
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
