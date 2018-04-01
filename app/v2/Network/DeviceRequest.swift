//
//  Device.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum DeviceRequest {
    case announcement()
    case notifiaction(token:String)
}

extension DeviceRequest: TargetType {
    var baseURL: URL {
        return URL(string: Constant.getApiUrl() + "device/")!
    }
    
    var path: String {
        switch self {
        case .announcement():
            return "announcement/ios"
        case .notifiaction(_):
            return "notification"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .announcement():
            return .get
        case .notifiaction(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .announcement():
            return .requestPlain
        case .notifiaction(let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
