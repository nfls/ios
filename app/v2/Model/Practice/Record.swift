//
//  Record.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/12.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Record: ImmutableMappable {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.problem = try map.value("problem")
        self.type = StatusType(rawValue: try map.value("type"))!
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
    }
    
    let id: UUID
    let problem: Problem
    let type: StatusType
    let time: Date
    
    enum StatusType: Int {
        case blank = 0
        case correct = 1
        case wrong = 2
        case selfMarkedCorrect = 3
        case selfMarkedWrong = 4
        case pending = 5
    }
}
