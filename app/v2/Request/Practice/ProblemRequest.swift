//
//  ProblemRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/14.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum ProblemRequest {
    case list(id: UUID)
    case detail(id: UUID)
    case search(text: String, precise: Bool, course: UUID?, isMultipleChoice: Bool?, size: Int, page: Int)
    case temp(problems: [UUID])
}

extension ProblemRequest: TargetType {
    var baseURL: URL {
        return WaterConstant.apiEndpoint.appendingPathComponent("problem")
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .list(_), .detail(_):
            return .get
        case .search(_, _, _, _, _, _), .temp(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .list(let id), .detail(let id):
            return .requestParameters(parameters: ["id": id.uuidString], encoding: URLEncoding.default)
        case .search(let text, let precise, let course, let isMultipleChoice, let size, let page) :
            return .requestParameters(parameters: [
                "text": text,
                "precise": precise,
                "course": course?.uuidString as Any,
                "isMultipleChoice": isMultipleChoice as Any,
                "size": size,
                "page": page
                ], encoding: JSONEncoding.default)
        case .temp(let problems):
            return .requestParameters(parameters: [
                "problems": problems.map { $0.uuidString }
                ], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return WaterConstant.header
    }
    
    
}
