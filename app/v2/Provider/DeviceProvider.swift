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
            if self.announcement != result.data.value {
                self.announcement = result.data.value
                completion()
            } else {
                self.announcement = result.data.value
            }
            
        })
    }
    
    public func checkUpdate(completion: @escaping (Bool) -> Void) {
        self.request(target: DeviceRequest.version(), type: DataWrapper<String>.self, success: { (version) in
            
            let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            if version.data.value.compare(current, options: .numeric) == .orderedDescending {
                completion(true)
            } else {
                completion(false)
            }
            
        })
    }
    
    public func regitserDevice(token: String) {
        self.request(target: .register(token: token), type: PushDevice.self, success: { (_) in
        })
    }
}
