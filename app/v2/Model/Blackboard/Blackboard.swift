//
//  Blackboard.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/11.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Blackboard: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.title = try map.value("title")
        self.announcement = try? map.value("announcement")
        self.students = try? map.value("students")
        self.teachers = try? map.value("teachers")
        self.code = try? map.value("code")
    }
    
    let id: UUID
    let title: String
    let announcement: String?
    let students: [User]?
    let teachers: [User]?
    let code: String?
}
