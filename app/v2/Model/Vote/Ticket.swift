//
//  Ticket.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/4.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Ticket: Model {
    required init(map: Map) throws {
        self.code = try map.value("code")
    }
    let code: String
}
