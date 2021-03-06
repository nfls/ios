//
//  GameRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/18.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum GameRequest {
    case list()
    case listRank()
}

extension GameRequest: TargetType {
    var baseURL: URL {
        return MainConstant.apiEndpoint.appendingPathComponent("game")
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
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
