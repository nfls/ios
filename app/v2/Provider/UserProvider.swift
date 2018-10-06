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
    var privay: User.Privacy? = nil
    public func getUser(_ completion: @escaping () -> Void) {
        self.request(target: UserRequest.current(), type: User.self, success: { (data) in
            self.current = data.data
            Defaults[.id] = data.data.id
            completion()
        })
    }
    
    public func getPrivacy(_ completion: @escaping () -> Void) {
        //self.request(target: UserRequest.privacy(antiSpider: <#T##Bool#>, privacy: <#T##Int#>), type: <#T##BaseMappable.Protocol#>, success: <#T##(AbstractResponse<BaseMappable>) -> Void#>)
    }
    
    public func postSendRequest(toEmail email: String, completion: @escaping (String?) -> Void) {
        self.request(target: UserRequest.code(type: 3, email: email, phone: nil), type: DataWrapper<String?>.self, success: { response in
            completion(response.data.value)
        })
    }
    
    public func postSendRequest(toPhone phone: String, completion: @escaping (String?) -> Void) {
        self.request(target: UserRequest.code(type: 3, email: nil, phone: phone), type: DataWrapper<String?>.self, success: { response in
            completion(response.data.value)
        })
    }
    
    public func changeSecurity(password: String, newPassword: String?, newEmail: String?, newPhone: String?, phoneCode: String?, emailCode: String?, clean: Bool? ,completion: @escaping (String) -> Void) {
        self.request(target: UserRequest.change(password: password, newPassword: newPassword, newEmail: newEmail, unbindPhone: nil, newPhone: newPhone, phoneCode: phoneCode, emailCode: emailCode, clean: clean), type: DataWrapper<String?>.self, success: { (response) in
            completion(response.data.value ?? "修改成功")
        })
    }
    
    public func changeAvatar(_ image: UIImage, completion: @escaping ()->Void) {
        self.request(target: UserRequest.avatar(image: image), type: DataWrapper<String?>.self, success: {_ in
            completion()
        })
    }
    
    public func changeUsername(_ username: String, completion: @escaping (String?) -> Void) {
        self.request(target: UserRequest.rename(username: username), type: DataWrapper<String?>.self, success: { response in
            completion(response.data.value)
        })
    }
}
