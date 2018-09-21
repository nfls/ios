//
//  Card.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/8.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Card: Model {
    required init(map: Map) throws {
        self.code = try map.value("code")
        self.image = try map.value("image")
    }
    let code: String
    let image: String
}
