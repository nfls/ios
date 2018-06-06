//
//  AbstractMessage.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

typealias AbstractError = AbstractMessage

struct AbstractMessage: ImmutableMappable,Error {
    let status: Int
    let message: String
    var localizedDescription: String {
        get {
            return self.message
        }
    }
    init(status: Int, message: String) {
        self.status = status
        self.message = message
    }
    init(map: Map) throws {
        self.status = try map.value("code")
        self.message = try map.value("data")
    }
}

