//
//  ProgressRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum RecordRequest {
    case wrong(course: UUID?, timezone: Int?, paper: Int?, start: Date?, end: Date?, hide: Bool, count: Bool, page: Int, size: Int)
    case submit(problem: UUID, textSolution: String)
    case status(problem: UUID)
    case progress(paper: UUID)
    case history(problem: UUID)
}

extension RecordRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint.appendingPathComponent("record")
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .submit(_, _),.wrong(_, _, _, _, _, _, _, _, _):
            return .post
        case .status(_), .progress(_), .history(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .submit(let id, let textSolution):
            return .requestParameters(parameters: ["id": id.uuidString, "textSolution": textSolution], encoding: JSONEncoding.default)
        case .wrong(let course, let timezone, let paper, let start, let end, let hide, let count, let page, let size):
            return .requestParameters(parameters: [
                "course": course?.uuidString as Any,
                "timezone": timezone ?? -1,
                "paper": paper ?? -1,
                "start": start as Any,
                "end": end as Any,
                "hide": hide,
                "action": count ? "count" : "list",
                "page": page,
                "size": size
                ], encoding: JSONEncoding.default)
        case .status(let id), .progress(let id), .history(let id):
            return .requestParameters(parameters: ["id": id.uuidString], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
