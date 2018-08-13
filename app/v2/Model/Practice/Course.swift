//
//  Course.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/11.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Course: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.name = try map.value("name")
        self.remark = try map.value("remark")
        self.type = CourseType(rawValue: try map.value("type"))!
    }
    
    let id: UUID
    let name: String
    let remark: String
    let type: CourseType
    
    enum CourseType: Int, Codable {
        case igcse = 1
        case alevel = 2
        case ibdp = 3
    }
}
