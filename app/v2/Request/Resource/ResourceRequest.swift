//
//  PastPaper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum ResourceRequest {
    case token()
    case announcement()
    case shortcut()
}

extension ResourceRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint.appendingPathComponent("resource")
    }
    
    var path: String {
        return String(describing: self)
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
