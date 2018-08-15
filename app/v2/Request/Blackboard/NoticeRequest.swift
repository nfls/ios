//
//  NoticeRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum NoticeRequest {
    case list(blackboard: UUID, page: Int)
    case download(blackboard: UUID, notice: UUID, file: UUID)
    case deadline()
    case unread()
}

extension NoticeRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint
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
        switch self {
        case .deadline(), .unread():
            return .requestPlain
        case .list(let id, let page):
            return .requestParameters(parameters: ["id": id.uuidString, "page": page], encoding: URLEncoding.default)
        case .download(let blackboard, let notice, let file):
            return .requestParameters(parameters: ["id": blackboard.uuidString, "noticeId": notice.uuidString, "fileId": file.uuidString], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
