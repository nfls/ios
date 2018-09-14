//
//  Chat.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/13.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Chat: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.sender = try map.value("sender")
        self.receiver = try map.value("receiver")
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        self.content = try map.value("content")
    }
    
    
    let id: UUID
    let sender: User
    let receiver: User
    let time: Date
    let content: String
}
