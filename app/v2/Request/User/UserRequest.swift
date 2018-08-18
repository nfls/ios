//
//  UserRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/18.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum UserRequest {
    case register(username: String, password: String, code:String, email: String?, phone: String?)
    case reset(password: String, code:String, email: String?, phone: String?)
    case change(password: String, newPassword: String?, newEmail: String?, unbindPhone: Bool?, newPhone: String?, phoneCode: String?, emailCode: String?, clean: Bool?)
    case code(captcha: String, type: Int, email: String?, phone: String?)
    case avatar(image: UIImage)
    case rename(name: String)
    case privacy(antiSpider: Bool, privacy: Int)
    case page(user: Int)
    case current()
}

extension UserRequest: TargetType {
    var baseURL: URL {
        return Constant.mainApiEndpoint
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .register(_, _, _, _, _), .reset(_, _, _, _), .change(_, _, _, _, _, _, _, _), .code(_, _, _, _), .avatar(_), .rename(_), .privacy(_, _):
            return .post
        case .page(_), .current():
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        <#code#>
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
