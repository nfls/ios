//
//  CourseRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum CourseRequest {
    case list(type: Course.CourseType)
    case all()
}

extension CourseRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint.appendingPathComponent("course")
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
        case .all():
            return .requestPlain
        case .list(let type):
            return .requestParameters(parameters: ["id": type.rawValue], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
