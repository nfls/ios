//
//  Gallery.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum GalleryRequest {
    case list()
    case detail(id: Int)
    case comment(id: Int, content: String)
    case likeStatus()
    case like()
}

extension GalleryRequest: TargetType {
    var baseURL: URL {
        return MainConstant.apiEndpoint.appendingPathComponent("media/gallery")
    }
    
    var path: String {
        switch self {
        case .likeStatus():
            return "status"
        default:
            return String(describing: self)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list(), .detail(_), .likeStatus():
            return .get
        case .comment(_, _), .like():
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .like(), .list(), .likeStatus():
            return .requestPlain
        case .comment(let id, let content):
            return .requestParameters(parameters: ["id": id, "content": content], encoding: JSONEncoding.default)
        case .detail(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
