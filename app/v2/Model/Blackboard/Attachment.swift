//
//  File.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/11.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Attachment: Model {
    required init(map: Map) throws {
        self.name = try map.value("name")
        self.id = try map.value("id")
    }
    
    let name: String
    let id: String
}
