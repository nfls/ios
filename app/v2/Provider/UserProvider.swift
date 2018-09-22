//
//  UserProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/8.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class UserProvider: AbstractProvider<UserRequest> {
    var current: User? = nil
    public func getUser(_ completion: @escaping () -> Void) {
        self.request(target: UserRequest.current(), type: User.self, success: { (data) in
            self.current = data.data
            Defaults[.id] = data.data.id
            completion()
        })
    }
}
