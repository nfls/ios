//
//  PastPaper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Cache
import AliyunOSSiOS
import FileKit

enum SchoolRequest {
    case pastpaperToken()
    case pastpaperHeader()
    case blackboardList()
    case blackboardDetail(id:String, page:Int?)
}

extension SchoolRequest: TargetType {
    var baseURL: URL {
        return Constant.mainApiEndpoint.appendingPathComponent("school")
    }
    
    var path: String {
        switch self {
        case .pastpaperToken():
            return "pastpaper/token"
        case .pastpaperHeader():
            return "pastpaper/header"
        case .blackboardList():
            return "blackboard/list"
        case .blackboardDetail(_, _):
            return "blackboard/detail"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .pastpaperToken():
            return .requestPlain
        case .pastpaperHeader():
            return .requestPlain
        case .blackboardList():
            return .requestPlain
        case .blackboardDetail(let id, let page):
            if let page = page {
                return .requestParameters(parameters: ["id":id,"page":page], encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: ["id":id], encoding: URLEncoding.default)
            }
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
