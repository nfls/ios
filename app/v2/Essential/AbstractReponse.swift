//
//  AbstractReponse.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import ObjectMapper
import Foundation


class AbstractResponse<T: BaseMappable>: ImmutableMappable {
    required init(map: Map) throws {
        self.code = try map.value("code")
        if(String(describing: T.self).contains("Wrapper")) {
            if let data = try T(JSON: map.JSON) {
                self.data = data
            } else {
                throw MapError(key: "data", currentValue: map.JSON, reason: "Failed")
            }
        } else {
            self.data = try map.value("data")
        }
    }
    let code:Int
    let data:T
}

class AbstractList<T: BaseMappable>: ImmutableMappable {
    required init(map: Map) throws {
        self.code = try map.value("code")
        self.data = try map.value("data")
    }
    let code:Int
    let data:[T]
}

class ListWrapper<T: ImmutableMappable>: ImmutableMappable {
    required init(map: Map) throws {
        self.list = try map.value("data")
    }
    let list:[T]
}

class DataWrapper<T>: ImmutableMappable {
    required init(map: Map) throws {
        self.value = try map.value("data")
    }
    let value:T
}
