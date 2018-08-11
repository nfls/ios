//
//  Device.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import DeviceKit

enum DeviceRequest {
    case announcement()
    case notifiaction(token:String)
    case version()
    case register(token: String)
}

extension DeviceRequest: TargetType {
    var baseURL: URL {
        return Constant.apiEndpoint.appendingPathComponent("device")
    }
    
    var path: String {
        switch self {
        case .announcement():
            return "announcement/ios"
        case .notifiaction(_):
            return "notification"
        case .version():
            return "version"
        case .register(_):
            return "pushRegister"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .announcement():
            return .get
        case .notifiaction(_):
            return .post
        case .version():
            return .get
        case .register(_):
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
        case .version():
            return .requestParameters(parameters: ["client_id": Constant.client_id], encoding: URLEncoding.default)
        case .register(let token):
            return .requestParameters(parameters: [
                "token": token,
                "type": "ios",
                "model": Device().description,
                "remark": Device().name
                ], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
