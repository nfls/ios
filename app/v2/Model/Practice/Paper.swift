//
//  Paper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/11.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Paper: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.paper = try map.value("paper")
        self.session = try map.value("session")
        self.timezone = try map.value("timezone")
        self.course = try map.value("course")
    }
    
    let id: UUID
    let paper: Int
    let session: String
    let timezone: Int
    let course: Course
}
