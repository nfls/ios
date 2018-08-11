//
//  File.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 02/03/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper
class Notice: ImmutableMappable {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.title = try map.value("title")
        self.content = try map.value("content")
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        if let deadline: String = try? map.value("deadline") {
            self.deadline = ISO8601DateFormatter().date(from: deadline)!
        } else {
            self.deadline = nil
        }
        self.files = try map.value("files")
        self.blackboard = try? map.value("blackboard")
    }
    
    let id: UUID
    let title: String
    let content: String
    let time: Date
    let deadline: Date?
    let files: [Attachment]
    let blackboard: Blackboard?
}
