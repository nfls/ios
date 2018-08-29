//
//  DefaultsKey.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let announcement = DefaultsKey<String>("annoucement")
    static let downloadCenterHeader = DefaultsKey<String>("downloadCenterHeader")
    static let waterAuthToken = DefaultsKey<String>("waterAuthToken")
}
