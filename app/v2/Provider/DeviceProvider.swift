//
//  DeviceProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class DeviceProvider: AbstractProvider<DeviceRequest> {
    public private(set) var announcement:String {
        get {
            return Defaults[.announcement]
        }
        set {
            Defaults[.announcement] = newValue
        }
    }

    public func getAnnouncement(completion: @escaping () -> Void) {
        self.request(target: DeviceRequest.announcement(), type: DataWrapper<String>.self, success: { result in
            if self.announcement != result.value {
                self.announcement = result.value
                completion()
            } else {
                self.announcement = result.value
            }
            
        })
    }
}
