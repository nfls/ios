//
//  Rank.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/13.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Rank: Model {
    required init(map: Map) throws {
        self.rank = try map.value("rank")
        self.score = try map.value("score")
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        self.user = try map.value("user")
        self.game = try map.value("game")
    }
    
    let rank: Int
    let score: Int
    let time: Date
    let user: User
    let game: String
}
