//
//  NFLSOauth2.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
import Moya

class NFLSOAuth2:OAuth2PasswordGrantDelegate {
    func loginController(oauth2: OAuth2PasswordGrant) -> AnyObject {
        return UIViewController()
    }
    
    var oauth2:OAuth2PasswordGrant
    init() {
        oauth2 = OAuth2PasswordGrant(settings: [
            "client_id": "9J/xuPUoNBOmA1erNKlBqQ==",
            "client_secret": "REGbItx41b4IYcK3PiPTXsWTh9KIA0vcHl/W4ediSEg=",
            "authorize_uri": "https://nfls.io/oauth/authorize",
            "token_uri": "https://nfls.io/oauth/accessToken",
            "scope": "",
            "secret_in_body": true,
            "keychain": true,
            "verbose": true
            ] as OAuth2JSON)
    }
    func login(username:String,password:String, completion: @escaping (_ success: Bool) -> Void) {
        oauth2.password = password
        oauth2.username = username
        oauth2.authorize { (_, error) in
            if error != nil {
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    func getRequestClosure<T:TargetType>(type:T.Type) -> MoyaProvider<T> {
        let requestClosure:MoyaProvider<T>.RequestClosure = { (endpoint, done) in
            var request = try! endpoint.urlRequest() // This is the request Moya generates
            self.oauth2.authorize { (_, error) in
                if error != nil {
                    self.oauth2.forgetTokens()
                    //self.showLogin()
                }
            }
            do {
                try request.sign(with: self.oauth2)
                done(.success(request))
            } catch {
                done(.success(request))
            }
        }
        let provider = MoyaProvider<T>(requestClosure: requestClosure)
        return provider
    }
    
}
