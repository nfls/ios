//
//  ChatRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/18.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum ChatRequest {
    case list()
    case send(id: Int, content: String)
}

extension ChatRequest: TargetType {
    var baseURL: URL {
        return Constant.mainApiEndpoint.appendingPathComponent("chat")
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .list():
            return .get
        case .send(_, _):
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
        case .send(let id, let content):
            return .requestParameters(parameters: ["id": id, "content": content], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
