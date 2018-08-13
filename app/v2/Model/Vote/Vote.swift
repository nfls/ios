//
//  Ticket.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/12.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Vote: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.content = try map.value("content")
        self.isEnabled = try map.value("enabled")
        self.title = try map.value("title")
        self.options = try map.value("options")
    }
    
    let id: UUID
    let content: String
    let isEnabled: Bool
    let title: String
    let options: [Option]
}
